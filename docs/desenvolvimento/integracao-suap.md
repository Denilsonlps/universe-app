# Integração com o SUAP — Estudo de viabilidade e decisão

> Documento de apoio ao TCC. Registra a pesquisa sobre a integração do app
> Universe com o SUAP (Sistema Unificado de Administração Pública) para login
> institucional e obtenção dos dados acadêmicos do aluno.

## Contexto

Duas necessidades do app não estavam previstas no escopo documentado do TCC e
surgiram do protótipo/evolução do projeto:

1. **Autenticação do estudante** (login). O TCC **não define** requisito de login,
   conta de usuário ou senha. "E-mail institucional", no documento, refere-se
   apenas ao e-mail do Setor de Estágios e ao método atual de divulgação de vagas.
2. **Dados acadêmicos do aluno** (curso, matrícula) para personalizar o conteúdo
   — em especial filtrar vagas de estágio por curso (RF031). O TCC trata "perfil
   do aluno" apenas conceitualmente; não especifica como obter esses dados.

> **Pendência de documentação do TCC:** incluir um requisito de autenticação (com
> justificativa: personalização por curso, vínculo do aluno, proteção de dados) ou
> registrar o login como evolução além do escopo original — análogo à migração
> FlutterFlow→Flutter.

## O que o SUAP oferece

- **API REST oficial** desenvolvida pela DIGTI do IFRN, usada também pelo IFSP
  (`suap.ifsp.edu.br`; documentação de referência em `suap.ifrn.edu.br/api/docs`).
- Expõe dados do aluno conforme o nível de permissão: **matrícula, nome, e-mail,
  foto, vínculo e curso**, além de boletim (notas/frequência), períodos letivos e
  horários.
- **Autenticação:**
  - **Token JWT** — `POST /api/v2/autenticacao/token/` com usuário/senha retorna
    `access`/`refresh`; dados em `GET /api/v2/minhas-informacoes/meus-dados/`
    (header `Authorization: Bearer <access>`). *(Confirmar caminhos exatos na
    documentação viva ao implementar.)*
  - **OAuth2 (recomendado)** — o IFSP atua como **provedor de identidade**: o
    aluno autentica na **página do SUAP** e o app recebe um token **sem ter acesso
    à senha institucional**. Mais seguro que o fluxo de token direto.
- **Registro do app no IFSP (necessário para OAuth2):** enviar e-mail para
  `suporte@ifsp.edu.br` com o app, o objetivo e a *redirect URL* (callback); o
  IFSP devolve os parâmetros de segurança (client_id/secret).
- **Precedente:** o app oficial **IFSP Conecta** (Android) já integra com o SUAP
  para alunos e servidores — evidência de que a integração é viável.

### Fontes
- API SUAP (docs): https://suap.ifrn.edu.br/api/docs/
- Notícia DIGTI/IFRN (interface para apps): https://portal.ifrn.edu.br/campus/reitoria/noticias/digti-cria-interface-que-auxilia-o-desenvolvimento-de-aplicativos/
- Wrapper PHP da API: https://github.com/ivmelo/suap-api-php
- Biblioteca OAuth2 SUAP: https://github.com/emersonart/Suap-OAuth2-PHP
- IFSP Conecta (Android): https://pep.ifsp.edu.br/index.php/publicacoes/547-aplicativo-ifsp-conecta-android

## Decisão: abordagem híbrida

O login via SUAP (OAuth2) resolveria login **e** dados do aluno de uma só vez —
porém depende da **aprovação do registro do app pelo IFSP**, prazo incerto para o
TCC. Para não travar a entrega, adotou-se uma estratégia **híbrida e à prova de
prazo**, aproveitando a interface `AuthRepository` já existente:

| Caminho | Papel | Estado |
|---|---|---|
| **Firebase Auth (e-mail/senha)** | Login funcional imediato; app demonstrável já | Implementado (Plano 2) |
| **Perfil auto-declarado no Firestore** | Aluno informa curso/matrícula (no cadastro **e** editável no perfil); personaliza conteúdo | A implementar (Plano 3) |
| **SUAP OAuth2** (`SuapAuthRepository`) | Login institucional preferencial + dados do aluno automáticos | Desenhado; implementação condicionada à aprovação do IFSP |

**Plano de contingência:** se a aprovação do IFSP sair a tempo, o SUAP vira o
login principal e a fonte dos dados do aluno; caso contrário, o fluxo
Firebase + perfil auto-declarado garante a entrega. A arquitetura
(interface `AuthRepository` + camada de perfil) absorve essa troca sem reescrever
a UI.

## Considerações de segurança

- Preferir **OAuth2** ao fluxo de token direto: evita que o app manipule a senha
  institucional do aluno (IFSP permanece como detentor das credenciais).
- Nunca armazenar senha institucional. Tokens (access/refresh) em armazenamento
  seguro do dispositivo.
- Solicitar apenas os escopos/dados necessários (curso, matrícula, nome).
