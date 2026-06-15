# SP1 — Fundação Firestore · Documento de Design

**Data:** 2026-06-11
**Fase:** Dados & Admin (sub-projeto 1 de 3)
**Projeto:** Universe — app do IFSP Campus Pirituba

> Parte da fase **Dados & Admin & Conteúdo**, decomposta em 3 sub-projetos:
> **SP1 — Fundação Firestore** (este doc), **SP2 — Papel Admin + Painel**,
> **SP3 — Conteúdo rico editável + Glossário/wikilinks**. Cada um tem spec, plano
> e implementação próprios. Brainstorming aprovado em 2026-06-11.

## 1. Objetivo

Substituir o `MockUniverseRepository` (dados embutidos no app) pela leitura real do
**Cloud Firestore**, com **sincronização em tempo real** — para que vagas, editais e
demais conteúdos atualizem no app sem republicação. Inclui persistência real de
**depoimentos** e **perfil**, e as **regras de segurança** (aluno lê / admin escreve).
Concretiza a **camada de dados** da arquitetura de 3 camadas do TCC (§2.4.1) e a
justificativa de "sincronização em tempo real" do Firestore (§2.6).

Ver também: [`arquitetura-dados-tempo-real.md`](../../desenvolvimento/arquitetura-dados-tempo-real.md).

## 2. Abordagem: tudo via `Stream`

Todos os métodos de leitura do repositório retornam `Stream<…>` (Firestore
`snapshots()`), expostos por `StreamProvider` no Riverpod. A UI usa um único padrão
(`AsyncValue.when` — loading / error / data). Justificativa: um só padrão na UI;
listeners do Firestore são baratos e o cache offline cobre os dados estáticos (que
simplesmente emitem com pouca frequência). Alternativas consideradas e descartadas:
híbrido (streams+futures — dois padrões) e tudo `Future` (perde o tempo real, que é
requisito).

## 3. Modelo de dados (coleções Firestore)

```
courses/{id}        { name, category, type, duration, period, icon }
benefits/{id}       { kind: 'gov'|'inst', icon, title, tag, description, steps[], url? }
internships/{id}    { role, companyName, area, duration, jobDescription,
                      requirements[], niceToHave[], companyDescription, benefits[],
                      grant, course, mode, link?, tag?, open, closedAt?(Timestamp) }
contests/{id}       { role, org, vagas, salary, level, about, link?, deadline(Timestamp) }
testimonials/{id}   { name, course, org, text, stars, authorUid, createdAt(Timestamp) }
faqs/{id}           { category, question, answer }
ifspInfo/{key}      { icon, title, subtitle, detail: { body?, rows[] } }
notifications/{id}  { icon, color, title, body, time, route?, unread }
users/{uid}         { name, email, role: 'student'|'admin', course?, enrollment? }
```

- **Timestamps reais:** `internships.closedAt` e `contests.deadline` viram
  `Timestamp` do Firestore; as regras RF034 (vaga encerrada visível por 30 dias) e
  RF036 (edital no período) passam a usar datas do servidor, calculadas no cliente
  como hoje (`visibleAt`/`isOpenAt`).
- Cada modelo ganha `factory X.fromDoc(DocumentSnapshot)` e `Map<String,dynamic> toMap()`.
  `ifspInfo` unifica o item de lista e o detalhe num só documento por `key`.

## 4. Interface de repositório

`UniverseRepository` evolui para streams:
```dart
abstract interface class UniverseRepository {
  Stream<List<Course>> watchCourses();
  Stream<List<Benefit>> watchBenefits(BenefitKind kind);
  Stream<List<Internship>> watchInternships({String courseFilter = 'Todos'});
  Stream<List<Contest>> watchContests();
  Stream<List<Testimonial>> watchTestimonials();
  Stream<List<Faq>> watchFaqs();
  Stream<List<IfspInfo>> watchIfspInfo();
  // escrita usada por aluno (RF032) e seeding/admin
  Future<void> addTestimonial(Testimonial t);
}
```
Filtros temporais (RF034/RF036) e por curso (RF031) aplicados no cliente após o
snapshot (volume pequeno). Implementações:
- **`FirestoreUniverseRepository`** — produção (snapshots + mapeamento).
- **`FakeUniverseRepository`** — em memória, retornando streams; **substitui** o
  `MockUniverseRepository` como fonte de **seed** e base de **testes**. Mantém o
  conteúdo pt-BR já transcrito.

Provider: `universeRepositoryProvider` passa a fornecer `FirestoreUniverseRepository`;
testes sobrescrevem com `FakeUniverseRepository`. Providers de stream derivados
(ex.: `coursesProvider`, `internshipsProvider(course)`, `benefitsProvider(kind)`,
`contestsProvider`, `testimonialsProvider`, `faqsProvider`, `ifspInfoProvider`).

## 5. Telas (refatoração para assíncrono)

Cada tela troca a leitura síncrona de `List` por `ref.watch(<streamProvider>)` e
renderiza via `AsyncValue.when`:
- **loading:** spinner/shimmer (usar `shimmer` já no pubspec, ou `CircularProgressIndicator` simples);
- **error:** card com mensagem + botão "Tentar novamente" (`ref.invalidate`);
- **data:** o conteúdo atual (reaproveita os widgets existentes).

Telas afetadas: Home (destaque/listas), Cursos (+filtro), IFSP (+detalhe),
Benefícios (gov/inst +detalhe), Estágio/Concursos (+detalhes +depoimentos),
Dúvidas, Perfil. Detalhes que hoje recebem o objeto via `extra` continuam por
`extra` (sem releitura), exceto onde precisam refletir tempo real.

## 6. Persistência real

- **Perfil:** já implementado em `FirestoreProfileRepository`; apenas confirmar como
  padrão e garantir `role` default `student` na criação do doc do usuário (no
  registro). `currentProfileProvider` permanece.
- **Depoimentos:** `addTestimonial` grava em `testimonials/` com `authorUid` e
  `createdAt`; o provider de sessão (`userTestimonialsProvider`) é removido — a lista
  vem do stream e aparece para todos (RF032).

## 7. Regras de segurança (firestore.rules)

```
function isSignedIn() { return request.auth != null; }
function isAdmin() {
  return isSignedIn() &&
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
// conteúdo: leitura autenticada; escrita só admin
match /{col}/{id} where col in [courses, benefits, internships, contests, faqs, ifspInfo, notifications] {
  allow read: if isSignedIn();
  allow write: if isAdmin();
}
match /testimonials/{id} {
  allow read: if isSignedIn();
  allow create: if isSignedIn() && request.resource.data.authorUid == request.auth.uid;
  allow update, delete: if isAdmin();
}
match /users/{uid} {
  allow read: if isSignedIn() && request.auth.uid == uid;
  allow create, update: if request.auth.uid == uid
    && request.resource.data.role == resource.data.role; // cliente não altera role
}
```
(Sintaxe ilustrativa; ajustar à gramática real das Firestore Rules na implementação.
A determinação de admin é o **campo `role` em `users/{uid}`**, definido manualmente
no console por enquanto — custom claims ficam como endurecimento futuro.)

## 8. Seeding

Um **seeder dev-only, idempotente**, que sobe o conteúdo do `FakeUniverseRepository`
(o mock atual) para o Firestore. Acionável apenas por admin/dev (ex.: ação no painel
ou um botão escondido em debug). Mantém o mock como **fonte canônica de seed** e de
**testes**. Reexecutar não duplica (usa IDs determinísticos / `set` com merge).

## 9. Offline

Persistência offline do Firestore habilitada (padrão em mobile). O app continua
utilizável sem rede, exibindo o último cache; ao reconectar, sincroniza.

## 10. Testes

- **Telas:** com `FakeUniverseRepository` (streams), testar os estados
  loading/data/empty das principais telas (override do provider).
- **Modelos:** `fromDoc`/`toMap` round-trip (usando `fake_cloud_firestore` ou um
  `Map` simulado — avaliar dependência de teste).
- **Regras RF031/RF034/RF036:** os testes de regra já existentes permanecem (lógica
  no modelo, independente da fonte).

## 11. Escopo

**Inclui (SP1):** modelos com (de)serialização, `FirestoreUniverseRepository` +
`FakeUniverseRepository` (streams), providers, refatoração das telas para assíncrono,
persistência de depoimentos e perfil, regras de segurança, seeder, offline.

**Fora (próximos):** painel admin e CRUD pela UI (SP2 — no SP1 o admin grava pelo
console); conteúdo rico em blocos + editor + glossário/wikilinks (SP3).

## 12. Riscos / decisões

1. **Refatoração ampla das telas** (síncrono → assíncrono) — esperado; mitigado pelo
   padrão único `AsyncValue.when` e pelos widgets já prontos.
2. **`role` via get() nas regras** custa 1 leitura por escrita — aceitável no volume;
   custom claims otimizam depois.
3. **Dependência de teste** para Firestore (`fake_cloud_firestore`) — avaliar no
   plano; alternativa é testar só via `FakeUniverseRepository` (sem tocar Firestore).
4. **Configuração do projeto Firebase** (Firestore habilitado na região) — pré-requisito
   operacional.
