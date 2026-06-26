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


PAP_BODY = (
    "O Programa de Auxílio Permanência ([[PAP]]) tem como objetivo viabilizar a igualdade "
    "de oportunidades entre os estudantes e contribuir para a melhoria do desempenho "
    "acadêmico, combatendo a retenção e a evasão decorrentes de dificuldades socioeconômicas."
    "\n\nPor meio do PAP são destinadas verbas para: auxílios Alimentação, Transporte e "
    "Moradia; apoio a estudantes pais e mães (auxílio-creche); Auxílio Saúde; e apoio "
    "didático-pedagógico."
)
PAP_CALLOUT = (
    "As inscrições abrem por edital da DAE/CSP do campus. Confira o edital vigente e seus "
    "anexos antes de se inscrever. Dúvidas sobre documentação? Procure o serviço social do "
    "campus — atendimento humano e confidencial."
)


def fix_pap(d):
    secs = [s for s in d.get("sections", []) if not (s.get("type") == "media" and s.get("videoUrl"))]
    for s in secs:
        if s.get("type") == "rich" and s.get("heading") == "O que é":
            s["body"] = PAP_BODY
        if s.get("type") == "callout":
            s["body"] = PAP_CALLOUT
        if s.get("type") == "sources":
            s["items"] = [
                {"label": "Inscrições e informações (DAE/CSP)", "url": "ptb.ifsp.edu.br/index.php/dae/csp"},
                {"label": "Tutorial do PAP", "url": "ifsp.edu.br/tutorialpap"},
            ]
    d["sections"] = secs


def fix_monitoria(d):
    for s in d.get("sections", []):
        if s.get("type") == "sources":
            s["items"] = [{"label": "Editais — IFSP Pirituba", "url": "ptb.ifsp.edu.br/index.php/editais"}]


def fix_ic(d):
    out = []
    for s in d.get("sections", []):
        if s.get("type") == "media" and s.get("mediaType") == "image" and not s.get("imageUrl"):
            out.append({"type": "steps", "heading": "Linha do tempo da pesquisa", "items": [
                "Edital de IC publicado e inscrições abertas.",
                "Submissão do projeto com o orientador.",
                "Avaliação e divulgação dos selecionados.",
                "Execução da pesquisa (cerca de 12 meses) com bolsa mensal.",
                "Entrega do relatório final e apresentação no congresso de IC.",
            ]})
        else:
            if s.get("type") == "sources":
                s["items"] = [{"label": "Pesquisa e Inovação — IFSP", "url": "ifsp.edu.br/pesquisa-e-inovacao"}]
            out.append(s)
    d["sections"] = out


def fix_extensao(d):
    for s in d.get("sections", []):
        if s.get("type") == "sources":
            s["items"] = [{"label": "Extensão — IFSP", "url": "ifsp.edu.br/extensao"}]


ADS_ABOUT = (
    "Objetivo geral\n\n"
    "O Curso Superior de Tecnologia em Análise e Desenvolvimento de Sistemas tem por objetivo "
    "desenvolver as habilidades do estudante para atuar na área de Tecnologia da Informação, "
    "tendo como referência os conhecimentos mais importantes da atividade profissional, e promover "
    "o desenvolvimento de competências de raciocínio, objetividade e iniciativa, além de estimular "
    "a cidadania e a responsabilidade social com espírito crítico, ético, inovador e empreendedor.\n\n"
    "Competências e habilidades\n\n"
    "• Analisar, projetar, desenvolver, testar, implantar e manter sistemas computacionais de informação;\n"
    "• Avaliar, selecionar, especificar e utilizar metodologias, tecnologias e ferramentas da Engenharia "
    "de Software, linguagens de programação e bancos de dados;\n"
    "• Coordenar equipes de produção de software;\n"
    "• Vistoriar, realizar perícia, avaliar e emitir laudo e parecer técnico em sua área de formação."
)
ADS_RESEARCH = (
    "A pesquisa científica faz parte da cultura acadêmica do IFSP, com projetos desenvolvidos por "
    "servidores(as) e estudantes. O principal grupo de pesquisa do curso de ADS é o GITES.\n\n"
    "GITES — Grupo de Informática e Tecnologia em Educação e Sociedade\n\n"
    "O GITES promove estudos, discussões e pesquisas focados em pesquisa e inovação tecnológica e no "
    "aprimoramento de conhecimentos em informática e TIC no contexto da educação e da sociedade. Linhas "
    "de pesquisa: educação a distância, algoritmos e programação, análise e mineração de dados, robótica, "
    "aprendizagem de máquina, e gestão, análise e segurança de dados e informação."
)


def fix_curso(nome, dados):
    achou = False
    for d in db.collection("courses").where("name", "==", nome).stream():
        d.reference.set(dados, merge=True)
        achou = True
        print(f"OK courses/{d.id} ({nome})")
    if not achou:
        print(f"!! curso não encontrado: {nome}")


fix_curso("Análise e Desenvolvimento de Sistemas", {
    "about": ADS_ABOUT, "research": ADS_RESEARCH,
    "researchUrl": "https://dgp.cnpq.br/dgp/espelhogrupo/7528238432160652",
    "curriculumUrl": "https://drive.ifsp.edu.br/s/CS3ah4zmKiNCYTy",
    "ppcUrl": "https://drive.ifsp.edu.br/s/pjtMN8o6NIueODd",
})

patch("contentDocs", "gov-cadunico", fix_cadunico)
patch("contentDocs", "gov-idjovem", fix_idjovem)
patch("contentDocs", "gov-isencoes", fix_isencoes)
patch("contentDocs", "inst-pap", fix_pap)
patch("contentDocs", "inst-monitoria", fix_monitoria)
patch("contentDocs", "inst-ic", fix_ic)
patch("contentDocs", "inst-extensao", fix_extensao)
print("Concluído.")
