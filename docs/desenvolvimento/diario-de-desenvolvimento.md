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
