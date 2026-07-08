# Guia de Arquitetura + Preparação para a Banca — Universe

> Documento de apoio à **compreensão do código** e à **defesa** do TCC.
> Explica *como tudo funciona*, o *porquê* de cada decisão e reúne as
> **perguntas mais prováveis da banca** com respostas objetivas.

---

## 1. Visão geral

**Universe** é um aplicativo para os estudantes do **IFSP – Câmpus Pirituba** que
centraliza, em um só lugar: informações do campus, cursos, benefícios
(governamentais e institucionais), vagas de estágio, concursos públicos e
notícias. Objetivo: **fortalecer a permanência estudantil** facilitando o acesso à
informação e às oportunidades.

- **Front-end:** Flutter (um mesmo código gera **web** e **Android**).
- **Back-end:** serviços gerenciados do **Firebase** (sem servidor próprio).
- **Automação + IA:** um *pipeline* em **Python** coleta vagas e notícias da
  internet e usa o **Google Gemini** para classificar e resumir.

---

## 2. Arquitetura em três camadas

```
┌── (1) PROCESSAMENTO EXTERNO — Python + IA (GitHub Actions, agendado) ──┐
│   API pública da Gupy (vagas)  ─┐                                       │
│   Feeds RSS (notícias)          ├─► script Python ─► Google Gemini      │
│                                 ┘   (coleta)         (classifica/resume) │
└───────────────────────────────┬────────────────────────────────────────┘
                                ▼  grava SUGESTÕES (status "pendente")
┌── (3) DADOS — Cloud Firestore ─────────────────────────────────────────┐
│   vagas_sugeridas / noticias_sugeridas  ──(curadoria do admin)──►        │
│   internships / news / contents … (conteúdo publicado, leitura pública) │
└───────────────────────────────┬────────────────────────────────────────┘
                  ┌─────────────┴───────────────┐
                  ▼                             ▼
        ┌── Cloud Function ──┐        ┌── (2) APRESENTAÇÃO — Flutter ──┐
        │ onNotificationCreated│──FCM─►│  Aluno: consulta (lê)          │
        │  → push por curso    │       │  Admin: curadoria + cadastro   │
        └──────────────────────┘       └────────────────────────────────┘
```

- **Camada 1 (processamento):** roda **fora do app**, na nuvem, de forma agendada.
  Nunca fala direto com o aluno — só grava *sugestões* no banco.
- **Camada 2 (apresentação):** o app Flutter. O **aluno lê**; o **administrador**
  (Setor de Estágios/Comunicação) faz a **curadoria** e o cadastro.
- **Camada 3 (dados):** o Cloud Firestore, banco em nuvem que **sincroniza em
  tempo real** com o app.

---

## 3. Mapa do código (estrutura de pastas)

```
lib/
├── core/                # infraestrutura transversal
│   ├── providers/       # provedores Riverpod (auth, perfil, onboarding, tema, repositórios)
│   ├── router/          # go_router: rotas + proteção por login (app_router.dart)
│   ├── theme/           # cores e tema (claro/escuro)
│   └── utils/           # utilitários (ex.: geração de id/slug)
├── data/                # CAMADA DE DADOS
│   ├── auth/            # AuthRepository (interface) + Firebase + Fake
│   ├── models/          # modelos (AppUser, Internship, Contest, News, VagaSugerida…)
│   ├── repositories/    # UniverseRepository (interface) + Firestore + Fake
│   ├── content/         # ContentDoc (páginas de conteúdo editáveis)
│   ├── profile/         # perfil do estudante (curso, role)
│   ├── push/            # PushService (registro de token FCM)
│   └── storage/         # upload de imagens (Firebase Storage)
├── features/            # CAMADA DE APRESENTAÇÃO (uma pasta por área)
│   ├── auth/            # onboarding, login, registro, splash
│   ├── home/ campus/ courses/ benefits/ internships/ news/ …
│   ├── notifications/   # central de notificações
│   └── admin/           # painel de administração + curadoria + editores
├── shared/              # widgets e "chrome" reutilizáveis
│   ├── brand/           # identidade visual (logo/ícone desenhados em código)
│   ├── chrome/          # cabeçalhos, barra inferior, menu lateral
│   └── widgets/         # botões, campos, cards, badges…
└── main.dart            # ponto de entrada: inicializa Firebase e sobe o app

pipeline/                # CAMADA DE PROCESSAMENTO (Python)
├── main.py              # coleta vagas (Gupy) + Gemini → vagas_sugeridas
├── news.py              # coleta notícias (RSS) + Gemini → noticias_sugeridas
└── fix_content.py       # correções pontuais de conteúdo em produção
functions/
└── index.js             # Cloud Function: envia push quando nasce uma notificação
```

Números aproximados: **~100 arquivos Dart** (core 10, data 28, features 36, shared 27),
2 pipelines Python e 1 Cloud Function.

---

## 4. Componentes principais (como funcionam)

### 4.1 Autenticação
- **Interface `AuthRepository`** (`data/auth/`) com duas implementações:
  `FirebaseAuthRepository` (produção) e `FakeAuthRepository` (testes, em memória).
- `authStateProvider` é um **`StreamProvider<AppUser?>`**: emite o usuário logado
  ou `null`, reagindo a login/logout em tempo real.
- No **cold start**, o stream é *semeado* com `FirebaseAuth.instance.currentUser`
  para refletir imediatamente a sessão já salva em disco (evita "piscar" a tela de
  login mesmo estando logado).

### 4.2 Navegação e proteção de rotas
- **`go_router`** (`core/router/app_router.dart`). O `redirect` decide a rota a
  partir de **duas fontes assíncronas**: o estado de autenticação e se o
  *onboarding* já foi visto. Enquanto qualquer uma não "assentou", mostra a
  **splash**; depois decide: deslogado → onboarding/login; logado → home.
- Rotas de administração (`/admin/...`) só aparecem para `role == 'admin'`.

### 4.3 Gerência de estado — Riverpod
- Todo o estado (usuário, perfil, tema, listas de dados) vem de **provedores**
  Riverpod. As telas fazem `ref.watch(...)` e se **reconstroem sozinhas** quando o
  dado muda. Isso combina com os *streams* do Firestore para dar **tempo real**.

### 4.4 Camada de dados — repositórios
- **`UniverseRepository`** (interface) expõe `watch…()` (streams de leitura) e
  métodos de escrita (`upsert…`, `delete…`). Duas implementações:
  `FirestoreUniverseRepository` (produção) e `FakeUniverseRepository` (dev/testes).
- O app depende da **interface**, não do Firestore diretamente — por isso os
  testes rodam sem rede (injetando o Fake).

### 4.5 Conteúdo dinâmico (benefícios)
- Páginas de benefícios são **`ContentDoc`** — documentos com seções tipadas
  (texto, mídia, passos, fontes). O admin edita pelo app; o aluno vê na hora.
  Suporta *wikilinks* `[[termo]]` que abrem um glossário.

### 4.6 Notificações push (FCM)
- No app, o **`PushService`** pede permissão, obtém o **token FCM** e o grava em
  `users/{uid}.fcmTokens`.
- No servidor, a **Cloud Function `onNotificationCreated`** dispara quando um
  documento nasce na coleção `notifications`. Ela lê os usuários, **filtra pelos
  tokens do curso-alvo** e envia o push via FCM (removendo tokens mortos).

### 4.7 Pipeline de dados + IA
- **Vagas (`pipeline/main.py`):** busca vagas de estágio na **API pública da
  Gupy** (JSON), envia a descrição de cada vaga ao **Google Gemini
  (gemini-2.5-flash)**, que **classifica o curso** e **extrai/resume** os dados
  (resumo, requisitos, bolsa, benefícios). Grava em `vagas_sugeridas` com status
  `pendente`. Também **encerra** automaticamente vagas que saíram do ar (RF034).
- **Notícias (`pipeline/news.py`):** lê **feeds RSS** de fontes oficiais, usa o
  Gemini para **resumir e categorizar**, e grava em `noticias_sugeridas`.
- Ambos rodam de forma **agendada no GitHub Actions** (cron), sem servidor próprio.
- **Curadoria:** as sugestões só viram conteúdo público (`internships`/`news`)
  depois que o admin **aprova/edita** no painel.

### 4.8 Segurança (regras do Firestore)
- Coleções de conteúdo (`courses`, `news`, `internships`, `contentDocs`, …):
  **leitura pública**, **escrita apenas para admin** (checagem de `role`).
- Coleções de triagem (`vagas_sugeridas`, `noticias_sugeridas`): acesso restrito.
- O papel `admin` fica no perfil do usuário; a UI e as regras **ambas** verificam.

---

## 5. Tecnologias e por que foram escolhidas

| Tecnologia | Papel | Por quê |
|---|---|---|
| **Flutter/Dart** | App (web + Android) | Um só código para as duas plataformas; performance nativa; substituiu o **FlutterFlow**, que tinha limitações de flexibilidade/versionamento |
| **Riverpod** | Estado | Reativo, testável, desacopla UI e dados |
| **go_router** | Navegação | Rotas declarativas + `redirect` para proteção por login |
| **Firebase Auth** | Login | Pronto, seguro, com persistência de sessão |
| **Cloud Firestore** | Banco | Sincronização **em tempo real**, escalável, sem servidor; regras de segurança declarativas |
| **Firebase Storage** | Imagens | Upload de imagens de conteúdo |
| **FCM + Cloud Functions** | Push | Notificações por curso, disparadas por evento no banco |
| **Firebase Hosting** | Web | Publicação da versão web |
| **Python + Gemini** | Pipeline/IA | Coleta e enriquece dados; a IA classifica e resume |
| **GitHub Actions** | Agendamento | Roda os pipelines periodicamente, de graça |

---

## 6. Perguntas prováveis da banca (com respostas)

**Por que Flutter e não FlutterFlow ou desenvolvimento nativo?**
> Começamos no FlutterFlow (baixo código), mas suas limitações de flexibilidade,
> versionamento e recursos avançados nos levaram a **migrar para o Flutter puro**,
> escrito à mão. O Flutter mantém a vantagem de **um código para web e Android**,
> com mais controle sobre a interface e a lógica.

**Como a inteligência artificial classifica as vagas? Qual modelo?**
> Usamos o **Google Gemini (gemini-2.5-flash)**. Para cada vaga coletada, enviamos
> a descrição bruta com um *prompt* que pede a saída em **JSON**, contendo o
> **curso** (dentre os do campus) e campos estruturados (resumo, requisitos,
> bolsa, benefícios). Um exemplo real está no **Quadro 05** do TCC.

**E se a IA errar ou "alucinar"?**
> Por isso existe a **curadoria humana**: nenhuma sugestão é publicada
> automaticamente — o administrador **aprova, edita ou recusa** antes. A IA
> **acelera** o trabalho; a decisão final é humana. Além disso, o curso é
> normalizado por uma tabela de rótulos válidos (`map_course`).

**Onde o pipeline roda? Tem servidor? Qual o custo?**
> Não há servidor próprio. Os scripts rodam **agendados no GitHub Actions**
> (gratuito). O back-end é todo **Firebase** (plano com cota gratuita generosa;
> as Cloud Functions exigem o plano Blaze, com custo residual).

**Como os dados chegam ao app em tempo real?**
> O Firestore expõe *streams*: os repositórios usam `snapshots()` e o Riverpod
> reconstrói a tela automaticamente quando um dado muda. Ou seja, o que o admin
> publica **aparece na hora** para o aluno, sem "atualizar".

**Como funciona a notificação push?**
> Ao publicar, cria-se um documento em `notifications`. Isso dispara a **Cloud
> Function**, que busca os **tokens FCM** dos alunos do **curso-alvo** e envia o
> push. O app registra o token no login (`PushService`).

**Como vocês impedem um aluno de virar administrador ou alterar dados?**
> O papel `admin` fica no perfil e é verificado **na interface e nas regras do
> Firestore**. As regras dão **leitura pública** ao conteúdo, mas **escrita só a
> admin**. Mesmo que alguém burlasse a UI, o banco recusaria a escrita.

**Por que Firestore (NoSQL) e não um banco SQL?**
> Pela **sincronização em tempo real**, pela **escalabilidade sem servidor** e
> pela integração direta com Auth/regras/Functions. O modelo de dados do app
> (documentos independentes: vagas, notícias, cursos) encaixa bem em NoSQL.

**A sessão de login não persistia no celular. Por quê?**
> Investigamos e **provamos em emulador Android limpo** que a sessão persiste
> normalmente. O problema era **específico do aparelho Xiaomi (HyperOS)**, que
> limpa o estado local do app ao fechá-lo — o que também derrubava as
> notificações. Mitigação: liberar *Autostart* e *bateria sem restrições*. É uma
> **limitação de ROMs OEM agressivas**, não do código.

**Como testaram o sistema?**
> Há **testes automatizados** (widget/unit) cobrindo autenticação, navegação
> (redirect), design system e regras de curadoria, rodando com o repositório
> **Fake** (sem rede). Além disso, verificação manual em web e Android.

**E a segurança da chave da API do Gemini?**
> A chave **não fica no app** — ela é usada apenas no pipeline (servidor), via
> variável de ambiente/segredo do GitHub Actions, nunca commitada no repositório.

**Qual a diferença entre `vagas_sugeridas` e `internships`?**
> `vagas_sugeridas` é a **fila de triagem** (o que a IA coletou, aguardando
> curadoria). `internships` é o **conteúdo publicado**, que o aluno vê. A vaga só
> passa de uma para outra quando o admin **aprova**.

**O app funciona offline?**
> O Firestore tem cache local, então dados já carregados podem ser exibidos sem
> rede; ações de escrita e o login exigem conexão.

**Web e Android usam o mesmo código?**
> Sim — o mesmo projeto Flutter gera as duas versões. Poucos pontos são
> específicos de plataforma (ex.: push no Android via FCM; no web depende de
> configuração adicional de VAPID).

**LGPD / dados pessoais?**
> O app coleta o mínimo (nome, e-mail institucional, curso) para autenticação e
> personalização. As vagas/notícias vêm de **fontes públicas**. Não há tratamento
> de dados sensíveis.

---

## 7. Limitações conhecidas (seja transparente na defesa)
- **Push na versão web** ainda não habilitado (exige VAPID + service worker).
- **Dependência da curadoria humana** para publicar (intencional, pela qualidade).
- **ROMs agressivas (Xiaomi/HyperOS)** podem limpar a sessão/token ao fechar o app
  — mitigável nas configurações do aparelho.
- O pipeline depende de **fontes externas** (API da Gupy, feeds RSS): mudanças
  nelas exigem manutenção — por isso há tratamento de erro por item.

---

*Este guia acompanha o código-fonte comentado e o diário de desenvolvimento
(`docs/desenvolvimento/diario-de-desenvolvimento.md`).*
