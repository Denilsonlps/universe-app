// data-content.jsx — rich content documents, glossary registry, news.
// Loaded BEFORE content.jsx. Exposes window.CONTENT_DOCS, window.GLOSSARY, window.NEWS_SEED.

// ── Glossary: keyword → internal target.
// { docId } → opens that content document.  { def } → opens a term definition sheet.
const GLOSSARY = {
  'Cadastro Único': { docId: 'gov-cadunico' },
  'CadÚnico': { docId: 'gov-cadunico', label: 'Cadastro Único' },
  'ID Jovem': { docId: 'gov-idjovem' },
  'Isenções': { docId: 'gov-isencoes' },
  'Transporte': { docId: 'gov-transporte' },
  'Bilhete Único': { docId: 'gov-transporte', label: 'Bilhete Único' },
  'PAP': { docId: 'inst-pap' },
  'Monitoria': { docId: 'inst-monitoria' },
  'Iniciação Científica': { docId: 'inst-ic' },
  'Extensão': { docId: 'inst-extensao' },
  'PIBIC': { docId: 'inst-ic', term: 'PIBIC', def: 'Programa Institucional de Bolsas de Iniciação Científica. Financia estudantes que desenvolvem pesquisa orientada por um docente, com bolsa mensal do CNPq ou da própria instituição.' },
  'PIBITI': { docId: 'inst-ic', term: 'PIBITI', def: 'Programa Institucional de Bolsas de Iniciação em Desenvolvimento Tecnológico e Inovação. Como o PIBIC, mas voltado a projetos de inovação e desenvolvimento tecnológico.' },
  'CRAS': { term: 'CRAS', def: 'Centro de Referência de Assistência Social. Unidade pública e gratuita onde você faz e atualiza o Cadastro Único e tem acesso a programas de assistência social. Procure o CRAS mais próximo da sua casa.' },
  'NIS': { term: 'NIS', def: 'Número de Identificação Social. Código gerado quando você entra no Cadastro Único; é ele que identifica você nos programas sociais e em pedidos de isenção de taxas.' },
  'SiSU': { term: 'SiSU', def: 'Sistema de Seleção Unificada. Plataforma do MEC que usa a nota do Enem para distribuir vagas em universidades e institutos públicos.' },
  'Sisu+': { term: 'Sisu+', def: 'Etapa complementar do SiSU criada em 2026 para preencher vagas remanescentes nas instituições públicas, com ingresso no 2º semestre.' },
  'Enem': { term: 'Enem', def: 'Exame Nacional do Ensino Médio. A nota do Enem é usada como critério de ingresso em boa parte das vagas das graduações, inclusive no IFSP via SiSU.' },
  'NAPNE': { term: 'NAPNE', def: 'Núcleo de Atendimento às Pessoas com Necessidades Específicas. Setor do campus que apoia estudantes com deficiência, garantindo acessibilidade e adaptações.' },
};

// ── helper to build a "fonte oficial" section
const officialNote = 'As informações deste app são um guia. Sempre confirme prazos e regras no canal oficial antes de solicitar.';

// ── Content documents. kind: 'gov' | 'inst'.
// section types: rich | steps | docs | media | faq | callout | sources
const CONTENT_DOCS = [
  {
    id: 'gov-cadunico', kind: 'gov', icon: 'card', title: 'Cadastro Único', tag: 'Federal',
    summary: 'A porta de entrada para os programas sociais do governo federal.',
    updated: '2026-06-10',
    sections: [
      { type: 'rich', heading: 'O que é', body: 'O [[Cadastro Único|CadÚnico]] é o registro que identifica famílias de baixa renda para os programas sociais do governo federal. É a partir dele que você acessa benefícios como o [[ID Jovem]], tarifas sociais de energia e o pedido de [[Isenções|isenção de taxas]] em concursos e no [[Enem]].\n\nAo entrar no Cadastro Único, você recebe um [[NIS]] — o número que identifica você em todos esses programas.' },
      { type: 'callout', variant: 'info', body: 'Não custa nada para se inscrever. O Cadastro Único é gratuito e feito presencialmente no [[CRAS]].' },
      { type: 'rich', heading: 'Quem pode se inscrever', body: 'Famílias com renda mensal de até meio salário mínimo por pessoa, ou de até três salários mínimos no total. Estudantes que moram sozinhos também podem fazer o seu próprio cadastro.' },
      { type: 'steps', heading: 'Como solicitar', items: [
        'Reúna documentos de todas as pessoas que moram com você (CPF ou título de eleitor do responsável).',
        'Procure o [[CRAS]] mais próximo da sua casa e leve um comprovante de residência.',
        'Um atendente fará a entrevista e registrará os dados da família.',
        'Guarde o seu [[NIS]] — você vai usá-lo em todos os benefícios.',
        'Atualize o cadastro a cada 2 anos ou sempre que algo mudar (endereço, renda, pessoas na casa).',
      ] },
      { type: 'media', mediaType: 'video', heading: 'Tutorial em vídeo', caption: 'Como fazer o Cadastro Único passo a passo (3 min)' },
      { type: 'faq', heading: 'Dúvidas frequentes', items: [
        { q: 'Preciso ir ao CRAS pessoalmente?', a: 'Sim. A inscrição inicial é presencial, mas atualizações simples podem ser feitas pelo app Cadastro Único.' },
        { q: 'Quanto tempo demora?', a: 'O registro é feito na hora da entrevista. O NIS pode levar alguns dias para ser ativado.' },
      ] },
      { type: 'sources', heading: 'Canais oficiais', items: [
        { label: 'gov.br — Cadastro Único', url: 'gov.br/cadastrounico' },
        { label: 'App Cadastro Único', url: 'play.google.com · App Store' },
      ] },
    ],
  },
  {
    id: 'gov-idjovem', kind: 'gov', icon: 'user', title: 'ID Jovem', tag: '15–29 anos',
    summary: 'Meia-entrada e transporte interestadual gratuito ou com desconto para jovens de baixa renda.',
    updated: '2026-06-05',
    sections: [
      { type: 'rich', heading: 'O que é', body: 'A Identidade Jovem ([[ID Jovem]]) é um documento digital gratuito que garante direitos a jovens de 15 a 29 anos inscritos no [[Cadastro Único]] com renda familiar de até dois salários mínimos.' },
      { type: 'rich', heading: 'Quais são os direitos', body: 'Meia-entrada em eventos artísticos, culturais e esportivos; e vagas gratuitas ou com 50% de desconto no transporte interestadual (ônibus, trem e barco entre estados).' },
      { type: 'docs', heading: 'O que você precisa', items: ['Ter entre 15 e 29 anos', '[[Cadastro Único]] ativo e atualizado', 'Renda familiar de até 2 salários mínimos'] },
      { type: 'steps', heading: 'Como emitir', items: [
        'Garanta que seu [[Cadastro Único]] está atualizado.',
        'Baixe o aplicativo ID Jovem ou acesse o site oficial.',
        'Informe seu [[NIS]] e dados pessoais.',
        'Pronto: a carteira digital fica disponível no app para apresentar quando precisar.',
      ] },
      { type: 'media', mediaType: 'image', heading: 'Como fica a carteira', caption: 'Exemplo da carteira digital do ID Jovem' },
      { type: 'callout', variant: 'warn', body: 'Para usar no transporte interestadual, solicite a vaga com antecedência — o número de lugares com gratuidade é limitado por viagem.' },
      { type: 'sources', heading: 'Canais oficiais', items: [{ label: 'gov.br — ID Jovem', url: 'gov.br/cidadania/id-jovem' }] },
    ],
  },
  {
    id: 'gov-transporte', kind: 'gov', icon: 'bus', title: 'Transporte estudantil', tag: 'Estadual',
    summary: 'Bilhete Único Escolar e gratuidade no transporte público para estudantes matriculados.',
    updated: '2026-05-28',
    sections: [
      { type: 'rich', heading: 'O que é', body: 'O [[Bilhete Único]] Escolar dá desconto ou gratuidade no transporte público de São Paulo para estudantes regularmente matriculados. Em conjunto com o [[ID Jovem]], amplia o acesso à mobilidade para quem estuda.' },
      { type: 'steps', heading: 'Como solicitar', items: [
        'Tenha em mãos um comprovante de matrícula atualizado do campus.',
        'Faça o cadastro no site da SPTrans com foto e documento.',
        'Acompanhe a aprovação e retire o cartão no posto indicado.',
        'Recarregue mensalmente para manter o benefício ativo.',
      ] },
      { type: 'callout', variant: 'info', body: 'Precisa do comprovante de matrícula? Solicite na secretaria do campus — veja os contatos na seção IFSP Pirituba.' },
      { type: 'sources', heading: 'Canais oficiais', items: [{ label: 'SPTrans — Bilhete Único Escolar', url: 'sptrans.com.br' }] },
    ],
  },
  {
    id: 'gov-isencoes', kind: 'gov', icon: 'doc', title: 'Isenção de taxas', tag: 'Concursos e Enem',
    summary: 'Isenção da taxa de inscrição em concursos, vestibulares e no Enem.',
    updated: '2026-06-01',
    sections: [
      { type: 'rich', heading: 'O que é', body: 'Estudantes de baixa renda podem pedir [[Isenções|isenção]] da taxa de inscrição no [[Enem]], em concursos públicos e em vestibulares. O critério mais comum é estar inscrito no [[Cadastro Único]] e informar o [[NIS]].' },
      { type: 'steps', heading: 'Como solicitar', items: [
        'Fique atento ao período de pedido de isenção — costuma ser antes das inscrições.',
        'No formulário, marque a opção de isenção e informe seu [[NIS]].',
        'Envie os documentos pedidos, se houver.',
        'Acompanhe o resultado (deferido ou indeferido) e, se negado, veja se há recurso.',
      ] },
      { type: 'callout', variant: 'warn', body: 'O prazo da isenção quase sempre é mais curto que o das inscrições. Não deixe para a última hora.' },
      { type: 'faq', heading: 'Dúvidas frequentes', items: [
        { q: 'Se a isenção for negada, ainda posso me inscrever?', a: 'Sim, mas você terá que pagar a taxa dentro do prazo normal de inscrição.' },
      ] },
      { type: 'sources', heading: 'Canais oficiais', items: [{ label: 'Página oficial do Enem', url: 'gov.br/inep/enem' }] },
    ],
  },
  {
    id: 'inst-pap', kind: 'inst', icon: 'benefits', title: 'PAP — Auxílio Permanência', tag: 'Auxílio',
    summary: 'Apoio financeiro para estudantes em situação de vulnerabilidade socioeconômica.',
    updated: '2026-06-12',
    sections: [
      { type: 'rich', heading: 'O que é', body: 'O Programa de Auxílio Permanência ([[PAP]]) é uma das principais ações de assistência estudantil do IFSP. Oferece apoio financeiro para que estudantes em vulnerabilidade consigam se manter no curso, incluindo auxílio-moradia, alimentação e transporte.' },
      { type: 'docs', heading: 'Documentos para a inscrição', items: ['Documento de identidade e CPF', 'Comprovante de renda de todos da família', 'Comprovante de residência', 'Comprovante de matrícula'] },
      { type: 'steps', heading: 'Como solicitar', items: [
        'Acompanhe a abertura do edital de assistência estudantil no campus.',
        'Preencha a inscrição no sistema acadêmico (SUAP).',
        'Anexe a documentação socioeconômica solicitada.',
        'Aguarde a análise do serviço social do campus.',
        'Se aprovado, o auxílio é pago mensalmente conforme o edital.',
      ] },
      { type: 'media', mediaType: 'video', heading: 'Tutorial em vídeo', caption: 'Como se inscrever no PAP pelo SUAP (5 min)' },
      { type: 'callout', variant: 'info', body: 'Dúvidas sobre documentação? Procure o serviço social do campus — atendimento humano e confidencial.' },
      { type: 'sources', heading: 'Canais oficiais', items: [{ label: 'Assistência Estudantil — IFSP', url: 'ptb.ifsp.edu.br/assistencia' }] },
    ],
  },
  {
    id: 'inst-monitoria', kind: 'inst', icon: 'award', title: 'Monitoria', tag: 'Bolsa',
    summary: 'Apoie colegas em uma disciplina e receba bolsa mensal.',
    updated: '2026-05-20',
    sections: [
      { type: 'rich', heading: 'O que é', body: 'Na [[Monitoria]], você atua como monitor de uma disciplina em que tem bom desempenho, ajudando colegas e o docente, e recebe uma bolsa mensal. É uma ótima primeira experiência acadêmica — e conta como atividade complementar.' },
      { type: 'steps', heading: 'Como participar', items: [
        'Tenha bom desempenho na disciplina desejada.',
        'Inscreva-se quando o edital de monitoria for publicado.',
        'Passe pela seleção feita pelo docente responsável.',
        'Cumpra a carga horária combinada e receba a bolsa.',
      ] },
      { type: 'faq', heading: 'Dúvidas frequentes', items: [
        { q: 'Monitoria atrapalha os estudos?', a: 'Não. A carga horária é planejada para caber na sua rotina, geralmente algumas horas por semana.' },
      ] },
      { type: 'sources', heading: 'Canais oficiais', items: [{ label: 'Editais de ensino — IFSP', url: 'ptb.ifsp.edu.br/editais' }] },
    ],
  },
  {
    id: 'inst-ic', kind: 'inst', icon: 'book', title: 'Iniciação Científica', tag: 'Pesquisa',
    summary: 'Desenvolva pesquisa orientada por um docente, com bolsa PIBIC ou PIBITI.',
    updated: '2026-06-08',
    sections: [
      { type: 'rich', heading: 'O que é', body: 'A [[Iniciação Científica]] permite que você desenvolva um projeto de pesquisa orientado por um docente, com bolsa mensal. As duas principais modalidades são o [[PIBIC]] (pesquisa científica) e o [[PIBITI]] (inovação e tecnologia).' },
      { type: 'rich', heading: 'PIBIC e PIBITI: qual a diferença?', body: 'O [[PIBIC]] é voltado à pesquisa científica em qualquer área do conhecimento. O [[PIBITI]] foca em desenvolvimento tecnológico e inovação — protótipos, software, processos. Ambos pagam bolsa e valem como experiência acadêmica.' },
      { type: 'steps', heading: 'Como participar', items: [
        'Procure um docente da sua área para ser seu orientador.',
        'Juntos, escrevam um projeto de pesquisa.',
        'Submetam o projeto ao edital de [[PIBIC]] ou [[PIBITI]].',
        'Se aprovado, desenvolva a pesquisa e receba a bolsa.',
        'Apresente os resultados no congresso de Iniciação Científica.',
      ] },
      { type: 'media', mediaType: 'image', heading: 'Linha do tempo da pesquisa', caption: 'Do projeto ao congresso: como funciona um ano de IC' },
      { type: 'sources', heading: 'Canais oficiais', items: [{ label: 'Pesquisa e Inovação — IFSP', url: 'ptb.ifsp.edu.br/pesquisa' }] },
    ],
  },
  {
    id: 'inst-extensao', kind: 'inst', icon: 'globe', title: 'Projeto de Extensão', tag: 'Comunidade',
    summary: 'Conecte o campus à comunidade em ações sociais, culturais e educativas — com bolsa.',
    updated: '2026-05-15',
    sections: [
      { type: 'rich', heading: 'O que é', body: 'A [[Extensão]] são projetos que levam o conhecimento do campus para fora dele, atendendo a comunidade. Você pode participar como bolsista ou voluntário e desenvolver habilidades que o mercado valoriza.' },
      { type: 'steps', heading: 'Como participar', items: [
        'Veja os projetos de extensão ativos no campus.',
        'Converse com o coordenador do projeto que te interessa.',
        'Inscreva-se no edital de extensão.',
        'Cumpra a carga horária e participe das ações.',
      ] },
      { type: 'callout', variant: 'info', body: 'Extensão conta como atividade complementar e enriquece muito o currículo.' },
      { type: 'sources', heading: 'Canais oficiais', items: [{ label: 'Extensão — IFSP', url: 'ptb.ifsp.edu.br/extensao' }] },
    ],
  },
];

// ── News seed (original copy; facts about Sisu+ 2026 etapa complementar).
const NEWS_SEED = [
  {
    id: 'n1', published: true, pinned: true,
    category: 'SiSU', source: 'MEC', date: '2026-06-08', read: '2 min',
    title: 'Sisu+ 2026: MEC libera consulta às vagas da etapa complementar',
    summary: 'Nova etapa do SiSU permite consultar antecipadamente as vagas remanescentes para ingresso no 2º semestre.',
    body: 'O Ministério da Educação liberou a consulta às vagas do [[Sisu+]], uma etapa complementar do [[SiSU]] criada para preencher vagas que ficaram remanescentes nas instituições públicas após as chamadas regulares.\n\nPela ferramenta do Portal de Acesso Único, é possível pesquisar cursos, instituições, municípios, turnos e modalidades de concorrência antes da abertura das inscrições — o que ajuda a planejar as escolhas com calma.\n\nO objetivo do programa é ampliar o acesso ao ensino superior público e reduzir o número de vagas que ficam ociosas ao longo do ano letivo.',
    facts: [['Inscrições', '15 a 19 de junho'], ['Resultado', '24 de junho'], ['Ingresso', '2º semestre de 2026']],
    sourceUrl: 'gov.br/mec',
  },
  {
    id: 'n2', published: true, pinned: false,
    category: 'SiSU', source: 'G1', date: '2026-06-15', read: '2 min',
    title: 'Universidades públicas oferecem mais de 1.700 vagas pelo Sisu+',
    summary: 'Estados divulgam a oferta de vagas remanescentes; quem concorreu na etapa regular pode se inscrever.',
    body: 'Com a abertura do [[Sisu+]], instituições públicas em diferentes estados divulgaram suas vagas remanescentes — em alguns estados, passando de 1.700 oportunidades em universidades e institutos.\n\nPodem se inscrever os estudantes que fizeram o [[Enem]] em uma das últimas três edições e que concorreram na etapa regular do [[SiSU]] 2026. O sistema considera automaticamente a edição do Enem com a melhor média ponderada para cada curso escolhido.\n\nNa inscrição, é possível escolher até duas opções de curso, definindo uma ordem de preferência.',
    facts: [['Vagas (exemplo)', '+1.700 em um estado'], ['Quem pode', 'Quem concorreu no SiSU regular'], ['Opções', 'Até 2 cursos']],
    sourceUrl: 'g1.globo.com',
  },
  {
    id: 'n3', published: true, pinned: false,
    category: 'Campus', source: 'IFSP Pirituba', date: '2026-06-11', read: '1 min',
    title: 'PAP: inscrições abertas para o auxílio permanência',
    summary: 'Edital de assistência estudantil do campus está com inscrições abertas pelo SUAP.',
    body: 'O campus abriu o edital do [[PAP]] — Programa de Auxílio Permanência. Estudantes em situação de vulnerabilidade podem solicitar apoio financeiro para moradia, alimentação e transporte.\n\nA inscrição é feita pelo sistema acadêmico (SUAP), com envio da documentação socioeconômica. Em caso de dúvida sobre os documentos, procure o serviço social do campus.',
    facts: [['Onde', 'SUAP'], ['Apoio', 'Moradia, alimentação, transporte']],
    sourceUrl: 'ptb.ifsp.edu.br',
  },
];

Object.assign(window, { GLOSSARY, CONTENT_DOCS, NEWS_SEED });
