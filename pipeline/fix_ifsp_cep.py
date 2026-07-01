"""Correção pontual: CEP do IFSP na produção (Firestore, coleção ifspInfo).
Troca 02610-002 -> 05110-000 em qualquer campo (inclui o detail aninhado).
Reusa a service account do pipeline. Rodar dentro de pipeline/:
    python fix_ifsp_cep.py
Idempotente.
"""
import sys
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass
from main import init_firestore

OLD, NEW = "02610-002", "05110-000"
db = init_firestore()


def deep_replace(obj):
    """Substitui OLD->NEW recursivamente; retorna (novo_obj, houve_mudanca)."""
    if isinstance(obj, str):
        return (obj.replace(OLD, NEW), OLD in obj)
    if isinstance(obj, dict):
        changed = False
        out = {}
        for k, v in obj.items():
            nv, c = deep_replace(v)
            out[k] = nv
            changed = changed or c
        return out, changed
    if isinstance(obj, list):
        changed = False
        out = []
        for v in obj:
            nv, c = deep_replace(v)
            out.append(nv)
            changed = changed or c
        return out, changed
    return obj, False


def main():
    docs = list(db.collection("ifspInfo").stream())
    print(f"{len(docs)} docs em ifspInfo")
    touched = 0
    for snap in docs:
        data = snap.to_dict()
        new_data, changed = deep_replace(data)
        if changed:
            snap.reference.set(new_data)
            touched += 1
            print(f"OK  ifspInfo/{snap.id} — CEP atualizado")
    print(f"Concluído. {touched} documento(s) atualizado(s).")
    if touched == 0:
        print("(nenhum doc continha o CEP antigo — talvez já corrigido)")


if __name__ == "__main__":
    main()
