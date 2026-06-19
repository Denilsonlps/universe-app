# SP3c — Notícias · Documento de Design

**Data:** 2026-06-18
**Fase:** Dados & Admin & Conteúdo (sub-projeto 3c — último do SP3)
**Projeto:** Universe — app do IFSP Campus Pirituba

> SP3: SP3a (conteúdo rico — leitura) ✅ → SP3b (editor de conteúdo + upload) ✅ →
> **SP3c — Notícias** (este doc). Baseado no protótipo (`screens-news.jsx`,
> `screens-admin.jsx`, `data-content.jsx` NEWS_SEED). Brainstorming aprovado em
> 2026-06-18.

## 1. Objetivo

Dar ao campus um canal de **avisos e novidades** dentro do app: o admin publica
notícias (com imagem, fatos rápidos e wikilinks para páginas de conteúdo/glossário) e
o aluno as vê num bloco na Home, numa lista dedicada com filtro por categoria, e numa
tela de detalhe. Fecha o SP3.

## 2. Modelo `News`

```
News {
  id, category, source, readTime,
  title, summary, body,            // body usa [[wikilinks]]
  date: DateTime,
  facts: List<({String label, String value})>,
  sourceUrl?, imageUrl?,
  published: bool, pinned: bool,
}
```
- Firestore: coleção **`news/{id}`**. `fromMap`/`toMap`; `date` como epoch-ms int;
  `facts` como lista de mapas `{label, value}` (evita array aninhado — mesma lição do
  `IfspDetail`). `published`/`pinned` default false/false no `fromMap`.
- **Categorias:** conjunto sugerido `['Campus', 'SiSU', 'Enem', 'Geral']` (chips no
  editor) + texto livre permitido.

## 3. Repositório + providers

`UniverseRepository`:
- `Stream<List<News>> watchPublishedNews()` — só `published == true`, ordenado por
  **pinned primeiro, depois `date` desc**.
- `Stream<List<News>> watchAllNews()` — todas (admin), `date` desc.
- `Future<void> upsertNews(News n)` · `Future<void> deleteNews(String id)`.

Firestore (`news` collection) + Fake (3 notícias do protótipo). Ordenação aplicada no
cliente (igual ao padrão atual de internships/contests). Providers:
`publishedNewsProvider` (StreamProvider<List<News>>) e `allNewsProvider`.

## 4. Telas do aluno

### 4.1 Home — bloco "Notícias"
- Seção na Home com título "Notícias" + **carrossel horizontal** de cards compactos
  das recentes (até ~6), com selo **"DESTAQUE"** nos `pinned`. Link **"Ver todas"** →
  `/noticias`. Usa `publishedNewsProvider`. Se vazia, a seção não aparece.

### 4.2 `/noticias` — `NewsListScreen`
- `GreenHero` "Notícias · Avisos do campus e do mundo acadêmico" (ícone `bell`).
- **Chips de categoria:** `Todas` + categorias presentes nas notícias publicadas.
- Lista vertical de `NewsCard` → `/noticias/:id` (passa o `News` via `extra`).
- Estados loading/erro/vazio via `AsyncListView`.

### 4.3 `/noticias/:id` — `NewsDetailScreen`
- Recebe `News` via `extra`; sem extra (deep-link), resolve por id via provider
  (`_NewsById`, igual ao padrão de `_ContentDocById`).
- Capa: `ContentImage(imageUrl)` se houver; senão herói verde de fallback com a
  categoria. Título, linha `fonte · data · tempo de leitura`.
- **Fatos rápidos:** grid de cards (label/valor) quando `facts` não vazio.
- Corpo: `WikiParagraphs(body)` com o resolvedor (glossário + título de páginas de
  conteúdo), igual ao SP3a.
- Card **"Fonte oficial"** com `sourceUrl` e botão que abre no navegador
  (`url_launcher`), quando houver.

### 4.4 `NewsCard`
- Card reutilizável com variantes **compact** (carrossel da Home) e padrão (lista):
  categoria (chip colorido por categoria), `pinned` (estrela/selo), título (2 linhas),
  `fonte · data` (+ tempo de leitura na variante padrão).

## 5. Admin

- **Hub** (`/admin`): adicionar o card **"Notícias"** → `/admin/noticias` (com
  contagem de publicadas no subtítulo).
- **`/admin/noticias` — `AdminNewsListScreen`:** lista `allNewsProvider` (publicadas e
  rascunhos, rascunho com opacidade reduzida + selo "Rascunho"), `AppToggle` inline
  para **publicar/despublicar** (chama `upsertNews` com `published` alternado), toque
  → editor. Botão **"Nova notícia"**.
- **`/admin/noticias/editar` — `AdminNewsEditScreen`:** recebe `News?` via `extra`
  (null = nova). Rascunho local em estado. Campos:
  - título; **categoria** (chips do conjunto sugerido + campo livre); fonte; resumo
    (multiline); **corpo** (multiline, com dica de `[[wikilinks]]`);
  - **fatos rápidos:** lista editável de pares `label`/`value` (adicionar/remover);
  - **imagem:** `ImagePickerField` (upload/link);
  - link da fonte; toggles **Destaque (pinned)** e **Publicar**.
  - **Salvar:** valida (título e corpo não vazios), `upsertNews` (id por
    `newId('news')` em nova; fixo na edição), volta. **Excluir** com confirmação
    (modo edição). Tratamento de erro (reseta estado + aviso), como no editor de
    conteúdo.

## 6. Navegação

Rotas novas (todas `fadeSlide`): `/noticias`, `/noticias/:id` (extra `News` ou resolve
por id), `/admin/noticias`, `/admin/noticias/editar` (extra `News?`). Home e hub
ganham as entradas. Gating do admin pelas regras (entradas só aparecem para admin).

## 7. Regras de segurança

- **Firestore:** a regra atual (catch-all) deixaria o aluno ler **rascunhos**. Trocar
  por uma regra específica de `news`:
  - `read`: `published == true` **ou** `isAdmin()`;
  - `write`: `isAdmin()`.
  (As demais coleções seguem no catch-all.)
- **Storage:** já coberto (imagens de notícia usam `content_images/`).

## 8. Seed + testes

- **Seeder:** popula `news` com as 3 notícias do protótipo (categoria, fonte, data,
  `facts`, `body` com wikilinks, `sourceUrl`; `published: true`; n1 `pinned: true`).
- **Testes:**
  - round-trip do `News` (inclui `facts` e datas);
  - `watchPublishedNews` exclui não-publicadas e ordena (pinned primeiro, depois data
    desc);
  - `upsert`/`delete` no Fake;
  - smoke do editor: publicar nova notícia chama `upsertNews`.

## 9. Reuso

`ImagePickerField`/`ContentImage`, `WikiText`/`WikiParagraphs` + resolvedor,
`AsyncListView`, `AppToggle`, `AppField` (multiline), `IconTile`, `GreenHero`/
`PageHeader`/`PageShell`, design system. Sem novas dependências.

## 10. Escopo

**Inclui (SP3c):** modelo `News`; repositório/providers; bloco na Home; lista +
detalhe; admin (lista + editor, publicar/destaque/excluir); rota; regra de leitura de
`news`; seed; testes.

**Fora:** comentários/curtidas; push notifications; gestão de categorias por UI
(conjunto fixo + texto livre); agendamento de publicação.

## 11. Riscos / notas

1. **`facts`** como lista de mapas `{label,value}` (não array aninhado) — Firestore.
2. **Regra de `news`** precisa ser publicada pelo usuário (passo operacional), senão a
   restrição de rascunho não vale e/ou a leitura quebra. Documentar.
3. **Ordenação** (pinned + data) feita no cliente, como o restante do app.
4. **Wikilinks no corpo** dependem do resolvedor (glossário + títulos de
   `contentDocs`); termos desconhecidos viram texto normal (comportamento do SP3a).
5. **`NewsDetailScreen` por id** (deep-link) usa `allNews`/`publishedNews` para
   resolver; se não achar, mostra "não encontrada".
