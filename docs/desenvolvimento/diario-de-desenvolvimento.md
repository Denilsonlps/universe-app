# Diário de Desenvolvimento — Universe

> Registro cronológico do processo de desenvolvimento do aplicativo Universe,
> mantido para servir de fonte ao TCC (capítulos de Desenvolvimento e Resultados).
> Cada entrada documenta **o que foi decidido, por quê, e o que foi feito**.

---

## 2026-06-11 — Definição da arquitetura e início da reconstrução

### Contexto
O projeto já possuía uma implementação Flutter completa, derivada do protótipo
de design (Claude Design / handoff React-JSX) e alinhada ao TCC. Decidiu-se
**reconstruir o aplicativo do zero com arquitetura limpa**, reaproveitando os
valores visuais já corretos (cores, espaçamentos) do protótipo.

### Materiais de origem
- **TCC** (`TCC.pdf`): requisitos funcionais (RF011–RF037) e não funcionais
  (RNF011–RNF015), arquitetura em três camadas (§2.4.1), atores e contexto.
- **Protótipo** (handoff `universe-app`): 26 telas em React/JSX, design system
  completo (`ui.jsx`, `chrome.jsx`), conteúdo pt-BR (`data.jsx`) e tema
  claro/escuro (`styles.css`).

### Decisões tomadas (com justificativa)
1. **Estratégia de dados: híbrida.** Firebase Auth real desde já; leitura de
   conteúdo via repositório mock atrás de uma interface (`UniverseRepository`),
   pronta para trocar por Firestore. *Por quê:* permite demonstrar o app cedo sem
   depender do backend completo, mantendo o caminho para a camada de dados do TCC.
2. **Tema: claro + escuro, layout fixo.** Mantém alternância de tema; descarta os
   "tweaks" de layout (grid/list/feature) que eram apenas experimentação de design.
3. **Escopo por rodadas.** Rodada 1 = fundação + núcleo do estudante; Rodada 2 =
   telas secundárias + painel admin; Fase de dados = Firestore real. *Por quê:*
   valida o padrão arquitetural antes de escalar; cada rodada é revisável.
4. **Arquitetura alinhada ao TCC (3 camadas).** O app é a **camada de
   apresentação**; Firestore é a **camada de dados**; o pipeline Python/Gemini
   permanece **externo**. O modelo de `Vaga` foi desenhado para casar com o
   pipeline (campos do RF033).
5. **Divergência FlutterFlow → Flutter.** O TCC documenta FlutterFlow (low-code);
   a reconstrução usa Flutter codado à mão. O autor ajustará o texto do TCC
   posteriormente — o foco do projeto mudou em relação à ideia inicial.

### Alinhamentos de requisitos aplicados ao design
- **RF033:** modelo `Internship` com os 10 campos exigidos, separando *descrição
  da vaga* de *descrição da empresa* (o protótipo unia ambos em um só campo).
- **RF034:** vaga encerrada permanece consultável por até 1 mês (`status`+`closedAt`).
- **RF035/RF036:** editais de concurso visíveis apenas no período de inscrição.
- **RF037 / RF012:** disclaimers de que o app apenas divulga vagas e não gere
  benefícios.

### Artefatos produzidos
- Documento de design/spec: `docs/superpowers/specs/2026-06-11-universe-rebuild-design.md`.
- Inicialização do versionamento Git.
- Este diário de desenvolvimento.

### Próximo passo
Criar o plano de implementação detalhado (Rodada 1) e iniciar a fundação
(tema, design system, navegação, Firebase Auth).

---

## 2026-06-11 — Plano 1 concluído: Fundação visual & navegação

### O que foi construído
Reconstrução da base do app, executada em tasks com TDD e commits frequentes,
na branch `feat/fundacao-visual-navegacao`:

- **Tema claro + escuro** via `ThemeExtension` (`AppColorsX`) com as paletas
  exatas do protótipo, e `AppTheme.light/dark` com a fonte Montserrat.
- **Provider de tema** (`themeModeProvider`) com persistência em
  `shared_preferences` — desenvolvido por TDD (teste vermelho → verde).
- **Design system** (10 widgets): `IconTile`, `AppCard`, `SectionTitle`,
  `AppButton`, `ListRow`, `StatusBadge`, `Stars`, `EmptyState`, `UserAvatar`,
  `AppChip` — todos lendo cores via a extensão de tema (suporte a dark mode).
- **Chrome** de navegação: `PageShell`, `HomeHeader`, `PageHeader`, `GreenHero`,
  `AppBottomNav`, `MenuDrawer`.
- **Navegação** com `go_router`: `ShellRoute` com 4 abas (Início, Cursos,
  Dúvidas, Perfil) + drawer lateral verde. Telas de conteúdo são placeholders
  (serão implementadas no Plano 3).
- **Wiring** em `main.dart`: `ProviderScope` + `MaterialApp.router` + tema reativo.

### Decisões técnicas (justificativa)
- **`ThemeExtension` em vez de cores hardcoded:** permite alternar claro/escuro
  sem reescrever widgets; cada widget acessa a paleta por `context.c`.
- **Mapa de ícones (string → `IconData`):** preserva os nomes semânticos do
  protótipo (`'cap'`, `'briefcase'`…) facilitando a tradução das telas no Plano 3.
- **Tela placeholder reutilizável:** mantém o app navegável e demonstrável
  enquanto as telas reais não chegam, sem código morto.

### Verificação
- `flutter analyze`: sem erros (apenas 3 infos estilísticos `use_null_aware_elements`).
- `flutter test`: 4/4 testes passando (provider de tema, smoke test do design
  system em ambos os temas, e boot do app exibindo a aba Início).
- `flutter run -d chrome` (porta 5000): app compila e é servido sem erros.

### Próximo passo
Plano 2 — Dados & Autenticação (models, `UniverseRepository` + mock, providers,
Firebase Auth, telas de splash/onboarding/login/registro).

---

## 2026-06-11 — Plano 2 concluído: Autenticação

### O que foi construído
Autenticação real com Firebase, com o app protegido por estado de login. Branch
`feat/autenticacao`, executado em tasks com TDD e commits frequentes.

- **Design system complementado:** `AppField` e `PasswordField` (campos de texto
  com rótulo, ícone, validação e erro), que faltavam para as telas de formulário.
- **Modelo `AppUser`** com papel (`student`/`admin`) — o `admin` representa o
  Setor de Estágios (spec §4), usado futuramente no painel de cadastro de vagas.
- **Camada de auth desacoplada:** interface `AuthRepository` com duas
  implementações — `FirebaseAuthRepository` (real, via `firebase_auth`, com
  mensagens de erro em pt-BR) e `FakeAuthRepository` (em memória, para testes
  sem rede). A UI depende só da interface.
- **Providers Riverpod:** `authRepositoryProvider` e `authStateProvider`
  (stream de `AppUser?`).
- **Telas:** splash (marca), onboarding (3 slides), login e registro (com regras
  de senha), fiéis ao protótipo.
- **Navegação por autenticação:** o `routerProvider` (go_router) observa o estado
  de auth e redireciona — carregando → splash; deslogado → onboarding/login/
  registro; logado → home. Logout pelo drawer volta ao fluxo de entrada.
- **`Firebase.initializeApp`** no `main`.

### Decisões técnicas (justificativa)
- **Interface `AuthRepository` + Fake:** concretiza a estratégia "híbrida" da spec
  (auth real, dados mock depois) e torna toda a auth testável sem Firebase/rede.
  Os testes injetam o fake via override do Riverpod.
- **Redirect centralizado no router** (em vez de navegação manual nas telas):
  fonte única de verdade para "onde o usuário pode estar" conforme o login.
- **`FakeAuthRepository.authState()`** emite o estado atual ao ser ouvido e
  depois repassa os eventos — replicando a semântica do `authStateChanges()`
  real do Firebase (corrigiu uma corrida do desenho inicial do plano).

### Verificação
- `flutter analyze`: sem erros.
- `flutter test`: 14/14 testes passando (auth repo, login, redirect, app boot,
  além dos do Plano 1, com o teste de navegação adaptado ao novo fluxo de auth).
- `flutter run -d chrome`: compila com Firebase inicializado e é servido sem erros.
- **Pendência operacional:** habilitar o provedor **Email/Senha** no Firebase
  Authentication do projeto para o cadastro/login reais funcionarem em produção.

### Próximo passo
Plano 3 — Camada de dados (models de conteúdo + `UniverseRepository` + mock com
regras RF034/RF036) e telas de conteúdo (Home, Cursos, IFSP, Benefícios,
Estágio/Concursos, Dúvidas, Perfil).

---

## 2026-06-11 — Decisão de identidade e dados do aluno (integração SUAP)

### Achado relevante para o TCC
Ao revisar a autenticação, constatou-se que **o TCC não documenta login/autenticação**
nem como obter os dados acadêmicos do aluno. São necessidades vindas do protótipo/
evolução do projeto. Registrada a pendência de documentar isso no TCC (requisito de
autenticação ou nota de evolução de escopo).

### Pesquisa
O **SUAP possui API REST oficial** (DIGTI/IFRN, usada pelo IFSP) que fornece curso,
matrícula, nome, e-mail e foto do aluno, com autenticação via JWT ou **OAuth2**
(recomendado — IFSP como provedor de identidade, sem o app ver a senha). Requer
registro do app junto ao IFSP (`suporte@ifsp.edu.br`). Há precedente: o app oficial
IFSP Conecta integra com o SUAP. Detalhes em
[`integracao-suap.md`](integracao-suap.md).

### Decisão (confirmada com o autor): abordagem híbrida
- **Agora:** Firebase Auth (e-mail/senha) + **perfil auto-declarado** no Firestore
  (curso capturado no cadastro **e** editável no perfil).
- **Preferencial/futuro:** `SuapAuthRepository` (OAuth2) como login institucional e
  fonte dos dados do aluno, condicionado à aprovação do IFSP. A interface
  `AuthRepository` + camada de perfil absorvem a troca sem reescrever a UI.

### Correção de UI
Corrigido um defeito visual na tela de login: a folha branca tinha cantos
arredondados revelando uma "fatia" de verde destoante (fundo sólido vs. cabeçalho
em gradiente). Solução: gradiente contínuo único atrás de todo o conteúdo.

---

## 2026-06-11 — Plano 3 concluído: Camada de dados & perfil do aluno

### O que foi construído
Toda a camada de dados do conteúdo do app + o perfil do aluno. Branch
`feat/camada-dados-perfil`, em tasks com TDD e commits frequentes.

- **Modelos de conteúdo:** `Course`, `Benefit` (+`BenefitKind`), `Internship`
  (com os **10 campos do RF033**, separando descrição da vaga e da empresa),
  `Contest`, `Testimonial`, `Faq`, `IfspInfo`/`IfspDetail`.
- **Regras de negócio testadas (TDD):**
  - RF034 — vaga encerrada permanece visível por até 30 dias (`Internship.visibleAt`).
  - RF036 — edital de concurso só dentro do período de inscrição (`Contest.isOpenAt`/`visibleAt`).
  - RF031 — estágios filtráveis por curso.
- **`UniverseRepository`** (interface) + **`MockUniverseRepository`** com o conteúdo
  pt-BR **transcrito fielmente** de `design_reference/.../data.jsx` (10 cursos, 8
  benefícios, 3 depoimentos, 6 FAQs, 6 itens do campus, 6 estágios, 4 concursos).
  Único campo sintetizado: a "descrição da vaga" (o protótipo unia-a à da empresa).
- **Perfil do aluno:** `StudentProfile` (uid, curso, matrícula) + `ProfileRepository`
  com `FirestoreProfileRepository` (real, coleção `users/{uid}`) e
  `FakeProfileRepository` (testes). Providers `universeRepositoryProvider`,
  `profileRepositoryProvider`, `currentProfileProvider`.
- **Captura de curso no cadastro:** seletor opcional no registro grava o perfil
  no Firestore; também será editável no perfil (decisão "Ambos").

### Decisões técnicas
- **Conteúdo como transcrição da fonte versionada** (`data.jsx`), não dados
  inventados — fidelidade ao protótipo e rastreabilidade.
- **Perfil atrás de interface** (`ProfileRepository`), como a auth — pronto para,
  no futuro, a fonte virar o SUAP (ver `integracao-suap.md`).
- Regras dos requisitos vivem **no modelo/repositório** (testáveis isoladamente),
  não na UI.

### Verificação
- `flutter analyze`: sem erros. `flutter test`: **20/20** (modelos, regras
  RF031/RF034/RF036, perfil, + tudo dos Planos 1–2).

### Próximo passo
Plano 4 — Telas de conteúdo (Home, Cursos, IFSP, Benefícios, Estágio/Concursos,
Dúvidas, Perfil) consumindo esta camada de dados, substituindo os placeholders.

---

## 2026-06-11 — Identidade visual (marca Universe)

### O que foi construído
A identidade da marca foi portada do protótipo (`brand.jsx`) para widgets Flutter
**vetoriais** em `lib/shared/brand/universe_brand.dart`:

- **`UniverseMark`** — o glifo da marca: chevron em "V" (capelo/visto) coroado por
  um ponto (cabeça do formando), desenhado via `CustomPainter` com a geometria
  exata do SVG original (viewBox 64×64).
- **`UniverseBadge`** — selo circular monograma (viewBox 44×44).
- **`UniverseAppIcon`** — ícone do app: squircle com gradiente verde, brilho
  radial e o mark em branco.
- **`UniverseWordmark`** — wordmark "UNI⋁RSE" recriado em tipografia (Montserrat
  800), com o mark no lugar do "V".

Substituiu o texto simples `Text('UNIVERSE')` por esses widgets no cabeçalho da
Home, no menu lateral, no login e no splash.

### Decisões técnicas
- **Vetor (CustomPainter) em vez de PNG:** escala nítida em qualquer tamanho,
  cor parametrizável (funciona em tema claro e escuro) e sem dependência de assets.
- A marca Universe é **própria e distinta do logo institucional do IFSP**
  (`ifsp-logo.png`), conforme a intenção do design — o logo do IFSP entrará na
  tela do campus (Plano 4).

### Verificação
- `flutter analyze`: sem erros. `flutter test`: **23/23** (inclui smoke test da marca).

---

## 2026-06-11 — Plano 4A concluído: telas Home, Cursos e IFSP

### O que foi construído
As primeiras telas de conteúdo reais, substituindo os placeholders, consumindo a
camada de dados (`UniverseRepository`) e o design system/marca:

- **Home (aba Início):** saudação com o nome do usuário autenticado, barra de busca
  (placeholder), ações rápidas, card de destaque e a lista "Explorar".
- **Cursos (aba):** filtro por categoria + busca, cards de curso, estado vazio;
  **detalhe do curso** com metadados, "sobre" e formas de ingresso.
- **IFSP (campus):** hero com estatísticas e lista "sobre o campus"; **detalhe**
  com texto/linhas (história, endereço, horário, estrutura, contatos, site).
- **Router:** Home e Cursos reais nas abas; `/ifsp`, `/ifsp/:key` e `/cursos/:name`
  como rotas full-screen (top-level). Dúvidas e Perfil seguem placeholders (4C).

### Decisões / correções da revisão
- **Navegação:** detalhes abrem com `context.push` (não `go`), preservando a aba e
  o estado de filtro e garantindo o botão voltar; trocar de aba usa `context.go`.
- **Drawer:** itens de rotas ainda não implementadas mostram "Em breve" em vez de
  não fazer nada; IFSP navega corretamente.
- **MenuDrawer:** lista trocada para `SingleChildScrollView+Column` (constrói todos
  os itens — lista curta e fixa).
- Rotas não implementadas (benefícios, estágio, cadastrar, moradia) → SnackBar
  "Em breve", sem links quebrados.

### Verificação
- `flutter analyze`: sem erros. `flutter test`: **23/23**.

### Próximo passo
Plano 4B — Benefícios (gov/inst + detalhe) e Estágio/Concursos (+ detalhes e
depoimentos), consumindo o repositório (RF033/RF034/RF036 já no modelo).

---

## 2026-06-11 — Correção de bug e decisão de dados em tempo real

### Correção (telas de detalhe — "tela vermelha")
Ao abrir um curso ou o IFSP, aparecia erro. Duas causas:
1. **"No Material widget found":** as telas de detalhe são rotas full-screen FORA
   do `ShellRoute` (sem `Scaffold`); o `PageShell` usava `Container` e o `InkWell`
   exige um ancestral `Material`. Corrigido: `PageShell` agora usa `Material`.
2. **"Illegal percent encoding in URI":** nomes de curso com `/` e `—` quebravam o
   parâmetro de URL. Corrigido: o curso é passado via `extra` do go_router.
Adicionado teste de regressão (`detail_screens_test.dart`). 25 testes no total.

### Decisão: atualização de dados e tempo real
Discutido como manter os dados atualizados sem republicar o app. Solução:
migrar a leitura para o **Firestore** (camada de dados do TCC), com **streams em
tempo real** para dados dinâmicos (vagas, concursos, editais, notificações) e
busca+cache para estáticos (cursos, IFSP, FAQ). A rotina de atualização fica no
**pipeline Python agendado** e no **painel admin**, não no app (Firestore faz
push). A interface `UniverseRepository` já isola a troca. Detalhes e proposta
completa em [`arquitetura-dados-tempo-real.md`](arquitetura-dados-tempo-real.md).
Sequência: terminar telas no mock (4B/4C) → Plano de Dados (Firestore).

---

## 2026-06-11 — Plano 4B concluído: Benefícios e Estágio/Concursos

### O que foi construído
- **Benefícios (gov/inst):** lista em cards + **detalhe** ("O que é" e "Como
  solicitar" em passos). Inclui **disclaimer RF012** (o app não cria/gere benefícios).
- **Estágio e Concursos:** abas (Estágios/Concursos), **filtro por curso** (RF031),
  cards de vaga e de concurso, e carrossel de **depoimentos**.
- **Detalhe da vaga:** os **10 campos do RF033** (descrição da vaga e da empresa
  separadas), **banner RF034** (encerrada visível por 1 mês) e **disclaimer RF037**.
- **Detalhe do concurso:** metadados + prazo + **disclaimer RF037**.
- **Depoimentos (RF032):** lista + publicação pelo aluno (em memória nesta fase).
- **Navegação:** novas rotas full-screen via `push`+`extra`; Home/drawer habilitados;
  "Ver estágios para este curso" abre a lista já filtrada pelo curso. `GreenHero`
  ganhou `action` opcional.

### Verificação
- `flutter analyze`: sem erros. `flutter test`: **25/25**. Revisão final aprovada
  (todos os RFs cobertos).

### Próximo passo
Plano 4C — Dúvidas (FAQ) e Perfil (com curso/edição). Depois, a fase de dados
(Firestore + tempo real).

---

## 2026-06-11 — Plano 4C concluído: Dúvidas e Perfil (telas de conteúdo fechadas)

### O que foi construído
- **Dúvidas (FAQ):** busca, filtro por categoria, lista de **accordion** (um aberto
  por vez, inicia tudo fechado) e card "Encaminhe sua dúvida" (categoria + mensagem).
- **Perfil:** hero com nome/e-mail (auth) e estatísticas (curso/matrícula do
  `currentProfileProvider`); **alternador de tema claro/escuro** ligado ao
  `themeModeProvider` (dark mode agora exposto e funcional em todo o app);
  grupos de ações; sair da conta.
- **Editar perfil (Cadastrar):** curso (dropdown) + matrícula **persistidos** via
  `ProfileRepository`; ao salvar, invalida o `currentProfileProvider` (o Perfil
  reflete na volta). Com tratamento de erro.
- **Design system:** `Accordion` e `AppToggle` adicionados (com testes).
- Router: Dúvidas e Perfil reais; `/cadastrar` top-level. Placeholder de aba
  removido (todas as 4 abas agora são telas reais).

### Correções da revisão
Tratamento de erro ao salvar perfil; FAQ inicia fechado e reseta na busca; arquivo
placeholder órfão removido; teste do AppToggle.

### Verificação
- `flutter analyze`: sem erros. `flutter test`: **27/27**.

### Estado
Todas as **telas de conteúdo do app estão completas no mock** (auth + 4 abas +
IFSP + cursos + benefícios + estágio/concursos + depoimentos + dúvidas + perfil).
Próximo: **fase de Dados & Admin & Conteúdo** (Firestore + tempo real, painel
admin para cadastrar vagas e editar conteúdo rico, glossário/wikilinks,
persistência real) — a ser desenhada via brainstorming.

---

## 2026-06-11 — SP1 concluído: Fundação Firestore (tempo real)

Fase **Dados & Admin** decomposta em 3 sub-projetos (SP1 Firestore → SP2 Admin →
SP3 Conteúdo rico). Brainstorming e spec aprovados; SP1 implementado.

### O que foi construído (código)
- **(De)serialização** de todos os modelos (`fromMap`/`toMap`, datas em epoch-ms),
  + `AppNotification`; `Testimonial` ganhou `authorUid`/`createdAt`; `IfspInfo`
  passou a embutir o detalhe (`detail`). Teste de round-trip.
- **`UniverseRepository` por streams** (`watch…`), com `FakeUniverseRepository`
  (renomeado do mock; seed/testes) e **`FirestoreUniverseRepository`** (snapshots
  em tempo real). As regras RF031/RF034/RF036 continuam aplicadas no repositório.
- **Stream providers** (Riverpod) e Firestore como padrão.
- **Todas as telas refatoradas** para assíncrono via o helper **`AsyncListView`**
  (loading/erro/vazio/dados + "tentar novamente").
- **Depoimentos persistidos** no Firestore (some o provider de sessão); doc
  `users/{uid}` criado com `role: 'student'` no registro.
- **Seeder** dev idempotente (sobe o conteúdo do Fake) + **`firestore.rules`**
  (aluno lê / admin escreve; perfil só do próprio; depoimento criado pelo autor).

### Decisões
- **Tudo via `Stream`** (um só padrão de UI; cache offline cobre estáticos).
- Datas como epoch-ms (int) no Firestore — simples e consistente.
- Admin via campo `role` em `users/{uid}` (sem Cloud Functions).

### Verificação
- `flutter analyze`: sem erros. `flutter test`: **31/31** (inclui teste de tela
  consumindo o repositório via stream com o Fake). Revisão final aprovada.

### Pendência operacional (console Firebase)
Para os dados reais aparecerem no app: habilitar o Cloud Firestore, **publicar as
regras** (`firestore.rules`), rodar o **seed** uma vez e marcar o usuário do Setor
de Estágios como `role: 'admin'`. Sem isso, o app compila e os testes passam (usam
o Fake), mas as telas ficam vazias/carregando.

### Próximo passo
SP2 — Papel Admin + Painel (cadastro de vagas/concursos pela UI).

---

## 2026-06-11 — SP2 concluído: Painel Admin (vagas & concursos)

### O que foi construído
O Setor de Estágios (admin) agora **cadastra, edita, encerra e exclui vagas e
concursos pela própria UI** — sem o console.

- **Papel admin:** `StudentProfile` ganhou `role` (só-leitura no cliente; `toMap`
  não grava, para não sobrescrever). `isAdminProvider` deriva o papel.
- **Repositório (escrita):** `upsertInternship/Contest`, `deleteInternship/Contest`,
  `watchAllInternships/Contests` (sem o filtro RF034/RF036 — admin vê tudo) e
  `newId`. Implementado no Firestore e no Fake. Providers `allInternshipsProvider`/
  `allContestsProvider`.
- **Painel `/admin`:** abas Vagas | Concursos, listas com editar (toque) e excluir
  (com confirmação), FAB "＋" por aba.
- **Formulários:** vaga (10 campos RF033 + curso/modalidade/tag/link + editor de
  listas para pré-requisitos/diferenciais/benefícios + alternador aberta/encerrada
  que grava `closedAt`); concurso (com date picker do prazo). Validação dos
  obrigatórios.
- **Gating:** o botão escudo (tela Estágio) e o item "Painel do Setor de Estágios"
  (menu) só aparecem para admin (`isAdminProvider`). Segurança real garantida pelas
  regras do Firestore (SP1).

### Decisões/correções
- `role` só-leitura no perfil (não sobrescreve ao salvar curso).
- Listas do `FakeUniverseRepository` passaram a ser de instância (evita vazamento
  de estado entre testes — achado da revisão final).

### Verificação
- `flutter analyze`: sem erros. `flutter test`: **37/37** (inclui CRUD do
  repositório e gating de admin). Revisão final aprovada.

### Próximo passo
SP3 — Conteúdo rico editável (modelo de blocos: o que é, etapas, vídeo/imagem,
última atualização) + glossário/wikilinks (`[[PIBIC]]`).

---

## 2026-06-18 — SP3a concluído: Conteúdo rico (leitura) + glossário/wikilinks

### O que foi construído
As páginas de benefícios deixaram de ser cartões com texto curto + link e passaram
a ser **conteúdo rico no estilo gov.br** — o app agora *explica* o benefício, não
apenas redireciona.

- **Modelo de conteúdo:** `ContentDoc{id, kind(gov/inst), icon, title, tag, summary,
  updatedAt, sections}` com `ContentSection` **selada** (Dart 3) em 7 tipos:
  `rich` (texto), `steps` (passo a passo numerado), `docs` (checklist), `media`
  (imagem/vídeo), `callout` (aviso info/warn), `faq` (acordeão) e `sources` (canais
  oficiais). `fromMap`/`toMap` com despacho por `type`; tipos desconhecidos são
  ignorados (tolerância a evolução futura do schema).
- **Glossário + wikilinks:** constante `glossary` (18 termos: Cadastro Único, ID
  Jovem, PIBIC, PIBITI, CRAS, NIS, SiSU, Enem, NAPNE…). O widget `WikiText` faz
  parse de `[[chave]]` e `[[chave|exibição]]`: termos com página abrem outro
  `ContentDoc`; termos com definição abrem uma **ficha** (`TermSheet`, bottom sheet).
- **Renderização:** `ContentSectionView` (um `switch` exaustivo na hierarquia selada,
  reaproveitando o design system — Card, Accordion, IconTile) + `ContentDocScreen`
  (`/conteudo/:id`) com herói verde, "Atualizado em dd/mm/aaaa" e as seções.
  `MediaView` mostra imagem via `CachedNetworkImage` e vídeo como thumbnail que abre
  o link no navegador (sem player embutido — escopo do SP3a é leitura).
- **Migração dos Benefícios:** a aba Benefícios (gov/inst) lista `contentDocs` por
  tipo e abre o `ContentDocScreen`. O modelo `Benefit`, a `BenefitDetailScreen`,
  `benefitsProvider`/`watchBenefits` e o seed de `benefits` foram **removidos**; o
  enum legado `BenefitKind` foi consolidado em `ContentKind`. O disclaimer **RF012**
  ("o app só informa") foi mantido.
- **Repositório/seed:** `watchContentDocs(kind)`/`watchContentDoc(id)` no Firestore e
  no Fake; providers `contentDocsProvider`/`contentDocProvider`. O Fake traz os **8
  documentos** transcritos fielmente do protótipo (`data-content.jsx`), com todos os
  `[[wikilinks]]`. O seeder agora popula a coleção `contentDocs`.

### Decisões/correções
- **`BenefitKind` → `ContentKind`:** como o modelo `Benefit` saiu e o enum só servia
  aos benefícios, consolidou-se um único enum (evita nome legado solto). Ajustado em
  todos os usos (verificado por `grep`).
- **Wikilink via `WidgetSpan`+`GestureDetector`** (em vez de `TapGestureRecognizer`):
  dispensa gerência manual do ciclo de vida dos recognizers.
- **Mídia (SP3a = leitura):** vídeos usam link de exemplo (YouTube) e imagens ficam
  como placeholder; o **upload ao Storage pelo admin** é o SP3b.
- Cast tolerante de `updatedAt` (`num`→`int`) no `fromMap`; `onOpenDoc` opcional no
  `TermSheet`; `parseVideoUrl` resolvido uma única vez (achados das revisões).

### Verificação
- `flutter analyze`: **sem erros**. `flutter test`: **42/42** (round-trip do
  `ContentDoc` por tipo, parser do `WikiText`, e os 8 docs do Fake: 4 gov + 4 inst).
- Execução subagent-driven: 7 tarefas, cada uma com revisão de spec + qualidade.
- **Pendência operacional do usuário:** rodar novamente o "Popular dados (dev)" no
  Perfil (admin) para criar a coleção `contentDocs` no Firestore.

### Próximo passo
SP3b — Editor de conteúdo no painel admin (criar/editar `ContentDoc` e suas seções,
com upload de imagem ao Firebase Storage).

---

## 2026-06-18 — SP3b concluído: Editor de conteúdo no admin + upload ao Storage

### O que foi construído
O admin agora **cria, edita e exclui** as páginas de benefício (conteúdo rico) e
suas seções pela própria UI, com **upload de imagem** ao Firebase Storage. Antes o
conteúdo só existia via seed; agora é gerenciado dentro do app.

- **Hub administrativo:** a rota `/admin` virou um **`AdminHubScreen`** com cards —
  "Vagas e concursos" (→ `/admin/vagas`, o painel anterior) e "Páginas de conteúdo"
  (→ `/admin/conteudo`). Prepara o terreno para Notícias (SP3c).
- **Lista de páginas (`/admin/conteudo`):** agrupa Governamentais/Institucionais
  (lê `allContentDocsProvider`), com botão "Nova página" e a dica de `[[wikilinks]]`.
- **Editor (`/admin/conteudo/editar`):** edita um **rascunho local** das seções como
  `List<Map>` (evita `copyWith` nas 7 classes seladas), convertendo para
  `ContentSection` via `fromMap` só ao **Publicar** (define `updatedAt = agora`).
  - Cabeçalho: título, tag, resumo e **seletor de ícone** visual (`IconPicker`).
    Em nova página, também escolhe o tipo (gov/inst); o **id** é gerado por slug do
    título (`gov-cadastro-unico`), fixo na edição para não quebrar wikilinks.
  - Seções: **adicionar** (7 tipos), **reordenar** (↑/↓), **excluir**; campos por
    tipo (texto, passo a passo, lista, mídia, destaque info/atenção, dúvidas, fontes).
  - **Excluir página** (com confirmação) no modo edição.
- **Upload de mídia (`MediaUploader`):** imagem → `image_picker` → bytes →
  `StorageService.uploadContentImage` (Firebase Storage, `putData` — compatível com
  web) → URL salva no doc, com progresso/erro; vídeo → link (sem upload), igual ao SP3a.
- **Repositório:** `upsertContentDoc`/`deleteContentDoc`/`watchAllContentDocs`
  (Firestore + Fake) + `allContentDocsProvider`. Util `slugify`/`generateDocId`
  (anti-colisão). `StorageService` (Firebase + Fake) + `storageServiceProvider`.
- **Regras:** novo `storage.rules` (`content_images/**`: leitura logada, escrita
  admin) + `firebase.json` passou a registrar `firestore`/`storage`. Firestore
  inalterado (o catch-all já gate-ia `contentDocs`).

### Decisões/correções
- **Rascunho como `List<Map>`** (abordagem JSON do protótipo) — bem mais simples que
  `copyWith` nas seladas; conversão final via `fromMap`.
- **Hub usa o header verde do app** (`GreenHero`/`PageHeader`), não o header escuro do
  protótipo (divergência FlutterFlow→Flutter já registrada).
- `Navigator.of(context).pop()` no editor (compatível com rota empilhada por
  `context.push` e testável sem GoRouter); `List<Map>.from` explícito em faq/sources
  (clareza, achado da revisão).
- Nova dependência: **`image_picker`**.

### Verificação
- `flutter analyze`: **sem erros**. `flutter test`: **50/50** (repo upsert/delete,
  slug/id incl. colisão, StorageService fake, smoke do editor: adicionar seção +
  publicar com `updatedAt` de hoje).
- Execução subagent-driven: tasks com revisão de spec + qualidade.
- **Pendências operacionais do usuário:** (1) publicar as **regras de Storage** no
  console Firebase (ou `firebase deploy --only storage`) — sem isso o upload falha;
  (2) garantir que o Storage esteja habilitado no projeto.

### Próximo passo
SP3c — Notícias (card do hub + feed na home + tela de notícia + editor admin).

---

## 2026-06-18 — Ajustes pós-teste do SP3b (mídia, ícones, vaga) + Storage no ar

Após habilitar o Firebase Storage e testar o upload no navegador, surgiram ajustes
de uso, todos aplicados na `main`:

- **CORS do Storage:** o upload subia, mas o navegador era bloqueado ao **baixar** a
  imagem (`No 'Access-Control-Allow-Origin'`). Causa: bucket sem CORS. Resolvido com
  `cors.json` (GET liberado) aplicado via Cloud Shell
  (`gsutil cors set cors.json gs://universe-app-ifsp.firebasestorage.app`). Passo
  operacional, documentado.
- **Suporte a SVG:** `CachedNetworkImage` não decodifica SVG. Criado `ContentImage`
  (vetorial via `flutter_svg`, raster via cache) usado no editor e na tela do aluno.
  Validação de formato no upload (PNG/JPEG/SVG) + dica visível. Removido o
  redimensionamento do `image_picker` (re-encodava e quebrava o SVG).
- **Imagem por link:** além do upload, é possível **colar a URL** de uma imagem.
- **Exibição da imagem (corte):** toggle por imagem **Preencher** (corta, `cover`) vs
  **Imagem inteira** (`contain`, sem corte) — campo `fit` em `MediaSection`.
- **Seletor de ícone:** virou **menu suspenso** (bottom sheet) com ~39 ícones (antes
  18, em grade fixa na tela).
- **Wikilinks entre páginas:** `[[Título de outra página]]` agora resolve pelo título
  de qualquer `ContentDoc` existente (além do glossário fixo) — `ContentDocScreen`
  passou a `ConsumerWidget` e injeta um resolvedor no `WikiText`.
- **Imagem na vaga de estágio:** `Internship.imageUrl` + campo no formulário admin +
  exibição no topo da tela de detalhe. Componente `ImagePickerField` reutilizável
  (upload + link + preview + validação) unifica o `MediaUploader` e a vaga.

### Verificação
- `flutter analyze`: sem erros. `flutter test`: **50/50**. Validado no navegador pelo
  usuário (upload, SVG, corte, ícones, imagem na vaga).

### Próximo passo
SP3c — Notícias (card no hub admin + feed na home + tela de notícia + editor).

---

## 2026-06-18 — SP3c concluído: Notícias (fim do SP3)

### O que foi construído
Canal de **avisos e novidades** do campus dentro do app — fechando o SP3.

- **Modelo `News`** (categoria, fonte, data, tempo de leitura, título, resumo, corpo
  com `[[wikilinks]]`, **fatos rápidos**, imagem, `sourceUrl`, `published`, `pinned`).
  Coleção `news/{id}`; `facts` como lista de mapas (Firestore não aceita array aninhado).
- **Repositório:** `watchPublishedNews` (só publicadas, fixadas primeiro + data desc),
  `watchAllNews` (admin), `upsertNews`/`deleteNews`; providers `publishedNewsProvider`/
  `allNewsProvider`. Fake traz as 3 notícias do protótipo.
- **Aluno:** bloco/**carrossel** de notícias na Home (com "Ver todas") → tela
  **`/noticias`** (filtro por categoria) → **`/noticias/:id`** (capa, fatos rápidos,
  corpo via `WikiParagraphs` com wikilinks p/ glossário e páginas, card de fonte
  oficial). `NewsCard` reutilizável (compacto + lista).
- **Admin:** 3º card no hub → **`/admin/noticias`** (lista com toggle publicar/
  despublicar inline) e **editor** (`/admin/noticias/editar`): categoria (chips +
  livre), fonte, tempo de leitura, resumo, corpo, **fatos rápidos** (editáveis),
  **imagem** (`ImagePickerField`), link da fonte, e toggles **Destaque**/**Publicar**;
  salvar/excluir com tratamento de erro.
- **Regra do Firestore:** leitura de `news` restrita a **publicadas ou admin** —
  condicionada no próprio catch-all (`col != 'news' || isAdmin() || published`),
  porque as regras concedem por união (um `match /news` separado não restringiria).
  Seeder popula `news`.

### Decisões/correções
- Fake passou a servir as 3 notícias via `_news` (instância), consistente com as
  demais listas; teste de ordenação filtra os próprios ids.
- Reuso pesado do SP3a/SP3b (WikiText/resolvedor, ImagePickerField/ContentImage,
  AsyncListView, AppToggle, design system) — sem dependências novas.

### Verificação
- `flutter analyze`: sem erros. `flutter test`: **55/55** (round-trip do News,
  ordenação/filtragem de publicadas, upsert/delete, smoke do editor). Regra do
  Firestore validada (MCP). Execução subagent-driven com revisões.
- **Pendências operacionais do usuário:** re-rodar "Popular dados (dev)" (cria `news`)
  e **publicar a regra do Firestore** no console (senão a restrição de rascunho não
  vale).

### Estado do SP3
SP3 (conteúdo rico) **concluído**: SP3a (leitura) + SP3b (editor + upload) + SP3c
(notícias). O app agora tem conteúdo rico gerenciável e um canal de notícias.

---

## 2026-06-22 — SP4: Pipeline de Vagas automatizado (scraping + Gemini → aprovação)

### O que foi construído
A **camada de processamento externo** da arquitetura do TCC, agora ligada ao app: o
pipeline Python coleta vagas, o Gemini **enriquece**, e o Setor de Estágios **aprova**
no app. Reduz a digitação manual mantendo a curadoria (RF037).

- **Contrato — coleção `vagas_sugeridas`:** id = `sha1(link)` (idempotente). Campos do
  `Internship` + `source: 'gupy-auto'`, `scrapedAt`, `status: 'pendente'|'recusada'`.
- **App:** modelo `VagaSugerida` (envolve `Internship`); repositório
  `watchVagasSugeridas`/`rejeitar`/`delete` + `vagasSugeridasProvider`; **card no hub**
  "Vagas sugeridas (N)"; **`AdminSugestoesScreen`** com **Aprovar** (cria a vaga via
  `upsertInternship` com o mesmo id + remove a sugestão), **Editar** (abre o
  `VagaFormScreen` pré-preenchido; ao salvar, remove a sugestão via `fromSuggestionId`)
  e **Recusar** (tombstone `status:'recusada'`). Fake traz 2 sugestões de exemplo.
- **Pipeline (`pipeline/`):** `main.py` evoluído — scraping da listagem (Gupy), abre a
  **página de cada vaga**, Gemini em **modo JSON** extrai descrição/requisitos/
  diferenciais/benefícios/bolsa/área/curso (mapeado p/ rótulo curto), e grava em
  `vagas_sugeridas` via **`firebase-admin`**. **Dedup:** pula vagas já em `internships`
  (aprovadas) ou `recusada`. `requirements.txt`, `README.md` (setup), `test_pipeline.py`
  (map_course/vaga_id). Service account no `.gitignore`.
- **Agendamento:** `.github/workflows/pipeline-vagas.yml` (cron diário + manual).
- **Regra do Firestore:** `vagas_sugeridas` é **só admin** (estendido no catch-all,
  junto com a regra de `news`). O pipeline (admin SDK) ignora as regras.

### Decisões
- `id = sha1(link)` em todas as pontas; aprovar reusa o id (dedup). Recusar mantém
  tombstone. Procedência `source` distingue auto vs manual; edição do admin prevalece.
- Mono-repo: o Python fica em `pipeline/` (versionado, evidência p/ o TCC).

### Verificação
- `flutter analyze`: sem erros. `flutter test`: **58/58** (round-trip VagaSugerida,
  filtro/ordem das sugeridas, aprovar cria vaga + remove sugestão, smoke da tela).
  Regra validada (MCP). `main.py` valida sintaxe; `map_course`/`vaga_id` testados.
- **Pendências operacionais do usuário:** (1) criar a **service account** do Firebase e
  os secrets `FIREBASE_SERVICE_ACCOUNT` e `GEMINI_API_KEY` no GitHub; (2) habilitar o
  Actions; (3) publicar a regra do Firestore atualizada; (4) re-rodar o seed (cria
  `vagas_sugeridas` de exemplo).

### Nota de TCC
Evolui a arquitetura documentada (de "CSV + cadastro manual" para "pipeline → Firestore
+ aprovação no app") — refletir no texto depois.

---

## 2026-06-23 — SP4 (ajuste): coleta via API JSON da Gupy (substitui o Selenium)

### Problema
O GitHub Actions retornava 0 vagas: a Gupy bloqueia o **navegador headless em IP de
nuvem** (anti-robô). Localmente funcionava, mas a automação na nuvem não.

### Solução
Descoberta a **API pública** da Gupy:
`GET https://employability-portal.gupy.io/api/v1/jobs?jobName=estágio&limit&offset`
→ JSON com `id, name, description (texto completo), careerPageName, jobUrl,
workplaceType, city, type, pagination.total`. O `main.py` foi **reescrito** para
consumir essa API com `requests`/`urllib` (sai o `selenium`/Chrome):
- Muito mais leve, rápido e robusto (sem seletores de DOM frágeis); a descrição já
  vem pronta para o Gemini extrair curso/área/requisitos/benefícios/bolsa.
- **id estável** = `gupy-<id da vaga>` (em vez de `sha1(link)`); aprovar reusa o id.
- Workflow do Actions simplificado (sem instalar Chrome) e **cron reativado** — uma API
  HTTP tende a passar no runner do GitHub (a confirmar na execução).

### Verificação
Local: `🔎 6 vagas retornadas pela API` → 6 enriquecidas e gravadas em
`vagas_sugeridas`. Funções `map_course`/`job_doc_id`/`map_mode` testadas.
Pendência: rodar o Actions para confirmar se a API passa no runner (se não, plano B é
um self-hosted runner numa máquina do campus).

### Nota de TCC
A camada externa passou de "web scraping com Selenium" para "consumo da API da Gupy" —
atualizar a descrição do pipeline no texto.

---

## 2026-06-23 — SP5: Pipeline de Notícias automatizado (RSS + Gemini → aprovação)

### O que foi construído
Espelha o SP4 (vagas), agora para **notícias**: um pipeline lê fontes de referência via
RSS, o Gemini filtra relevância + categoriza + resume, e o resultado vira **sugestões**
que o Setor aprova no app. Por direitos autorais, guarda só **título + resumo próprio +
link** para a matéria na fonte.

- **Contrato — `noticias_sugeridas`:** id = `sha1(link)`; campos do `News` + `scrapedAt`
  + `status: 'pendente'|'recusada'`.
- **App:** `NoticiaSugerida` (envolve `News`); repo `watch/rejeitar/delete` +
  `noticiasSugeridasProvider`; card no hub "Notícias sugeridas (N)" →
  `AdminNoticiasSugeridasScreen` (Aprovar = `upsertNews` mesmo id + remove sugestão /
  Editar via `AdminNewsEditScreen.fromSuggestionId` / Recusar = tombstone). Fake com 2
  exemplos.
- **Pipeline (`pipeline/news.py`):** `feedparser` lê G1 Educação, MEC, concursos e IFSP;
  pré-filtro por palavra-chave (sisu, enem, concurso, edital, estágio, bolsa…); Gemini
  em modo JSON decide `{relevante, category, summary}`; grava via `firebase-admin`
  (dedup por `news`/`recusada`); reaproveita `init_firestore`/`init_gemini` do `main.py`.
  Nova dep `feedparser`. Workflow `pipeline-noticias.yml` (cron diário + manual).
- **Regra do Firestore:** `noticias_sugeridas` só admin (estende o catch-all junto com
  `news`/`vagas_sugeridas`).

### Verificação
- `flutter analyze`: sem erros. `flutter test`: **61/61** (round-trip NoticiaSugerida,
  filtro/ordem das sugeridas, aprovar cria News + remove, smoke da tela). `news.py`
  valida sintaxe; funções `casa_keyword`/`news_doc_id` testadas.
- **Pendências operacionais do usuário:** publicar a regra atualizada do Firestore;
  manter o Actions habilitado (secrets já existem); re-rodar o seed (cria
  `noticias_sugeridas` de exemplo). Feeds que mudarem são manutenção esperada.

### Nota de TCC
A camada externa passou a ter **dois pipelines** (vagas via API Gupy; notícias via RSS),
ambos com curadoria humana no app antes de chegar ao aluno (RF037).

---

## SP6 — Polimento da Home + remoção dos "Em breve" (2026-06-24)

### Objetivo
Eliminar os placeholders "Em breve" das telas principais, ligando-os a dados/telas
reais — maior ganho de qualidade percebida para a apresentação do TCC.

### Mudanças
- **Home (`home_screen.dart`):**
  - Card de destaque agora exibe uma **vaga real em aberto** (`allInternshipsProvider`,
    primeira `open && visibleAt`), com cargo + empresa · bolsa; toca → detalhe da vaga.
    Some quando não há vagas (sem dado falso).
  - Barra de **busca** abre a nova tela `/busca` (era "Em breve").
  - **Sino** do cabeçalho abre `/noticias` (era "Em breve").
  - Ação rápida "Moradia" (rota inexistente → "Em breve") trocada por **"Notícias"**.
- **Busca (`features/search/screens/busca_screen.dart`):** tela nova. Busca unificada
  (≥2 letras) em cursos, benefícios (contentDocs gov+inst), vagas e notícias, com
  resultados agrupados e navegação direta para cada item.
- **Perfil (`perfil_screen.dart`):**
  - "Carteirinha digital" → nova tela `/carteirinha` (cartão gerado do perfil:
    nome, curso curto, matrícula, avatar).
  - "Alterar senha" → envia **e-mail de redefinição** (Firebase
    `sendPasswordResetEmail`), com diálogo de confirmação.
  - "Termos e privacidade" → nova tela estática `/termos`.
- **Auth:** `AuthRepository.resetPassword` (interface) + implementações Firebase
  (`sendPasswordResetEmail`) e Fake (valida conta existente).

### Verificação
- `flutter analyze`: sem erros. `flutter test`: **61/61** (suíte existente sem regressão).

### Nota de TCC
Restam como "Em breve" apenas guardas genéricas em rotas não usadas (fallback do drawer
e do `_go` da Home); nenhuma entrada visível ao aluno cai nelas. Carteirinha é documento
interno gerado a partir do perfil (não substitui a carteirinha institucional).

---

## SP7a — Central de notificações + filtro por curso (2026-06-25)

### Objetivo
Avisar o estudante sobre novidades (vagas do seu curso, notícias) e permitir o filtro
opt-in "só o meu curso". Push real no aparelho fica para o SP7b (FCM + Android).

### Mudanças
- **Modelo `AppNotification`** (`type` vaga/noticia/sistema, `targetCourse?`, `route?`,
  `createdAt`) + coleção `notifications`. (Substituiu um modelo órfão do protótipo.)
- **Repositório**: `watchNotifications()` (50 mais recentes) + `addNotification()` no
  Firestore e no Fake (com 2 exemplos + getter p/ seed). `notificationsProvider`.
- **Geração na curadoria (RF037)**: aprovar vaga/notícia cria a notificação
  (vaga → targetCourse do curso, route `/estagio`; notícia → route `/noticias/{id}`).
- **Perfil**: `StudentProfile` ganhou `onlyMyCourse` (opt-in, padrão false) e
  `lastSeenNotificationsAt`. Toggle "Mostrar só o meu curso" no Perfil.
- **UI**: sino da Home abre `/notificacoes` com badge de não-lidas
  (`unreadNotificationsCountProvider`: compara `createdAt` com `lastSeenAt` e respeita o
  filtro de curso). `NotificacoesScreen` marca como visto ao abrir.
- **Filtro por curso** aplicado também: lista de estágios assume o curso do aluno quando
  o toggle está ligado; destaque da Home já é sensível ao curso.
- **Regras Firestore**: `notifications` já coberto pelo catch-all (leitura logada,
  escrita admin) — sem mudança.
- **Seed**: popula `notifications` de exemplo.

### Verificação
- `flutter analyze` limpo. `flutter test`: **63/63** (round-trip + `matchesCourse`).
- Deploy no Firebase Hosting (https://universe-app-ifsp.web.app).

### Nota de TCC
A notificação só nasce de conteúdo **curado** pelo admin (nunca direto do raspador),
mantendo o RF037. SP7b (push real no celular) exige build Android + FCM + função
enviadora — planejado na spec `2026-06-25-sp7-notificacoes-design.md`.

---

## SP7b — Push real (FCM): artefatos preparados (2026-06-25)

### Situação
A central (SP7a) já roda. O push no aparelho depende de pré-requisitos de ambiente que
são do autor, então o que **não depende** deles foi adiantado e versionado; o cliente
Flutter fica documentado para colar quando o ambiente estiver pronto.

- **Bloqueio 1:** adicionar `firebase_messaging` exige `flutter pub get` com **Modo de
  Desenvolvedor do Windows** ativo (symlinks de plugin). Sem isso o pub get falha.
- **Bloqueio 2:** Cloud Functions exige **plano Blaze**.

### Entregue agora (não quebra o build atual)
- **Cloud Function** `functions/index.js` (gatilho `onCreate` em `notifications/{id}`;
  filtra tokens por curso via `courseShort`; envia multicast; limpa tokens inválidos) +
  `functions/package.json` + `.gitignore`. `firebase.json` ganhou `functions.source`.
- **Guia** `docs/desenvolvimento/push-fcm-setup.md` com o passo a passo e o código do
  cliente (`PushService`, provider, wiring no `main.dart`, build do APK, push web/VAPID).

### Próximo (quando o autor liberar o ambiente)
Ativar Modo Dev → `firebase_messaging` + PushService + wiring; Blaze →
`firebase deploy --only functions`; `flutter build apk --release` para testar no celular.

---

## SP7b — Push real (FCM): cliente implementado (2026-06-25)

Modo de Desenvolvedor do Windows ativado pelo autor → `firebase_messaging` adicionado.

- **`firebase_messaging: ^15.1.3`** no pubspec.
- **`PushService`** (`lib/data/push/push_service.dart`): pede permissão, pega o token e
  grava em `users/{uid}.fcmTokens` (arrayUnion) + escuta `onTokenRefresh`. **Guard `kIsWeb`**
  (web não registra — precisa de VAPID/SW), então o build/deploy web seguem intactos.
- **`pushServiceProvider`** em repository_provider.
- **`main.dart`**: handler de background (`@pragma('vm:entry-point')`), registro/limpeza do
  token no `authStateProvider`, e **balão em foreground** via `scaffoldMessengerKey`
  (SnackBar em `FirebaseMessaging.onMessage`).
- **Cloud Function** `onNotificationCreated` deployada (Blaze): envia FCM por curso.
  Primeiro deploy exigiu habilitar APIs (cloudfunctions/cloudbuild/run/eventarc/pubsub) e
  aguardar a propagação do Eventarc Service Agent.
- Verificação: `flutter analyze` limpo, **63 testes**, `flutter build web` OK.

### Notícias
Selo **"Destaque"** no card + ordenação pinned-first reforçada na lista; o carrossel já
ordenava. `MAX_DIAS_NOTICIA=2` fixado no workflow de notícias.

### Pendência de teste
Validar push de ponta a ponta no **APK** (build/install no celular) — `flutter build apk
--release`. Push web fica para depois (VAPID + service worker).

---

## Ajustes de identidade e conteúdo (2026-07-01)

Rodada de acabamento a partir da revisão do app pelo autor. Três frentes:

### 1. CEP do IFSP corrigido (02610-002 → 05110-000)
O endereço do campus estava com o CEP errado. A tela do IFSP é servida pela coleção
**`ifspInfo`** do Firestore (não muda só com o código), então a correção foi em dois lugares:
- **Produção:** script pontual `pipeline/fix_ifsp_cep.py` (get-modify-set, idempotente,
  deep-replace do CEP em qualquer campo, inclusive no `detail` aninhado). Atualizou
  `ifspInfo/endereco`.
- **Seed/dev:** `fake_universe_repository.dart` (bloco `endereco`).
- Decisão de escopo: **não** tornar a tela do IFSP editável pelo admin agora — ela usa
  modelo próprio (`IfspInfo`/`IfspDetail`), separado do editor de `ContentDocs`; fica como
  evolução futura.

### 2. "Painel do Setor de Estágios" → "Painel de Administração"
O painel já abrange vagas, notícias e páginas de conteúdo, então o rótulo ganhou um nome
mais abrangente na UI (drawer, `admin_hub_screen`, `admin_panel_screen`) + teste
`admin_gating_test` ajustado. **No TCC nada muda**: "Setor de Estágios" continua como o
*ator/curador* nas seções §2.2/§2.4; apenas o rótulo visível ficou mais genérico.

### 3. Ícone do app (Android + web)
Faltava a identidade visual nos ícones (eram os padrões do Flutter). Gerado o ícone
1024px **por código** (`scratchpad/gen_icon.py`, PIL) reproduzindo o `UniverseAppIcon` da
marca — squircle verde com gradiente, "V" branco e o ponto verde-claro (cabeça do formando):
- Fontes em `assets/icon/` (`app_icon.png` cheio + `app_icon_foreground.png` p/ adaptativo).
- **`flutter_launcher_icons`** (dev dep) gerou: Android legado + **adaptativo**
  (foreground/background `#00573A`), **web** (Icon-192/512 + maskable) e **favicon**.
- Metadados genéricos corrigidos de brinde: rótulo Android **"Universe"**, `<title>` e
  descrição da web, e `manifest.json` (nome real + tema verde `#00573A`).

### Publicação
- **Web:** `flutter build web --release` → `firebase deploy --only hosting` →
  **https://universe-app-ifsp.web.app** (nova versão no ar, já com ícone/manifesto).
- **APK:** `flutter build apk --release` (release novo com o ícone e o rename).
- Verificação: `flutter analyze lib test` **sem issues**; `admin_gating_test` verde.
