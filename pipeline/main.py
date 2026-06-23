import os, sys, time, json, re
# Console do Windows (cp1252) não imprime emojis; força UTF-8 na saída.
try:
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
except Exception:
    pass
import urllib.parse
import urllib.request
import urllib.error
import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv
from google import genai
from google.genai import types

load_dotenv()

# Rótulos curtos de curso usados no app (devem casar com o VagaFormScreen).
CURSOS_APP = ["ADS", "Gestão Pública", "Eng. de Produção", "Redes", "Administração", "Logística", "Todos"]

# API pública de busca de vagas da Gupy (JSON — sem necessidade de navegador).
GUPY_API = "https://employability-portal.gupy.io/api/v1/jobs"
_UA = {"User-Agent": "Mozilla/5.0", "Accept": "application/json"}

_MODE_MAP = {"on-site": "Presencial", "remote": "Remoto", "hybrid": "Híbrido"}


def map_course(valor: str) -> str:
    """Normaliza o curso retornado pelo modelo para um rótulo do app."""
    if not valor:
        return "Todos"
    v = valor.strip().lower()
    tabela = {
        "ads": "ADS", "análise e desenvolvimento": "ADS", "analise e desenvolvimento": "ADS",
        "gestão pública": "Gestão Pública", "gestao publica": "Gestão Pública",
        "produção": "Eng. de Produção", "producao": "Eng. de Produção", "engenharia": "Eng. de Produção",
        "redes": "Redes", "administração": "Administração", "administracao": "Administração",
        "logística": "Logística", "logistica": "Logística",
    }
    for chave, rotulo in tabela.items():
        if chave in v:
            return rotulo
    for rotulo in CURSOS_APP:
        if rotulo.lower() == v:
            return rotulo
    return "Todos"


def job_doc_id(job_id) -> str:
    """Id estável do documento a partir do id da vaga na Gupy."""
    return f"gupy-{job_id}"


def map_mode(workplace_type: str) -> str:
    return _MODE_MAP.get((workplace_type or "").lower(), "Presencial")


def is_remote(job: dict) -> bool:
    return bool(job.get("isRemoteWork")) or (job.get("workplaceType", "").lower() == "remote")


# Estado-alvo do campus. Vagas não-remotas só interessam se forem deste estado.
ESTADO_ALVO = os.getenv("ESTADO_ALVO", "São Paulo")


def keep_vaga(job: dict) -> bool:
    """Mantém a vaga se for remota (qualquer estado) ou presencial/híbrida em SP."""
    if is_remote(job):
        return True
    return (job.get("state") or "") == ESTADO_ALVO


def init_firestore():
    cred_path = os.getenv("FIREBASE_SERVICE_ACCOUNT", "service-account.json")
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)
    return firestore.client()


def init_gemini():
    return genai.Client(api_key=os.getenv("GEMINI_API_KEY"))


PROMPT_EXTRACAO = """Você extrai dados de uma vaga de estágio para um app acadêmico.
Cursos do campus (use EXATAMENTE um destes em "course"): {cursos}
Se nenhum servir, use "Todos".

Texto da vaga:
\"\"\"{texto}\"\"\"

Responda em JSON com as chaves:
course (string), area (string), duration (string), grant (string, bolsa/remuneração),
jobDescription (string, 1-3 frases), companyDescription (string, 1-2 frases),
requirements (array de strings), niceToHave (array de strings), benefits (array de strings).
Use "" ou [] quando não houver a informação. Responda só o JSON."""


def extrair_estruturado(client, texto: str) -> dict:
    prompt = PROMPT_EXTRACAO.format(cursos=", ".join(CURSOS_APP), texto=(texto or "")[:6000])
    for tentativa in range(4):
        try:
            resp = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=prompt,
                config=types.GenerateContentConfig(response_mime_type="application/json"),
            )
            data = json.loads(resp.text)
            return {
                "course": map_course(str(data.get("course", ""))),
                "area": str(data.get("area", "")),
                "duration": str(data.get("duration", "")),
                "grant": str(data.get("grant", "")),
                "jobDescription": str(data.get("jobDescription", "")),
                "companyDescription": str(data.get("companyDescription", "")),
                "requirements": [str(x) for x in (data.get("requirements") or [])],
                "niceToHave": [str(x) for x in (data.get("niceToHave") or [])],
                "benefits": [str(x) for x in (data.get("benefits") or [])],
            }
        except Exception as e:
            erro = str(e)
            m = re.search(r"retry in (\d+)", erro)
            if m:
                time.sleep(int(m.group(1)) + 5)
            elif "503" in erro or "UNAVAILABLE" in erro or "overloaded" in erro.lower():
                time.sleep(10 * (tentativa + 1))  # backoff em sobrecarga temporária
            else:
                print(f"❌ Erro no Gemini: {e}")
                break
    return {"course": "Todos", "area": "", "duration": "", "grant": "",
            "jobDescription": "", "companyDescription": "", "requirements": [], "niceToHave": [], "benefits": []}


def ja_tratada(db, vid: str) -> bool:
    if db.collection("internships").document(vid).get().exists:
        return True
    sug = db.collection("vagas_sugeridas").document(vid).get()
    return sug.exists and sug.to_dict().get("status") == "recusada"


def buscar_vagas(termo: str, max_vagas: int, max_paginas: int = 25):
    """Busca vagas de estágio na API da Gupy (paginado), aplicando o filtro de
    tipo (estágio) e localização (remota OU em SP). Pagina até juntar `max_vagas`
    aprovadas ou esgotar (limitado por `max_paginas` por segurança)."""
    out = []
    offset, limit, paginas = 0, 20, 0
    while len(out) < max_vagas and paginas < max_paginas:
        params = urllib.parse.urlencode({"jobName": termo, "limit": limit, "offset": offset})
        req = urllib.request.Request(f"{GUPY_API}?{params}", headers=_UA)
        with urllib.request.urlopen(req, timeout=25) as r:
            payload = json.loads(r.read().decode("utf-8"))
        data = payload.get("data", [])
        if not data:
            break
        for job in data:
            # Só estágio (a busca por nome pode trazer outros tipos) e local relevante.
            if job.get("type") and job.get("type") != "vacancy_type_internship":
                continue
            if not keep_vaga(job):
                continue
            out.append(job)
            if len(out) >= max_vagas:
                break
        total = payload.get("pagination", {}).get("total", 0)
        offset += limit
        paginas += 1
        if offset >= total:
            break
    return out


def vaga_existe(job_id: str) -> bool:
    """True se a vaga ainda está no ar na Gupy (200); False se saiu (404).
    Em erro de rede/instabilidade, retorna True para não encerrar por engano."""
    try:
        req = urllib.request.Request(f"{GUPY_API}/{job_id}", headers=_UA)
        with urllib.request.urlopen(req, timeout=20) as r:
            return r.status == 200
    except urllib.error.HTTPError as e:
        return e.code != 404
    except Exception:
        return True


def encerrar_inativas(db) -> int:
    """RF034: encerra vagas auto (id `gupy-<id>`) já publicadas que saíram do ar."""
    fechadas = 0
    for d in db.collection("internships").stream():
        if not d.id.startswith("gupy-"):
            continue
        data = d.to_dict()
        if not data.get("open", True):
            continue
        job_id = d.id[len("gupy-"):]
        if not vaga_existe(job_id):
            d.reference.update({"open": False, "closedAt": int(time.time() * 1000)})
            fechadas += 1
            print(f"🚫 Encerrada (saiu do ar): {data.get('role', d.id)}")
        time.sleep(0.3)
    return fechadas


def main():
    db = init_firestore()
    client = init_gemini()
    termo = os.getenv("TERMO_BUSCA", "estágio")
    max_vagas = int(os.getenv("MAX_VAGAS", "30"))

    # RF034: encerra as vagas auto já publicadas que saíram do ar.
    fechadas = encerrar_inativas(db)
    if fechadas:
        print(f"🚫 {fechadas} vaga(s) encerrada(s) por terem saído do ar.")

    vagas = buscar_vagas(termo, max_vagas)
    print(f"🔎 {len(vagas)} vagas (estágio · remota ou {ESTADO_ALVO}) coletadas da Gupy.")

    novas = 0
    for job in vagas:
        vid = job_doc_id(job.get("id"))
        titulo = job.get("name", "")
        if not titulo:
            continue
        if ja_tratada(db, vid):
            print(f"⏭️  Pulando (já tratada): {titulo}")
            continue
        print(f"🤖 Enriquecendo: {titulo}")
        extra = extrair_estruturado(client, job.get("description", ""))
        doc = {
            "role": titulo,
            "companyName": job.get("careerPageName", ""),
            "mode": map_mode(job.get("workplaceType")),
            "link": job.get("jobUrl", ""),
            "tag": "Novo", "open": True, "closedAt": None,
            "source": "gupy-auto", "scrapedAt": int(time.time() * 1000), "status": "pendente",
            **extra,
        }
        # ja_tratada() já barrou aprovadas/recusadas; set limpo evita ressuscitar tombstone.
        db.collection("vagas_sugeridas").document(vid).set(doc)
        novas += 1
        time.sleep(1)

    print(f"✅ {novas} sugestões gravadas em 'vagas_sugeridas'.")


if __name__ == "__main__":
    main()
