import '../models/course_model.dart';
import '../models/internship_model.dart';
import '../models/contest_model.dart';
import '../models/benefit_model.dart';
import '../models/faq_model.dart';
import '../models/testimonial_model.dart';

abstract final class MockRepository {
  // ── Courses ─────────────────────────────────────────────────────────────────

  static List<CourseModel> get courses => [
        const CourseModel(
          id: 'ads',
          name: 'Análise e Desenvolvimento de Sistemas',
          level: CourseLevel.tecnologo,
          duration: '3 anos',
          shift: CourseShift.noturno,
          description:
              'Forma profissionais capazes de analisar, projetar e implementar sistemas computacionais, com ênfase em desenvolvimento de software, banco de dados e engenharia de software.',
          tags: ['TI', 'Programação', 'Sistemas'],
        ),
        const CourseModel(
          id: 'gestao-publica',
          name: 'Gestão Pública',
          level: CourseLevel.tecnologo,
          duration: '2,5 anos',
          shift: CourseShift.noturno,
          description:
              'Prepara profissionais para atuar na gestão de órgãos e entidades públicas, com foco em administração, políticas públicas e gestão de recursos.',
          tags: ['Gestão', 'Público', 'Administração'],
        ),
        const CourseModel(
          id: 'letras',
          name: 'Letras',
          level: CourseLevel.licenciatura,
          duration: '4 anos',
          shift: CourseShift.noturno,
          description:
              'Licenciatura voltada para a formação de professores de língua portuguesa e literatura, com base em estudos linguísticos e literários.',
          tags: ['Educação', 'Linguagens', 'Literatura'],
        ),
        const CourseModel(
          id: 'eng-producao',
          name: 'Engenharia de Produção',
          level: CourseLevel.bacharelado,
          duration: '5 anos',
          shift: CourseShift.integral,
          description:
              'Forma engenheiros capazes de projetar, implantar e gerenciar sistemas de produção de bens e serviços, com foco em qualidade, eficiência e inovação.',
          tags: ['Engenharia', 'Produção', 'Qualidade'],
        ),
        const CourseModel(
          id: 'administracao-tec',
          name: 'Administração',
          level: CourseLevel.tecnicoIntegrado,
          duration: '3 anos',
          shift: CourseShift.matutino,
          description:
              'Curso técnico integrado ao ensino médio, com formação completa em gestão empresarial, recursos humanos, marketing e finanças.',
          tags: ['Técnico', 'Administração', 'Gestão'],
        ),
        const CourseModel(
          id: 'redes',
          name: 'Redes de Computadores',
          level: CourseLevel.tecnicoConcomitante,
          duration: '2 anos',
          shift: CourseShift.vespertino,
          description:
              'Forma técnicos aptos a instalar, configurar e gerenciar redes de computadores, garantindo segurança e disponibilidade dos sistemas.',
          tags: ['Técnico', 'Redes', 'TI'],
        ),
        const CourseModel(
          id: 'logistica',
          name: 'Logística',
          level: CourseLevel.tecnicoSubsequente,
          duration: '1,5 ano',
          shift: CourseShift.noturno,
          description:
              'Prepara profissionais para planejar, executar e controlar operações logísticas, abrangendo transporte, armazenagem e cadeia de suprimentos.',
          tags: ['Técnico', 'Logística', 'Cadeia'],
        ),
        const CourseModel(
          id: 'proeja-admin',
          name: 'Administração (PROEJA)',
          level: CourseLevel.proeja,
          duration: '3 anos',
          shift: CourseShift.noturno,
          description:
              'Educação de Jovens e Adultos integrada ao ensino médio, com qualificação em administração para estudantes que retomam os estudos.',
          tags: ['EJA', 'Administração', 'Inclusão'],
        ),
        const CourseModel(
          id: 'gestao-projetos',
          name: 'Gestão de Projetos',
          level: CourseLevel.especializacao,
          duration: '1,5 ano',
          shift: CourseShift.noturno,
          description:
              'Especialização voltada a profissionais que desejam aprofundar conhecimentos em metodologias de gerenciamento de projetos, como PMBOK e ágeis.',
          tags: ['Pós', 'Projetos', 'Gestão'],
        ),
        const CourseModel(
          id: 'humanidades',
          name: 'Humanidades',
          level: CourseLevel.especializacao,
          duration: '1,5 ano',
          shift: CourseShift.noturno,
          description:
              'Especialização interdisciplinar que abrange sociologia, filosofia, história e literatura, voltada à formação crítica e humanista.',
          tags: ['Pós', 'Humanidades', 'Ciências Sociais'],
        ),
      ];

  // ── Internships ─────────────────────────────────────────────────────────────

  static List<InternshipModel> get internships => [
        const InternshipModel(
          id: 'dev-web-prefeitura',
          role: 'Desenvolvedor Web',
          company: 'Prefeitura de São Paulo',
          targetCourse: 'ADS',
          stipendCents: 110000,
          modality: InternshipModality.hibrido,
          status: InternshipStatus.aberta,
          description:
              'Desenvolvimento e manutenção de sistemas web para a Secretaria Municipal de Tecnologia e Inovação. Trabalho com React, Node.js e banco de dados PostgreSQL.',
          requirements: 'Cursando ADS a partir do 2º semestre. Conhecimento em HTML, CSS e JavaScript.',
        ),
        const InternshipModel(
          id: 'suporte-ti-tjsp',
          role: 'Suporte em TI',
          company: 'TJSP',
          targetCourse: 'Redes',
          stipendCents: 100000,
          modality: InternshipModality.presencial,
          status: InternshipStatus.aberta,
          description:
              'Suporte técnico a usuários do Tribunal de Justiça, incluindo configuração de equipamentos, resolução de incidentes e manutenção de redes locais.',
          requirements: 'Cursando Redes a partir do 2º semestre. Conhecimento em Windows Server e TCP/IP.',
        ),
        const InternshipModel(
          id: 'jovem-aprendiz-bb',
          role: 'Jovem Aprendiz',
          company: 'Banco do Brasil',
          targetCourse: 'Administração',
          stipendCents: 98000,
          modality: InternshipModality.presencial,
          status: InternshipStatus.aberta,
          description:
              'Programa Jovem Aprendiz para estudantes do curso técnico de Administração. Atuação em atendimento ao cliente, análise de documentos e auxílio em processos bancários.',
          requirements: 'Cursando Técnico em Administração. Idade entre 14 e 24 anos.',
        ),
        const InternshipModel(
          id: 'logistica-correios',
          role: 'Estágio em Logística',
          company: 'Correios',
          targetCourse: 'Logística',
          stipendCents: 105000,
          modality: InternshipModality.presencial,
          status: InternshipStatus.aberta,
          description:
              'Acompanhamento e apoio às operações logísticas dos Correios, incluindo controle de estoque, rastreamento de encomendas e otimização de rotas.',
          requirements: 'Cursando Técnico em Logística. CNH desejável.',
        ),
        const InternshipModel(
          id: 'melhoria-processos-vw',
          role: 'Melhoria de Processos',
          company: 'Volkswagen',
          targetCourse: 'Engenharia de Produção',
          stipendCents: 140000,
          modality: InternshipModality.presencial,
          status: InternshipStatus.encerrada,
          description:
              'Apoio em projetos de melhoria contínua na linha de produção, utilizando metodologias Lean Manufacturing e Six Sigma.',
          requirements: 'Cursando Engenharia de Produção a partir do 4º semestre. Inglês intermediário.',
        ),
        const InternshipModel(
          id: 'gestao-publica-sec',
          role: 'Gestão Pública',
          company: 'Secretaria de Educação SP',
          targetCourse: 'Gestão Pública',
          stipendCents: 100000,
          modality: InternshipModality.hibrido,
          status: InternshipStatus.encerrada,
          description:
              'Apoio na elaboração e acompanhamento de políticas educacionais municipais, análise de indicadores e elaboração de relatórios.',
          requirements: 'Cursando Gestão Pública a partir do 2º semestre.',
        ),
      ];

  // ── Contests ────────────────────────────────────────────────────────────────

  static List<ContestModel> get contests => [
        ContestModel(
          id: 'tec-admin-ifsp',
          role: 'Técnico Administrativo',
          organization: 'IFSP Reitoria',
          vacancies: 24,
          salaryCents: 418000,
          status: ContestStatus.aberta,
          deadline: DateTime(2026, 7, 30),
          description:
              'Concurso público para provimento de vagas de Técnico Administrativo em Educação no Instituto Federal de São Paulo. Requisito: ensino médio completo.',
        ),
        ContestModel(
          id: 'agente-apoio-prefsp',
          role: 'Agente de Apoio Escolar',
          organization: 'Prefeitura de São Paulo',
          vacancies: 120,
          salaryCents: 264000,
          status: ContestStatus.aberta,
          deadline: DateTime(2026, 8, 15),
          description:
              'Processo seletivo para Agente de Apoio Escolar nas escolas municipais de São Paulo. Carga horária de 40h semanais.',
        ),
        ContestModel(
          id: 'analista-sistemas-dataprev',
          role: 'Analista de Sistemas',
          organization: 'Dataprev',
          vacancies: 40,
          salaryCents: 630000,
          status: ContestStatus.aberta,
          deadline: DateTime(2026, 8, 2),
          description:
              'Concurso nacional para Analista de Sistemas Previdenciários. Exige graduação em Ciência da Computação, Sistemas de Informação ou áreas correlatas.',
        ),
        ContestModel(
          id: 'aux-biblioteca-usp',
          role: 'Auxiliar de Biblioteca',
          organization: 'USP',
          vacancies: 8,
          salaryCents: 290000,
          status: ContestStatus.encerrada,
          description:
              'Processo seletivo para Auxiliar de Biblioteca nas unidades da Universidade de São Paulo. Requisito: ensino médio completo e conhecimento básico em informática.',
        ),
      ];

  // ── Benefits ─────────────────────────────────────────────────────────────────

  static List<BenefitModel> get benefits => [
        const BenefitModel(
          id: 'auxilio-estudantil',
          name: 'Auxílio Estudantil',
          kind: BenefitKind.gov,
          description: 'Apoio financeiro para estudantes em situação de vulnerabilidade socioeconômica matriculados no IFSP.',
          howToAccess: 'Acesse o SUAP, vá em Atividades Estudantis > Auxílios e preencha o formulário de solicitação.',
          iconName: 'account_balance_wallet',
        ),
        const BenefitModel(
          id: 'passe-livre',
          name: 'Passe Livre Estudantil',
          kind: BenefitKind.gov,
          description: 'Gratuidade no transporte público municipal para estudantes da rede pública de ensino.',
          howToAccess: 'Retire o formulário na Secretaria, preencha e entregue com documentação na Central de Mobilidade Urbana.',
          iconName: 'directions_bus',
        ),
        const BenefitModel(
          id: 'ru',
          name: 'Restaurante Universitário',
          kind: BenefitKind.inst,
          description: 'Refeições subsidiadas servidas no campus, com cardápio balanceado a preço acessível.',
          howToAccess: 'Cadastre-se na Assistência Estudantil para obter isenção ou desconto conforme renda familiar.',
          iconName: 'restaurant',
        ),
        const BenefitModel(
          id: 'bolsa-iniciacao',
          name: 'Bolsa de Iniciação Científica',
          kind: BenefitKind.inst,
          description: 'Programa de incentivo à pesquisa científica com bolsa mensal para estudantes selecionados.',
          howToAccess: 'Fique atento aos editais publicados no site do IFSP e procure um professor orientador.',
          iconName: 'science',
        ),
        const BenefitModel(
          id: 'prouni',
          name: 'ProUni',
          kind: BenefitKind.gov,
          description: 'Programa do Governo Federal que concede bolsas de estudo integrais e parciais em instituições privadas.',
          howToAccess: 'Inscreva-se pelo portal do MEC durante o período de inscrições do ENEM.',
          iconName: 'school',
        ),
        const BenefitModel(
          id: 'monitoria',
          name: 'Programa de Monitoria',
          kind: BenefitKind.inst,
          description: 'Estudantes com bom desempenho auxiliam colegas nas disciplinas, com bolsa ou horas de atividade complementar.',
          howToAccess: 'Verifique os editais de monitoria no SUAP ou com a coordenação do seu curso.',
          iconName: 'people',
        ),
      ];

  // ── FAQs ─────────────────────────────────────────────────────────────────────

  static List<FAQModel> get faqs => [
        const FAQModel(
          id: 'faq-pirituba',
          question: 'Como é viver em Pirituba?',
          answer:
              'Pirituba é uma região tranquila da Zona Noroeste de São Paulo, bem servida por transporte público (CPTM Linha 7-Rubi e diversas linhas de ônibus), comércio local e áreas verdes como o Parque da Cidade.',
          category: 'Campus',
          order: 1,
        ),
        const FAQModel(
          id: 'faq-republica',
          question: 'O campus possui república estudantil?',
          answer:
              'O campus não oferece moradia própria, mas o serviço social orienta sobre repúblicas e auxílio-moradia. Veja a seção Moradia para opções próximas e dicas.',
          category: 'Campus',
          order: 2,
        ),
        const FAQModel(
          id: 'faq-acessibilidade',
          question: 'O campus possui acessibilidade para PcD?',
          answer:
              'Sim. O campus conta com rampas, elevador, piso tátil, banheiros adaptados e o NAPNE — núcleo de apoio às pessoas com necessidades específicas.',
          category: 'Campus',
          order: 3,
        ),
        const FAQModel(
          id: 'faq-enem-sisu',
          question: 'Como utilizo minha nota do Enem no IF?',
          answer:
              'Parte das vagas das graduações é ofertada via SiSU, usando a nota do Enem. Acompanhe os editais no site e fique atento às datas de inscrição do SiSU.',
          category: 'Enem',
          order: 4,
        ),
        const FAQModel(
          id: 'faq-enem-bolsa',
          question: 'O IFSP oferece bolsa para quem entra pelo Enem?',
          answer:
              'Sim. Após a matrícula, você pode concorrer aos auxílios do PAP e demais programas de assistência estudantil, independentemente da forma de ingresso.',
          category: 'Enem',
          order: 5,
        ),
        const FAQModel(
          id: 'faq-trancamento',
          question: 'Como faço para trancar a matrícula?',
          answer:
              'O trancamento é solicitado pela Secretaria, dentro do calendário acadêmico. Procure a CRE do campus ou abra um chamado no sistema acadêmico.',
          category: 'Gerais',
          order: 6,
        ),
      ];

  // ── Testimonials ──────────────────────────────────────────────────────────────

  static List<TestimonialModel> get testimonials => [
        TestimonialModel(
          id: 'dep-ana',
          authorName: 'Ana Souza',
          authorCourse: 'ADS',
          content:
              'O estágio que consegui pelo app mudou minha vida! Em 3 meses já fui efetivada. O app me avisou quando abriu a vaga e pude me preparar com antecedência.',
          company: 'Prefeitura de SP',
          role: 'Desenvolvedora Web',
          createdAt: DateTime(2026, 3, 10),
        ),
        TestimonialModel(
          id: 'dep-carlos',
          authorName: 'Carlos Menezes',
          authorCourse: 'Engenharia de Produção',
          content:
              'Passei no concurso do IFSP Reitoria que vi aqui. A seção de concursos sempre tem oportunidades relevantes para os cursos do campus. Recomendo a todos!',
          company: 'IFSP',
          role: 'Técnico Administrativo',
          createdAt: DateTime(2026, 2, 5),
        ),
        TestimonialModel(
          id: 'dep-julia',
          authorName: 'Julia Ferreira',
          authorCourse: 'Gestão Pública',
          content:
              'Não sabia nem que existia o auxílio estudantil até ver no app. Consegui o benefício e isso fez toda a diferença para continuar estudando sem depender só da família.',
          createdAt: DateTime(2026, 4, 20),
        ),
        TestimonialModel(
          id: 'dep-rodrigo',
          authorName: 'Rodrigo Lima',
          authorCourse: 'Redes',
          content:
              'O app é super fácil de usar e tem tudo que preciso sobre o campus em um lugar só. Uso todo dia para ver notícias, calendário e as vagas de estágio.',
          createdAt: DateTime(2026, 5, 1),
        ),
      ];

  // ── Campus Info ──────────────────────────────────────────────────────────────

  static const Map<String, dynamic> campusInfo = {
    'name': 'IFSP Campus Pirituba',
    'address': 'Av. Mutinga, 951 — Pirituba, São Paulo — SP',
    'phone': '(11) 3596-7700',
    'hours': 'Segunda a Sexta: 08h às 22h\nSábado: 08h às 12h',
    'email': 'prt@ifsp.edu.br',
    'website': 'https://prt.ifsp.edu.br',
    'about':
        'O IFSP Campus Pirituba foi inaugurado em 2010 e atende a região noroeste da cidade de São Paulo. Oferece cursos técnicos, tecnológicos, de licenciatura, bacharelado e pós-graduação, com foco na formação cidadã e profissional dos estudantes.',
  };

  // ── Housing ──────────────────────────────────────────────────────────────────

  static const List<Map<String, dynamic>> republicas = [
    {
      'id': 'rep-1',
      'name': 'República Verde',
      'address': 'R. Comendador Elias Zarzur, Pirituba',
      'distance': '650m do campus',
      'priceRange': 'R\$650 – R\$900/mês',
      'rooms': 3,
      'contact': '(11) 94567-8901',
    },
    {
      'id': 'rep-2',
      'name': 'Casa dos Estudantes',
      'address': 'Av. Mutinga, Pirituba',
      'distance': '300m do campus',
      'priceRange': 'R\$700 – R\$1.000/mês',
      'rooms': 5,
      'contact': '(11) 98765-4321',
    },
    {
      'id': 'rep-3',
      'name': 'República Pirituba',
      'address': 'R. Pereira da Mota, Pirituba',
      'distance': '900m do campus',
      'priceRange': 'R\$600 – R\$850/mês',
      'rooms': 4,
      'contact': '(11) 91234-5678',
    },
  ];
}
