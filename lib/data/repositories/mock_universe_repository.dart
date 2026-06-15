import '../models/course.dart';
import '../models/benefit.dart';
import '../models/internship.dart';
import '../models/contest.dart';
import '../models/testimonial.dart';
import '../models/faq.dart';
import '../models/ifsp_info.dart';
import 'universe_repository.dart';

class MockUniverseRepository implements UniverseRepository {
  // ── Courses ──────────────────────────────────────────────────────────────
  @override
  List<Course> courses() => const [
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

  // ── Benefits ─────────────────────────────────────────────────────────────
  @override
  List<Benefit> benefits(BenefitKind kind) =>
      kind == BenefitKind.gov ? _benGov : _benInst;

  static const _benGov = [
    Benefit(
      icon: 'card',
      title: 'Cadastro Único',
      tag: 'Federal',
      description:
          'Porta de entrada para programas sociais do governo federal. Permite acesso a tarifas sociais, ID Jovem e isenções.',
      steps: [
        'Reúna documentos de todos do domicílio',
        'Procure um posto do CRAS da sua região',
        'Mantenha o cadastro atualizado a cada 2 anos',
      ],
      url: 'https://www.gov.br/pt-br/servicos/inscrever-se-no-cadastro-unico-para-programas-sociais-do-governo-federal',
    ),
    Benefit(
      icon: 'user',
      title: 'ID Jovem',
      tag: '15–29 anos',
      description:
          'Garante meia-entrada em eventos e vagas gratuitas/com desconto no transporte interestadual para jovens de baixa renda.',
      steps: [
        'Tenha o Cadastro Único ativo',
        'Acesse o app ID Jovem',
        'Gere a carteira digital',
      ],
      url: 'https://www.gov.br/pt-br/servicos/obter-a-carteira-de-identidade-jovem',
    ),
    Benefit(
      icon: 'bus',
      title: 'Transporte',
      tag: 'Estadual',
      description:
          'Bilhete Único Escolar e gratuidade no transporte público para estudantes matriculados na rede.',
      steps: [
        'Comprovante de matrícula atualizado',
        'Solicite o bilhete na SPTrans',
        'Recarregue mensalmente',
      ],
      url: 'https://www.sptrans.com.br/',
    ),
    Benefit(
      icon: 'doc',
      title: 'Isenções',
      tag: 'Taxas',
      description:
          'Isenção de taxas em concursos, vestibulares e no Enem para estudantes de baixa renda.',
      steps: [
        'Verifique o período de solicitação no edital',
        'Informe seu nº do NIS',
        'Acompanhe o deferimento',
      ],
      url: 'https://www.gov.br/inep/pt-br/areas-de-atuacao/avaliacao-e-exames-educacionais/enem',
    ),
  ];

  static const _benInst = [
    Benefit(
      icon: 'benefits',
      title: 'PAP',
      tag: 'Auxílio',
      description:
          'Programa de Auxílio Permanência — apoio financeiro para estudantes em vulnerabilidade socioeconômica.',
      steps: [
        'Inscreva-se no edital de assistência',
        'Anexe documentação socioeconômica',
        'Aguarde a análise do serviço social',
      ],
      url: 'https://ptb.ifsp.edu.br/',
    ),
    Benefit(
      icon: 'award',
      title: 'Monitoria',
      tag: 'Bolsa',
      description:
          'Atue como monitor de uma disciplina, apoie colegas e receba bolsa mensal.',
      steps: [
        'Tenha bom desempenho na disciplina',
        'Inscreva-se no edital de monitoria',
        'Passe pela seleção do docente',
      ],
      url: 'https://ptb.ifsp.edu.br/',
    ),
    Benefit(
      icon: 'book',
      title: 'Iniciação Científica',
      tag: 'Pesquisa',
      description:
          'Desenvolva pesquisa orientada por um docente com bolsa PIBIC/PIBITI.',
      steps: [
        'Procure um orientador',
        'Submeta o projeto ao edital',
        'Apresente no congresso de IC',
      ],
      url: 'https://ptb.ifsp.edu.br/',
    ),
    Benefit(
      icon: 'globe',
      title: 'Projeto de Extensão',
      tag: 'Comunidade',
      description:
          'Participe de ações que conectam o campus à comunidade, com bolsa de extensão.',
      steps: [
        'Escolha um projeto ativo',
        'Inscreva-se com o coordenador',
        'Cumpra a carga horária',
      ],
      url: 'https://ptb.ifsp.edu.br/',
    ),
  ];

  // ── Testimonials ──────────────────────────────────────────────────────────
  @override
  List<Testimonial> testimonials() => const [
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
  @override
  List<Faq> faqs() => const [
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

  // ── IFSP Info ─────────────────────────────────────────────────────────────
  @override
  List<IfspInfo> ifspInfo() => const [
        IfspInfo(
          key: 'historia',
          icon: 'book',
          title: 'História',
          subtitle: 'Fundado em 1909, mais de um século de educação pública',
        ),
        IfspInfo(
          key: 'endereco',
          icon: 'pin',
          title: 'Endereço',
          subtitle: 'Av. Mutinga, 951 — Pirituba, São Paulo/SP',
        ),
        IfspInfo(
          key: 'horario',
          icon: 'clock',
          title: 'Horário de funcionamento',
          subtitle: 'Seg a Sex · 08h às 22h',
        ),
        IfspInfo(
          key: 'estrutura',
          icon: 'institution',
          title: 'Estrutura',
          subtitle: 'Laboratórios, biblioteca, quadra e auditório',
        ),
        IfspInfo(
          key: 'contatos',
          icon: 'phone',
          title: 'Contatos',
          subtitle: '(11) 3596-7700 · cmp@ifsp.edu.br',
        ),
        IfspInfo(
          key: 'site',
          icon: 'globe',
          title: 'Site oficial',
          subtitle: 'ptb.ifsp.edu.br',
        ),
      ];

  @override
  IfspDetail? ifspDetail(String key) => _details[key];

  static final Map<String, IfspDetail> _details = {
    'historia': const IfspDetail(
      key: 'historia',
      icon: 'book',
      title: 'História',
      body:
          'A Rede Federal de Educação nasceu em 1909, com as Escolas de Aprendizes Artífices. O IFSP é herdeiro dessa tradição centenária de ensino público, gratuito e de qualidade.\n\nO Campus Pirituba integra essa rede na Zona Noroeste de São Paulo, oferecendo cursos técnicos, de graduação e de pós-graduação, com forte ligação à comunidade local por meio de projetos de ensino, pesquisa e extensão.',
    ),
    'endereco': const IfspDetail(
      key: 'endereco',
      icon: 'pin',
      title: 'Endereço',
      body: 'Av. Mutinga, 951 — Pirituba\nSão Paulo / SP · CEP 02610-002',
    ),
    'horario': const IfspDetail(
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
    'estrutura': const IfspDetail(
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
    'contatos': const IfspDetail(
      key: 'contatos',
      icon: 'phone',
      title: 'Contatos',
      rows: [
        ('Telefone', '(11) 3596-7700'),
        ('E-mail', 'cmp@ifsp.edu.br'),
        ('Endereço', 'Av. Mutinga, 951 — Pirituba'),
      ],
    ),
    'site': const IfspDetail(
      key: 'site',
      icon: 'globe',
      title: 'Site oficial',
      rows: [
        ('Portal do campus', 'ptb.ifsp.edu.br'),
        ('Notícias e editais', 'ptb.ifsp.edu.br/noticias'),
        ('Sistema acadêmico (SUAP)', 'suap.ifsp.edu.br'),
      ],
    ),
  };

  // ── Internships ───────────────────────────────────────────────────────────
  static final List<Internship> _internships = [
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
  static final List<Contest> _contests = [
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

  // ── Query methods ─────────────────────────────────────────────────────────
  @override
  List<Internship> internships({
    String courseFilter = 'Todos',
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    return _internships
        .where((e) => e.visibleAt(ref))
        .where((e) => courseFilter == 'Todos' || e.course == courseFilter)
        .toList();
  }

  /// Retorna a vaga pelo id, independentemente da visibilidade (para deep-links).
  @override
  Internship? internship(String id) {
    final m = _internships.where((e) => e.id == id);
    return m.isEmpty ? null : m.first;
  }

  @override
  List<Contest> contests({DateTime? now}) {
    final ref = now ?? DateTime.now();
    return _contests.where((c) => c.visibleAt(ref)).toList();
  }

  /// Retorna o concurso pelo id, independentemente da visibilidade (para deep-links).
  @override
  Contest? contest(String id) {
    final m = _contests.where((c) => c.id == id);
    return m.isEmpty ? null : m.first;
  }
}
