import '../models/course.dart';
import '../models/internship.dart';
import '../models/contest.dart';
import '../models/testimonial.dart';
import '../models/faq.dart';
import '../models/ifsp_info.dart';
import '../models/content_doc.dart';
import 'universe_repository.dart';

class FakeUniverseRepository implements UniverseRepository {
  final List<Testimonial> _extraTestimonials = [];

  // ── Courses ──────────────────────────────────────────────────────────────
  static const _courses = [
    Course(
      name: 'Análise e Desenvolvimento de Sistemas',
      category: 'Graduação',
      type: 'Tecnólogo',
      duration: '3 anos',
      period: 'Noturno',
      icon: 'doc',
    ),
    Course(
      name: 'Gestão Pública',
      category: 'Graduação',
      type: 'Tecnólogo',
      duration: '2,5 anos',
      period: 'Noturno',
      icon: 'institution',
    ),
    Course(
      name: 'Letras — Português / Inglês',
      category: 'Graduação',
      type: 'Licenciatura',
      duration: '4 anos',
      period: 'Noturno',
      icon: 'book',
    ),
    Course(
      name: 'Engenharia de Produção',
      category: 'Graduação',
      type: 'Bacharelado',
      duration: '5 anos',
      period: 'Integral',
      icon: 'settings',
    ),
    Course(
      name: 'Administração',
      category: 'Técnico',
      type: 'Integrado ao Médio',
      duration: '3 anos',
      period: 'Matutino',
      icon: 'briefcase',
    ),
    Course(
      name: 'Redes de Computadores',
      category: 'Técnico',
      type: 'Concomitante',
      duration: '2 anos',
      period: 'Vespertino',
      icon: 'globe',
    ),
    Course(
      name: 'Logística',
      category: 'Técnico',
      type: 'Subsequente',
      duration: '1,5 ano',
      period: 'Noturno',
      icon: 'bus',
    ),
    Course(
      name: 'PROEJA — Administração',
      category: 'Técnico',
      type: 'EJA Integrado',
      duration: '3 anos',
      period: 'Noturno',
      icon: 'flag',
    ),
    Course(
      name: 'Gestão de Projetos',
      category: 'Pós-graduação',
      type: 'Especialização',
      duration: '1,5 ano',
      period: 'Noturno',
      icon: 'award',
    ),
    Course(
      name: 'Humanidades',
      category: 'Pós-graduação',
      type: 'Especialização',
      duration: '1,5 ano',
      period: 'Noturno',
      icon: 'book',
    ),
  ];

  // ── Testimonials ──────────────────────────────────────────────────────────
  static const _testimonials = [
    Testimonial(
      name: 'Lucas Pereira',
      course: 'ADS',
      org: 'Prefeitura de SP',
      stars: 5,
      text:
          'Estagiar no setor de TI da Prefeitura foi um divisor de águas. Aprendi na prática o que via em sala e fui efetivado depois de um ano.',
    ),
    Testimonial(
      name: 'Mariana Costa',
      course: 'Logística',
      org: 'Correios',
      stars: 4,
      text:
          'O estágio nos Correios me deu visão real de operações. A bolsa ajudou muito e a equipe era super acolhedora com quem está começando.',
    ),
    Testimonial(
      name: 'Rafael Souza',
      course: 'Administração',
      org: 'Banco do Brasil',
      stars: 5,
      text:
          'Como Jovem Aprendiz, consegui conciliar estudo e trabalho. Recomendo demais para quem quer começar cedo no mercado.',
    ),
  ];

  // ── FAQs ──────────────────────────────────────────────────────────────────
  static const _faqs = [
    Faq(
      category: 'Campus',
      question: 'Como é viver em Pirituba?',
      answer:
          'Pirituba é uma região tranquila da Zona Noroeste de São Paulo, bem servida por transporte público (CPTM Linha 7-Rubi e diversas linhas de ônibus), comércio local e áreas verdes como o Parque da Cidade.',
    ),
    Faq(
      category: 'Campus',
      question: 'O campus possui república estudantil?',
      answer:
          'O campus não oferece moradia própria, mas o serviço social orienta sobre repúblicas e auxílio-moradia. Veja a seção Moradia para opções próximas e dicas.',
    ),
    Faq(
      category: 'Campus',
      question: 'O campus possui acessibilidade para PcD?',
      answer:
          'Sim. O campus conta com rampas, elevador, piso tátil, banheiros adaptados e o NAPNE — núcleo de apoio às pessoas com necessidades específicas.',
    ),
    Faq(
      category: 'Enem',
      question: 'Como utilizo minha nota do Enem no IF?',
      answer:
          'Parte das vagas das graduações é ofertada via SiSU, usando a nota do Enem. Acompanhe os editais no site e fique atento às datas de inscrição do SiSU.',
    ),
    Faq(
      category: 'Enem',
      question: 'O IFSP oferece bolsa para quem entra pelo Enem?',
      answer:
          'Sim. Após a matrícula, você pode concorrer aos auxílios do PAP e demais programas de assistência estudantil, independentemente da forma de ingresso.',
    ),
    Faq(
      category: 'Gerais',
      question: 'Como faço para trancar a matrícula?',
      answer:
          'O trancamento é solicitado pela Secretaria, dentro do calendário acadêmico. Procure a CRE do campus ou abra um chamado no sistema acadêmico.',
    ),
  ];

  // ── IFSP Info (com detail embutido) ───────────────────────────────────────
  static const _ifspInfo = [
    IfspInfo(
      key: 'historia',
      icon: 'book',
      title: 'História',
      subtitle: 'Fundado em 1909, mais de um século de educação pública',
      detail: IfspDetail(
        key: 'historia',
        icon: 'book',
        title: 'História',
        body:
            'A Rede Federal de Educação nasceu em 1909, com as Escolas de Aprendizes Artífices. O IFSP é herdeiro dessa tradição centenária de ensino público, gratuito e de qualidade.\n\nO Campus Pirituba integra essa rede na Zona Noroeste de São Paulo, oferecendo cursos técnicos, de graduação e de pós-graduação, com forte ligação à comunidade local por meio de projetos de ensino, pesquisa e extensão.',
      ),
    ),
    IfspInfo(
      key: 'endereco',
      icon: 'pin',
      title: 'Endereço',
      subtitle: 'Av. Mutinga, 951 — Pirituba, São Paulo/SP',
      detail: IfspDetail(
        key: 'endereco',
        icon: 'pin',
        title: 'Endereço',
        body: 'Av. Mutinga, 951 — Pirituba\nSão Paulo / SP · CEP 02610-002',
      ),
    ),
    IfspInfo(
      key: 'horario',
      icon: 'clock',
      title: 'Horário de funcionamento',
      subtitle: 'Seg a Sex · 08h às 22h',
      detail: IfspDetail(
        key: 'horario',
        icon: 'clock',
        title: 'Horário de funcionamento',
        body: 'A secretaria acadêmica atende das 09h às 20h em dias úteis.',
        rows: [
          ('Segunda a Sexta', '08h às 22h'),
          ('Sábado', '08h às 12h'),
          ('Domingo e feriados', 'Fechado'),
        ],
      ),
    ),
    IfspInfo(
      key: 'estrutura',
      icon: 'institution',
      title: 'Estrutura',
      subtitle: 'Laboratórios, biblioteca, quadra e auditório',
      detail: IfspDetail(
        key: 'estrutura',
        icon: 'institution',
        title: 'Estrutura',
        rows: [
          ('Laboratórios de informática', 'doc'),
          ('Biblioteca', 'book'),
          ('Quadra poliesportiva', 'star'),
          ('Auditório', 'institution'),
          ('Laboratórios técnicos', 'settings'),
          ('Acessibilidade (NAPNE)', 'shield'),
        ],
      ),
    ),
    IfspInfo(
      key: 'contatos',
      icon: 'phone',
      title: 'Contatos',
      subtitle: '(11) 3596-7700 · cmp@ifsp.edu.br',
      detail: IfspDetail(
        key: 'contatos',
        icon: 'phone',
        title: 'Contatos',
        rows: [
          ('Telefone', '(11) 3596-7700'),
          ('E-mail', 'cmp@ifsp.edu.br'),
          ('Endereço', 'Av. Mutinga, 951 — Pirituba'),
        ],
      ),
    ),
    IfspInfo(
      key: 'site',
      icon: 'globe',
      title: 'Site oficial',
      subtitle: 'ptb.ifsp.edu.br',
      detail: IfspDetail(
        key: 'site',
        icon: 'globe',
        title: 'Site oficial',
        rows: [
          ('Portal do campus', 'ptb.ifsp.edu.br'),
          ('Notícias e editais', 'ptb.ifsp.edu.br/noticias'),
          ('Sistema acadêmico (SUAP)', 'suap.ifsp.edu.br'),
        ],
      ),
    ),
  ];

  // ── Internships ───────────────────────────────────────────────────────────
  // Instância (não static): cada repositório tem cópia mutável própria,
  // evitando vazamento de estado entre testes.
  final List<Internship> _internships = [
    const Internship(
      id: 'e1',
      role: 'Estágio em Desenvolvimento Web',
      companyName: 'Prefeitura de São Paulo',
      area: 'Tecnologia da Informação',
      course: 'ADS',
      mode: 'Híbrido',
      grant: 'R\$ 1.100',
      benefits: ['Vale-transporte', 'Recesso remunerado', 'Seguro de vida'],
      duration: '6h/dia · 12 meses',
      tag: 'Novo',
      open: true,
      link: 'sp.gov.br/estagios',
      requirements: [
        'Cursando a partir do 2º semestre de ADS',
        'Conhecimento em HTML, CSS e JavaScript',
        'Noções de Git',
      ],
      niceToHave: [
        'React ou Vue',
        'Experiência com APIs REST',
        'Figma',
      ],
      companyDescription:
          'A Prefeitura de São Paulo mantém um programa de estágio voltado à modernização dos serviços digitais ao cidadão, com mentoria técnica e rotação entre squads.',
      jobDescription:
          'Desenvolvimento e manutenção de páginas e sistemas web para serviços digitais ao cidadão.',
    ),
    const Internship(
      id: 'e2',
      role: 'Estágio em Suporte de TI',
      companyName: 'Tribunal de Justiça SP',
      area: 'Infraestrutura',
      course: 'Redes',
      mode: 'Presencial',
      grant: 'R\$ 1.000',
      benefits: ['Vale-transporte', 'Vale-refeição'],
      duration: '6h/dia · 12 meses',
      open: true,
      link: 'tjsp.jus.br/estagio',
      requirements: [
        'Cursando Redes de Computadores ou ADS',
        'Conhecimento em redes e hardware',
        'Boa comunicação',
      ],
      niceToHave: [
        'Certificações Cisco',
        'Inglês técnico',
      ],
      companyDescription:
          'O TJSP oferece estágio em sua central de suporte, atendendo usuários internos e dando manutenção a parque de máquinas e rede.',
      jobDescription:
          'Atendimento de chamados técnicos, suporte a usuários e manutenção de equipamentos e rede interna.',
    ),
    const Internship(
      id: 'e3',
      role: 'Jovem Aprendiz — Administração',
      companyName: 'Banco do Brasil',
      area: 'Administrativo',
      course: 'Administração',
      mode: 'Presencial',
      grant: 'R\$ 980',
      benefits: ['Vale-transporte', 'Vale-refeição', 'Plano de saúde'],
      duration: '4h/dia · 24 meses',
      open: true,
      link: 'bb.com.br/carreiras',
      requirements: [
        'Cursando técnico em Administração',
        'Idade entre 16 e 22 anos',
        'Ensino regular',
      ],
      niceToHave: [
        'Pacote Office',
        'Experiência prévia',
      ],
      companyDescription:
          'O programa Jovem Aprendiz do Banco do Brasil combina trabalho e formação, com trilha de capacitação e possibilidade de efetivação.',
      jobDescription:
          'Apoio a rotinas administrativas bancárias, atendimento e organização documental com trilha de capacitação.',
    ),
    const Internship(
      id: 'e4',
      role: 'Estágio em Logística',
      companyName: 'Correios',
      area: 'Operações',
      course: 'Logística',
      mode: 'Presencial',
      grant: 'R\$ 1.050',
      benefits: ['Vale-transporte', 'Auxílio-alimentação'],
      duration: '6h/dia · 12 meses',
      open: true,
      link: 'correios.com.br/estagio',
      requirements: [
        'Cursando Logística',
        'Disponibilidade para período integral de estágio',
        'Organização',
      ],
      niceToHave: [
        'Excel intermediário',
        'Conhecimento de WMS',
      ],
      companyDescription:
          'Estágio nos centros de distribuição dos Correios, acompanhando roteirização, controle de estoque e indicadores operacionais.',
      jobDescription:
          'Acompanhamento de roteirização, controle de estoque e levantamento de indicadores operacionais nos centros de distribuição.',
    ),
    Internship(
      id: 'e5',
      role: 'Estágio em Melhoria de Processos',
      companyName: 'Volkswagen',
      area: 'Engenharia',
      course: 'Eng. de Produção',
      mode: 'Presencial',
      grant: 'R\$ 1.400',
      benefits: ['Transporte fretado', 'Restaurante interno', 'PLR'],
      duration: '6h/dia · 18 meses',
      open: false,
      closedAt: DateTime.now().subtract(const Duration(days: 10)),
      link: 'vwbr.com.br/carreiras',
      requirements: [
        'Cursando Engenharia de Produção',
        'Conhecimento em Lean / Kaizen',
        'Inglês intermediário',
      ],
      niceToHave: [
        'Power BI',
        'Experiência com indústria',
      ],
      companyDescription:
          'Estágio na planta da Volkswagen acompanhando projetos de melhoria contínua e indicadores de produtividade na linha de montagem.',
      jobDescription:
          'Apoio a projetos de melhoria contínua (Lean/Kaizen) e acompanhamento de indicadores de produtividade na linha de montagem.',
    ),
    Internship(
      id: 'e6',
      role: 'Estágio em Gestão Pública',
      companyName: 'Secretaria Estadual de Educação',
      area: 'Gestão',
      course: 'Gestão Pública',
      mode: 'Híbrido',
      grant: 'R\$ 1.000',
      benefits: ['Vale-transporte', 'Recesso remunerado'],
      duration: '6h/dia · 12 meses',
      open: false,
      closedAt: DateTime.now().subtract(const Duration(days: 10)),
      link: 'educacao.sp.gov.br',
      requirements: [
        'Cursando Gestão Pública',
        'Boa redação oficial',
        'Pacote Office',
      ],
      niceToHave: [
        'Conhecimento de licitações',
        'Power BI',
      ],
      companyDescription:
          'Apoio à gestão de programas educacionais, com elaboração de relatórios, planilhas e acompanhamento de indicadores.',
      jobDescription:
          'Elaboração de relatórios, organização de planilhas e acompanhamento de indicadores de programas educacionais estaduais.',
    ),
  ];

  // ── Contests ──────────────────────────────────────────────────────────────
  final List<Contest> _contests = [
    Contest(
      id: 'c1',
      role: 'Técnico Administrativo em Educação',
      org: 'IFSP — Reitoria',
      vagas: '24 vagas',
      salary: 'R\$ 4.180,66',
      level: 'Ensino Médio Técnico',
      deadline: DateTime(2026, 7, 30),
      link: 'ifsp.edu.br/concursos',
      about:
          'Concurso para provimento de cargos técnico-administrativos nos campi do IFSP, com prova objetiva e discursiva.',
    ),
    Contest(
      id: 'c2',
      role: 'Agente de Apoio Escolar',
      org: 'Prefeitura de SP',
      vagas: '120 vagas',
      salary: 'R\$ 2.640,00',
      level: 'Ensino Médio',
      deadline: DateTime(2026, 8, 15),
      link: 'prefeitura.sp.gov.br',
      about:
          'Atuação em unidades educacionais municipais no apoio à rotina escolar e aos estudantes.',
    ),
    Contest(
      id: 'c3',
      role: 'Analista de Sistemas Júnior',
      org: 'Dataprev',
      vagas: '40 vagas',
      salary: 'R\$ 6.300,00',
      level: 'Superior',
      deadline: DateTime(2026, 8, 2),
      link: 'dataprev.gov.br',
      about:
          'Desenvolvimento e manutenção de sistemas previdenciários de grande porte, com prova objetiva e de títulos.',
    ),
    Contest(
      id: 'c4',
      role: 'Auxiliar de Biblioteca',
      org: 'USP',
      vagas: '8 vagas',
      salary: 'R\$ 2.900,00',
      level: 'Ensino Médio',
      deadline: DateTime(2026, 5, 2),
      link: 'usp.br/concursos',
      about:
          'Apoio às atividades de catalogação, atendimento e organização do acervo das bibliotecas da USP.',
    ),
  ];

  // ── Content Docs ──────────────────────────────────────────────────────────
  final List<ContentDoc> _contentDocs = [
    ContentDoc(
      id: 'gov-cadunico',
      kind: ContentKind.gov,
      icon: 'card',
      title: 'Cadastro Único',
      tag: 'Federal',
      summary: 'A porta de entrada para os programas sociais do governo federal.',
      updatedAt: DateTime(2026, 6, 10),
      sections: [
        RichSection(
          heading: 'O que é',
          body: 'O [[Cadastro Único|CadÚnico]] é o registro que identifica famílias de baixa renda para os programas sociais do governo federal. É a partir dele que você acessa benefícios como o [[ID Jovem]], tarifas sociais de energia e o pedido de [[Isenções|isenção de taxas]] em concursos e no [[Enem]].\n\nAo entrar no Cadastro Único, você recebe um [[NIS]] — o número que identifica você em todos esses programas.',
        ),
        const CalloutSection(
          variant: 'info',
          body: 'Não custa nada para se inscrever. O Cadastro Único é gratuito e feito presencialmente no [[CRAS]].',
        ),
        RichSection(
          heading: 'Quem pode se inscrever',
          body: 'Famílias com renda mensal de até meio salário mínimo por pessoa, ou de até três salários mínimos no total. Estudantes que moram sozinhos também podem fazer o seu próprio cadastro.',
        ),
        StepsSection(
          heading: 'Como solicitar',
          items: [
            'Reúna documentos de todas as pessoas que moram com você (CPF ou título de eleitor do responsável).',
            'Procure o [[CRAS]] mais próximo da sua casa e leve um comprovante de residência.',
            'Um atendente fará a entrevista e registrará os dados da família.',
            'Guarde o seu [[NIS]] — você vai usá-lo em todos os benefícios.',
            'Atualize o cadastro a cada 2 anos ou sempre que algo mudar (endereço, renda, pessoas na casa).',
          ],
        ),
        MediaSection(
          mediaType: 'video',
          heading: 'Tutorial em vídeo',
          caption: 'Como fazer o Cadastro Único passo a passo (3 min)',
          videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        ),
        FaqSection(
          heading: 'Dúvidas frequentes',
          items: [
            (q: 'Preciso ir ao CRAS pessoalmente?', a: 'Sim. A inscrição inicial é presencial, mas atualizações simples podem ser feitas pelo app Cadastro Único.'),
            (q: 'Quanto tempo demora?', a: 'O registro é feito na hora da entrevista. O NIS pode levar alguns dias para ser ativado.'),
          ],
        ),
        SourcesSection(
          heading: 'Canais oficiais',
          items: [
            (label: 'gov.br — Cadastro Único', url: 'gov.br/cadastrounico'),
            (label: 'App Cadastro Único', url: 'play.google.com · App Store'),
          ],
        ),
      ],
    ),
    ContentDoc(
      id: 'gov-idjovem',
      kind: ContentKind.gov,
      icon: 'user',
      title: 'ID Jovem',
      tag: '15–29 anos',
      summary: 'Meia-entrada e transporte interestadual gratuito ou com desconto para jovens de baixa renda.',
      updatedAt: DateTime(2026, 6, 5),
      sections: [
        RichSection(
          heading: 'O que é',
          body: 'A Identidade Jovem ([[ID Jovem]]) é um documento digital gratuito que garante direitos a jovens de 15 a 29 anos inscritos no [[Cadastro Único]] com renda familiar de até dois salários mínimos.',
        ),
        RichSection(
          heading: 'Quais são os direitos',
          body: 'Meia-entrada em eventos artísticos, culturais e esportivos; e vagas gratuitas ou com 50% de desconto no transporte interestadual (ônibus, trem e barco entre estados).',
        ),
        DocsSection(
          heading: 'O que você precisa',
          items: [
            'Ter entre 15 e 29 anos',
            '[[Cadastro Único]] ativo e atualizado',
            'Renda familiar de até 2 salários mínimos',
          ],
        ),
        StepsSection(
          heading: 'Como emitir',
          items: [
            'Garanta que seu [[Cadastro Único]] está atualizado.',
            'Baixe o aplicativo ID Jovem ou acesse o site oficial.',
            'Informe seu [[NIS]] e dados pessoais.',
            'Pronto: a carteira digital fica disponível no app para apresentar quando precisar.',
          ],
        ),
        MediaSection(
          mediaType: 'image',
          heading: 'Como fica a carteira',
          caption: 'Exemplo da carteira digital do ID Jovem',
        ),
        const CalloutSection(
          variant: 'warn',
          body: 'Para usar no transporte interestadual, solicite a vaga com antecedência — o número de lugares com gratuidade é limitado por viagem.',
        ),
        SourcesSection(
          heading: 'Canais oficiais',
          items: [
            (label: 'gov.br — ID Jovem', url: 'gov.br/cidadania/id-jovem'),
          ],
        ),
      ],
    ),
    ContentDoc(
      id: 'gov-transporte',
      kind: ContentKind.gov,
      icon: 'bus',
      title: 'Transporte estudantil',
      tag: 'Estadual',
      summary: 'Bilhete Único Escolar e gratuidade no transporte público para estudantes matriculados.',
      updatedAt: DateTime(2026, 5, 28),
      sections: [
        RichSection(
          heading: 'O que é',
          body: 'O [[Bilhete Único]] Escolar dá desconto ou gratuidade no transporte público de São Paulo para estudantes regularmente matriculados. Em conjunto com o [[ID Jovem]], amplia o acesso à mobilidade para quem estuda.',
        ),
        StepsSection(
          heading: 'Como solicitar',
          items: [
            'Tenha em mãos um comprovante de matrícula atualizado do campus.',
            'Faça o cadastro no site da SPTrans com foto e documento.',
            'Acompanhe a aprovação e retire o cartão no posto indicado.',
            'Recarregue mensalmente para manter o benefício ativo.',
          ],
        ),
        const CalloutSection(
          variant: 'info',
          body: 'Precisa do comprovante de matrícula? Solicite na secretaria do campus — veja os contatos na seção IFSP Pirituba.',
        ),
        SourcesSection(
          heading: 'Canais oficiais',
          items: [
            (label: 'SPTrans — Bilhete Único Escolar', url: 'sptrans.com.br'),
          ],
        ),
      ],
    ),
    ContentDoc(
      id: 'gov-isencoes',
      kind: ContentKind.gov,
      icon: 'doc',
      title: 'Isenção de taxas',
      tag: 'Concursos e Enem',
      summary: 'Isenção da taxa de inscrição em concursos, vestibulares e no Enem.',
      updatedAt: DateTime(2026, 6, 1),
      sections: [
        RichSection(
          heading: 'O que é',
          body: 'Estudantes de baixa renda podem pedir [[Isenções|isenção]] da taxa de inscrição no [[Enem]], em concursos públicos e em vestibulares. O critério mais comum é estar inscrito no [[Cadastro Único]] e informar o [[NIS]].',
        ),
        StepsSection(
          heading: 'Como solicitar',
          items: [
            'Fique atento ao período de pedido de isenção — costuma ser antes das inscrições.',
            'No formulário, marque a opção de isenção e informe seu [[NIS]].',
            'Envie os documentos pedidos, se houver.',
            'Acompanhe o resultado (deferido ou indeferido) e, se negado, veja se há recurso.',
          ],
        ),
        const CalloutSection(
          variant: 'warn',
          body: 'O prazo da isenção quase sempre é mais curto que o das inscrições. Não deixe para a última hora.',
        ),
        FaqSection(
          heading: 'Dúvidas frequentes',
          items: [
            (q: 'Se a isenção for negada, ainda posso me inscrever?', a: 'Sim, mas você terá que pagar a taxa dentro do prazo normal de inscrição.'),
          ],
        ),
        SourcesSection(
          heading: 'Canais oficiais',
          items: [
            (label: 'Página oficial do Enem', url: 'gov.br/inep/enem'),
          ],
        ),
      ],
    ),
    ContentDoc(
      id: 'inst-pap',
      kind: ContentKind.inst,
      icon: 'benefits',
      title: 'PAP — Auxílio Permanência',
      tag: 'Auxílio',
      summary: 'Apoio financeiro para estudantes em situação de vulnerabilidade socioeconômica.',
      updatedAt: DateTime(2026, 6, 12),
      sections: [
        RichSection(
          heading: 'O que é',
          body: 'O Programa de Auxílio Permanência ([[PAP]]) é uma das principais ações de assistência estudantil do IFSP. Oferece apoio financeiro para que estudantes em vulnerabilidade consigam se manter no curso, incluindo auxílio-moradia, alimentação e transporte.',
        ),
        DocsSection(
          heading: 'Documentos para a inscrição',
          items: [
            'Documento de identidade e CPF',
            'Comprovante de renda de todos da família',
            'Comprovante de residência',
            'Comprovante de matrícula',
          ],
        ),
        StepsSection(
          heading: 'Como solicitar',
          items: [
            'Acompanhe a abertura do edital de assistência estudantil no campus.',
            'Preencha a inscrição no sistema acadêmico (SUAP).',
            'Anexe a documentação socioeconômica solicitada.',
            'Aguarde a análise do serviço social do campus.',
            'Se aprovado, o auxílio é pago mensalmente conforme o edital.',
          ],
        ),
        MediaSection(
          mediaType: 'video',
          heading: 'Tutorial em vídeo',
          caption: 'Como se inscrever no PAP pelo SUAP (5 min)',
          videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        ),
        const CalloutSection(
          variant: 'info',
          body: 'Dúvidas sobre documentação? Procure o serviço social do campus — atendimento humano e confidencial.',
        ),
        SourcesSection(
          heading: 'Canais oficiais',
          items: [
            (label: 'Assistência Estudantil — IFSP', url: 'ptb.ifsp.edu.br/assistencia'),
          ],
        ),
      ],
    ),
    ContentDoc(
      id: 'inst-monitoria',
      kind: ContentKind.inst,
      icon: 'award',
      title: 'Monitoria',
      tag: 'Bolsa',
      summary: 'Apoie colegas em uma disciplina e receba bolsa mensal.',
      updatedAt: DateTime(2026, 5, 20),
      sections: [
        RichSection(
          heading: 'O que é',
          body: 'Na [[Monitoria]], você atua como monitor de uma disciplina em que tem bom desempenho, ajudando colegas e o docente, e recebe uma bolsa mensal. É uma ótima primeira experiência acadêmica — e conta como atividade complementar.',
        ),
        StepsSection(
          heading: 'Como participar',
          items: [
            'Tenha bom desempenho na disciplina desejada.',
            'Inscreva-se quando o edital de monitoria for publicado.',
            'Passe pela seleção feita pelo docente responsável.',
            'Cumpra a carga horária combinada e receba a bolsa.',
          ],
        ),
        FaqSection(
          heading: 'Dúvidas frequentes',
          items: [
            (q: 'Monitoria atrapalha os estudos?', a: 'Não. A carga horária é planejada para caber na sua rotina, geralmente algumas horas por semana.'),
          ],
        ),
        SourcesSection(
          heading: 'Canais oficiais',
          items: [
            (label: 'Editais de ensino — IFSP', url: 'ptb.ifsp.edu.br/editais'),
          ],
        ),
      ],
    ),
    ContentDoc(
      id: 'inst-ic',
      kind: ContentKind.inst,
      icon: 'book',
      title: 'Iniciação Científica',
      tag: 'Pesquisa',
      summary: 'Desenvolva pesquisa orientada por um docente, com bolsa PIBIC ou PIBITI.',
      updatedAt: DateTime(2026, 6, 8),
      sections: [
        RichSection(
          heading: 'O que é',
          body: 'A [[Iniciação Científica]] permite que você desenvolva um projeto de pesquisa orientado por um docente, com bolsa mensal. As duas principais modalidades são o [[PIBIC]] (pesquisa científica) e o [[PIBITI]] (inovação e tecnologia).',
        ),
        RichSection(
          heading: 'PIBIC e PIBITI: qual a diferença?',
          body: 'O [[PIBIC]] é voltado à pesquisa científica em qualquer área do conhecimento. O [[PIBITI]] foca em desenvolvimento tecnológico e inovação — protótipos, software, processos. Ambos pagam bolsa e valem como experiência acadêmica.',
        ),
        StepsSection(
          heading: 'Como participar',
          items: [
            'Procure um docente da sua área para ser seu orientador.',
            'Juntos, escrevam um projeto de pesquisa.',
            'Submetam o projeto ao edital de [[PIBIC]] ou [[PIBITI]].',
            'Se aprovado, desenvolva a pesquisa e receba a bolsa.',
            'Apresente os resultados no congresso de Iniciação Científica.',
          ],
        ),
        MediaSection(
          mediaType: 'image',
          heading: 'Linha do tempo da pesquisa',
          caption: 'Do projeto ao congresso: como funciona um ano de IC',
        ),
        SourcesSection(
          heading: 'Canais oficiais',
          items: [
            (label: 'Pesquisa e Inovação — IFSP', url: 'ptb.ifsp.edu.br/pesquisa'),
          ],
        ),
      ],
    ),
    ContentDoc(
      id: 'inst-extensao',
      kind: ContentKind.inst,
      icon: 'globe',
      title: 'Projeto de Extensão',
      tag: 'Comunidade',
      summary: 'Conecte o campus à comunidade em ações sociais, culturais e educativas — com bolsa.',
      updatedAt: DateTime(2026, 5, 15),
      sections: [
        RichSection(
          heading: 'O que é',
          body: 'A [[Extensão]] são projetos que levam o conhecimento do campus para fora dele, atendendo a comunidade. Você pode participar como bolsista ou voluntário e desenvolver habilidades que o mercado valoriza.',
        ),
        StepsSection(
          heading: 'Como participar',
          items: [
            'Veja os projetos de extensão ativos no campus.',
            'Converse com o coordenador do projeto que te interessa.',
            'Inscreva-se no edital de extensão.',
            'Cumpra a carga horária e participe das ações.',
          ],
        ),
        const CalloutSection(
          variant: 'info',
          body: 'Extensão conta como atividade complementar e enriquece muito o currículo.',
        ),
        SourcesSection(
          heading: 'Canais oficiais',
          items: [
            (label: 'Extensão — IFSP', url: 'ptb.ifsp.edu.br/extensao'),
          ],
        ),
      ],
    ),
  ];

  // ── Stream methods ────────────────────────────────────────────────────────
  @override
  Stream<List<Course>> watchCourses() => Stream.value(_courses);

  @override
  Stream<List<Internship>> watchInternships({String courseFilter = 'Todos'}) {
    final now = DateTime.now();
    return Stream.value(
      _internships
          .where((e) => e.visibleAt(now))
          .where((e) => courseFilter == 'Todos' || e.course == courseFilter)
          .toList(),
    );
  }

  @override
  Stream<List<Contest>> watchContests() {
    final now = DateTime.now();
    return Stream.value(_contests.where((c) => c.visibleAt(now)).toList());
  }

  @override
  Stream<List<Testimonial>> watchTestimonials() =>
      Stream.value([..._extraTestimonials, ..._testimonials]);

  @override
  Stream<List<Faq>> watchFaqs() => Stream.value(_faqs);

  @override
  Stream<List<IfspInfo>> watchIfspInfo() => Stream.value(_ifspInfo);

  @override
  Stream<List<ContentDoc>> watchContentDocs(ContentKind kind) =>
      Stream.value(_contentDocs.where((d) => d.kind == kind).toList());

  @override
  Stream<ContentDoc?> watchContentDoc(String id) {
    final m = _contentDocs.where((d) => d.id == id);
    return Stream.value(m.isEmpty ? null : m.first);
  }

  @override
  Future<void> addTestimonial(Testimonial t) async =>
      _extraTestimonials.insert(0, t);

  // ── Admin write ───────────────────────────────────────────────────────────
  var _idSeq = 1000;

  @override
  Stream<List<Internship>> watchAllInternships() => Stream.value(List.of(_internships));
  @override
  Stream<List<Contest>> watchAllContests() => Stream.value(List.of(_contests));
  @override
  Future<void> upsertInternship(Internship v) async {
    final i = _internships.indexWhere((e) => e.id == v.id);
    if (i >= 0) { _internships[i] = v; } else { _internships.add(v); }
  }
  @override
  Future<void> deleteInternship(String id) async => _internships.removeWhere((e) => e.id == id);
  @override
  Future<void> upsertContest(Contest c) async {
    final i = _contests.indexWhere((e) => e.id == c.id);
    if (i >= 0) { _contests[i] = c; } else { _contests.add(c); }
  }
  @override
  Future<void> deleteContest(String id) async => _contests.removeWhere((e) => e.id == id);
  @override
  String newId(String collection) => '${collection}_${_idSeq++}';

  @override
  Stream<List<ContentDoc>> watchAllContentDocs() => Stream.value(List.of(_contentDocs));
  @override
  Future<void> upsertContentDoc(ContentDoc d) async {
    final i = _contentDocs.indexWhere((e) => e.id == d.id);
    if (i >= 0) { _contentDocs[i] = d; } else { _contentDocs.add(d); }
  }
  @override
  Future<void> deleteContentDoc(String id) async => _contentDocs.removeWhere((e) => e.id == id);

  // Getters para o seeder lerem todo o conteúdo bruto:
  List<Course> get allCourses => _courses;
  List<Internship> get allInternships => _internships;
  List<Contest> get allContests => _contests;
  List<Testimonial> get allTestimonials => _testimonials;
  List<Faq> get allFaqs => _faqs;
  List<IfspInfo> get allIfspInfo => _ifspInfo;
  List<ContentDoc> get allContentDocs => _contentDocs;
}
