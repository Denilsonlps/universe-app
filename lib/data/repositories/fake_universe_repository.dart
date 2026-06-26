import '../models/course.dart';
import '../models/internship.dart';
import '../models/contest.dart';
import '../models/testimonial.dart';
import '../models/faq.dart';
import '../models/ifsp_info.dart';
import '../models/content_doc.dart';
import '../models/news.dart';
import '../models/vaga_sugerida.dart';
import '../models/noticia_sugerida.dart';
import '../models/app_notification.dart';
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
      about: 'Objetivo geral\n\n'
          'O Curso Superior de Tecnologia em Análise e Desenvolvimento de Sistemas tem por objetivo '
          'desenvolver as habilidades do estudante para atuar na área de Tecnologia da Informação, '
          'tendo como referência os conhecimentos mais importantes da atividade profissional, e promover '
          'o desenvolvimento de competências de raciocínio, objetividade e iniciativa, além de estimular '
          'a cidadania e a responsabilidade social com espírito crítico, ético, inovador e empreendedor.\n\n'
          'Competências e habilidades\n\n'
          '• Analisar, projetar, desenvolver, testar, implantar e manter sistemas computacionais de informação;\n'
          '• Avaliar, selecionar, especificar e utilizar metodologias, tecnologias e ferramentas da Engenharia '
          'de Software, linguagens de programação e bancos de dados;\n'
          '• Coordenar equipes de produção de software;\n'
          '• Vistoriar, realizar perícia, avaliar e emitir laudo e parecer técnico em sua área de formação.',
      research: 'A pesquisa científica faz parte da cultura acadêmica do IFSP, com projetos desenvolvidos por '
          'servidores(as) e estudantes. O principal grupo de pesquisa do curso de ADS é o GITES.\n\n'
          'GITES — Grupo de Informática e Tecnologia em Educação e Sociedade\n\n'
          'O GITES promove estudos, discussões e pesquisas focados em pesquisa e inovação tecnológica e no '
          'aprimoramento de conhecimentos em informática e TIC no contexto da educação e da sociedade. Linhas '
          'de pesquisa: educação a distância, algoritmos e programação, análise e mineração de dados, robótica, '
          'aprendizagem de máquina, e gestão, análise e segurança de dados e informação.',
      researchUrl: 'https://dgp.cnpq.br/dgp/espelhogrupo/7528238432160652',
      curriculumUrl: 'https://drive.ifsp.edu.br/s/CS3ah4zmKiNCYTy',
      ppcUrl: 'https://cursos.ifsp.edu.br/graduacao/curso/PTB130200/',
    ),
    Course(
      name: 'Gestão Pública',
      category: 'Graduação',
      type: 'Tecnólogo',
      duration: '2,5 anos',
      period: 'Noturno',
      icon: 'institution',
      about: 'Objetivo geral\n\n'
          'O Curso Superior de Tecnologia em Gestão Pública tem como objetivo formar profissionais aptos a '
          'atuar de maneira efetiva, transparente e participativa na gestão de órgãos e entidades da '
          'Administração Direta e Indireta das diferentes esferas de governo, contribuindo para a melhoria '
          'da qualidade dos serviços públicos prestados à sociedade, bem como atuar em empresas privadas que '
          'demandam profissionais com estas características.\n\n'
          'Competências e habilidades\n\n'
          '• Diagnosticar o cenário político, econômico, social e legal da gestão pública;\n'
          '• Desenvolver e aplicar inovações científico-tecnológicas nos processos de gestão pública;\n'
          '• Planejar, implantar, supervisionar e avaliar projetos e programas de políticas públicas voltados ao desenvolvimento local e regional;\n'
          '• Aplicar metodologias inovadoras de gestão, baseadas nos princípios da administração pública, legislação vigente e ética profissional;\n'
          '• Planejar e implantar ações vinculadas à prestação de serviços públicos;\n'
          '• Avaliar e emitir parecer técnico em sua área de formação.',
      researchUrl: 'https://drive.ifsp.edu.br/s/3SL4sdji1xy9mgB',
      curriculumUrl: 'https://drive.ifsp.edu.br/s/DbRVXWiCXF887tq',
      ppcUrl: 'https://cursos.ifsp.edu.br/graduacao/curso/PTB130000/',
    ),
    Course(
      name: 'Letras — Português / Inglês',
      category: 'Graduação',
      type: 'Licenciatura',
      duration: '4 anos',
      period: 'Noturno',
      icon: 'book',
      researchUrl: 'https://drive.ifsp.edu.br/s/YTcEjKGS0krEV0B',
      curriculumUrl: 'https://drive.ifsp.edu.br/s/BJ5aZCTZEFx6cTH',
      ppcUrl: 'https://cursos.ifsp.edu.br/campus/PTB',
    ),
    Course(
      name: 'Engenharia de Produção',
      category: 'Graduação',
      type: 'Bacharelado',
      duration: '5 anos',
      period: 'Integral',
      icon: 'settings',
      about: 'Objetivo geral\n\n'
          'O curso de Engenharia de Produção do Câmpus São Paulo Pirituba visa formar um profissional com '
          'sólida formação técnico-científica, visão sistêmica e generalista, capaz de transformar a realidade '
          'por meio da solução de problemas — projetando, implantando, readequando e gerenciando sistemas '
          'produtivos de bens ou serviços, com busca contínua por melhoria e respeito aos fatores econômicos, '
          'ao elemento humano, ao meio ambiente e aos contextos sociais, políticos e culturais.\n\n'
          'Competências e habilidades\n\n'
          '• Formular e conceber soluções de engenharia, compreendendo os usuários e seu contexto;\n'
          '• Analisar e compreender fenômenos físicos e químicos por meio de modelos validados por experimentação;\n'
          '• Conceber, projetar e analisar sistemas, produtos (bens e serviços), componentes ou processos;\n'
          '• Implantar, supervisionar e controlar as soluções de Engenharia;\n'
          '• Comunicar-se eficazmente nas formas escrita, oral e gráfica;\n'
          '• Trabalhar e liderar equipes multidisciplinares.',
      research: 'A Extensão no IFSP promove a interação transformadora entre a comunidade acadêmica e a '
          'sociedade. No Câmpus Pirituba, destacam-se iniciativas como a concepção de uma Incubadora de '
          'Inovação, a criação de uma Empresa Júnior e projetos como o Programa Mulheres do IFSP.\n\n'
          'Na pesquisa, estudantes de Engenharia de Produção têm acesso a programas de iniciação científica e '
          'podem atuar em grupos interdisciplinares, como AMBIENTEC, GETS, NEOGEP, GITES e SONAED.',
      researchUrl: 'https://drive.google.com/file/d/1LOqJB2cRKGBv_iY2VYVaGQ_TpJa5GwIt/view',
      curriculumUrl: 'https://drive.google.com/file/d/1KIEafQRje36V9XfVe0OTJst-nuDGOxCs/view',
      ppcUrl: 'https://cursos.ifsp.edu.br/campus/PTB',
    ),
    Course(
      name: 'Administração',
      category: 'Técnico',
      type: 'Integrado ao Médio',
      duration: '3 anos',
      period: 'Matutino',
      icon: 'briefcase',
      about: 'Objetivo geral\n\n'
          'O Técnico em Administração articula competências técnicas e conhecimentos historicamente '
          'construídos a valores estéticos, éticos, políticos, culturais, científicos e tecnológicos. '
          'Forma um profissional cidadão, preparado para refletir sobre questões sociais, orientado pelo '
          'respeito à diversidade, à inclusão social, ao meio ambiente e aos direitos humanos.\n\n'
          'Competências e habilidades\n\n'
          '• Atuar na área administrativa de forma ética, inovadora e conforme a legislação, unindo teoria e prática;\n'
          '• Desenvolver autonomia intelectual, pensamento crítico e protagonismo no aprendizado;\n'
          '• Aplicar gestão organizacional, análise de indicadores, tomada de decisão e comportamento empreendedor;\n'
          '• Compreender a sociedade e promover práticas inclusivas alinhadas aos direitos humanos;\n'
          '• Preparar-se para o mundo do trabalho com responsabilidade social e ambiental;\n'
          '• Ler, produzir textos e usar múltiplas linguagens com senso crítico.',
      researchUrl: 'https://drive.ifsp.edu.br/s/OVUCAUUaO9nSrZr',
      curriculumUrl: 'https://drive.ifsp.edu.br/s/xCA3fbWjLLWC1WL',
      ppcUrl: 'https://cursos.ifsp.edu.br/campus/PTB',
    ),
    Course(
      name: 'Redes de Computadores',
      category: 'Técnico',
      type: 'Concomitante',
      duration: '2 anos',
      period: 'Vespertino',
      icon: 'globe',
      about: 'Objetivo geral\n\n'
          'O curso técnico em Redes de Computadores visa formar profissionais capazes de planejar, implementar, '
          'gerenciar e manter ambientes de TI com redes de computadores de forma confiável, robusta e organizada. '
          'O curso articula competências técnicas, éticas e socioambientais, promovendo o pensamento crítico, o '
          'protagonismo e a criatividade, e integrando ensino, pesquisa e extensão.\n\n'
          'Competências e habilidades\n\n'
          '• Projetar, implementar e gerenciar redes seguindo normas técnicas, com confiabilidade, disponibilidade e segurança;\n'
          '• Definir e implementar políticas de segurança e de acesso a dados;\n'
          '• Configurar e manter dispositivos ativos e passivos e dominar protocolos de comunicação;\n'
          '• Aplicar pensamento crítico e raciocínio lógico na solução de problemas;\n'
          '• Integrar fundamentos científicos e tecnológicos relacionando teoria e prática;\n'
          '• Atuar com autonomia, empreendedorismo e preparo para o mercado de trabalho.',
      researchUrl: 'https://drive.ifsp.edu.br/s/Mtk2SrW7fgyhTDv',
      curriculumUrl: 'https://drive.ifsp.edu.br/s/iB9ck3VC90moQto',
      ppcUrl: 'https://cursos.ifsp.edu.br/campus/PTB',
    ),
    Course(
      name: 'Logística',
      category: 'Técnico',
      type: 'Subsequente',
      duration: '1,5 ano',
      period: 'Noturno',
      icon: 'bus',
      about: 'Objetivo geral\n\n'
          'O Curso Técnico em Logística tem como objetivo formar profissionais e cidadãos técnicos de nível '
          'médio competentes técnica, ética e politicamente, com elevado grau de responsabilidade social, '
          'capazes de saber, saber fazer e gerenciar atividades e aspectos organizacionais e humanos, '
          'visando à produção de bens, serviços e conhecimentos.\n\n'
          'Competências e habilidades\n\n'
          '• Planejar, programar, operar e controlar funções logísticas nas organizações;\n'
          '• Integrar educação básica e profissional com atuação ética e sustentável;\n'
          '• Usar criticamente as tecnologias de informação e comunicação;\n'
          '• Respeitar direitos humanos, inclusão social e diversidade;\n'
          '• Dominar a linguagem matemática aplicada à logística;\n'
          '• Manter relações éticas e criativas com fornecedores, clientes e setores internos.',
      researchUrl: 'https://drive.google.com/file/d/1hhKftSo4jXmjcUDHhf4Btlca3zdqsovq/view',
      curriculumUrl: 'https://drive.google.com/file/d/1_b4GQTJwYgH3SwqdeVAc5QcD-RIB2jTZ/view',
      ppcUrl: 'https://cursos.ifsp.edu.br/campus/PTB',
    ),
    Course(
      name: 'PROEJA — Administração',
      category: 'Técnico',
      type: 'EJA Integrado',
      duration: '3 anos',
      period: 'Noturno',
      icon: 'flag',
      about: 'Objetivo geral\n\n'
          'O principal objetivo do curso é o resgate da cidadania do público de jovens e adultos, a partir do '
          'reconhecimento da educação como direito e da articulação entre formação geral e formação para o '
          'trabalho — especificamente para a atuação como Técnico em Administração (Resolução CNE/CEB nº 6/2012).\n\n'
          'Competências e habilidades\n\n'
          '• Flexibilizar métodos e organização para reduzir abandono e reprovação;\n'
          '• Oferecer ensino significativo, respeitando os conhecimentos prévios dos estudantes;\n'
          '• Fortalecer leitura, escrita e matemática para a aprendizagem contínua;\n'
          '• Capacitar para a atuação como técnico em Administração, com foco no arranjo produtivo local;\n'
          '• Integrar disciplinas técnicas e comuns com ênfase na interdisciplinaridade;\n'
          '• Valorizar conhecimentos prévios, estimulando autoestima, pensamento crítico e cidadania.',
      researchUrl: 'https://drive.google.com/file/d/10ZyW8FFzldpSlR14CAYtfrXq0poDnjji/view',
      curriculumUrl: 'https://drive.google.com/file/d/1gL2YzsVwXk-1jDeNcqVCMGxtY2JQmjgH/view',
      ppcUrl: 'https://cursos.ifsp.edu.br/campus/PTB',
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
      about: 'Objetivo geral\n\n'
          'A Especialização em Humanidades — Educação, Política e Sociedade é um curso presencial que oferece '
          'qualificação a licenciados e bacharéis das Ciências Humanas e áreas correlatas. Com grade '
          'multidisciplinar, busca uma formação abrangente e atualizada, ampliando o capital cultural dos '
          'pós-graduandos com base no debate acadêmico contemporâneo.\n\n'
          'Competências e habilidades\n\n'
          '• Formar a partir de uma perspectiva crítica e plural da sociedade contemporânea;\n'
          '• Compreender o percurso histórico do último século e seus dilemas políticos, sociais e culturais;\n'
          '• Avaliar as relações de poder nas diversas esferas da vida social;\n'
          '• Apoiar licenciados no aprimoramento da atividade docente;\n'
          '• Envolver os estudantes com a pesquisa acadêmica e a publicação científica.',
      curriculumUrl: 'https://drive.ifsp.edu.br/s/qb7AGLXfExwwgRF',
      ppcUrl: 'https://cursos.ifsp.edu.br/campus/PTB',
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
      subtitle: 'Campus do Plano de Expansão da Rede Federal · 2016',
      detail: IfspDetail(
        key: 'historia',
        icon: 'book',
        title: 'História',
        body:
            'O Campus Pirituba (PTB) faz parte do Plano de Expansão da Rede Federal de Educação Profissional e Tecnológica. Está localizado na região noroeste do município de São Paulo do Estado de São Paulo que abrange as regiões de Pirituba, Jaraguá, São Domingos, Freguesia do Ó, Vila Brasilândia, Anhanguera e Perus, englobando cerca de 1 milhão de habitantes. A abrangência do Campus se estende também para os municípios vizinhos de Caieiras, Osasco e Barueri.\n\nO Campus Pirituba foi instalado em um terreno de aproximadamente 67.297,31 metros quadrados. Este terreno foi concessão administrativa de uso por 90 anos, a título gratuito, pela Prefeitura do Município de São Paulo através da Lei Municipal nº 15.686 de 26 de março de 2013, editada no processo administrativo nº 2012-0.272.628-0.\n\nPara a definição dos eixos tecnológicos do campus foi determinado a realização de quatro audiências públicas, sendo que as três primeiras audiências seriam para a consulta pública e a última para dar um retorno e divulgar os eixos tecnológicos e os cursos definidos. As três primeiras audiências públicas que definiram os eixos tecnológicos do Campus foram realizadas em 14 e 28 de novembro de 2015 nos bairros de Pirituba e Perus, respectivamente e a terceira foi realizada em 12 de dezembro de 2015, no bairro da Brasilândia. A última audiência pública, com o objetivo de divulgar o resultado final das audiências à população do entorno do Campus Pirituba, foi realizada em 25 de junho de 2016 no próprio campus.',
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
      subtitle: 'Seg a Sex · 07h às 22h30',
      detail: IfspDetail(
        key: 'horario',
        icon: 'clock',
        title: 'Horário de funcionamento',
        body: 'A secretaria acadêmica atende das 10h às 12h e das 13h às 19h, em dias úteis.',
        rows: [
          ('Campus (Seg a Sex)', '07h às 22h30'),
          ('Secretaria acadêmica', '10h–12h · 13h–19h'),
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
      subtitle: '(11) 2504-0100 · ptb.ifsp.edu.br',
      detail: IfspDetail(
        key: 'contatos',
        icon: 'phone',
        title: 'Contatos',
        rows: [
          ('Telefone', '(11) 2504-0100'),
          ('Endereço', 'Av. Mutinga, 951 — Pirituba'),
          ('Site', 'ptb.ifsp.edu.br'),
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
            (label: 'gov.br — Cadastro Único', url: 'gov.br/mds/pt-br/acoes-e-programas/cadastro-unico'),
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
            'Acesse o site oficial idjovem.juventude.gov.br ou baixe o app ID Jovem (gov.br).',
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
            (label: 'ID Jovem — site oficial', url: 'idjovem.juventude.gov.br'),
            (label: 'gov.br — sobre o ID Jovem', url: 'gov.br/juventude'),
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
            (label: 'Página oficial do Enem', url: 'enem.inep.gov.br'),
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
          body: 'O Programa de Auxílio Permanência ([[PAP]]) tem como objetivo viabilizar a igualdade de oportunidades entre os estudantes e contribuir para a melhoria do desempenho acadêmico, combatendo a retenção e a evasão decorrentes de dificuldades socioeconômicas.\n\nPor meio do PAP são destinadas verbas para: auxílios Alimentação, Transporte e Moradia; apoio a estudantes pais e mães (auxílio-creche); Auxílio Saúde; e apoio didático-pedagógico.',
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
        const CalloutSection(
          variant: 'info',
          body: 'As inscrições abrem por edital da DAE/CSP do campus. Confira o edital vigente e seus anexos antes de se inscrever. Dúvidas sobre documentação? Procure o serviço social do campus — atendimento humano e confidencial.',
        ),
        SourcesSection(
          heading: 'Canais oficiais',
          items: [
            (label: 'Inscrições e informações (DAE/CSP)', url: 'ptb.ifsp.edu.br/index.php/dae/csp'),
            (label: 'Tutorial do PAP', url: 'ifsp.edu.br/tutorialpap'),
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
            (label: 'Editais — IFSP Pirituba', url: 'ptb.ifsp.edu.br/index.php/editais'),
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
        StepsSection(
          heading: 'Linha do tempo da pesquisa',
          items: [
            'Edital de IC publicado e inscrições abertas.',
            'Submissão do projeto com o orientador.',
            'Avaliação e divulgação dos selecionados.',
            'Execução da pesquisa (cerca de 12 meses) com bolsa mensal.',
            'Entrega do relatório final e apresentação no congresso de IC.',
          ],
        ),
        SourcesSection(
          heading: 'Canais oficiais',
          items: [
            (label: 'Pesquisa e Inovação — IFSP', url: 'ifsp.edu.br/pesquisa-e-inovacao'),
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
            (label: 'Extensão — IFSP', url: 'ifsp.edu.br/extensao'),
          ],
        ),
      ],
    ),
  ];

  // ── News ──────────────────────────────────────────────────────────────────
  // Instância mutável própria (igual às demais listas do Fake), iniciada a partir
  // das 3 notícias do protótipo. watch*/allNews leem desta mesma lista.
  final List<News> _news = List.of(_seedNews);

  // 3 notícias do protótipo — fonte das notícias iniciais (e do seeder).
  static final List<News> _seedNews = [
    News(
      id: 'n1', category: 'SiSU', source: 'MEC', readTime: '2 min',
      title: 'Sisu+ 2026: MEC libera consulta às vagas da etapa complementar',
      summary: 'Nova etapa do SiSU permite consultar antecipadamente as vagas remanescentes para ingresso no 2º semestre.',
      body: 'O Ministério da Educação liberou a consulta às vagas do [[Sisu+]], uma etapa complementar do [[SiSU]] criada para preencher vagas que ficaram remanescentes nas instituições públicas após as chamadas regulares.\n\nPela ferramenta do Portal de Acesso Único, é possível pesquisar cursos, instituições, municípios, turnos e modalidades de concorrência antes da abertura das inscrições — o que ajuda a planejar as escolhas com calma.\n\nO objetivo do programa é ampliar o acesso ao ensino superior público e reduzir o número de vagas que ficam ociosas ao longo do ano letivo.',
      date: DateTime(2026, 6, 8), published: true, pinned: true,
      facts: const [(label: 'Inscrições', value: '15 a 19 de junho'), (label: 'Resultado', value: '24 de junho'), (label: 'Ingresso', value: '2º semestre de 2026')],
      sourceUrl: 'gov.br/mec',
    ),
    News(
      id: 'n2', category: 'SiSU', source: 'G1', readTime: '2 min',
      title: 'Universidades públicas oferecem mais de 1.700 vagas pelo Sisu+',
      summary: 'Estados divulgam a oferta de vagas remanescentes; quem concorreu na etapa regular pode se inscrever.',
      body: 'Com a abertura do [[Sisu+]], instituições públicas em diferentes estados divulgaram suas vagas remanescentes — em alguns estados, passando de 1.700 oportunidades em universidades e institutos.\n\nPodem se inscrever os estudantes que fizeram o [[Enem]] em uma das últimas três edições e que concorreram na etapa regular do [[SiSU]] 2026. O sistema considera automaticamente a edição do Enem com a melhor média ponderada para cada curso escolhido.\n\nNa inscrição, é possível escolher até duas opções de curso, definindo uma ordem de preferência.',
      date: DateTime(2026, 6, 15), published: true,
      facts: const [(label: 'Vagas (exemplo)', value: '+1.700 em um estado'), (label: 'Quem pode', value: 'Quem concorreu no SiSU regular'), (label: 'Opções', value: 'Até 2 cursos')],
      sourceUrl: 'g1.globo.com',
    ),
    News(
      id: 'n3', category: 'Campus', source: 'IFSP Pirituba', readTime: '1 min',
      title: 'PAP: inscrições abertas para o auxílio permanência',
      summary: 'Edital de assistência estudantil do campus está com inscrições abertas pelo SUAP.',
      body: 'O campus abriu o edital do [[PAP]] — Programa de Auxílio Permanência. Estudantes em situação de vulnerabilidade podem solicitar apoio financeiro para moradia, alimentação e transporte.\n\nA inscrição é feita pelo sistema acadêmico (SUAP), com envio da documentação socioeconômica. Em caso de dúvida sobre os documentos, procure o serviço social do campus.',
      date: DateTime(2026, 6, 11), published: true,
      facts: const [(label: 'Onde', value: 'SUAP'), (label: 'Apoio', value: 'Moradia, alimentação, transporte')],
      sourceUrl: 'ptb.ifsp.edu.br',
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

  @override
  Stream<List<News>> watchPublishedNews() {
    final list = _news.where((n) => n.published).toList();
    list.sort((a, b) { if (a.pinned != b.pinned) return a.pinned ? -1 : 1; return b.date.compareTo(a.date); });
    return Stream.value(list);
  }
  @override
  Stream<List<News>> watchAllNews() {
    final list = List.of(_news)..sort((a, b) => b.date.compareTo(a.date));
    return Stream.value(list);
  }
  @override
  Future<void> upsertNews(News n) async {
    final i = _news.indexWhere((e) => e.id == n.id);
    if (i >= 0) { _news[i] = n; } else { _news.add(n); }
  }
  @override
  Future<void> deleteNews(String id) async => _news.removeWhere((e) => e.id == id);

  // ── Vagas sugeridas (pipeline) ──────────────────────────────────────────────
  static final List<VagaSugerida> _seedSugeridas = [
    VagaSugerida(
      id: 'sug-exemplo-1',
      scrapedAt: DateTime(2026, 6, 20), source: 'gupy-auto',
      vaga: const Internship(
        id: 'sug-exemplo-1', role: 'Estágio em Front-end', companyName: 'TechCorp',
        area: 'Tecnologia da Informação', duration: '6h/dia · 12 meses',
        jobDescription: 'Desenvolvimento de interfaces web com foco em acessibilidade.',
        requirements: ['Cursando ADS', 'HTML, CSS e JS', 'Git'],
        niceToHave: ['React', 'Figma'], companyDescription: 'Software house de SP.',
        benefits: ['Vale-transporte', 'Vale-refeição'], grant: 'R\$ 1.200',
        course: 'ADS', mode: 'Híbrido', link: 'https://portal.gupy.io/job/exemplo-1'),
    ),
    VagaSugerida(
      id: 'sug-exemplo-2',
      scrapedAt: DateTime(2026, 6, 21), source: 'gupy-auto',
      vaga: const Internship(
        id: 'sug-exemplo-2', role: 'Estágio em Logística', companyName: 'TransLog',
        area: 'Operações', duration: '6h/dia · 12 meses',
        jobDescription: 'Apoio ao controle de estoque e roteirização.',
        requirements: ['Cursando Logística', 'Excel intermediário'],
        niceToHave: ['WMS'], companyDescription: 'Operadora logística.',
        benefits: ['Vale-transporte'], grant: 'R\$ 1.050',
        course: 'Logística', mode: 'Presencial', link: 'https://portal.gupy.io/job/exemplo-2'),
    ),
  ];
  final List<VagaSugerida> _vagasSugeridas = List.of(_seedSugeridas);

  @override
  Stream<List<VagaSugerida>> watchVagasSugeridas() {
    final list = _vagasSugeridas.where((v) => v.status == 'pendente').toList()
      ..sort((a, b) => b.scrapedAt.compareTo(a.scrapedAt));
    return Stream.value(list);
  }
  @override
  Future<void> rejeitarVagaSugerida(String id) async {
    final i = _vagasSugeridas.indexWhere((v) => v.id == id);
    if (i >= 0) {
      final old = _vagasSugeridas[i];
      _vagasSugeridas[i] = VagaSugerida(id: old.id, vaga: old.vaga, scrapedAt: old.scrapedAt, source: old.source, status: 'recusada');
    }
  }
  @override
  Future<void> deleteVagaSugerida(String id) async => _vagasSugeridas.removeWhere((v) => v.id == id);

  /// Usado por testes/seed para inserir sugestões.
  Future<void> upsertVagaSugerida(VagaSugerida v) async {
    final i = _vagasSugeridas.indexWhere((e) => e.id == v.id);
    if (i >= 0) { _vagasSugeridas[i] = v; } else { _vagasSugeridas.add(v); }
  }
  List<VagaSugerida> get allVagasSugeridas => _vagasSugeridas;

  // ── Notícias sugeridas (pipeline) ───────────────────────────────────────────
  static final List<NoticiaSugerida> _seedNoticiasSugeridas = [
    NoticiaSugerida(
      id: 'noticia-sug-1', scrapedAt: DateTime(2026, 6, 22),
      noticia: News(
        id: 'noticia-sug-1', category: 'SiSU', source: 'G1', readTime: '1 min',
        title: 'Sisu+: prazo de inscrição encerra nesta sexta', summary: 'Etapa complementar do SiSU recebe inscrições até sexta-feira.',
        body: 'Etapa complementar do SiSU recebe inscrições até sexta-feira.', date: DateTime(2026, 6, 22),
        facts: const [], sourceUrl: 'https://g1.globo.com/educacao/exemplo-1', published: false),
    ),
    NoticiaSugerida(
      id: 'noticia-sug-2', scrapedAt: DateTime(2026, 6, 21),
      noticia: News(
        id: 'noticia-sug-2', category: 'Concurso', source: 'PCI Concursos', readTime: '1 min',
        title: 'Concurso abre vagas de nível médio e superior', summary: 'Edital prevê vagas com salários de até R\$ 6 mil; inscrições abertas.',
        body: 'Edital prevê vagas com salários de até R\$ 6 mil; inscrições abertas.', date: DateTime(2026, 6, 21),
        facts: const [], sourceUrl: 'https://www.pciconcursos.com.br/exemplo-2', published: false),
    ),
  ];
  final List<NoticiaSugerida> _noticiasSugeridas = List.of(_seedNoticiasSugeridas);

  @override
  Stream<List<NoticiaSugerida>> watchNoticiasSugeridas() {
    final list = _noticiasSugeridas.where((n) => n.status == 'pendente').toList()
      ..sort((a, b) => b.scrapedAt.compareTo(a.scrapedAt));
    return Stream.value(list);
  }
  @override
  Future<void> rejeitarNoticiaSugerida(String id) async {
    final i = _noticiasSugeridas.indexWhere((n) => n.id == id);
    if (i >= 0) {
      final old = _noticiasSugeridas[i];
      _noticiasSugeridas[i] = NoticiaSugerida(id: old.id, noticia: old.noticia, scrapedAt: old.scrapedAt, status: 'recusada');
    }
  }
  @override
  Future<void> deleteNoticiaSugerida(String id) async => _noticiasSugeridas.removeWhere((n) => n.id == id);

  /// Usado por testes/seed para inserir sugestões de notícia.
  Future<void> upsertNoticiaSugerida(NoticiaSugerida n) async {
    final i = _noticiasSugeridas.indexWhere((e) => e.id == n.id);
    if (i >= 0) { _noticiasSugeridas[i] = n; } else { _noticiasSugeridas.add(n); }
  }
  List<NoticiaSugerida> get allNoticiasSugeridas => _noticiasSugeridas;

  // ── Notificações ────────────────────────────────────────────────────────────
  static final List<AppNotification> _seedNotifications = [
    AppNotification(
      id: 'notif-1', type: 'vaga', targetCourse: 'ADS',
      title: 'Nova vaga para ADS', body: 'Estágio em Front-end na TechCorp · R\$ 1.200',
      route: '/estagio', createdAt: DateTime(2026, 6, 24, 9)),
    AppNotification(
      id: 'notif-2', type: 'noticia',
      title: 'Sisu+ 2026', body: 'MEC libera consulta às vagas da etapa complementar.',
      route: '/noticias', createdAt: DateTime(2026, 6, 23, 14)),
  ];
  final List<AppNotification> _notifications = List.of(_seedNotifications);

  @override
  Stream<List<AppNotification>> watchNotifications() {
    final list = List.of(_notifications)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Stream.value(list);
  }
  @override
  Future<void> addNotification(AppNotification n) async => _notifications.insert(0, n);
  List<AppNotification> get allNotifications => _notifications;

  // Getters para o seeder lerem todo o conteúdo bruto:
  List<Course> get allCourses => _courses;
  List<Internship> get allInternships => _internships;
  List<Contest> get allContests => _contests;
  List<Testimonial> get allTestimonials => _testimonials;
  List<Faq> get allFaqs => _faqs;
  List<IfspInfo> get allIfspInfo => _ifspInfo;
  List<ContentDoc> get allContentDocs => _contentDocs;
  // Getter para o seeder: retorna as notícias atuais do Fake.
  List<News> get allNews => _news;
}
