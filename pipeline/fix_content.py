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
from firebase_admin import firestore
from main import init_firestore

db = init_firestore()
DEL = firestore.DELETE_FIELD


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
    "curriculumUrl": "https://drive.ifsp.edu.br/s/CS3ah4zmKiNCYTy?dir=/&editing=false&openfile=true",
    "ppcUrl": "https://cursos.ifsp.edu.br/graduacao/curso/PTB130200/",  # catálogo oficial (PPC p/ download)
})

fix_curso("Gestão de Projetos", {
    "about": ("Objetivo geral\n\n"
        "A Especialização em Gestão de Projetos prepara profissionais para gerenciar projetos complexos que "
        "exigem conhecimento especializado — uma habilidade cada vez mais requisitada pelas empresas. O curso é "
        "presencial, gratuito e aberto a profissionais de todas as áreas (não apenas Administração, Gestão ou "
        "Engenharia), com ingresso anual em fevereiro.\n\n"
        "O corpo docente é formado por mestres e doutores com experiência nos setores público, privado e do "
        "terceiro setor. A escolha de um gerente de projetos capacitado aumenta muito as chances de sucesso de "
        "um projeto."),
    "ppcUrl": "https://drive.ifsp.edu.br/s/cHKckyfPDflmhK9",
})

fix_curso("Gestão Pública", {
    "about": ("Objetivo geral\n\n"
        "O Curso Superior de Tecnologia em Gestão Pública tem como objetivo formar profissionais aptos a "
        "atuar de maneira efetiva, transparente e participativa na gestão de órgãos e entidades da "
        "Administração Direta e Indireta das diferentes esferas de governo, contribuindo para a melhoria da "
        "qualidade dos serviços públicos prestados à sociedade, bem como atuar em empresas privadas que "
        "demandam profissionais com estas características.\n\n"
        "Competências e habilidades\n\n"
        "• Diagnosticar o cenário político, econômico, social e legal da gestão pública;\n"
        "• Desenvolver e aplicar inovações científico-tecnológicas nos processos de gestão pública;\n"
        "• Planejar, implantar, supervisionar e avaliar projetos e programas de políticas públicas voltados ao desenvolvimento local e regional;\n"
        "• Aplicar metodologias inovadoras de gestão, baseadas nos princípios da administração pública, legislação vigente e ética profissional;\n"
        "• Planejar e implantar ações vinculadas à prestação de serviços públicos;\n"
        "• Avaliar e emitir parecer técnico em sua área de formação."),
    "researchUrl": "https://drive.ifsp.edu.br/s/3SL4sdji1xy9mgB",
    "curriculumUrl": "https://drive.ifsp.edu.br/s/DbRVXWiCXF887tq",
    "ppcUrl": "https://cursos.ifsp.edu.br/graduacao/curso/PTB130000/",
})

fix_curso("Engenharia de Produção", {
    "about": ("Objetivo geral\n\n"
        "O curso de Engenharia de Produção do Câmpus São Paulo Pirituba visa formar um profissional com sólida "
        "formação técnico-científica, visão sistêmica e generalista, capaz de transformar a realidade por meio "
        "da solução de problemas — projetando, implantando, readequando e gerenciando sistemas produtivos de "
        "bens ou serviços, com busca contínua por melhoria e respeito aos fatores econômicos, ao elemento "
        "humano, ao meio ambiente e aos contextos sociais, políticos e culturais.\n\n"
        "Competências e habilidades\n\n"
        "• Formular e conceber soluções de engenharia, compreendendo os usuários e seu contexto;\n"
        "• Analisar e compreender fenômenos físicos e químicos por meio de modelos validados por experimentação;\n"
        "• Conceber, projetar e analisar sistemas, produtos (bens e serviços), componentes ou processos;\n"
        "• Implantar, supervisionar e controlar as soluções de Engenharia;\n"
        "• Comunicar-se eficazmente nas formas escrita, oral e gráfica;\n"
        "• Trabalhar e liderar equipes multidisciplinares."),
    "research": ("A Extensão no IFSP promove a interação transformadora entre a comunidade acadêmica e a "
        "sociedade. No Câmpus Pirituba, destacam-se iniciativas como a concepção de uma Incubadora de Inovação, "
        "a criação de uma Empresa Júnior e projetos como o Programa Mulheres do IFSP.\n\n"
        "Na pesquisa, estudantes de Engenharia de Produção têm acesso a programas de iniciação científica e "
        "podem atuar em grupos interdisciplinares, como AMBIENTEC, GETS, NEOGEP, GITES e SONAED."),
    "researchUrl": "https://drive.google.com/file/d/1LOqJB2cRKGBv_iY2VYVaGQ_TpJa5GwIt/view",
    "curriculumUrl": "https://drive.google.com/file/d/1KIEafQRje36V9XfVe0OTJst-nuDGOxCs/view",
    "ppcUrl": "https://cursos.ifsp.edu.br/campus/PTB",
})

fix_curso("Redes de Computadores", {
    "about": ("Objetivo geral\n\n"
        "O curso técnico em Redes de Computadores visa formar profissionais capazes de planejar, implementar, "
        "gerenciar e manter ambientes de TI com redes de computadores de forma confiável, robusta e organizada. "
        "O curso articula competências técnicas, éticas e socioambientais, promovendo o pensamento crítico, o "
        "protagonismo e a criatividade, e integrando ensino, pesquisa e extensão.\n\n"
        "Competências e habilidades\n\n"
        "• Projetar, implementar e gerenciar redes seguindo normas técnicas, com confiabilidade, disponibilidade e segurança;\n"
        "• Definir e implementar políticas de segurança e de acesso a dados;\n"
        "• Configurar e manter dispositivos ativos e passivos e dominar protocolos de comunicação;\n"
        "• Aplicar pensamento crítico e raciocínio lógico na solução de problemas;\n"
        "• Integrar fundamentos científicos e tecnológicos relacionando teoria e prática;\n"
        "• Atuar com autonomia, empreendedorismo e preparo para o mercado de trabalho."),
    "researchUrl": "https://drive.ifsp.edu.br/s/Mtk2SrW7fgyhTDv",
    "curriculumUrl": "https://drive.ifsp.edu.br/s/iB9ck3VC90moQto",
    "ppcUrl": "https://cursos.ifsp.edu.br/campus/PTB",
})

PTB = "https://cursos.ifsp.edu.br/campus/PTB"

fix_curso("Letras — Português / Inglês", {
    "researchUrl": "https://drive.ifsp.edu.br/s/YTcEjKGS0krEV0B",
    "curriculumUrl": "https://drive.ifsp.edu.br/s/BJ5aZCTZEFx6cTH",
    "ppcUrl": PTB,
})

fix_curso("Administração", {
    "about": ("Objetivo geral\n\n"
        "O Técnico em Administração articula competências técnicas e conhecimentos historicamente "
        "construídos a valores estéticos, éticos, políticos, culturais, científicos e tecnológicos. Forma um "
        "profissional cidadão, preparado para refletir sobre questões sociais, orientado pelo respeito à "
        "diversidade, à inclusão social, ao meio ambiente e aos direitos humanos.\n\n"
        "Competências e habilidades\n\n"
        "• Atuar na área administrativa de forma ética, inovadora e conforme a legislação, unindo teoria e prática;\n"
        "• Desenvolver autonomia intelectual, pensamento crítico e protagonismo no aprendizado;\n"
        "• Aplicar gestão organizacional, análise de indicadores, tomada de decisão e comportamento empreendedor;\n"
        "• Compreender a sociedade e promover práticas inclusivas alinhadas aos direitos humanos;\n"
        "• Preparar-se para o mundo do trabalho com responsabilidade social e ambiental;\n"
        "• Ler, produzir textos e usar múltiplas linguagens com senso crítico."),
    "researchUrl": "https://drive.ifsp.edu.br/s/OVUCAUUaO9nSrZr",
    "curriculumUrl": "https://drive.ifsp.edu.br/s/xCA3fbWjLLWC1WL",
    "ppcUrl": PTB,
})

fix_curso("Logística", {
    "about": ("Objetivo geral\n\n"
        "O Curso Técnico em Logística tem como objetivo formar profissionais e cidadãos técnicos de nível médio "
        "competentes técnica, ética e politicamente, com elevado grau de responsabilidade social, capazes de "
        "saber, saber fazer e gerenciar atividades e aspectos organizacionais e humanos, visando à produção de "
        "bens, serviços e conhecimentos.\n\n"
        "Competências e habilidades\n\n"
        "• Planejar, programar, operar e controlar funções logísticas nas organizações;\n"
        "• Integrar educação básica e profissional com atuação ética e sustentável;\n"
        "• Usar criticamente as tecnologias de informação e comunicação;\n"
        "• Respeitar direitos humanos, inclusão social e diversidade;\n"
        "• Dominar a linguagem matemática aplicada à logística;\n"
        "• Manter relações éticas e criativas com fornecedores, clientes e setores internos."),
    "researchUrl": "https://drive.google.com/file/d/1hhKftSo4jXmjcUDHhf4Btlca3zdqsovq/view",
    "curriculumUrl": "https://drive.google.com/file/d/1_b4GQTJwYgH3SwqdeVAc5QcD-RIB2jTZ/view",
    "ppcUrl": PTB,
})

fix_curso("PROEJA — Administração", {
    "about": ("Objetivo geral\n\n"
        "O principal objetivo do curso é o resgate da cidadania do público de jovens e adultos, a partir do "
        "reconhecimento da educação como direito e da articulação entre formação geral e formação para o "
        "trabalho — especificamente para a atuação como Técnico em Administração (Resolução CNE/CEB nº 6/2012).\n\n"
        "Competências e habilidades\n\n"
        "• Flexibilizar métodos e organização para reduzir abandono e reprovação;\n"
        "• Oferecer ensino significativo, respeitando os conhecimentos prévios dos estudantes;\n"
        "• Fortalecer leitura, escrita e matemática para a aprendizagem contínua;\n"
        "• Capacitar para a atuação como técnico em Administração, com foco no arranjo produtivo local;\n"
        "• Integrar disciplinas técnicas e comuns com ênfase na interdisciplinaridade;\n"
        "• Valorizar conhecimentos prévios, estimulando autoestima, pensamento crítico e cidadania."),
    "researchUrl": "https://drive.google.com/file/d/10ZyW8FFzldpSlR14CAYtfrXq0poDnjji/view",
    "curriculumUrl": "https://drive.google.com/file/d/1gL2YzsVwXk-1jDeNcqVCMGxtY2JQmjgH/view",
    "ppcUrl": PTB,
})

fix_curso("Humanidades", {
    "about": ("Objetivo geral\n\n"
        "A Especialização em Humanidades — Educação, Política e Sociedade é um curso presencial que oferece "
        "qualificação a licenciados e bacharéis das Ciências Humanas e áreas correlatas. Com grade "
        "multidisciplinar, busca uma formação abrangente e atualizada, ampliando o capital cultural dos "
        "pós-graduandos com base no debate acadêmico contemporâneo.\n\n"
        "Competências e habilidades\n\n"
        "• Formar a partir de uma perspectiva crítica e plural da sociedade contemporânea;\n"
        "• Compreender o percurso histórico do último século e seus dilemas políticos, sociais e culturais;\n"
        "• Avaliar as relações de poder nas diversas esferas da vida social;\n"
        "• Apoiar licenciados no aprimoramento da atividade docente;\n"
        "• Envolver os estudantes com a pesquisa acadêmica e a publicação científica."),
    "curriculumUrl": "https://drive.ifsp.edu.br/s/qb7AGLXfExwwgRF",
    "ppcUrl": PTB,
})

patch("contentDocs", "gov-cadunico", fix_cadunico)
patch("contentDocs", "gov-idjovem", fix_idjovem)
patch("contentDocs", "gov-isencoes", fix_isencoes)
patch("contentDocs", "inst-pap", fix_pap)
patch("contentDocs", "inst-monitoria", fix_monitoria)
patch("contentDocs", "inst-ic", fix_ic)
patch("contentDocs", "inst-extensao", fix_extensao)
print("Concluído.")
