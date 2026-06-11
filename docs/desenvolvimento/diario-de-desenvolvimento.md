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
