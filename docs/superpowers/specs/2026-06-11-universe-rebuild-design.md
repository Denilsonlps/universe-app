# Universe — Reconstrução (Rodada 1) · Documento de Design

**Data:** 2026-06-11
**Projeto:** Universe — app para estudantes do IFSP Campus Pirituba
**Base:** TCC (Lopes & Silva, 2026) + protótipo handoff Claude Design (React/JSX)

---

## 1. Contexto e propósito (do TCC)

O Universe é uma aplicação mobile que centraliza, para os estudantes do IFSP
Campus Pirituba, informações sobre: o campus, cursos, benefícios governamentais
e institucionais, vagas de estágio e concursos públicos. O objetivo é fortalecer
as políticas de permanência estudantil, democratizando o acesso a recursos hoje
dispersos em e-mails e murais (TCC §1.1).

Público-alvo: estudantes (ingressantes e remanescentes). Ator secundário: o
**Setor de Estágios** do campus, que cadastra vagas. Atores externos: sites de
vagas (coletados por pipeline externo).

## 2. Arquitetura alinhada ao TCC (§2.4.1 — três camadas)

O TCC define uma arquitetura em **três camadas**. Esta reconstrução implementa a
**camada de apresentação** e consome a **camada de dados**; a camada de
processamento externo permanece fora do app:

| Camada (TCC) | O que é | Neste projeto |
|---|---|---|
| **Processamento externo** | Script Python: web scraping + categorização por LLM (Gemini) → CSV | **Externo ao app.** O app não o executa. Restrição: o modelo de `Vaga` deve casar com os campos que o pipeline produz. |
| **Apresentação** | App Universe (consulta pelo aluno; cadastro pelo Setor de Estágios) | **Este app Flutter.** Aluno lê; admin (Setor de Estágios) escreve vagas. |
| **Dados** | Firebase Firestore (armazenamento + sincronização) | Interface `UniverseRepository`. Implementação `MockUniverseRepository` agora; `FirestoreUniverseRepository` na fase de dados. |

### 2.1 Divergência registrada: FlutterFlow → Flutter

O TCC documenta que o app foi construído em **FlutterFlow** (low-code, §1.4.4 e
§2.6). Esta reconstrução usa **Flutter codado à mão**. É uma divergência
**deliberada** com a documentação. Decisão acadêmica pendente do autor: tratar no
texto do TCC como **evolução/migração** (FlutterFlow para Flutter nativo) ou
ajustar a seção de ferramentas. **Não bloqueia a implementação.**

### 2.2 Estrutura de pastas (feature-first, camadas claras)

```
lib/
  core/
    theme/        app_colors (claro+escuro), app_theme (M3 + Montserrat)
    router/       app_router (go_router): ShellRoute + rotas full-screen
    providers/    theme_provider, auth_provider, repository_provider
  shared/
    widgets/      design system: AppButton, AppCard, AppChip, AppField,
                  IconTile, ListRow, StatusBadge, Stars, EmptyState,
                  Accordion, UserAvatar, AppToggle, SectionTitle
    chrome/       PageShell, HomeHeader, PageHeader, GreenHero,
                  BottomNav, MenuDrawer, AppToast
  data/
    models/       user, course, benefit, internship (vaga), contest (concurso),
                  testimonial, faq, ifsp_info, notification — imutáveis
    repositories/ universe_repository (abstrato)
                  mock_universe_repository (Rodada 1)
                  [firestore_universe_repository — fase de dados]
  features/
    auth/  home/  campus/  courses/  benefits/  internships/  faqs/  profile/
  main.dart       Firebase.initializeApp + ProviderScope + MaterialApp.router
```

**Regra de isolamento:** a UI depende **apenas** da interface `UniverseRepository`.
Trocar mock→Firestore = mudar uma linha no `repository_provider`.

## 3. Modelo de dados (fidelidade aos requisitos funcionais)

### 3.1 `Internship` (Vaga) — RF033, RF034

RF033 exige **10 campos**. O protótipo unia "descrição da vaga" e "descrição da
empresa" num só `about`; **separamos** para cumprir o RF033:

| # (RF033) | Campo | Tipo |
|---|---|---|
| i | `companyName` (empresa) | String |
| ii | `area` (área de atuação) | String |
| iii | `role` (cargo) | String |
| iv | `duration` (duração) | String |
| v | `jobDescription` (descrição da vaga) | String |
| vi | `requirements` (pré-requisitos) | List\<String> |
| vii | `niceToHave` (diferenciais) | List\<String> |
| viii | `companyDescription` (descrição da empresa) | String |
| ix | `benefits` (benefícios) | List\<String> |
| x | `grant` (salário/bolsa) | String |

Campos auxiliares (do protótipo + regras): `id`, `course` (RF031: organizar por
curso), `mode` (presencial/híbrido), `link`, `tag`, `status` (`open`/`closed`),
`closedAt` (DateTime?).

**RF034:** vaga `closed` permanece visível para consulta por **até 1 mês** após
`closedAt`. Filtro do repositório oculta vagas encerradas há mais de 30 dias.

### 3.2 `Contest` (Concurso) — RF035, RF036

`id`, `role`, `org`, `vagas`, `salary`, `level`, `deadline` (DateTime), `status`,
`link`, `about`. **RF036:** edital visível **apenas durante o período de
inscrição** — filtro por `deadline`/`status`.

### 3.3 Demais modelos
`Course` (RF013: benefícios específicos por curso quando aplicável), `Benefit`
(gov/inst, com `steps` de obtenção — RF011), `Testimonial` (RF032),
`Faq`, `IfspInfo`/`IfspDetail`, `AppNotification`, `AppUser`.

### 3.4 Avisos legais (disclaimers)
- **RF037:** na tela de detalhe da vaga/concurso — "O app apenas divulga; o
  processo seletivo é conduzido pela empresa/órgão responsável."
- **RF012:** na tela de benefícios — "O app não cria nem gere benefícios;
  dúvidas devem ir aos canais oficiais do campus."

## 4. Repositório e controle de acesso

```dart
abstract interface class UniverseRepository {
  // Leitura (aluno)
  Future<List<Course>> getCourses();
  Future<List<Internship>> getInternships({String? course});   // aplica RF034
  Future<List<Contest>> getContests();                          // aplica RF036
  Future<List<Benefit>> getBenefits(BenefitKind kind);
  Future<List<Testimonial>> getTestimonials();
  Future<List<Faq>> getFaqs();
  // ... ifspInfo, notifications

  // Escrita (admin — Setor de Estágios) — usado pelo Painel Admin (Rodada 2)
  Future<void> upsertInternship(Internship vaga);
  Future<void> deleteInternship(String id);
  Future<void> addTestimonial(Testimonial t);   // aluno também publica (RF032)
}
```

**Papéis:** `student` (leitura) e `admin` (leitura + escrita de vagas). Mesmo o
Painel Admin sendo Rodada 2, a interface e o `AuthProvider` já distinguem o papel
agora, refletindo o ator "Setor de Estágios" do TCC.

## 5. Tema (claro + escuro)

Portados de `styles.css` do protótipo (valores exatos dos dois temas):
- Marca: `green-900..050`; superfícies neutras quentes; `ink/ink-2/ink-3`; `line`.
- Dark: superfícies invertidas, verdes de acento clareados para contraste.
- `ThemeMode` em provider Riverpod, persistido em `shared_preferences`.
  Alternador no Perfil e no menu lateral.
- Fonte **Montserrat** (google_fonts). Layout **fixo** (Home = lista,
  Benefícios = cards); os "tweaks" do protótipo eram experimentação de design.

## 6. Navegação

- `go_router` com `ShellRoute` → **bottom nav**: Início · Cursos · Dúvidas · Perfil.
- **Menu lateral** (drawer verde) com itens do TCC: IFSP, Cursos, Benefícios
  Gov/Inst, Estágio e Concursos, Moradia, Dúvidas, Cadastrar, Configurações, Sair.
- Detalhes em rotas full-screen com `GreenHero` (header verde curvo + voltar).
- Transições slide/fade equivalentes ao protótipo.

## 7. Autenticação (real — híbrido)

- **Firebase Auth** e-mail/senha (login + registro). Domínio sugerido
  `@aluno.ifsp.edu.br` (validação leve, não bloqueante).
- **Splash** decide rota inicial pelo estado de auth (auth → Home; senão →
  Onboarding/Login).
- Leitura de conteúdo via `MockUniverseRepository` nesta rodada.

## 8. Escopo

### Rodada 1 (esta spec) — núcleo do estudante
Fundação (tema claro+escuro, design system, chrome, router, Firebase Auth) +
**Splash, Onboarding, Login, Registro** + **4 abas** (Home, Cursos, Dúvidas/FAQ,
Perfil) + conteúdo principal: **IFSP** (+detalhe), **Benefícios Gov/Inst**
(+detalhe), **Estágio/Concursos** (+detalhe de vaga e de concurso, com
disclaimers e filtro por curso).

### Rodada 2 (depois)
Depoimentos (publicação pelo aluno — RF032), Moradia/Repúblicas, Carteirinha,
Cadastrar informações, Notificações, Busca global, **Painel Admin** (cadastro de
vagas — Setor de Estágios), tela de erro de conexão, Configurações.

### Fase de dados (depois da Rodada 2)
`FirestoreUniverseRepository` substitui o mock; regras de segurança Firestore por
papel (aluno lê / admin escreve).

## 9. Rastreabilidade de requisitos (TCC → entrega)

| Requisito | Onde é atendido |
|---|---|
| RF011 (lista de benefícios + obtenção) | Benefícios Gov/Inst + detalhe (`steps`) — R1 |
| RF012 (app não gere benefícios) | Disclaimer na tela de benefícios — R1 |
| RF013 (benefícios por curso) | `Course` + seção no detalhe do curso — R1 |
| RF031 (estágios por curso) | Filtro por curso na tela de Estágio — R1 |
| RF032 (depoimentos) | Carrossel em Estágio (R1) + tela/publish (R2) |
| RF033 (10 campos da vaga) | Modelo `Internship` + detalhe da vaga — R1 |
| RF034 (encerrada visível 1 mês) | `status`+`closedAt`, filtro no repositório — R1 |
| RF035/RF036 (editais no período) | `Contest.deadline`+filtro — R1 |
| RF037 (só divulgação) | Disclaimer no detalhe de vaga/concurso — R1 |
| RNF011 (responsivo) | Layout flexível Flutter — R1 |
| RNF014 (Android/iOS) | Flutter multiplataforma — R1 |
| RNF015 (carregamento < 3s) | Mock em memória; metas no Firestore — R1/dados |

## 10. Testes

- **Widget tests** para os primitivos do design system (Button, Card, Chip,
  Field, ListRow, StatusBadge) e para o `PageShell`/chrome.
- **Unit tests** para regras do repositório: filtro RF034 (1 mês) e RF036
  (período de inscrição), filtro por curso (RF031).
- Smoke test do fluxo de navegação (auth → home → detalhe).

## 11. Riscos / decisões em aberto
1. **FlutterFlow vs Flutter** (§2.1) — decisão acadêmica do autor.
2. **Aproveitamento do código atual:** a implementação existente em `lib/` foi
   derivada deste mesmo protótipo; valores corretos (cores, espaçamentos) serão
   reaproveitados, mas a arquitetura será reescrita conforme esta spec.
3. **Domínio de e-mail** no registro: validar `@aluno.ifsp.edu.br`? (sugerido:
   validação leve, não bloqueante).
