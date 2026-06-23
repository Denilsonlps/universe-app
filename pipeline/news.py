import os, sys, time, json, re, hashlib, unicodedata
try:
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
except Exception:
    pass
import feedparser
from google.genai import types
from main import init_firestore, init_gemini  # reaproveita inicialização

# Fontes RSS (rótulo + url). Ajuste/expanda conforme necessário.
FEEDS = [
    {"source": "G1 Educação", "url": "https://g1.globo.com/rss/g1/educacao/"},
    {"source": "MEC", "url": "https://www.gov.br/mec/pt-br/assuntos/noticias/RSS"},
    {"source": "PCI Concursos", "url": "https://www.pciconcursos.com.br/noticias/rss"},
    {"source": "IFSP", "url": "https://www.ifsp.edu.br/component/content/?format=feed&type=rss"},
]

KEYWORDS = ["ifsp", "sisu", "enem", "prouni", "fies", "concurso", "edital",
            "estagio", "bolsa", "vestibular", "matricula", "faculdade", "universidade"]

CATEGORIAS = ["Campus", "SiSU", "Enem", "Concurso", "Geral"]


def _sem_acento(s: str) -> str:
    return "".join(c for c in unicodedata.normalize("NFD", s or "") if unicodedata.category(c) != "Mn").lower()


def casa_keyword(texto: str) -> bool:
    t = _sem_acento(texto)
    return any(k in t for k in KEYWORDS)


def news_doc_id(link: str) -> str:
    return hashlib.sha1((link or "").encode("utf-8")).hexdigest()


def _entry_data(entry):
    titulo = (entry.get("title") or "").strip()
    link = (entry.get("link") or "").strip()
    resumo_feed = re.sub(r"<[^>]+>", " ", entry.get("summary", "")).strip()
    # data
    dt_ms = int(time.time() * 1000)
    if entry.get("published_parsed"):
        dt_ms = int(time.mktime(entry["published_parsed"]) * 1000)
    # imagem (media:content ou enclosure)
    img = None
    if entry.get("media_content"):
        img = entry["media_content"][0].get("url")
    elif entry.get("links"):
        for l in entry["links"]:
            if (l.get("type") or "").startswith("image"):
                img = l.get("href")
                break
    return titulo, link, resumo_feed, dt_ms, img


PROMPT = """Você cura notícias para um app de estudantes do IFSP.
Categorias possíveis: {cats}.

Notícia:
Título: {titulo}
Resumo: {resumo}

Responda em JSON:
- relevante (bool): é útil para estudantes (vestibular, Enem, SiSU, concurso, bolsa, IFSP, educação)?
- category (string): uma das categorias acima.
- summary (string): resumo curto e neutro, 2-3 frases, sem copiar o texto literal.
Responda só o JSON."""


def avaliar(client, titulo, resumo):
    p = PROMPT.format(cats=", ".join(CATEGORIAS), titulo=titulo, resumo=resumo[:2000])
    for tentativa in range(4):
        try:
            r = client.models.generate_content(
                model="gemini-2.5-flash", contents=p,
                config=types.GenerateContentConfig(response_mime_type="application/json"))
            d = json.loads(r.text)
            cat = d.get("category", "Geral")
            return {
                "relevante": bool(d.get("relevante", False)),
                "category": cat if cat in CATEGORIAS else "Geral",
                "summary": str(d.get("summary", "")).strip(),
            }
        except Exception as e:
            erro = str(e)
            m = re.search(r"retry in (\d+)", erro)
            if m:
                time.sleep(int(m.group(1)) + 5)
            elif "503" in erro or "UNAVAILABLE" in erro or "overloaded" in erro.lower():
                time.sleep(10 * (tentativa + 1))
            else:
                print(f"❌ Erro no Gemini: {e}")
                break
    return {"relevante": False, "category": "Geral", "summary": ""}


def ja_tratada(db, vid):
    if db.collection("news").document(vid).get().exists:
        return True
    s = db.collection("noticias_sugeridas").document(vid).get()
    return s.exists and s.to_dict().get("status") == "recusada"


def main():
    db = init_firestore()
    client = init_gemini()
    max_noticias = int(os.getenv("MAX_NOTICIAS", "15"))
    novas = 0
    for feed in FEEDS:
        if novas >= max_noticias:
            break
        try:
            parsed = feedparser.parse(feed["url"])
        except Exception as e:
            print(f"⚠️  Falha no feed {feed['source']}: {e}")
            continue
        for entry in parsed.entries:
            if novas >= max_noticias:
                break
            titulo, link, resumo_feed, dt_ms, img = _entry_data(entry)
            if not titulo or not link:
                continue
            if not casa_keyword(titulo + " " + resumo_feed):
                continue
            vid = news_doc_id(link)
            if ja_tratada(db, vid):
                continue
            aval = avaliar(client, titulo, resumo_feed)
            if not aval["relevante"]:
                continue
            resumo = aval["summary"] or resumo_feed[:300]
            doc = {
                "category": aval["category"], "source": feed["source"], "readTime": "1 min",
                "title": titulo, "summary": resumo, "body": resumo,
                "date": dt_ms, "facts": [], "sourceUrl": link, "imageUrl": img,
                "published": False, "pinned": False,
                "scrapedAt": int(time.time() * 1000), "status": "pendente",
            }
            db.collection("noticias_sugeridas").document(vid).set(doc)
            novas += 1
            print(f"📰 {feed['source']}: {titulo}")
            time.sleep(1)
    print(f"✅ {novas} notícias sugeridas gravadas em 'noticias_sugeridas'.")


if __name__ == "__main__":
    main()
