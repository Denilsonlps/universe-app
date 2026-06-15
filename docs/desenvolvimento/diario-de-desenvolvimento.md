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
