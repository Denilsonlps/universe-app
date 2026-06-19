# SP3b — Editor de conteúdo no admin + upload ao Storage · Documento de Design

**Data:** 2026-06-18
**Fase:** Dados & Admin & Conteúdo (sub-projeto 3b)
**Projeto:** Universe — app do IFSP Campus Pirituba

> SP3 decomposto em: SP3a — Conteúdo rico (leitura) ✅ → **SP3b — Editor de
> conteúdo no admin** (este doc) → SP3c — Notícias. Baseado no protótipo
> (`screens-admin.jsx`, `content.jsx`). Brainstorming aprovado em 2026-06-18.

## 1. Objetivo

Permitir que o **admin** (Setor de Estágios/Comunicação) **crie, edite e exclua**
as páginas de conteúdo rico (`contentDocs`) pela própria UI — incluindo o conjunto
de seções tipadas e o **upload de imagens** ao Firebase Storage. Hoje o conteúdo só
existe via seed; após o SP3b, o conteúdo é gerenciado pelo app. Leitura/renderização
já foi entregue no SP3a.

## 2. Navegação (hub admin)

- Novo **`AdminHubScreen`** na rota `/admin`: cabeçalho escuro "Painel
  administrativo" + cards:
  - **Vagas e concursos** → `/admin/vagas` (o atual `AdminPanelScreen`, apenas
    movido de rota).
  - **Páginas de conteúdo** → `/admin/conteudo`.
  - (**Notícias** entra no SP3c — não incluir agora.)
- O `AdminPanelScreen` (vagas/concursos) é preservado **sem alterações de conteúdo**;
  só muda a rota de `/admin` para `/admin/vagas`, e seus formulários continuam em
  `/admin/vaga` e `/admin/concurso`.
- Gating inalterado: entradas só aparecem para `isAdmin`; segurança real nas regras.

## 3. Repositório + Storage

### 3.1 Repositório (`UniverseRepository`)
- `Future<void> upsertContentDoc(ContentDoc d)` — `set(doc(d.id), d.toMap())`.
- `Future<void> deleteContentDoc(String id)`.
- `Stream<List<ContentDoc>> watchAllContentDocs()` — todos (gov+inst), sem filtro,
  para a lista do editor.
- `newId('contentDocs')` já existe (usado se necessário).
- Implementar em Firestore e Fake. Provider `allContentDocsProvider`
  (StreamProvider<List<ContentDoc>>).

### 3.2 Storage (`StorageService`)
- Novo serviço fino (`lib/data/storage/storage_service.dart`):
  `Future<String> uploadContentImage(Uint8List bytes, {required String ext, void Function(double)? onProgress})`
  → grava em `content_images/<uuid>.<ext>` e retorna a `downloadURL`.
- Interface + impl `FirebaseStorageService` (usa `firebase_storage`) + `FakeStorageService`
  (retorna uma URL determinística, sem rede). Provider `storageServiceProvider`
  (Firebase por padrão; Fake nos testes).
- `uuid` gerado sem dependência nova (ex.: timestamp + `Random`), para não inflar o
  pubspec além do `image_picker`.

## 4. Lista de páginas — `AdminContentListScreen` (`/admin/conteudo`)

- Lê `allContentDocsProvider`. Grupos **Governamentais** / **Institucionais**
  (por `kind`). Cada card: `IconTile(d.icon)`, título, "N seções · atualizado em
  dd/mm". Toque → editor (passa o `ContentDoc` via `extra`).
- Botão **"Nova página"** → editor em modo criação.
- Card de dica explicando `[[colchetes]]` para wikilinks (espelha o protótipo).
- Estados loading/erro/vazio via `AsyncListView`/equivalente.

## 5. Editor — `AdminContentEditScreen` (`/admin/conteudo/editar`)

- Recebe um `ContentDoc?` via `extra` (null = nova página). Mantém um **rascunho
  local** (`StatefulWidget`) — uma cópia editável; nada é gravado até **Publicar**.
- **Publicar:** valida mínimos (título não vazio; ao menos 1 seção), define
  `updatedAt = DateTime.now()`, chama `upsertContentDoc`, mostra confirmação e volta.
- **Cabeçalho do doc (campos):** título, tag, resumo.
  - **Nova página:** também escolhe **tipo** (gov/inst, par de botões) e **ícone**
    (ver §6). O **id** é gerado automaticamente: `slug(title)` prefixado por kind
    (`gov-cadastro-unico`), com sufixo numérico se já existir id igual.
  - **Edição:** id e kind fixos (não editáveis); ícone editável.
- **Seções (lista reordenável):** cada seção é um card com cabeçalho (rótulo do tipo
  + ↑/↓ mover + excluir) e os campos do tipo:
  - `rich` → texto (multiline) [+ heading].
  - `callout` → texto + variante (Informação/Atenção).
  - `steps` / `docs` → itens, um por linha (`split('\n')`), [+ heading].
  - `faq` → lista de pares pergunta/resposta, com adicionar/remover item, [+ heading].
  - `sources` → lista de {label, url}, com adicionar/remover item, [+ heading].
  - `media` → `MediaUploader` (§7) + legenda, [+ heading].
- **Adicionar seção:** seletor com os 7 tipos (rótulos amigáveis: Texto, Passo a
  passo, Lista/documentos, Vídeo/imagem, Destaque, Dúvidas, Fontes oficiais), cada
  um cria uma seção padrão preenchida (placeholders úteis).
- **Excluir página:** ação no editor (modo edição), com confirmação.

## 6. Seletor de ícone

- Grid visual dos ícones disponíveis no app (`appIcons`), exposto como uma lista de
  chaves selecionáveis. Admin toca para escolher; o selecionado fica destacado.
  Sem digitação de nomes de ícone. Usado tanto na criação quanto na edição.

## 7. Upload de mídia — `MediaUploader`

- Seção `media` com alternância **Imagem / Vídeo** (define `mediaType`):
  - **Imagem:** botão "Escolher imagem" → `image_picker` (nova dependência) →
    obtém bytes (`readAsBytes`, funciona no web) → `StorageService.uploadContentImage`
    → grava `imageUrl` no rascunho. Mostra preview (via `CachedNetworkImage`) e
    indicador de progresso/erro. Permite trocar/remover.
  - **Vídeo:** campo de URL (YouTube/Vimeo) → grava `videoUrl` (sem upload), igual ao
    SP3a (`parseVideoUrl`/`MediaView`).
- Apenas imagens vão ao Storage; vídeo permanece por link.

## 8. Regras de segurança

- **Firestore:** sem mudança — o catch-all `match /{col}/{id}` já garante leitura
  logada e escrita só-admin para `contentDocs`.
- **Storage:** criar `storage.rules` (novo arquivo no repo) com:
  - `content_images/**`: **leitura só para usuários logados** (consistente com o app);
    **escrita só para admin** (mesma checagem `users/{uid}.role == 'admin'`).
  - Registrar em `firebase.json` (criar/atualizar a seção `storage`). Publicar as
    regras no console é **passo operacional do usuário** (como nas fases anteriores).

## 9. Dependências

- Adicionar **`image_picker`** ao `pubspec.yaml` (seleção de arquivo; web+mobile).
- `firebase_storage` e `cached_network_image` já presentes. Sem outras dependências
  novas (uuid gerado localmente).

## 10. Testes

- Repositório (Fake): `upsertContentDoc` insere/atualiza por id; `deleteContentDoc`
  remove; `watchAllContentDocs` retorna todos.
- Geração de **slug/id**: `slug('Cadastro Único')` → `cadastro-unico`; prefixo por
  kind; sufixo em colisão (`-2`).
- **`StorageService`** fake: `uploadContentImage` retorna URL não vazia (sem rede).
- **Editor (widget smoke):** adicionar uma seção aumenta a contagem do rascunho;
  reordenar troca a ordem; remover diminui; "Publicar" chama `upsertContentDoc` (com
  repositório fake injetado) e define `updatedAt` para hoje.
- Sem chamadas de rede reais nos testes (Fake repo + Fake storage).

## 11. Escopo

**Inclui (SP3b):** hub admin; lista de páginas; editor (criar/editar/excluir doc e
seções, reordenar, todos os 7 tipos); seletor de ícone; upload de imagem ao Storage +
vídeo por link; `storage.rules`; `image_picker`; providers/serviços; testes.

**Fora:** notícias (SP3c); glossário editável no Firestore (futuro); upload de vídeo
ao Storage; edição de cursos/IFSP como conteúdo rico (futuro).

## 12. Riscos / notas

1. **`image_picker` no web** retorna `XFile` com bytes (`readAsBytes`); usar
   `putData` no Storage (não `putFile`). Garantir o caminho web.
2. **Geração de id** deve evitar colisão e caracteres inválidos (slug ASCII,
   minúsculas, hífens). Edição não altera id (senão quebra wikilinks/links).
3. **`updatedAt`** é definido no momento de publicar (não editável manualmente).
4. **Regras do Storage** precisam ser publicadas pelo usuário no console; sem isso o
   upload falha — documentar como passo operacional.
5. **Rascunho local**: editar uma cópia evita gravar parcial; só "Publicar" persiste.
6. **AdminPanelScreen** muda de rota (`/admin` → `/admin/vagas`); conferir todas as
   entradas (menu, botão escudo) e o redirect.
