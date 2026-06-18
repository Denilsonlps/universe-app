# SP3a — Conteúdo Rico (leitura) · Documento de Design

**Data:** 2026-06-11
**Fase:** Dados & Admin & Conteúdo (sub-projeto 3a)
**Projeto:** Universe — app do IFSP Campus Pirituba

> SP3 decomposto em: **SP3a — Conteúdo rico (leitura)** (este doc) → **SP3b —
> Editor de conteúdo no admin** → **SP3c — Notícias**. Brainstorming aprovado em
> 2026-06-11. Baseado no protótipo atualizado (`content.jsx`, `data-content.jsx`).

## 1. Objetivo

Transformar as páginas de benefícios em **conteúdo rico** (estilo gov.br): seções
de "o que é", "como solicitar" (etapas), documentos, mídia (imagem/vídeo), avisos,
FAQ e fontes oficiais — com **palavras-chave em wikilink** (`[[PIBIC]]`) que abrem
outra página de conteúdo ou uma ficha de definição. O app deixa de ser um mero
redirecionador e passa a explicar de fato. Esta sub-fase cobre **leitura** (modelo +
renderização + glossário + mídia + migração dos benefícios); a **edição pelo admin**
é o SP3b.

## 2. Modelo de conteúdo

### 2.1 `ContentDoc`
```
ContentDoc { id, kind: 'gov'|'inst', icon, title, tag, summary, updatedAt(DateTime), sections: List<ContentSection> }
```
Firestore: coleção **`contentDocs/{id}`**; `sections` = lista de mapas (cada um com `type`).

### 2.2 `ContentSection` (sealed)
Hierarquia selada (Dart 3) com `factory ContentSection.fromMap(Map)` (dispatch por
`type`) e `toMap()` por subclasse:
- `RichSection { String? heading; String body; }` — `type:'rich'`
- `StepsSection { String? heading; List<String> items; }` — `type:'steps'`
- `DocsSection { String? heading; List<String> items; }` — `type:'docs'`
- `MediaSection { String? heading; String? caption; String mediaType('image'|'video'); String? imageUrl; String? videoUrl; }` — `type:'media'`
- `CalloutSection { String variant('info'|'warn'); String body; }` — `type:'callout'`
- `FaqSection { String? heading; List<({String q, String a})> items; }` — `type:'faq'`
- `SourcesSection { String? heading; List<({String label, String url})> items; }` — `type:'sources'`

`fromMap` desconhecido → ignora (retorna null e é filtrado), para tolerar tipos
futuros sem quebrar.

## 3. Glossário + wikilinks

- **Glossário**: constante Dart `glossary` (portada de `data-content.jsx`): `Map<String, GlossaryEntry>` onde `GlossaryEntry { String? docId; String? term; String? def; String? label; }`. Termos: Cadastro Único, ID Jovem, Isenções, Transporte, Bilhete Único, PAP, Monitoria, Iniciação Científica, Extensão, PIBIC, PIBITI, CRAS, NIS, SiSU, Sisu+, Enem, NAPNE. (Mover para Firestore = melhoria futura.)
- **`WikiText`** (widget): recebe `String text`; faz parse de `[[chave]]` e `[[chave|exibição]]` via RegExp; para cada match: se `glossary[chave]` existe → `TextSpan`/`WidgetSpan` tocável (cor `green700`, sublinhado) com `recognizer`/gesture → `resolveTerm`; senão → texto normal. Quebra parágrafos em `\n\n` (`WikiParagraphs`).
- **`resolveTerm(context, chave)`**: se entry tem `docId` → `context.push('/conteudo/<docId>')`; se tem `def` → abre **ficha de termo** (`showModalBottomSheet` com `TermSheet`).

## 4. Renderização

- **`ContentDocScreen`** (rota `/conteudo/:id`, ou recebe `ContentDoc` via `extra`):
  `GreenHero` (title/tag/icon) + `UpdatedPill` ("Atualizado em <data>") + as seções
  renderizadas por um `ContentSectionView` (switch no sealed type), com `WikiText`
  nos textos. Estados loading/erro/não encontrado.
- **`ContentSectionView`**: um widget por tipo (rich/steps/docs/media/callout/faq/
  sources), reaproveitando o design system (Card, IconTile, Accordion p/ faq, etc.).
- **`MediaView`**: imagem → `CachedNetworkImage` (URL do Storage ou qualquer http);
  vídeo → se `videoUrl` é YouTube/Vimeo, mostra **thumbnail** com play que abre o link
  no navegador (`url_launcher`); placeholder quando sem mídia. Sem player embutido.
- **`TermSheet`**: bottom sheet com o termo, a definição e, se houver `docId`, botão
  "Ver página completa".

## 5. Migração dos Benefícios

- A aba **Benefícios** (gov/inst) passa a listar **`contentDocs`** por `kind`
  (cards: ícone, título, tag, `summary`) → abre `ContentDocScreen`. Mantém o
  disclaimer **RF012**.
- A antiga `BenefitDetailScreen`, o modelo `Benefit`/`BenefitKind` (na parte de
  conteúdo) e a coleção `benefits` são **substituídos** pelos content docs.
  - `BenefitKind` (gov/inst) **permanece como enum** reutilizado por `ContentDoc.kind`
    e pelo provider (evita string solta). Apenas o modelo `Benefit` (campos
    description/steps/url) e seu detalhe saem de cena.
  - Remover `benefitsProvider` (substituído por `contentDocsProvider(kind)`),
    `benefit_detail_screen.dart` e o seed de `benefits`.
- O "Acessar portal oficial" vira a seção **`sources`** dentro do doc.

## 6. Repositório + seed

- `UniverseRepository`: `Stream<List<ContentDoc>> watchContentDocs(BenefitKind kind)`
  e `Stream<ContentDoc?> watchContentDoc(String id)` (ou buscar via lista).
  Implementação Firestore (`contentDocs`) e Fake (conteúdo do protótipo).
- Providers: `contentDocsProvider(BenefitKind)` e `contentDocProvider(String id)`.
- **Seeder**: popular `contentDocs` com os 8 documentos de `data-content.jsx`
  (com os `[[wikilinks]]` no texto, etapas, callouts, faq, sources, e media como
  placeholders/links). Remover o seed de `benefits`.

## 7. Navegação

- Rotas: `/conteudo/:id` (full-screen, `pageBuilder` com `fadeSlide`); abertura por
  `extra: ContentDoc` quando vindo da lista (sem releitura), ou por `:id` no wikilink.
- Wikilink `docId` → `context.push('/conteudo/<id>')`. Wikilink `def` → bottom sheet.
- Home: o item "Benefícios Gov/Inst" continua indo para a aba/lista; os cards da
  lista abrem o content doc.

## 8. Mídia (escopo do SP3a = leitura)

Imagens são exibidas de uma **URL** (que no SP3b virá do Firebase Storage); vídeos
de **link** externo (YouTube/Vimeo → thumbnail → abre no navegador). **Upload** ao
Storage é do **SP3b** (editor). No SP3a, os docs seedados usam imagens por URL
(placeholder/ilustrativa) e vídeos por link de exemplo.

## 9. Testes

- **`WikiText` parser:** extrai `[[..]]`; `[[a|b]]` mostra "b"; chave conhecida vira
  link, desconhecida vira texto; texto sem wikilink intacto.
- **(De)serialização** de cada `ContentSection` (round-trip por tipo) e de `ContentDoc`.
- **Render** do `ContentDocScreen` com um `ContentDoc` fake: aparece o título, uma
  etapa, e um wikilink conhecido é tocável.

## 10. Escopo

**Inclui (SP3a):** modelos `ContentDoc`/`ContentSection`, glossário + `WikiText` +
`TermSheet`, `ContentDocScreen` + `ContentSectionView` + `MediaView`, providers,
migração da aba Benefícios para content docs, seeder, rotas, testes.

**Fora:** editor admin de conteúdo + upload ao Storage (SP3b); notícias (SP3c);
aplicar conteúdo rico ao IFSP/cursos (futuro); glossário no Firestore (futuro).

## 11. Riscos / notas

1. **Migração dos benefícios** remove o modelo `Benefit` e a coleção `benefits` —
   atualizar/limpar testes e o seed; manter `BenefitKind`.
2. **`cached_network_image`** já está no pubspec — usar para imagens; tratar erro/
   loading com placeholder.
3. **Wikilink em `Text.rich`**: usar `TextSpan` com `TapGestureRecognizer` (gerir o
   ciclo de vida dos recognizers no `StatefulWidget`/`dispose`) ou `WidgetSpan` com
   `InkWell`. Preferir `WidgetSpan`+`GestureDetector` para evitar gerência manual de
   recognizers (mais simples e seguro).
4. **Re-seed:** o botão dev de seed passa a popular `contentDocs` (e não `benefits`);
   após implementar, rodar o seed novamente para criar a coleção.
5. **Glossário bundled:** wikilinks só resolvem termos conhecidos; no SP3b, quando o
   admin escrever novos `[[termos]]`, considerar glossário no Firestore.
