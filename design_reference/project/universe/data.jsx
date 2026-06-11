// data.jsx — UNIVERSE content (pt-BR), refined from the source design.
const DATA = {
  user: { name: 'Ana Beatriz', email: 'ana.silva@aluno.ifsp.edu.br', course: 'Análise e Desenvolvimento de Sistemas', enroll: 'PT3024187' },

  home: [
    { screen: 'ifsp', icon: 'institution', title: 'IFSP Pirituba', sub: 'Conheça o campus, estrutura e contatos' },
    { screen: 'cursos', tab: true, icon: 'cap', title: 'Cursos', sub: 'Graduações, técnicos e pós-graduação' },
    { screen: 'benGov', icon: 'benefits', title: 'Benefícios Governamentais', sub: 'Cadastro Único, ID Jovem, transporte e isenções' },
    { screen: 'benInst', icon: 'award', title: 'Benefícios Institucionais', sub: 'PAP, monitoria, iniciação científica e extensão' },
    { screen: 'estagio', icon: 'briefcase', title: 'Estágio e Concursos', sub: 'Vagas, editais e concursos públicos' },
    { screen: 'cadastrar', icon: 'edit', title: 'Cadastrar informações', sub: 'Atualize seus dados e documentos' },
  ],

  quick: [
    { screen: 'moradia', icon: 'house', label: 'Moradia' },
    { screen: 'duvidas', tab: true, icon: 'question', label: 'Dúvidas' },
    { screen: 'benGov', icon: 'card', label: 'ID Jovem' },
    { screen: 'ifsp', icon: 'pin', label: 'Endereço' },
  ],

  courseCats: ['Todos', 'Graduação', 'Técnico', 'Pós-graduação'],
  courses: [
    { name: 'Análise e Desenvolvimento de Sistemas', cat: 'Graduação', type: 'Tecnólogo', dur: '3 anos', period: 'Noturno', icon: 'doc' },
    { name: 'Gestão Pública', cat: 'Graduação', type: 'Tecnólogo', dur: '2,5 anos', period: 'Noturno', icon: 'institution' },
    { name: 'Letras — Português / Inglês', cat: 'Graduação', type: 'Licenciatura', dur: '4 anos', period: 'Noturno', icon: 'book' },
    { name: 'Engenharia de Produção', cat: 'Graduação', type: 'Bacharelado', dur: '5 anos', period: 'Integral', icon: 'settings' },
    { name: 'Administração', cat: 'Técnico', type: 'Integrado ao Médio', dur: '3 anos', period: 'Matutino', icon: 'briefcase' },
    { name: 'Redes de Computadores', cat: 'Técnico', type: 'Concomitante', dur: '2 anos', period: 'Vespertino', icon: 'globe' },
    { name: 'Logística', cat: 'Técnico', type: 'Subsequente', dur: '1,5 ano', period: 'Noturno', icon: 'bus' },
    { name: 'PROEJA — Administração', cat: 'Técnico', type: 'EJA Integrado', dur: '3 anos', period: 'Noturno', icon: 'flag' },
    { name: 'Gestão de Projetos', cat: 'Pós-graduação', type: 'Especialização', dur: '1,5 ano', period: 'Noturno', icon: 'award' },
    { name: 'Humanidades', cat: 'Pós-graduação', type: 'Especialização', dur: '1,5 ano', period: 'Noturno', icon: 'book' },
  ],

  benGov: [
    { icon: 'card', title: 'Cadastro Único', tag: 'Federal', desc: 'Porta de entrada para programas sociais do governo federal. Permite acesso a tarifas sociais, ID Jovem e isenções.', steps: ['Reúna documentos de todos do domicílio', 'Procure um posto do CRAS da sua região', 'Mantenha o cadastro atualizado a cada 2 anos'] },
    { icon: 'user', title: 'ID Jovem', tag: '15–29 anos', desc: 'Garante meia-entrada em eventos e vagas gratuitas/com desconto no transporte interestadual para jovens de baixa renda.', steps: ['Tenha o Cadastro Único ativo', 'Acesse o app ID Jovem', 'Gere a carteira digital'] },
    { icon: 'bus', title: 'Transporte', tag: 'Estadual', desc: 'Bilhete Único Escolar e gratuidade no transporte público para estudantes matriculados na rede.', steps: ['Comprovante de matrícula atualizado', 'Solicite o bilhete na SPTrans', 'Recarregue mensalmente'] },
    { icon: 'doc', title: 'Isenções', tag: 'Taxas', desc: 'Isenção de taxas em concursos, vestibulares e no Enem para estudantes de baixa renda.', steps: ['Verifique o período de solicitação no edital', 'Informe seu nº do NIS', 'Acompanhe o deferimento'] },
  ],

  benInst: [
    { icon: 'benefits', title: 'PAP', tag: 'Auxílio', desc: 'Programa de Auxílio Permanência — apoio financeiro para estudantes em vulnerabilidade socioeconômica.', steps: ['Inscreva-se no edital de assistência', 'Anexe documentação socioeconômica', 'Aguarde a análise do serviço social'] },
    { icon: 'award', title: 'Monitoria', tag: 'Bolsa', desc: 'Atue como monitor de uma disciplina, apoie colegas e receba bolsa mensal.', steps: ['Tenha bom desempenho na disciplina', 'Inscreva-se no edital de monitoria', 'Passe pela seleção do docente'] },
    { icon: 'book', title: 'Iniciação Científica', tag: 'Pesquisa', desc: 'Desenvolva pesquisa orientada por um docente com bolsa PIBIC/PIBITI.', steps: ['Procure um orientador', 'Submeta o projeto ao edital', 'Apresente no congresso de IC'] },
    { icon: 'globe', title: 'Projeto de Extensão', tag: 'Comunidade', desc: 'Participe de ações que conectam o campus à comunidade, com bolsa de extensão.', steps: ['Escolha um projeto ativo', 'Inscreva-se com o coordenador', 'Cumpra a carga horária'] },
  ],

  estagioTabs: ['Estágios', 'Concursos'],
  estagioCourses: ['Todos', 'ADS', 'Gestão Pública', 'Eng. de Produção', 'Redes', 'Administração', 'Logística'],
  estagios: [
    { id: 'e1', role: 'Estágio em Desenvolvimento Web', org: 'Prefeitura de São Paulo', area: 'Tecnologia da Informação', course: 'ADS', mode: 'Híbrido', grant: 'R$ 1.100', benefits: ['Vale-transporte', 'Recesso remunerado', 'Seguro de vida'], dur: '6h/dia · 12 meses', tag: 'Novo', status: 'open', link: 'sp.gov.br/estagios',
      reqs: ['Cursando a partir do 2º semestre de ADS', 'Conhecimento em HTML, CSS e JavaScript', 'Noções de Git'],
      nice: ['React ou Vue', 'Experiência com APIs REST', 'Figma'],
      about: 'A Prefeitura de São Paulo mantém um programa de estágio voltado à modernização dos serviços digitais ao cidadão, com mentoria técnica e rotação entre squads.' },
    { id: 'e2', role: 'Estágio em Suporte de TI', org: 'Tribunal de Justiça SP', area: 'Infraestrutura', course: 'Redes', mode: 'Presencial', grant: 'R$ 1.000', benefits: ['Vale-transporte', 'Vale-refeição'], dur: '6h/dia · 12 meses', status: 'open', link: 'tjsp.jus.br/estagio',
      reqs: ['Cursando Redes de Computadores ou ADS', 'Conhecimento em redes e hardware', 'Boa comunicação'],
      nice: ['Certificações Cisco', 'Inglês técnico'],
      about: 'O TJSP oferece estágio em sua central de suporte, atendendo usuários internos e dando manutenção a parque de máquinas e rede.' },
    { id: 'e3', role: 'Jovem Aprendiz — Administração', org: 'Banco do Brasil', area: 'Administrativo', course: 'Administração', mode: 'Presencial', grant: 'R$ 980', benefits: ['Vale-transporte', 'Vale-refeição', 'Plano de saúde'], dur: '4h/dia · 24 meses', status: 'open', link: 'bb.com.br/carreiras',
      reqs: ['Cursando técnico em Administração', 'Idade entre 16 e 22 anos', 'Ensino regular'],
      nice: ['Pacote Office', 'Experiência prévia'],
      about: 'O programa Jovem Aprendiz do Banco do Brasil combina trabalho e formação, com trilha de capacitação e possibilidade de efetivação.' },
    { id: 'e4', role: 'Estágio em Logística', org: 'Correios', area: 'Operações', course: 'Logística', mode: 'Presencial', grant: 'R$ 1.050', benefits: ['Vale-transporte', 'Auxílio-alimentação'], dur: '6h/dia · 12 meses', status: 'open', link: 'correios.com.br/estagio',
      reqs: ['Cursando Logística', 'Disponibilidade para período integral de estágio', 'Organização'],
      nice: ['Excel intermediário', 'Conhecimento de WMS'],
      about: 'Estágio nos centros de distribuição dos Correios, acompanhando roteirização, controle de estoque e indicadores operacionais.' },
    { id: 'e5', role: 'Estágio em Melhoria de Processos', org: 'Volkswagen', area: 'Engenharia', course: 'Eng. de Produção', mode: 'Presencial', grant: 'R$ 1.400', benefits: ['Transporte fretado', 'Restaurante interno', 'PLR'], dur: '6h/dia · 18 meses', status: 'closed', link: 'vwbr.com.br/carreiras',
      reqs: ['Cursando Engenharia de Produção', 'Conhecimento em Lean / Kaizen', 'Inglês intermediário'],
      nice: ['Power BI', 'Experiência com indústria'],
      about: 'Estágio na planta da Volkswagen acompanhando projetos de melhoria contínua e indicadores de produtividade na linha de montagem.' },
    { id: 'e6', role: 'Estágio em Gestão Pública', org: 'Secretaria Estadual de Educação', area: 'Gestão', course: 'Gestão Pública', mode: 'Híbrido', grant: 'R$ 1.000', benefits: ['Vale-transporte', 'Recesso remunerado'], dur: '6h/dia · 12 meses', status: 'closed', link: 'educacao.sp.gov.br',
      reqs: ['Cursando Gestão Pública', 'Boa redação oficial', 'Pacote Office'],
      nice: ['Conhecimento de licitações', 'Power BI'],
      about: 'Apoio à gestão de programas educacionais, com elaboração de relatórios, planilhas e acompanhamento de indicadores.' },
  ],
  concursos: [
    { id: 'c1', role: 'Técnico Administrativo em Educação', org: 'IFSP — Reitoria', vagas: '24 vagas', salary: 'R$ 4.180,66', level: 'Ensino Médio Técnico', period: 'até 30/07/2026', tag: 'Inscrições abertas', status: 'open', link: 'ifsp.edu.br/concursos',
      about: 'Concurso para provimento de cargos técnico-administrativos nos campi do IFSP, com prova objetiva e discursiva.' },
    { id: 'c2', role: 'Agente de Apoio Escolar', org: 'Prefeitura de SP', vagas: '120 vagas', salary: 'R$ 2.640,00', level: 'Ensino Médio', period: 'até 15/08/2026', status: 'open', link: 'prefeitura.sp.gov.br',
      about: 'Atuação em unidades educacionais municipais no apoio à rotina escolar e aos estudantes.' },
    { id: 'c3', role: 'Analista de Sistemas Júnior', org: 'Dataprev', vagas: '40 vagas', salary: 'R$ 6.300,00', level: 'Superior', period: 'até 02/08/2026', status: 'open', link: 'dataprev.gov.br',
      about: 'Desenvolvimento e manutenção de sistemas previdenciários de grande porte, com prova objetiva e de títulos.' },
    { id: 'c4', role: 'Auxiliar de Biblioteca', org: 'USP', vagas: '8 vagas', salary: 'R$ 2.900,00', level: 'Ensino Médio', period: 'encerrado em 02/05/2026', status: 'closed', link: 'usp.br/concursos',
      about: 'Apoio às atividades de catalogação, atendimento e organização do acervo das bibliotecas da USP.' },
  ],

  testimonials: [
    { name: 'Lucas Pereira', course: 'ADS', org: 'Prefeitura de SP', stars: 5, text: 'Estagiar no setor de TI da Prefeitura foi um divisor de águas. Aprendi na prática o que via em sala e fui efetivado depois de um ano.' },
    { name: 'Mariana Costa', course: 'Logística', org: 'Correios', stars: 4, text: 'O estágio nos Correios me deu visão real de operações. A bolsa ajudou muito e a equipe era super acolhedora com quem está começando.' },
    { name: 'Rafael Souza', course: 'Administração', org: 'Banco do Brasil', stars: 5, text: 'Como Jovem Aprendiz, consegui conciliar estudo e trabalho. Recomendo demais para quem quer começar cedo no mercado.' },
  ],

  republicas: [
    { icon: 'house', t: 'Repúblicas universitárias', d: 'Quartos compartilhados a partir de R$ 600/mês, geralmente perto da CPTM Pirituba.', tag: 'A partir de R$ 600' },
    { icon: 'pin', t: 'Bairros recomendados', d: 'Pirituba, Vila Mangalot e Jaraguá — bem servidos de transporte e comércio.', tag: 'Zona Noroeste' },
    { icon: 'shield', t: 'Antes de alugar', d: 'Confira contrato, condições do imóvel e visite pessoalmente antes de fechar.', tag: 'Segurança' },
  ],
  republicaLinks: [
    { icon: 'globe', t: 'Mural de vagas do campus', d: 'Grupo oficial de moradia estudantil', url: 'ptb.ifsp.edu.br/moradia' },
    { icon: 'benefits', t: 'Auxílio-moradia (PAP)', d: 'Apoio financeiro do IFSP', screen: 'benInst' },
    { icon: 'phone', t: 'Serviço Social do campus', d: '(11) 3596-7700 · ramal 212', copy: '(11) 3596-7700' },
  ],

  faqCats: ['Todas', 'Campus', 'Enem', 'Gerais'],
  faqs: [
    { cat: 'Campus', q: 'Como é viver em Pirituba?', a: 'Pirituba é uma região tranquila da Zona Noroeste de São Paulo, bem servida por transporte público (CPTM Linha 7-Rubi e diversas linhas de ônibus), comércio local e áreas verdes como o Parque da Cidade.' },
    { cat: 'Campus', q: 'O campus possui república estudantil?', a: 'O campus não oferece moradia própria, mas o serviço social orienta sobre repúblicas e auxílio-moradia. Veja a seção Moradia para opções próximas e dicas.' },
    { cat: 'Campus', q: 'O campus possui acessibilidade para PcD?', a: 'Sim. O campus conta com rampas, elevador, piso tátil, banheiros adaptados e o NAPNE — núcleo de apoio às pessoas com necessidades específicas.' },
    { cat: 'Enem', q: 'Como utilizo minha nota do Enem no IF?', a: 'Parte das vagas das graduações é ofertada via SiSU, usando a nota do Enem. Acompanhe os editais no site e fique atento às datas de inscrição do SiSU.' },
    { cat: 'Enem', q: 'O IFSP oferece bolsa para quem entra pelo Enem?', a: 'Sim. Após a matrícula, você pode concorrer aos auxílios do PAP e demais programas de assistência estudantil, independentemente da forma de ingresso.' },
    { cat: 'Gerais', q: 'Como faço para trancar a matrícula?', a: 'O trancamento é solicitado pela Secretaria, dentro do calendário acadêmico. Procure a CRE do campus ou abra um chamado no sistema acadêmico.' },
  ],

  ifspInfo: [
    { key: 'historia', icon: 'book', title: 'História', sub: 'Fundado em 1909, mais de um século de educação pública' },
    { key: 'endereco', icon: 'pin', title: 'Endereço', sub: 'Av. Mutinga, 951 — Pirituba, São Paulo/SP' },
    { key: 'horario', icon: 'clock', title: 'Horário de funcionamento', sub: 'Seg a Sex · 08h às 22h' },
    { key: 'estrutura', icon: 'institution', title: 'Estrutura', sub: 'Laboratórios, biblioteca, quadra e auditório' },
    { key: 'contatos', icon: 'phone', title: 'Contatos', sub: '(11) 3596-7700 · cmp@ifsp.edu.br' },
    { key: 'site', icon: 'globe', title: 'Site oficial', sub: 'ptb.ifsp.edu.br' },
  ],
  ifspDetails: {
    historia: { icon: 'book', title: 'História', kind: 'text',
      body: 'A Rede Federal de Educação nasceu em 1909, com as Escolas de Aprendizes Artífices. O IFSP é herdeiro dessa tradição centenária de ensino público, gratuito e de qualidade.\n\nO Campus Pirituba integra essa rede na Zona Noroeste de São Paulo, oferecendo cursos técnicos, de graduação e de pós-graduação, com forte ligação à comunidade local por meio de projetos de ensino, pesquisa e extensão.' },
    endereco: { icon: 'pin', title: 'Endereço', kind: 'map',
      address: 'Av. Mutinga, 951 — Pirituba\nSão Paulo / SP · CEP 02610-002', copy: 'Av. Mutinga, 951 - Pirituba, São Paulo/SP' },
    horario: { icon: 'clock', title: 'Horário de funcionamento', kind: 'hours',
      hours: [['Segunda a Sexta', '08h às 22h'], ['Sábado', '08h às 12h'], ['Domingo e feriados', 'Fechado']],
      note: 'A secretaria acadêmica atende das 09h às 20h em dias úteis.' },
    estrutura: { icon: 'institution', title: 'Estrutura', kind: 'list',
      items: [['Laboratórios de informática', 'doc'], ['Biblioteca', 'book'], ['Quadra poliesportiva', 'star'], ['Auditório', 'institution'], ['Laboratórios técnicos', 'settings'], ['Acessibilidade (NAPNE)', 'shield']] },
    contatos: { icon: 'phone', title: 'Contatos', kind: 'contacts',
      contacts: [
        { icon: 'phone', label: 'Telefone', value: '(11) 3596-7700', copy: '(11) 3596-7700' },
        { icon: 'mail', label: 'E-mail', value: 'cmp@ifsp.edu.br', copy: 'cmp@ifsp.edu.br' },
        { icon: 'pin', label: 'Endereço', value: 'Av. Mutinga, 951 — Pirituba', copy: 'Av. Mutinga, 951 - Pirituba, São Paulo/SP' },
      ] },
    site: { icon: 'globe', title: 'Site oficial', kind: 'site',
      url: 'ptb.ifsp.edu.br', links: [['Portal do campus', 'ptb.ifsp.edu.br'], ['Notícias e editais', 'ptb.ifsp.edu.br/noticias'], ['Sistema acadêmico (SUAP)', 'suap.ifsp.edu.br']] },
  },

  notifications: [
    { icon: 'briefcase', color: 'var(--green-600)', title: 'Nova vaga de estágio', body: 'Desenvolvimento Web na Prefeitura de SP — bolsa R$ 1.100.', time: 'agora', unread: true, go: 'estagio' },
    { icon: 'benefits', color: 'var(--green-600)', title: 'PAP — inscrições abertas', body: 'O edital de assistência estudantil está aberto até 28/06.', time: '2h', unread: true, go: 'benInst' },
    { icon: 'cap', color: 'var(--navy)', title: 'Matrícula confirmada', body: 'Sua matrícula no 4º semestre foi confirmada.', time: 'ontem', go: 'perfil', tab: true },
    { icon: 'question', color: 'var(--ink-2)', title: 'Resposta à sua dúvida', body: 'A coordenação respondeu sua pergunta sobre o SiSU.', time: '3 dias', go: 'duvidas', tab: true },
  ],
};
window.DATA = DATA;
