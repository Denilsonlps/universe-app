# SP7 — Notificações (central no app + filtro por curso) e push (Android)

**Data:** 2026-06-25
**Status:** SP7a aprovado (fazer agora); SP7b planejado (push real).

## Objetivo
Avisar o estudante sobre novidades relevantes (especialmente novas vagas do seu
curso) e notícias. O app tem como alvo o uso no celular; push real depende do app
Android (FCM), então o trabalho é dividido em duas fases.

## SP7a — Central de notificações + filtro por curso (esta fase)

### Modelo
`AppNotification { id, title, body, type ('vaga'|'noticia'|'sistema'), targetCourse?, route?, createdAt }`
em coleção `notifications`. `targetCourse` nulo = para todos; senão, rótulo curto do
curso (ex.: 'ADS').

### Geração (respeita a curadoria RF037)
A notificação nasce quando o **admin aprova** uma sugestão:
- Aprovar vaga (`AdminSugestoesScreen`) → notificação type=`vaga`, targetCourse=curso da
  vaga, route=`/estagio`.
- Aprovar notícia (`AdminNoticiasSugeridasScreen`) → type=`noticia`, targetCourse=null,
  route=`/noticias/{id}`.
Só conteúdo curado gera aviso (nunca o raspador direto).

### Preferências do aluno (no perfil)
- `onlyMyCourse` (bool, **padrão false / opt-in**): quando ligado, mostra só vagas e
  notificações do curso do aluno.
- `lastSeenNotificationsAt` (DateTime?): marca a última visita à central; usado para o
  contador de não-lidas.

### UI
- Sino da Home abre `/notificacoes`; ponto/badge aparece quando há não-lidas.
- `NotificacoesScreen`: lista (filtrada pelo curso quando `onlyMyCourse`), toque navega
  pela `route`; ao abrir, grava `lastSeenNotificationsAt = agora`.
- Filtro por curso aplicado também à lista de estágios (curso inicial = curso do aluno)
  e ao card de destaque da Home (já sensível ao curso).
- Toggle "Mostrar só o meu curso" no Perfil.

### Dados / segurança
- Regra Firestore: `notifications` — leitura por logado; escrita só admin (estende o
  catch-all junto com news/sugeridas).

### Não-objetivos (ficam para SP7b)
- Push real (FCM), token por dispositivo, Cloud Function enviadora, build Android.

## SP7b — Push real no celular (próxima fase)
`firebase_messaging` + permissão + token salvo no usuário; Cloud Function dispara FCM
no `onCreate` de `notifications` (filtrando por curso); build Android (APK) para validar
push no aparelho. Web tem push parcial (PWA).

## Verificação
`flutter analyze` limpo; `flutter test` verde (round-trip do modelo + Fake implementa as
novas operações). Deploy no Firebase Hosting.
