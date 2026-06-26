"""Correções pontuais de conteúdo na produção (Firestore), via get-modify-set.
Reusa a service account do pipeline. Rodar dentro de pipeline/:
    python fix_content.py
Idempotente — pode rodar de novo sem duplicar.
"""
import sys
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass
from main import init_firestore

db = init_firestore()


def patch(col, doc_id, fn):
    ref = db.collection(col).document(doc_id)
    snap = ref.get()
    if not snap.exists:
        print(f"!! {col}/{doc_id} não existe")
        return
    data = snap.to_dict()
    fn(data)
    ref.set(data)
    print(f"OK {col}/{doc_id}")


def fix_cadunico(d):
    secs = d.get("sections", [])
    # remove qualquer vídeo do tutorial (estava com link de música / rickroll)
    secs = [s for s in secs if not (s.get("type") == "media" and (s.get("videoUrl")))]
    for s in secs:
        if s.get("type") == "sources":
            s["items"] = [
                {"label": "gov.br — Cadastro Único",
                 "url": "gov.br/mds/pt-br/acoes-e-programas/cadastro-unico"},
            ]
    d["sections"] = secs


def fix_idjovem(d):
    for s in d.get("sections", []):
        if s.get("type") == "sources":
            s["items"] = [
                {"label": "ID Jovem — site oficial", "url": "idjovem.juventude.gov.br"},
                {"label": "gov.br — sobre o ID Jovem", "url": "gov.br/juventude"},
            ]
        if s.get("type") == "steps":
            s["items"] = [
                ("Acesse o site oficial idjovem.juventude.gov.br ou baixe o app ID Jovem (gov.br)."
                 if "Baixe o aplicativo ID Jovem" in i else i)
                for i in s.get("items", [])
            ]


def fix_isencoes(d):
    for s in d.get("sections", []):
        if s.get("type") == "sources":
            for it in s.get("items", []):
                if "enem" in (it.get("url", "").lower()) or "Enem" in it.get("label", ""):
                    it["url"] = "enem.inep.gov.br"


patch("contentDocs", "gov-cadunico", fix_cadunico)
patch("contentDocs", "gov-idjovem", fix_idjovem)
patch("contentDocs", "gov-isencoes", fix_isencoes)
print("Concluído.")
