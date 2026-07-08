"""Pipeline de NOTÍCIAS — camada de processamento externo (Python + IA).

Fluxo (executado de forma agendada no GitHub Actions):
  1. Lê feeds RSS de fontes oficiais/confiáveis (G1 Educação + buscas no Google News).
  2. Pré-filtra por palavras-chave e por janela de recência (últimos N dias).
  3. Envia título/resumo ao Google Gemini, que decide a RELEVÂNCIA para o
     estudante, CLASSIFICA a categoria (Campus, SiSU, Enem, Concurso, Geral) e
     gera um RESUMO curto e neutro.
  4. Grava as relevantes em `noticias_sugeridas` (status "pendente"), para a
     curadoria humana revisar/publicar no app.

Deduplicação por título normalizado: a mesma matéria vinda de feeds/links
diferentes colapsa em um único documento, evitando sugestões repetidas.
"""
import os, sys, time, json, re, hashlib, unicodedata, urllib.parse
try:
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
except Exception:
    pass
import feedparser
from google.genai import types
from main import init_firestore, init_gemini  # reaproveita inicialização


def _gnews(query: str) -> str:
    """Feed RSS do Google News para uma consulta (pt-BR)."""
    return "https://news.google.com/rss/search?" + urllib.parse.urlencode(
        {"q": query, "hl": "pt-BR", "gl": "BR", "ceid": "BR:pt-419"})


# Fontes RSS (rótulo + url). G1 Educação (geral) + buscas direcionadas no Google News
# (robustas e temáticas — gov.br/IFSP/PCI não expõem RSS estável).
FEEDS = [
    {"source": "G1 Educação", "url": "https://g1.globo.com/rss/g1/educacao/"},
    {"source": "IFSP", "url": _gnews('IFSP "Instituto Federal" São Paulo')},
    {"source": "Concursos", "url": _gnews('concurso público edital São Paulo')},
    {"source": "Educação", "url": _gnews('Sisu OR Enem OR Prouni OR Fies inscrições')},
]

KEYWORDS = ["ifsp", "sisu", "enem", "prouni", "fies", "concurso", "edital",
            "estagio", "bolsa", "vestibular", "matricula", "faculdade", "universidade"]

CATEGORIAS = ["Campus", "SiSU", "Enem", "Concurso", "Geral"]


def _sem_acento(s: str) -> str:
    return "".join(c for c in unicodedata.normalize("NFD", s or "") if unicodedata.category(c) != "Mn").lower()


def casa_keyword(texto: str) -> bool:
    t = _sem_acento(texto)
    return any(k in t for k in KEYWORDS)


def _norm_titulo(titulo: str) -> str:
    """Título sem acento/pontuação/espaços extras — base estável p/ dedup."""
    t = _sem_acento(re.sub(r"[^\w\s]", " ", titulo or ""))
    return re.sub(r"\s+", " ", t).strip()


def news_doc_id(titulo: str) -> str:
    # Id pelo título normalizado: a mesma matéria (links diferentes no Google News
    # e no G1) colapsa no mesmo documento, evitando sugestões repetidas.
    return hashlib.sha1(_norm_titulo(titulo).encode("utf-8")).hexdigest()


def _entry_data(entry, fonte_padrao):
    titulo = (entry.get("title") or "").strip()
    link = (entry.get("link") or "").strip()
    resumo_feed = re.sub(r"<[^>]+>", " ", entry.get("summary", "")).strip()
    # Veículo real (Google News expõe <source>Veículo</source>); senão, o rótulo da fonte.
    veiculo = ((entry.get("source") or {}).get("title") or "").strip() or fonte_padrao
    # Google News põe " - Veículo" no fim do título; remove para ficar limpo.
    if veiculo and titulo.endswith(f" - {veiculo}"):
        titulo = titulo[: -(len(veiculo) + 3)].strip()
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
    return titulo, link, resumo_feed, dt_ms, img, veiculo


# Instrução (prompt) enviada ao Gemini: além de resumir e categorizar, o modelo
# atua como um FILTRO DE RELEVÂNCIA (relevante=true/false), descartando conteúdo
# sem utilidade prática para o estudante. "Na dúvida, relevante=false" reduz ruído.
PROMPT = """Você cura notícias para um app de estudantes do IFSP Campus Pirituba.
Categorias possíveis: {cats}.

Notícia:
Título: {titulo}
Resumo: {resumo}

Marque relevante=true SOMENTE se a notícia for de utilidade prática direta para o
estudante, sobre: Enem, SiSU, Prouni, Fies, vestibular, matrícula, inscrições, editais,
concurso público, bolsa/auxílio, estágio, ou o próprio IFSP.
Marque relevante=false para: curiosidades, celebridades, esportes, opinião/colunas,
rankings, entretenimento, política geral, ou notícias sem ação clara para o aluno.
Na dúvida, prefira relevante=false.

Responda em JSON:
- relevante (bool)
- category (string): uma das categorias acima.
- summary (string): resumo curto e neutro, 2-3 frases, sem copiar o texto literal.
Responda só o JSON."""


def avaliar(client, titulo, resumo):
    """Pergunta ao Gemini se a notícia é relevante e obtém categoria + resumo.

    Mesmo padrão do pipeline de vagas: saída em JSON, até 4 tentativas com backoff
    para limite de taxa/sobrecarga, e fallback seguro (relevante=False) se falhar,
    para não publicar algo sem avaliação. A categoria é validada contra a lista
    permitida (CATEGORIAS); fora dela, cai em "Geral".
    """
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
    # Teto por fonte: distribui a cota entre os feeds (evita uma só fonte dominar).
    por_fonte = max(1, -(-max_noticias // len(FEEDS)))  # ceil
    # Janela de recência: só notícias publicadas nos últimos N dias (padrão 2).
    max_dias = int(os.getenv("MAX_DIAS_NOTICIA", "2"))
    cutoff_ms = int((time.time() - max_dias * 86400) * 1000)
    novas = 0
    vistos = set()  # ids já vistos nesta execução (evita reprocessar a mesma matéria)
    for feed in FEEDS:
        if novas >= max_noticias:
            break
        try:
            parsed = feedparser.parse(feed["url"])
        except Exception as e:
            print(f"⚠️  Falha no feed {feed['source']}: {e}")
            continue
        novas_feed = 0
        for entry in parsed.entries:
            if novas >= max_noticias or novas_feed >= por_fonte:
                break
            titulo, link, resumo_feed, dt_ms, img, veiculo = _entry_data(entry, feed["source"])
            if not titulo or not link:
                continue
            if dt_ms < cutoff_ms:  # notícia antiga (fora da janela de recência)
                continue
            if not casa_keyword(titulo + " " + resumo_feed):
                continue
            vid = news_doc_id(titulo)
            if vid in vistos:  # mesma matéria já vista nesta execução (outro feed/link)
                continue
            vistos.add(vid)
            if ja_tratada(db, vid):
                continue
            # IA avalia relevância + categoria + resumo; descarta o que não for útil.
            aval = avaliar(client, titulo, resumo_feed)
            if not aval["relevante"]:
                continue
            resumo = aval["summary"] or resumo_feed[:300]
            doc = {
                "category": aval["category"], "source": veiculo, "readTime": "1 min",
                "title": titulo, "summary": resumo, "body": resumo,
                "date": dt_ms, "facts": [], "sourceUrl": link, "imageUrl": img,
                "published": False, "pinned": False,
                "scrapedAt": int(time.time() * 1000), "status": "pendente",
            }
            db.collection("noticias_sugeridas").document(vid).set(doc)
            novas += 1
            novas_feed += 1
            print(f"📰 [{feed['source']}/{veiculo}] {titulo}")
            time.sleep(1)
    print(f"✅ {novas} notícias sugeridas gravadas em 'noticias_sugeridas'.")


if __name__ == "__main__":
    main()
