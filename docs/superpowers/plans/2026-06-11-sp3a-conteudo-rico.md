# SP3a — Conteúdo Rico (leitura) · Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Renderizar páginas de conteúdo rico (seções tipadas + wikilinks + mídia) para os benefícios, lendo de `contentDocs` no Firestore, com glossário/termos.

**Architecture:** `ContentDoc` + `ContentSection` (sealed) em `data/models`. Glossário (constante) + `WikiText` (parser de `[[..]]`) + `TermSheet`. `ContentDocScreen` renderiza seções via `ContentSectionView`. Repositório ganha `watchContentDocs`/`watchContentDoc` (Firestore + Fake). Benefícios migram para content docs.

**Tech Stack:** cloud_firestore, flutter_riverpod, go_router, cached_network_image, url_launcher. Sem novas dependências.

**Spec:** `docs/superpowers/specs/2026-06-11-sp3a-conteudo-rico-design.md`.
**Fonte de conteúdo (versionada):** `design_reference/project/universe/data-content.jsx` (GLOSSARY + CONTENT_DOCS) e `content.jsx` (renderer/parser de referência).

**Estado atual:** Benefícios usam `Benefit`/`benefitsProvider(kind)`/`BenefitsScreen`/`BenefitDetailScreen`; seed popula `benefits`. `BenefitKind{gov,inst}` em `benefit.dart`. `AsyncListView`, `Accordion`, `cached_network_image` disponíveis.

---

## Estrutura de arquivos (SP3a)

```
lib/data/models/content_doc.dart        ContentDoc + ContentSection (sealed) + fromMap/toMap
lib/data/content/glossary.dart          glossary (Map<String, GlossaryEntry>) + GlossaryEntry
lib/shared/content/wiki_text.dart       WikiText + WikiParagraphs + resolveTerm
lib/shared/content/term_sheet.dart      showTermSheet (bottom sheet)
lib/shared/content/media_view.dart      MediaView (imagem/vídeo-link) + parseVideoUrl
lib/shared/content/content_section_view.dart  render de uma ContentSection
lib/features/content/screens/content_doc_screen.dart  ContentDocScreen
lib/data/repositories/universe_repository.dart  + watchContentDocs/watchContentDoc
lib/data/repositories/firestore_universe_repository.dart  impl
lib/data/repositories/fake_universe_repository.dart       impl + conteúdo transcrito
lib/core/providers/repository_provider.dart  + contentDocsProvider/contentDocProvider
lib/data/repositories/seed.dart          seeda contentDocs; remove benefits
lib/features/benefits/screens/benefits_screen.dart  lista contentDocs
lib/core/router/app_router.dart          rota /conteudo/:id + wikilink; remove benefit detail
test/data/content_doc_test.dart  ·  test/shared/wiki_text_test.dart
```
Remoções: `lib/features/benefits/screens/benefit_detail_screen.dart`, `Benefit` (modelo de conteúdo) e `benefitsProvider`, seed de `benefits`.

---

### Task 1: Modelos ContentDoc + ContentSection (sealed)

**Files:** Create `lib/data/models/content_doc.dart`; Test `test/data/content_doc_test.dart`

- [ ] **Step 1: Escrever o teste (FALHA primeiro)**

`test/data/content_doc_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/content_doc.dart';

void main() {
  test('ContentDoc round-trip com várias seções', () {
    final doc = ContentDoc(
      id: 'gov-x', kind: ContentKind.gov, icon: 'card', title: 'X', tag: 'Federal',
      summary: 's', updatedAt: DateTime(2026, 6, 10),
      sections: [
        const RichSection(heading: 'O que é', body: 'Texto [[PIBIC]].'),
        const StepsSection(heading: 'Como', items: ['a', 'b']),
        const MediaSection(mediaType: 'video', caption: 'c', videoUrl: 'https://youtu.be/abc'),
        const CalloutSection(variant: 'warn', body: 'cuidado'),
        const FaqSection(items: [(q: 'q?', a: 'r')]),
        const SourcesSection(items: [(label: 'gov', url: 'gov.br')]),
        const DocsSection(items: ['doc1']),
      ],
    );
    final back = ContentDoc.fromMap('gov-x', doc.toMap());
    expect(back.title, 'X');
    expect(back.kind, ContentKind.gov);
    expect(back.updatedAt, DateTime(2026, 6, 10));
    expect(back.sections.length, 7);
    expect((back.sections[0] as RichSection).body, 'Texto [[PIBIC]].');
    expect((back.sections[1] as StepsSection).items, ['a', 'b']);
    expect((back.sections[4] as FaqSection).items.first.q, 'q?');
  });
}
```

- [ ] **Step 2: Rodar e confirmar a falha** — `flutter test test/data/content_doc_test.dart` → FAIL.

- [ ] **Step 3: Implementar os modelos**

`lib/data/models/content_doc.dart`:
```dart
enum ContentKind { gov, inst }

/// Seção tipada de um documento de conteúdo.
sealed class ContentSection {
  const ContentSection();
  Map<String, dynamic> toMap();

  static ContentSection? fromMap(Map<String, dynamic> m) {
    switch (m['type']) {
      case 'rich':
        return RichSection(heading: m['heading'], body: m['body'] ?? '');
      case 'steps':
        return StepsSection(heading: m['heading'], items: List<String>.from(m['items'] ?? const []));
      case 'docs':
        return DocsSection(heading: m['heading'], items: List<String>.from(m['items'] ?? const []));
      case 'media':
        return MediaSection(heading: m['heading'], caption: m['caption'], mediaType: m['mediaType'] ?? 'image', imageUrl: m['imageUrl'], videoUrl: m['videoUrl']);
      case 'callout':
        return CalloutSection(variant: m['variant'] ?? 'info', body: m['body'] ?? '');
      case 'faq':
        return FaqSection(heading: m['heading'], items: ((m['items'] ?? const []) as List).map((e) => (q: (e['q'] ?? '') as String, a: (e['a'] ?? '') as String)).toList());
      case 'sources':
        return SourcesSection(heading: m['heading'], items: ((m['items'] ?? const []) as List).map((e) => (label: (e['label'] ?? '') as String, url: (e['url'] ?? '') as String)).toList());
      default:
        return null;
    }
  }
}

class RichSection extends ContentSection {
  final String? heading;
  final String body;
  const RichSection({this.heading, required this.body});
  @override
  Map<String, dynamic> toMap() => {'type': 'rich', 'heading': heading, 'body': body};
}

class StepsSection extends ContentSection {
  final String? heading;
  final List<String> items;
  const StepsSection({this.heading, required this.items});
  @override
  Map<String, dynamic> toMap() => {'type': 'steps', 'heading': heading, 'items': items};
}

class DocsSection extends ContentSection {
  final String? heading;
  final List<String> items;
  const DocsSection({this.heading, required this.items});
  @override
  Map<String, dynamic> toMap() => {'type': 'docs', 'heading': heading, 'items': items};
}

class MediaSection extends ContentSection {
  final String? heading, caption, imageUrl, videoUrl;
  final String mediaType; // 'image' | 'video'
  const MediaSection({this.heading, this.caption, required this.mediaType, this.imageUrl, this.videoUrl});
  @override
  Map<String, dynamic> toMap() => {'type': 'media', 'heading': heading, 'caption': caption, 'mediaType': mediaType, 'imageUrl': imageUrl, 'videoUrl': videoUrl};
}

class CalloutSection extends ContentSection {
  final String variant; // 'info' | 'warn'
  final String body;
  const CalloutSection({required this.variant, required this.body});
  @override
  Map<String, dynamic> toMap() => {'type': 'callout', 'variant': variant, 'body': body};
}

class FaqSection extends ContentSection {
  final String? heading;
  final List<({String q, String a})> items;
  const FaqSection({this.heading, required this.items});
  @override
  Map<String, dynamic> toMap() => {'type': 'faq', 'heading': heading, 'items': [for (final i in items) {'q': i.q, 'a': i.a}]};
}

class SourcesSection extends ContentSection {
  final String? heading;
  final List<({String label, String url})> items;
  const SourcesSection({this.heading, required this.items});
  @override
  Map<String, dynamic> toMap() => {'type': 'sources', 'heading': heading, 'items': [for (final i in items) {'label': i.label, 'url': i.url}]};
}

class ContentDoc {
  final String id;
  final ContentKind kind;
  final String icon, title, tag, summary;
  final DateTime updatedAt;
  final List<ContentSection> sections;
  const ContentDoc({required this.id, required this.kind, required this.icon, required this.title, required this.tag, required this.summary, required this.updatedAt, required this.sections});

  Map<String, dynamic> toMap() => {
        'kind': kind.name, 'icon': icon, 'title': title, 'tag': tag, 'summary': summary,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'sections': [for (final s in sections) s.toMap()],
      };

  factory ContentDoc.fromMap(String id, Map<String, dynamic> m) => ContentDoc(
        id: id,
        kind: m['kind'] == 'inst' ? ContentKind.inst : ContentKind.gov,
        icon: m['icon'] ?? 'doc', title: m['title'] ?? '', tag: m['tag'] ?? '', summary: m['summary'] ?? '',
        updatedAt: DateTime.fromMillisecondsSinceEpoch((m['updatedAt'] ?? 0) as int),
        sections: ((m['sections'] ?? const []) as List)
            .map((e) => ContentSection.fromMap(Map<String, dynamic>.from(e)))
            .whereType<ContentSection>()
            .toList(),
      );
}
```

- [ ] **Step 4:** `flutter test test/data/content_doc_test.dart` → PASS. `flutter analyze lib/data/models/content_doc.dart` → limpo.
- [ ] **Step 5:** Commit — `git add lib/data/models/content_doc.dart test/data/content_doc_test.dart && git commit -m "feat(content): modelos ContentDoc + ContentSection (sealed)"`

---

### Task 2: Glossário + WikiText + teste do parser

**Files:** Create `lib/data/content/glossary.dart`, `lib/shared/content/wiki_text.dart`; Test `test/shared/wiki_text_test.dart`

- [ ] **Step 1: Glossário** — Create `lib/data/content/glossary.dart`. Transcrever o `GLOSSARY` de `design_reference/project/universe/data-content.jsx` para Dart:
```dart
class GlossaryEntry {
  final String? docId;   // abre /conteudo/<docId>
  final String? term;    // título da ficha (default = chave)
  final String? def;     // definição (abre ficha)
  final String? label;   // rótulo alternativo (não usado no link)
  const GlossaryEntry({this.docId, this.term, this.def, this.label});
}

/// Glossário do app. Transcrito de design_reference/.../data-content.jsx (GLOSSARY).
const glossary = <String, GlossaryEntry>{
  'Cadastro Único': GlossaryEntry(docId: 'gov-cadunico'),
  'CadÚnico': GlossaryEntry(docId: 'gov-cadunico', label: 'Cadastro Único'),
  'ID Jovem': GlossaryEntry(docId: 'gov-idjovem'),
  'Isenções': GlossaryEntry(docId: 'gov-isencoes'),
  'Transporte': GlossaryEntry(docId: 'gov-transporte'),
  'Bilhete Único': GlossaryEntry(docId: 'gov-transporte', label: 'Bilhete Único'),
  'PAP': GlossaryEntry(docId: 'inst-pap'),
  'Monitoria': GlossaryEntry(docId: 'inst-monitoria'),
  'Iniciação Científica': GlossaryEntry(docId: 'inst-ic'),
  'Extensão': GlossaryEntry(docId: 'inst-extensao'),
  'PIBIC': GlossaryEntry(docId: 'inst-ic', term: 'PIBIC', def: 'Programa Institucional de Bolsas de Iniciação Científica. Financia estudantes que desenvolvem pesquisa orientada por um docente, com bolsa mensal do CNPq ou da própria instituição.'),
  'PIBITI': GlossaryEntry(docId: 'inst-ic', term: 'PIBITI', def: 'Programa Institucional de Bolsas de Iniciação em Desenvolvimento Tecnológico e Inovação. Como o PIBIC, mas voltado a projetos de inovação e desenvolvimento tecnológico.'),
  'CRAS': GlossaryEntry(term: 'CRAS', def: 'Centro de Referência de Assistência Social. Unidade pública e gratuita onde você faz e atualiza o Cadastro Único e tem acesso a programas de assistência social.'),
  'NIS': GlossaryEntry(term: 'NIS', def: 'Número de Identificação Social. Código gerado quando você entra no Cadastro Único; identifica você nos programas sociais e em pedidos de isenção.'),
  'SiSU': GlossaryEntry(term: 'SiSU', def: 'Sistema de Seleção Unificada. Plataforma do MEC que usa a nota do Enem para distribuir vagas em universidades e institutos públicos.'),
  'Sisu+': GlossaryEntry(term: 'Sisu+', def: 'Etapa complementar do SiSU criada em 2026 para preencher vagas remanescentes nas instituições públicas, com ingresso no 2º semestre.'),
  'Enem': GlossaryEntry(term: 'Enem', def: 'Exame Nacional do Ensino Médio. A nota é usada como critério de ingresso em boa parte das vagas das graduações, inclusive no IFSP via SiSU.'),
  'NAPNE': GlossaryEntry(term: 'NAPNE', def: 'Núcleo de Atendimento às Pessoas com Necessidades Específicas. Setor do campus que apoia estudantes com deficiência.'),
};
```

- [ ] **Step 2: Teste do parser (FALHA primeiro)**

`test/shared/wiki_text_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/shared/content/wiki_text.dart';

void main() {
  testWidgets('WikiText mostra display de [[chave|display]] e o texto plano', (t) async {
    await t.pumpWidget(MaterialApp(theme: AppTheme.light, home: Scaffold(body:
      WikiText('Veja o [[Cadastro Único|CadÚnico]] e o [[PIBIC]]. Fim.', onOpenDoc: (_) {}, onOpenTerm: (_) {}),
    )));
    expect(find.textContaining('CadÚnico'), findsOneWidget);
    expect(find.textContaining('PIBIC'), findsOneWidget);
    expect(find.textContaining('Fim.'), findsOneWidget);
  });

  test('parseWikiTokens separa texto e chaves', () {
    final toks = parseWikiTokens('a [[X|b]] c [[Y]] d');
    expect(toks.length, 5);
    expect(toks[0].text, 'a ');
    expect(toks[1].linkKey, 'X');
    expect(toks[1].text, 'b');
    expect(toks[3].linkKey, 'Y');
    expect(toks[3].text, 'Y');
    expect(toks[4].text, ' d');
  });
}
```

- [ ] **Step 3: WikiText** — Create `lib/shared/content/wiki_text.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/content/glossary.dart';

/// Token de wiki-texto: trecho de texto plano OU um link (linkKey != null).
class WikiToken {
  final String text;
  final String? linkKey;
  const WikiToken(this.text, [this.linkKey]);
}

final _wikiRe = RegExp(r'\[\[([^\]]+)\]\]');

List<WikiToken> parseWikiTokens(String text) {
  final out = <WikiToken>[];
  var last = 0;
  for (final m in _wikiRe.allMatches(text)) {
    if (m.start > last) out.add(WikiToken(text.substring(last, m.start)));
    final inner = m.group(1)!;
    final parts = inner.split('|');
    final key = parts.first;
    final disp = parts.length > 1 ? parts[1] : parts.first;
    out.add(WikiToken(disp, key));
    last = m.end;
  }
  if (last < text.length) out.add(WikiToken(text.substring(last)));
  return out;
}

/// Renderiza texto com `[[chave]]`/`[[chave|exibição]]` como links do glossário.
class WikiText extends StatelessWidget {
  final String text;
  final void Function(String docId) onOpenDoc;
  final void Function(String termKey) onOpenTerm;
  final TextStyle? style;
  const WikiText(this.text, {super.key, required this.onOpenDoc, required this.onOpenTerm, this.style});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final base = style ?? TextStyle(fontSize: 13.5, height: 1.62, color: c.ink2);
    final linkStyle = base.copyWith(color: c.green700, fontWeight: FontWeight.w700, decoration: TextDecoration.underline, decorationColor: c.green100);
    return Text.rich(TextSpan(children: [
      for (final tk in parseWikiTokens(text))
        if (tk.linkKey != null && glossary.containsKey(tk.linkKey))
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () {
                final g = glossary[tk.linkKey]!;
                if (g.def != null) { onOpenTerm(tk.linkKey!); }
                else if (g.docId != null) { onOpenDoc(g.docId!); }
              },
              child: Text(tk.text, style: linkStyle),
            ),
          )
        else
          TextSpan(text: tk.text, style: base),
    ]));
  }
}

/// Parágrafos separados por \n\n, cada um com wikilinks.
class WikiParagraphs extends StatelessWidget {
  final String text;
  final void Function(String docId) onOpenDoc;
  final void Function(String termKey) onOpenTerm;
  const WikiParagraphs(this.text, {super.key, required this.onOpenDoc, required this.onOpenTerm});
  @override
  Widget build(BuildContext context) {
    final paras = text.split('\n\n');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (var i = 0; i < paras.length; i++)
        Padding(padding: EdgeInsets.only(top: i == 0 ? 0 : 11), child: WikiText(paras[i], onOpenDoc: onOpenDoc, onOpenTerm: onOpenTerm)),
    ]);
  }
}
```

- [ ] **Step 4:** `flutter test test/shared/wiki_text_test.dart` → PASS. `flutter analyze` nos novos arquivos → limpo.
- [ ] **Step 5:** Commit — `git add lib/data/content/glossary.dart lib/shared/content/wiki_text.dart test/shared/wiki_text_test.dart && git commit -m "feat(content): glossario + WikiText (wikilinks)"`

---

### Task 3: TermSheet + MediaView

**Files:** Create `lib/shared/content/term_sheet.dart`, `lib/shared/content/media_view.dart`

- [ ] **Step 1: TermSheet**

`lib/shared/content/term_sheet.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/content/glossary.dart';
import '../widgets/app_button.dart';
import '../widgets/icon_tile.dart';

/// Mostra a ficha de definição de um termo do glossário (bottom sheet).
Future<void> showTermSheet(BuildContext context, String termKey, {required void Function(String docId) onOpenDoc}) {
  final g = glossary[termKey];
  if (g == null) return Future.value();
  final c = context.c;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: c.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(999)))),
        const SizedBox(height: 18),
        Row(children: [
          IconTile('book', size: 42),
          const SizedBox(width: 11),
          Expanded(child: Text(g.term ?? termKey, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: c.ink))),
        ]),
        const SizedBox(height: 12),
        Text(g.def ?? '', style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2)),
        if (g.docId != null) ...[
          const SizedBox(height: 18),
          AppButton('Ver página completa', full: true, icon: 'chevR',
            onTap: () { Navigator.pop(ctx); onOpenDoc(g.docId!); }),
        ],
      ]),
    ),
  );
}
```

- [ ] **Step 2: MediaView**

`lib/shared/content/media_view.dart`:
```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/icon_tile.dart';

({String watch, String? thumb})? parseVideoUrl(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  final u = url.trim();
  final yt = RegExp(r'(?:youtube\.com/(?:watch\?v=|embed/|shorts/)|youtu\.be/)([\w-]{11})').firstMatch(u);
  if (yt != null) {
    final id = yt.group(1)!;
    return (watch: 'https://www.youtube.com/watch?v=$id', thumb: 'https://img.youtube.com/vi/$id/hqdefault.jpg');
  }
  final vimeo = RegExp(r'vimeo\.com/(\d+)').firstMatch(u);
  if (vimeo != null) return (watch: 'https://vimeo.com/${vimeo.group(1)}', thumb: null);
  if (u.startsWith('http')) return (watch: u, thumb: null);
  return null;
}

/// Renderiza imagem (URL) ou vídeo (link → thumbnail que abre no navegador).
class MediaView extends StatelessWidget {
  final String mediaType; // 'image' | 'video'
  final String? imageUrl, videoUrl, caption;
  const MediaView({super.key, required this.mediaType, this.imageUrl, this.videoUrl, this.caption});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget inner;
    if (mediaType == 'image' && imageUrl != null && imageUrl!.isNotEmpty) {
      inner = CachedNetworkImage(
        imageUrl: imageUrl!, height: 190, width: double.infinity, fit: BoxFit.cover,
        placeholder: (_, __) => Container(height: 190, color: c.bg2),
        errorWidget: (_, __, ___) => _placeholder(c, false),
      );
    } else if (mediaType == 'video' && parseVideoUrl(videoUrl) != null) {
      final v = parseVideoUrl(videoUrl)!;
      inner = GestureDetector(
        onTap: () { final uri = Uri.tryParse(v.watch); if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication); },
        child: Stack(alignment: Alignment.center, children: [
          if (v.thumb != null) CachedNetworkImage(imageUrl: v.thumb!, height: 190, width: double.infinity, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(height: 190, color: c.green900))
          else Container(height: 190, width: double.infinity, color: c.green900),
          Container(width: 60, height: 60, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(Icons.play_arrow, color: c.green800, size: 34)),
        ]),
      );
    } else {
      inner = _placeholder(c, mediaType == 'video');
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        inner,
        if (caption != null) Container(color: c.card, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), child: Text(caption!, style: TextStyle(fontSize: 12, color: c.ink2, fontWeight: FontWeight.w500))),
      ]),
    );
  }

  Widget _placeholder(AppColorsX c, bool isVideo) => Container(
    height: 150, color: c.bg2, alignment: Alignment.center,
    child: Icon(appIcon(isVideo ? 'globe' : 'doc'), size: 30, color: c.ink3),
  );
}
```

- [ ] **Step 3:** `flutter analyze lib/shared/content/` → limpo.
- [ ] **Step 4:** Commit — `git add lib/shared/content/term_sheet.dart lib/shared/content/media_view.dart && git commit -m "feat(content): TermSheet e MediaView"`

---

### Task 4: ContentSectionView + ContentDocScreen

**Files:** Create `lib/shared/content/content_section_view.dart`, `lib/features/content/screens/content_doc_screen.dart`

- [ ] **Step 1: ContentSectionView** — render de uma seção (switch no sealed), com callbacks de wikilink.

`lib/shared/content/content_section_view.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/content_doc.dart';
import '../widgets/accordion.dart';
import '../widgets/app_card.dart';
import '../widgets/icon_tile.dart';
import '../widgets/section_title.dart';
import 'media_view.dart';
import 'wiki_text.dart';

class ContentSectionView extends StatelessWidget {
  final ContentSection section;
  final void Function(String docId) onOpenDoc;
  final void Function(String termKey) onOpenTerm;
  const ContentSectionView({super.key, required this.section, required this.onOpenDoc, required this.onOpenTerm});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final s = section;
    Widget heading(String? h) => h == null ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(bottom: 11), child: SectionTitle(h));

    switch (s) {
      case RichSection():
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [heading(s.heading), WikiParagraphs(s.body, onOpenDoc: onOpenDoc, onOpenTerm: onOpenTerm)]);
      case StepsSection():
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          heading(s.heading),
          for (var i = 0; i < s.items.length; i++) Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 27, height: 27, alignment: Alignment.center, decoration: BoxDecoration(color: c.green800, shape: BoxShape.circle), child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800))),
              const SizedBox(width: 13),
              Expanded(child: WikiText(s.items[i], onOpenDoc: onOpenDoc, onOpenTerm: onOpenTerm, style: TextStyle(fontSize: 13.5, height: 1.5, color: c.ink))),
            ]),
          ),
        ]);
      case DocsSection():
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          heading(s.heading),
          AppCard(child: Column(children: [
            for (final it in s.items) Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(appIcon('checkCircle'), size: 18, color: c.green500),
              const SizedBox(width: 11),
              Expanded(child: WikiText(it, onOpenDoc: onOpenDoc, onOpenTerm: onOpenTerm, style: TextStyle(fontSize: 13.5, height: 1.45, color: c.ink))),
            ])),
          ])),
        ]);
      case MediaSection():
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [heading(s.heading), MediaView(mediaType: s.mediaType, imageUrl: s.imageUrl, videoUrl: s.videoUrl, caption: s.caption)]);
      case CalloutSection():
        final warn = s.variant == 'warn';
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: warn ? const Color(0x1FF2B01E) : c.green050, borderRadius: BorderRadius.circular(14), border: Border.all(color: warn ? const Color(0x4DF2B01E) : c.green100)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(appIcon(warn ? 'bell' : 'shield'), size: 20, color: warn ? const Color(0xFFC98A0E) : c.green600),
            const SizedBox(width: 12),
            Expanded(child: WikiText(s.body, onOpenDoc: onOpenDoc, onOpenTerm: onOpenTerm, style: TextStyle(fontSize: 12.5, height: 1.5, color: c.ink2, fontWeight: FontWeight.w500))),
          ]),
        );
      case FaqSection():
        return _FaqList(section: s, onOpenDoc: onOpenDoc, onOpenTerm: onOpenTerm);
      case SourcesSection():
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          heading(s.heading),
          for (final src in s.items) Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: AppCard(
              onTap: () { final uri = Uri.tryParse(src.url.startsWith('http') ? src.url : 'https://${src.url}'); if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication); },
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(children: [
                Icon(appIcon('globe'), size: 19, color: c.green700),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(src.label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink)),
                  Text(src.url, style: TextStyle(fontSize: 11.5, color: c.green700)),
                ])),
                Icon(appIcon('chevR'), size: 16, color: c.ink3),
              ]),
            ),
          ),
        ]);
    }
  }
}

class _FaqList extends StatefulWidget {
  final FaqSection section;
  final void Function(String docId) onOpenDoc;
  final void Function(String termKey) onOpenTerm;
  const _FaqList({required this.section, required this.onOpenDoc, required this.onOpenTerm});
  @override
  State<_FaqList> createState() => _FaqListState();
}

class _FaqListState extends State<_FaqList> {
  int _open = -1;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (widget.section.heading != null) Padding(padding: const EdgeInsets.only(bottom: 11), child: SectionTitle(widget.section.heading!)),
      for (var i = 0; i < widget.section.items.length; i++) Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Accordion(question: widget.section.items[i].q, answer: widget.section.items[i].a, open: _open == i, onToggle: () => setState(() => _open = _open == i ? -1 : i)),
      ),
    ]);
  }
}
```
> Nota: o `import 'package:url_launcher/url_launcher.dart';` é necessário em
> `content_section_view.dart` para os `sources`. Adicionar.

- [ ] **Step 2: ContentDocScreen**

`lib/features/content/screens/content_doc_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_doc.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/content/content_section_view.dart';
import '../../../shared/content/term_sheet.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/icon_tile.dart';

class ContentDocScreen extends StatelessWidget {
  final ContentDoc? doc;
  const ContentDocScreen({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final d = doc;
    if (d == null) {
      return PageShell(
        bodyPadding: EdgeInsets.zero,
        header: PageHeader(title: 'Conteúdo', onBack: () => context.pop()),
        body: const EmptyState(icon: 'doc', title: 'Conteúdo não encontrado'),
      );
    }
    void openDoc(String id) => context.push('/conteudo/$id');
    void openTerm(String key) => showTermSheet(context, key, onOpenDoc: openDoc);
    final updated = '${d.updatedAt.day.toString().padLeft(2, '0')}/${d.updatedAt.month.toString().padLeft(2, '0')}/${d.updatedAt.year}';

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: d.title, subtitle: d.tag, icon: d.icon, onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(appIcon('clock'), size: 14, color: c.ink3),
            const SizedBox(width: 6),
            Text('Atualizado em $updated', style: TextStyle(fontSize: 11.5, color: c.ink3, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 18),
          for (final s in d.sections) Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: ContentSectionView(section: s, onOpenDoc: openDoc, onOpenTerm: openTerm),
          ),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 3:** `flutter analyze lib/shared/content/ lib/features/content/` → limpo.
- [ ] **Step 4:** Commit — `git add lib/shared/content/content_section_view.dart lib/features/content/ && git commit -m "feat(content): ContentSectionView e ContentDocScreen"`

---

### Task 5: Repositório (content docs) + providers + conteúdo no Fake

**Files:** Modify `universe_repository.dart`, `firestore_universe_repository.dart`, `fake_universe_repository.dart`, `repository_provider.dart`

- [ ] **Step 1: Interface** — adicionar:
```dart
  Stream<List<ContentDoc>> watchContentDocs(ContentKind kind);
  Stream<ContentDoc?> watchContentDoc(String id);
```
(import `../models/content_doc.dart`.)

- [ ] **Step 2: Firestore impl**:
```dart
  @override
  Stream<List<ContentDoc>> watchContentDocs(ContentKind kind) => _db.collection('contentDocs')
      .where('kind', isEqualTo: kind.name).snapshots().map((s) => _map(s, ContentDoc.fromMap));
  @override
  Stream<ContentDoc?> watchContentDoc(String id) =>
      _db.collection('contentDocs').doc(id).snapshots().map((d) => d.exists ? ContentDoc.fromMap(d.id, d.data()!) : null);
```

- [ ] **Step 3: Fake impl** — transcrever os 8 documentos de `design_reference/project/universe/data-content.jsx` (CONTENT_DOCS) para uma lista `_contentDocs` de `ContentDoc` (com as seções tipadas e os `[[wikilinks]]` exatos no texto). Mapear `updated` (string ISO) → `DateTime`. Implementar:
```dart
  @override
  Stream<List<ContentDoc>> watchContentDocs(ContentKind kind) => Stream.value(_contentDocs.where((d) => d.kind == kind).toList());
  @override
  Stream<ContentDoc?> watchContentDoc(String id) => Stream.value(_contentDocs.where((d) => d.id == id).firstOrNull);
  // getter p/ o seeder:
  List<ContentDoc> get allContentDocs => _contentDocs;
```
> `firstOrNull`: usar `final m = _contentDocs.where(...); return Stream.value(m.isEmpty ? null : m.first);` se necessário.
> Para `media`: usar `imageUrl`/`videoUrl` ilustrativos — onde o protótipo tinha vídeo, pôr um `videoUrl` de exemplo do YouTube; onde imagem, um `imageUrl` (pode ser uma URL de placeholder estável) ou deixar nulo (mostra placeholder). Não inventar conteúdo textual — transcrever fielmente os textos/etapas/faq/sources.

- [ ] **Step 4: Providers** — em `repository_provider.dart`:
```dart
final contentDocsProvider = StreamProvider.family<List<ContentDoc>, ContentKind>((ref, k) => ref.watch(universeRepositoryProvider).watchContentDocs(k));
final contentDocProvider = StreamProvider.family<ContentDoc?, String>((ref, id) => ref.watch(universeRepositoryProvider).watchContentDoc(id));
```
(import content_doc.dart.)

- [ ] **Step 5:** `flutter analyze lib/data/repositories/ lib/core/providers/repository_provider.dart` → limpo. (As telas de benefício ainda usam o caminho antigo — Task 6 migra; pode haver erro só na Task 6.)
- [ ] **Step 6:** Commit — `git add lib/data/repositories/ lib/core/providers/repository_provider.dart && git commit -m "feat(content): repositorio de contentDocs + providers + conteudo no Fake"`

---

### Task 6: Migrar Benefícios + rotas + remover caminho antigo

**Files:** Modify `benefits_screen.dart`, `app_router.dart`, `home_screen.dart`; Delete `benefit_detail_screen.dart`; Modify `seed.dart`; remove `Benefit` model usage

- [ ] **Step 1: BenefitsScreen** → listar `contentDocs`:
```dart
// usar ref.watch(contentDocsProvider(kind == 'gov' ? ContentKind.gov : ContentKind.inst))
// kind aqui passa a ser ContentKind. Card: ícone (IconTile(doc.icon)), título (doc.title),
// tag (doc.tag) e summary (doc.summary). onTap: context.push('/conteudo/${doc.id}', extra: doc).
// Manter o parágrafo introdutório e o disclaimer RF012 (Task do P4B).
```
Trocar a assinatura `BenefitsScreen({required BenefitKind kind})` para usar `ContentKind` (ou mapear). Recomendado: trocar para `ContentKind kind`.

- [ ] **Step 2: Router** — adicionar imports content_doc + ContentDocScreen + contentDocProvider. Rotas:
```dart
GoRoute(path: '/beneficios/gov', pageBuilder: (c, s) => fadeSlide(s, const BenefitsScreen(kind: ContentKind.gov))),
GoRoute(path: '/beneficios/inst', pageBuilder: (c, s) => fadeSlide(s, const BenefitsScreen(kind: ContentKind.inst))),
GoRoute(path: '/conteudo/:id', pageBuilder: (c, s) {
  final extra = s.extra;
  if (extra is ContentDoc) return fadeSlide(s, ContentDocScreen(doc: extra));
  // sem extra (wikilink/deep-link): resolver por id via Consumer
  return fadeSlide(s, _ContentDocById(id: s.pathParameters['id']!));
}),
```
Remover a rota `/beneficios/detail` e o import de `benefit_detail_screen.dart` e `benefit.dart` (se não usado). Criar `_ContentDocById` (ConsumerWidget) no router (ou num arquivo) que faz `ref.watch(contentDocProvider(id)).when(... ContentDocScreen(doc: d) ...)`.
```dart
class _ContentDocById extends ConsumerWidget {
  final String id;
  const _ContentDocById({required this.id});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(contentDocProvider(id)).when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const ContentDocScreen(doc: null),
      data: (d) => ContentDocScreen(doc: d),
    );
  }
}
```

- [ ] **Step 3: Remover caminho antigo** — `git rm lib/features/benefits/screens/benefit_detail_screen.dart`. Remover `benefitsProvider` de `repository_provider.dart` e `watchBenefits` da interface/impls/Fake **se** não houver mais uso. Remover o modelo `Benefit` (`lib/data/models/benefit.dart`) **mantendo** `BenefitKind`? — Não: substituímos por `ContentKind`. Onde `BenefitKind` era usado (estágio? não — só benefícios), trocar por `ContentKind`. Verificar com `grep -rn "BenefitKind\|benefitsProvider\|watchBenefits\|models/benefit" lib` e limpar todos os usos. Atualizar `firestore_mapping_test`/outros testes que referenciem `Benefit` (remover esse trecho do teste, sem enfraquecer os demais).

- [ ] **Step 4: Home** — `_pushRoutes` já tem `/beneficios/gov` e `/inst`; nada a mudar além de garantir que ainda navegam.

- [ ] **Step 5: Seed** — em `seed.dart`: remover o bloco que popula `benefits`; adicionar:
```dart
  for (final d in fake.allContentDocs) {
    batch.set(db.collection('contentDocs').doc(d.id), d.toMap());
  }
```

- [ ] **Step 6:** `flutter analyze` (whole) → limpo. `flutter test` → todos PASS (ajustar testes que usavam Benefit). Commit — `git add -A && git commit -m "feat(content): migra Beneficios para content docs (rota /conteudo); remove caminho antigo"`

---

### Task 7: Verificação + seed + diário

- [ ] **Step 1:** `flutter analyze` (limpo) + `flutter test` (todos PASS).
- [ ] **Step 2:** Rodar no navegador (logado, admin): **Perfil → "Popular dados (dev)"** novamente (agora cria `contentDocs`). Abrir Benefícios → um benefício → ver a página rica (o que é, etapas, callout, faq, fontes); tocar num **wikilink** (`PIBIC` abre ficha; `Cadastro Único` abre outra página). Conferir "Atualizado em".
- [ ] **Step 3:** Diário (SP3a: conteúdo rico + glossário/wikilinks; benefícios migrados).
- [ ] **Step 4:** Commit — `git add docs/ && git commit -m "docs: registra SP3a (conteudo rico - leitura)"`

---

## Self-Review (cobertura da spec)
- **§2 modelos:** Task 1 ✓. **§3 glossário/wikilinks:** Task 2 ✓. **§4 render/MediaView/TermSheet:** Tasks 3–4 ✓.
- **§5 migração benefícios:** Task 6 ✓. **§6 repositório/seed:** Tasks 5–6 ✓. **§7 rotas:** Task 6 ✓.
- **§9 testes:** Tasks 1 (modelos), 2 (parser) ✓.

**Riscos/notas:**
1. **Remoção de `Benefit`/`BenefitKind`** toca vários arquivos — usar `grep` e migrar tudo para `ContentKind`; ajustar/limpar testes do `Benefit` sem enfraquecer os demais.
2. **Conteúdo no Fake** é transcrição fiel de `design_reference/.../data-content.jsx` (textos/etapas/faq/sources/wikilinks). Mídia: imagem por URL placeholder ou nula; vídeo por link de exemplo.
3. **`url_launcher`** import necessário em `media_view.dart` e `content_section_view.dart` (sources).
4. **Re-seed** cria `contentDocs`; a coleção `benefits` antiga pode ser ignorada/apagada no console (opcional).
5. **`firstOrNull`** em listas: usar fallback `isEmpty ? null : first` se o lint pedir `package:collection`.
