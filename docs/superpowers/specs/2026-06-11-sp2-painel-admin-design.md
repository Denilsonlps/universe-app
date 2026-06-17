# SP2 — Papel Admin + Painel · Documento de Design

**Data:** 2026-06-11
**Fase:** Dados & Admin (sub-projeto 2 de 3)
**Projeto:** Universe — app do IFSP Campus Pirituba

> Sequência: **SP1 Firestore** (concluído) → **SP2 Painel Admin** (este doc) →
> **SP3 Conteúdo rico + glossário**. Brainstorming aprovado em 2026-06-11.

## 1. Objetivo

Permitir que o **Setor de Estágios** (admin) **cadastre, edite, encerre e exclua
vagas de estágio e concursos públicos pela própria UI** — em vez do console do
Firebase. Concretiza o ator "Setor de Estágios" do TCC (§2.2/§2.4.2: cadastro
manual de vagas) e a camada de apresentação no fluxo de escrita.

Escopo confirmado no brainstorming: **apenas vagas e concursos**. Benefícios, IFSP,
FAQ e o editor de conteúdo rico ficam para o **SP3**.

## 2. Papel do admin

- `StudentProfile` ganha o campo **`role`** (lido de `users/{uid}.role`; default
  `'student'`). `currentProfileProvider` já lê esse doc.
- Novo `isAdminProvider` (derivado): `currentProfile?.role == 'admin'`.
- A determinação de admin permanece o campo `role` em `users/{uid}` (definido no
  console; custom claims = endurecimento futuro), conforme SP1.

## 3. Entradas (visíveis só para admin)

- **Botão escudo** no `GreenHero` da tela Estágio: renderizado **apenas se
  `isAdmin`**; ao tocar, navega para `/admin`. (Para aluno comum, não aparece.)
- Item no **menu lateral** (drawer): "Painel do Setor de Estágios" — visível só
  para admin — navega para `/admin`.

## 4. Painel Admin (`/admin`)

- `PageHeader` "Painel — Setor de Estágios" + abas **Vagas | Concursos**.
- Cada aba lista **todos** os registros (inclui encerrados/expirados — o admin não
  sofre os filtros RF034/RF036 do aluno). Item: toque = editar; ação de **excluir**
  com diálogo de confirmação.
- **FAB "＋"**: abre o formulário de nova vaga / novo concurso conforme a aba ativa.
- Estados loading/erro/vazio via `AsyncListView` (reuso do SP1).

## 5. Formulários

### 5.1 Vaga (`/admin/vaga` — nova; recebe `Internship?` via `extra` para editar)
Campos (todos do RF033 + auxiliares):
- Texto: cargo, empresa, área, descrição da vaga, descrição da empresa, bolsa,
  duração, link (opcional), tag (opcional).
- Curso: **dropdown** (`courseShortLabels` sem "Todos").
- Modalidade: dropdown (Presencial/Híbrido/Remoto).
- Listas (pré-requisitos, diferenciais, benefícios): editor de itens
  (campo + "adicionar", chips removíveis).
- **Status:** alternador Aberta/Encerrada. Ao marcar Encerrada, grava
  `closedAt = now` (se ainda não tinha). Ao reabrir, `closedAt = null`.
- Validação: cargo, empresa, área, descrição da vaga e bolsa obrigatórios.
- Salvar → `upsertInternship`. Editar reusa o `id`; novo gera `id`
  (`internships` doc novo).

### 5.2 Concurso (`/admin/concurso` — nova; recebe `Contest?` via `extra` para editar)
Campos: cargo, órgão, vagas, salário, escolaridade, sobre, link (opcional),
**prazo** (date picker → `deadline`). Validação: cargo, órgão, prazo obrigatórios.
Salvar → `upsertContest`.

## 6. Repositório (escrita + leitura admin)

Adições à `UniverseRepository`:
```dart
Stream<List<Internship>> watchAllInternships();   // sem filtro de visibilidade
Stream<List<Contest>> watchAllContests();
Future<void> upsertInternship(Internship vaga);    // cria ou atualiza (por id)
Future<void> deleteInternship(String id);
Future<void> upsertContest(Contest c);
Future<void> deleteContest(String id);
```
- **Firestore:** `watchAll…` = `snapshots()` sem filtro; `upsert…` = `set(doc(id), toMap())`
  (id novo via `collection.doc().id` quando vazio); `delete…` = `doc(id).delete()`.
- **Fake:** mesmas operações em memória (para testes).
- Providers admin: `allInternshipsProvider`, `allContestsProvider` (StreamProvider).

> Os modelos `Internship`/`Contest` precisam permitir construir com `id` definido
> pelo cliente (já têm `id`). Para "novo", o repositório gera o id antes do `set`.

## 7. Segurança

Sem mudança nas regras (SP1 já garante escrita só para `isAdmin()`). O gating na UI
é conveniência/UX; a segurança real está nas regras do Firestore.

## 8. Estrutura de arquivos

```
lib/data/profile/student_profile.dart      + campo role
lib/core/providers/profile_provider.dart   + isAdminProvider
lib/core/providers/repository_provider.dart + allInternshipsProvider/allContestsProvider
lib/data/repositories/universe_repository.dart       + métodos de escrita/admin
lib/data/repositories/firestore_universe_repository.dart  impl
lib/data/repositories/fake_universe_repository.dart       impl
lib/features/admin/screens/admin_panel_screen.dart   painel (abas + listas + FAB)
lib/features/admin/screens/vaga_form_screen.dart     formulário de vaga
lib/features/admin/screens/concurso_form_screen.dart formulário de concurso
lib/core/router/app_router.dart            rotas /admin, /admin/vaga, /admin/concurso
lib/features/internships/screens/estagio_screen.dart  escudo só p/ admin
lib/shared/chrome/menu_drawer.dart         item admin condicional
```

## 9. Testes

- `FakeUniverseRepository`: upsert (cria/atualiza), delete, watchAll (inclui
  encerrados).
- Gating: com `role student`, a entrada de admin não aparece; com `admin`, aparece.
- Validação do formulário de vaga (campos obrigatórios bloqueiam salvar).

## 10. Escopo / fora

**Inclui:** role no perfil + gating, painel (abas, listas com editar/excluir, FAB),
formulários de vaga e concurso, métodos de escrita no repositório, rotas.

**Fora (SP3):** benefícios/IFSP/FAQ; conteúdo rico em blocos; glossário/wikilinks;
moderação de depoimentos (pode entrar no SP3 ou depois). Upload de imagens (Storage)
fica para o SP3 (conteúdo rico).

## 11. Riscos / notas

1. **Formulário de vaga é grande** (muitos campos) — quebrar em seções no widget;
   manter o arquivo focado (form + um sub-widget de editor de lista).
2. **`watchAll…` sem filtro** é só para o painel admin; as telas do aluno continuam
   usando os providers filtrados (RF034/RF036).
3. **Geração de id** para novos registros: usar `FirebaseFirestore` doc id no
   Firestore; no Fake, um contador/UUID simples.
4. **`role` no StudentProfile**: garantir que o `toMap` do perfil **não sobrescreva**
   `role` ao salvar curso/matrícula (a regra do SP1 já impede o cliente de alterar
   `role`; o `ProfileRepository.save` deve usar `merge` e não enviar `role`).
