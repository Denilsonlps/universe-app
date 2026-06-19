# SP3c — Notícias · Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) ou superpowers:executing-plans. Steps usam checkbox (`- [ ]`).

**Goal:** Notícias do campus: o admin publica (com imagem, fatos rápidos e wikilinks) e o aluno vê na Home, numa lista com filtro por categoria e no detalhe.

**Architecture:** Modelo `News` + coleção Firestore `news`. Repositório com leitura (publicadas/todas) e escrita admin. Telas do aluno (bloco na Home + `/noticias` + `/noticias/:id`) e do admin (lista + editor) reusam o que já existe: `WikiParagraphs`+resolvedor, `ImagePickerField`/`ContentImage`, `AsyncListView`, `AppToggle`, design system.

**Tech Stack:** flutter_riverpod, go_router, cloud_firestore, url_launcher. Sem dependências novas.

**Spec:** `docs/superpowers/specs/2026-06-18-sp3c-noticias-design.md`.

**Reuso (assinaturas reais já no projeto):**
- `WikiParagraphs(String text, {required void Function(String) onOpenDoc, required void Function(String) onOpenTerm, String? Function(String)? resolveDoc})` (`lib/shared/content/wiki_text.dart`).
- `showTermSheet(BuildContext, String termKey, {void Function(String)? onOpenDoc})` (`lib/shared/content/term_sheet.dart`).
- `ImagePickerField({required String? imageUrl, required ValueChanged<String?> onChanged, BoxFit previewFit})` (`lib/shared/content/image_picker_field.dart`).
- `ContentImage(String url, {double? height, width, BoxFit fit, ...})` (`lib/shared/content/content_image.dart`).
- `AsyncListView<T>({required AsyncValue<List<T>> value, VoidCallback? onRetry, String? emptyTitle, required Widget Function(List<T>) data})` (`lib/shared/widgets/async_view.dart`).
- `AppToggle({required bool on, required ValueChanged<bool> onChanged})`; `AppField(... multiline: true)`; `AppButton('lbl', full:, variant:, icon:, onTap:)`; `AppCard(child:, onTap:, padding:)`; `AppChip(String, {onTap})`; `IconTile(name, size:)`/`appIcon`; `SectionTitle(String)`; `GreenHero(title:, subtitle:, icon:, onBack:)`/`PageHeader(title:, onBack:)`/`PageShell(header:, body:, bodyPadding:)`.
- `allContentDocsProvider` (para o resolvedor de wikilinks no detalhe).
- `newId('news')`, `universeRepositoryProvider`.

---

## Estrutura de arquivos

```
lib/data/models/news.dart                                  News + fromMap/toMap
lib/data/repositories/universe_repository.dart             + watchPublishedNews/watchAllNews/upsertNews/deleteNews
lib/data/repositories/firestore_universe_repository.dart   impl
lib/data/repositories/fake_universe_repository.dart        impl + 3 notícias
lib/core/providers/repository_provider.dart                + publishedNewsProvider/allNewsProvider
lib/features/news/widgets/news_card.dart                   NewsCard (compact + padrão)
lib/features/news/screens/news_list_screen.dart            /noticias
lib/features/news/screens/news_detail_screen.dart          /noticias/:id (+ _NewsById)
lib/features/home/screens/home_screen.dart                 bloco "Notícias"
lib/features/admin/screens/admin_hub_screen.dart           + card Notícias
lib/features/admin/screens/admin_news_list_screen.dart     /admin/noticias
lib/features/admin/screens/admin_news_edit_screen.dart     /admin/noticias/editar
lib/core/router/app_router.dart                            rotas
lib/data/repositories/seed.dart                            seeda news
firestore.rules                                            leitura de news restrita
test/data/news_test.dart  ·  test/data/news_repo_test.dart  ·  test/features/admin_news_edit_test.dart
```

---

### Task 1: Modelo News

**Files:** Create `lib/data/models/news.dart`; Test `test/data/news_test.dart`

- [ ] **Step 1: Teste (FALHA)** — `test/data/news_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/news.dart';

void main() {
  test('News round-trip com facts', () {
    final n = News(
      id: 'n1', category: 'SiSU', source: 'MEC', readTime: '2 min',
      title: 'T', summary: 's', body: 'corpo [[SiSU]]',
      date: DateTime(2026, 6, 8), published: true, pinned: true,
      facts: const [(label: 'Inscrições', value: '15 a 19/06')],
      sourceUrl: 'gov.br/mec', imageUrl: 'https://x/y.png',
    );
    final back = News.fromMap('n1', n.toMap());
    expect(back.title, 'T');
    expect(back.category, 'SiSU');
    expect(back.date, DateTime(2026, 6, 8));
    expect(back.published, true);
    expect(back.pinned, true);
    expect(back.facts.single.label, 'Inscrições');
    expect(back.facts.single.value, '15 a 19/06');
    expect(back.sourceUrl, 'gov.br/mec');
    expect(back.imageUrl, 'https://x/y.png');
  });

  test('fromMap tolera ausências', () {
    final back = News.fromMap('x', const {'title': 'T'});
    expect(back.published, false);
    expect(back.pinned, false);
    expect(back.facts, isEmpty);
    expect(back.sourceUrl, isNull);
  });
}
```
- [ ] **Step 2:** `flutter test test/data/news_test.dart` → FAIL.
- [ ] **Step 3: Implementar** — `lib/data/models/news.dart`:
```dart
class News {
  final String id, category, source, readTime, title, summary, body;
  final DateTime date;
  final List<({String label, String value})> facts;
  final String? sourceUrl, imageUrl;
  final bool published, pinned;
  const News({
    required this.id, required this.category, required this.source, required this.readTime,
    required this.title, required this.summary, required this.body, required this.date,
    this.facts = const [], this.sourceUrl, this.imageUrl,
    this.published = false, this.pinned = false,
  });

  Map<String, dynamic> toMap() => {
        'category': category, 'source': source, 'readTime': readTime,
        'title': title, 'summary': summary, 'body': body,
        'date': date.millisecondsSinceEpoch,
        'facts': [for (final f in facts) {'label': f.label, 'value': f.value}],
        'sourceUrl': sourceUrl, 'imageUrl': imageUrl,
        'published': published, 'pinned': pinned,
      };

  factory News.fromMap(String id, Map<String, dynamic> m) => News(
        id: id,
        category: m['category'] ?? 'Geral', source: m['source'] ?? '',
        readTime: m['readTime'] ?? '', title: m['title'] ?? '',
        summary: m['summary'] ?? '', body: m['body'] ?? '',
        date: DateTime.fromMillisecondsSinceEpoch((m['date'] as num? ?? 0).toInt()),
        facts: ((m['facts'] ?? const []) as List)
            .map((e) => (label: (e['label'] ?? '') as String, value: (e['value'] ?? '') as String))
            .toList(),
        sourceUrl: m['sourceUrl'], imageUrl: m['imageUrl'],
        published: m['published'] ?? false, pinned: m['pinned'] ?? false,
      );
}
```
- [ ] **Step 4:** `flutter test test/data/news_test.dart` → PASS. `flutter analyze lib/data/models/news.dart` → limpo.
- [ ] **Step 5:** Commit — `git add lib/data/models/news.dart test/data/news_test.dart && git commit -m "feat(news): modelo News"`

---

### Task 2: Repositório + providers + Fake (3 notícias)

**Files:** Modify `universe_repository.dart`, `firestore_universe_repository.dart`, `fake_universe_repository.dart`, `repository_provider.dart`; Test `test/data/news_repo_test.dart`

- [ ] **Step 1: Teste (FALHA)** — `test/data/news_repo_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/news.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';

void main() {
  test('publishedNews exclui rascunhos e ordena (pinned, data desc)', () async {
    final repo = FakeUniverseRepository();
    await repo.upsertNews(News(id: 'a', category: 'Geral', source: '', readTime: '', title: 'A', summary: '', body: '', date: DateTime(2026, 1, 1), published: true));
    await repo.upsertNews(News(id: 'b', category: 'Geral', source: '', readTime: '', title: 'B', summary: '', body: '', date: DateTime(2026, 3, 1), published: true));
    await repo.upsertNews(News(id: 'c', category: 'Geral', source: '', readTime: '', title: 'C', summary: '', body: '', date: DateTime(2026, 2, 1), published: true, pinned: true));
    await repo.upsertNews(News(id: 'd', category: 'Geral', source: '', readTime: '', title: 'D', summary: '', body: '', date: DateTime(2026, 5, 1), published: false));

    final pub = await repo.watchPublishedNews().first;
    expect(pub.map((n) => n.id).toList(), ['c', 'b', 'a']); // pinned 1º, depois data desc; rascunho 'd' fora
  });

  test('upsert/delete e watchAll', () async {
    final repo = FakeUniverseRepository();
    final before = (await repo.watchAllNews().first).length;
    await repo.upsertNews(News(id: 'z', category: 'Geral', source: '', readTime: '', title: 'Z', summary: '', body: '', date: DateTime(2026, 1, 1)));
    expect((await repo.watchAllNews().first).length, before + 1);
    await repo.deleteNews('z');
    expect((await repo.watchAllNews().first).where((n) => n.id == 'z'), isEmpty);
  });
}
```
- [ ] **Step 2:** `flutter test test/data/news_repo_test.dart` → FAIL.
- [ ] **Step 3: Interface** (`universe_repository.dart`) — add `import '../models/news.dart';` e:
```dart
  Stream<List<News>> watchPublishedNews();
  Stream<List<News>> watchAllNews();
  Future<void> upsertNews(News n);
  Future<void> deleteNews(String id);
```
- [ ] **Step 4: Firestore impl** (`firestore_universe_repository.dart`) — add `import '../models/news.dart';` e:
```dart
  @override
  Stream<List<News>> watchPublishedNews() => _db.collection('news')
      .where('published', isEqualTo: true).snapshots().map((s) {
        final list = _map(s, News.fromMap);
        list.sort((a, b) { if (a.pinned != b.pinned) return a.pinned ? -1 : 1; return b.date.compareTo(a.date); });
        return list;
      });
  @override
  Stream<List<News>> watchAllNews() => _db.collection('news').snapshots().map((s) {
        final list = _map(s, News.fromMap);
        list.sort((a, b) => b.date.compareTo(a.date));
        return list;
      });
  @override
  Future<void> upsertNews(News n) => _db.collection('news').doc(n.id).set(n.toMap());
  @override
  Future<void> deleteNews(String id) => _db.collection('news').doc(id).delete();
```
- [ ] **Step 5: Fake impl** (`fake_universe_repository.dart`) — add `import '../models/news.dart';`. Add a instance list (perto de `_contentDocs`) com as 3 notícias do protótipo (transcrever de `design_reference/project/universe/data-content.jsx` `NEWS_SEED`: n1 SiSU/MEC/2026-06-08/pinned, n2 SiSU/G1/2026-06-15, n3 Campus/IFSP Pirituba/2026-06-11; manter `body` com `[[wikilinks]]`, `facts`, `sourceUrl`; todas `published: true`):
```dart
  final List<News> _news = [
    News(
      id: 'n1', category: 'SiSU', source: 'MEC', readTime: '2 min',
      title: 'Sisu+ 2026: MEC libera consulta às vagas da etapa complementar',
      summary: 'Nova etapa do SiSU permite consultar antecipadamente as vagas remanescentes para ingresso no 2º semestre.',
      body: 'O Ministério da Educação liberou a consulta às vagas do [[Sisu+]], uma etapa complementar do [[SiSU]] criada para preencher vagas que ficaram remanescentes nas instituições públicas após as chamadas regulares.\n\nPela ferramenta do Portal de Acesso Único, é possível pesquisar cursos, instituições, municípios, turnos e modalidades de concorrência antes da abertura das inscrições — o que ajuda a planejar as escolhas com calma.\n\nO objetivo do programa é ampliar o acesso ao ensino superior público e reduzir o número de vagas que ficam ociosas ao longo do ano letivo.',
      date: DateTime(2026, 6, 8), published: true, pinned: true,
      facts: const [(label: 'Inscrições', value: '15 a 19 de junho'), (label: 'Resultado', value: '24 de junho'), (label: 'Ingresso', value: '2º semestre de 2026')],
      sourceUrl: 'gov.br/mec',
    ),
    News(
      id: 'n2', category: 'SiSU', source: 'G1', readTime: '2 min',
      title: 'Universidades públicas oferecem mais de 1.700 vagas pelo Sisu+',
      summary: 'Estados divulgam a oferta de vagas remanescentes; quem concorreu na etapa regular pode se inscrever.',
      body: 'Com a abertura do [[Sisu+]], instituições públicas em diferentes estados divulgaram suas vagas remanescentes — em alguns estados, passando de 1.700 oportunidades em universidades e institutos.\n\nPodem se inscrever os estudantes que fizeram o [[Enem]] em uma das últimas três edições e que concorreram na etapa regular do [[SiSU]] 2026. O sistema considera automaticamente a edição do Enem com a melhor média ponderada para cada curso escolhido.\n\nNa inscrição, é possível escolher até duas opções de curso, definindo uma ordem de preferência.',
      date: DateTime(2026, 6, 15), published: true,
      facts: const [(label: 'Vagas (exemplo)', value: '+1.700 em um estado'), (label: 'Quem pode', value: 'Quem concorreu no SiSU regular'), (label: 'Opções', value: 'Até 2 cursos')],
      sourceUrl: 'g1.globo.com',
    ),
    News(
      id: 'n3', category: 'Campus', source: 'IFSP Pirituba', readTime: '1 min',
      title: 'PAP: inscrições abertas para o auxílio permanência',
      summary: 'Edital de assistência estudantil do campus está com inscrições abertas pelo SUAP.',
      body: 'O campus abriu o edital do [[PAP]] — Programa de Auxílio Permanência. Estudantes em situação de vulnerabilidade podem solicitar apoio financeiro para moradia, alimentação e transporte.\n\nA inscrição é feita pelo sistema acadêmico (SUAP), com envio da documentação socioeconômica. Em caso de dúvida sobre os documentos, procure o serviço social do campus.',
      date: DateTime(2026, 6, 11), published: true,
      facts: const [(label: 'Onde', value: 'SUAP'), (label: 'Apoio', value: 'Moradia, alimentação, transporte')],
      sourceUrl: 'ptb.ifsp.edu.br',
    ),
  ];

  @override
  Stream<List<News>> watchPublishedNews() {
    final list = _news.where((n) => n.published).toList();
    list.sort((a, b) { if (a.pinned != b.pinned) return a.pinned ? -1 : 1; return b.date.compareTo(a.date); });
    return Stream.value(list);
  }
  @override
  Stream<List<News>> watchAllNews() {
    final list = List.of(_news)..sort((a, b) => b.date.compareTo(a.date));
    return Stream.value(list);
  }
  @override
  Future<void> upsertNews(News n) async {
    final i = _news.indexWhere((e) => e.id == n.id);
    if (i >= 0) { _news[i] = n; } else { _news.add(n); }
  }
  @override
  Future<void> deleteNews(String id) async => _news.removeWhere((e) => e.id == id);

  // getter para o seeder
  List<News> get allNews => _news;
```
- [ ] **Step 6: Providers** (`repository_provider.dart`) — add `import '../../data/models/news.dart';` e:
```dart
final publishedNewsProvider = StreamProvider<List<News>>((ref) => ref.watch(universeRepositoryProvider).watchPublishedNews());
final allNewsProvider = StreamProvider<List<News>>((ref) => ref.watch(universeRepositoryProvider).watchAllNews());
```
- [ ] **Step 7:** `flutter test test/data/news_repo_test.dart` → PASS. `flutter analyze` → limpo.
- [ ] **Step 8:** Commit — `git add lib/data/ lib/core/providers/repository_provider.dart test/data/news_repo_test.dart && git commit -m "feat(news): repositorio + providers + 3 noticias no Fake"`

---

### Task 3: NewsCard

**Files:** Create `lib/features/news/widgets/news_card.dart`

- [ ] **Step 1: Implementar** — card com variante `compact` (carrossel) e padrão (lista):
```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/news.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/icon_tile.dart';

String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

class NewsCard extends StatelessWidget {
  final News news;
  final VoidCallback onTap;
  final bool compact;
  const NewsCard({super.key, required this.news, required this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(999)),
      child: Text(news.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.green700)),
    );

    if (compact) {
      return SizedBox(
        width: 250,
        child: AppCard(
          onTap: onTap,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              chip,
              const Spacer(),
              if (news.pinned) Icon(appIcon('star'), size: 14, color: const Color(0xFFF2B01E)),
            ]),
            const SizedBox(height: 9),
            Text(news.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, height: 1.3, color: c.ink)),
            const SizedBox(height: 9),
            Text('${news.source} · ${_fmtDate(news.date)}', style: TextStyle(fontSize: 11, color: c.ink3, fontWeight: FontWeight.w600)),
          ]),
        ),
      );
    }

    return AppCard(
      onTap: onTap,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        IconTile(news.category == 'Campus' ? 'institution' : 'cap', size: 56, iconSize: 26),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [chip, if (news.pinned) ...[const SizedBox(width: 7), Icon(appIcon('star'), size: 13, color: const Color(0xFFF2B01E))]]),
          const SizedBox(height: 6),
          Text(news.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3, color: c.ink)),
          const SizedBox(height: 6),
          Text('${news.source} · ${_fmtDate(news.date)} · ${news.readTime}', style: TextStyle(fontSize: 11, color: c.ink3, fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }
}
```
- [ ] **Step 2:** `flutter analyze lib/features/news/widgets/news_card.dart` → limpo (compila com os imports; usado nas próximas tasks).
- [ ] **Step 3:** Commit — `git add lib/features/news/widgets/news_card.dart && git commit -m "feat(news): NewsCard (compact + lista)"`

---

### Task 4: Lista + detalhe (aluno)

**Files:** Create `lib/features/news/screens/news_list_screen.dart`, `lib/features/news/screens/news_detail_screen.dart`

- [ ] **Step 1: NewsListScreen** — `lib/features/news/screens/news_list_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../data/models/news.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/async_view.dart';
import '../widgets/news_card.dart';

class NewsListScreen extends ConsumerStatefulWidget {
  const NewsListScreen({super.key});
  @override
  ConsumerState<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends ConsumerState<NewsListScreen> {
  String _cat = 'Todas';
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(publishedNewsProvider);
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: 'Notícias', subtitle: 'Avisos do campus e do mundo acadêmico', icon: 'bell', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AsyncListView<News>(
          value: async,
          onRetry: () => ref.invalidate(publishedNewsProvider),
          emptyTitle: 'Nenhuma notícia',
          data: (all) {
            final cats = ['Todas', ...{for (final n in all) n.category}];
            if (!cats.contains(_cat)) _cat = 'Todas';
            final list = _cat == 'Todas' ? all : all.where((n) => n.category == _cat).toList();
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: cats.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 9),
                  itemBuilder: (_, i) => AppChip(cats[i], active: _cat == cats[i], onTap: () => setState(() => _cat = cats[i])),
                ),
              ),
              const SizedBox(height: 16),
              for (final n in list) Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NewsCard(news: n, onTap: () => context.push('/noticias/${n.id}', extra: n)),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
```
NOTA: confirme a assinatura de `AppChip` — se for `AppChip(String label, {bool active, VoidCallback? onTap})`, use como acima; se `active` não existir, use o construtor real (ex.: sem destaque de seleção) e ajuste.

- [ ] **Step 2: NewsDetailScreen** — `lib/features/news/screens/news_detail_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/launch.dart';
import '../../../data/models/content_doc.dart';
import '../../../data/models/news.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/content/content_image.dart';
import '../../../shared/content/term_sheet.dart';
import '../../../shared/content/wiki_text.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/icon_tile.dart';

class NewsDetailScreen extends ConsumerWidget {
  final News? news;
  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final n = news;
    if (n == null) {
      return PageShell(
        bodyPadding: EdgeInsets.zero,
        header: PageHeader(title: 'Notícia', onBack: () => context.pop()),
        body: const EmptyState(icon: 'bell', title: 'Notícia não encontrada'),
      );
    }
    void openDoc(String id) => context.push('/conteudo/$id');
    void openTerm(String key) => showTermSheet(context, key, onOpenDoc: openDoc);
    final all = ref.watch(allContentDocsProvider).valueOrNull ?? const <ContentDoc>[];
    final byTitle = {for (final p in all) p.title.toLowerCase().trim(): p.id};
    String? resolveDoc(String key) => byTitle[key.toLowerCase().trim()];
    final date = '${n.date.day.toString().padLeft(2, '0')}/${n.date.month.toString().padLeft(2, '0')}/${n.date.year}';

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: n.title, subtitle: n.category, icon: 'bell', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (n.imageUrl != null && n.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(color: c.bg2, width: double.infinity, constraints: const BoxConstraints(minHeight: 180),
                child: ContentImage(n.imageUrl!, height: 180, width: double.infinity)),
            ),
            const SizedBox(height: 16),
          ],
          Text('${n.source} · $date · ${n.readTime} de leitura', style: TextStyle(fontSize: 12, color: c.ink3, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (n.facts.isNotEmpty) ...[
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final f in n.facts) Container(
                width: 150,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(13)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f.label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: c.green700)),
                  const SizedBox(height: 3),
                  Text(f.value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.25, color: c.ink)),
                ]),
              ),
            ]),
            const SizedBox(height: 18),
          ],
          WikiParagraphs(n.body, onOpenDoc: openDoc, onOpenTerm: openTerm, resolveDoc: resolveDoc),
          if (n.sourceUrl != null && n.sourceUrl!.isNotEmpty) ...[
            const SizedBox(height: 22),
            AppCard(
              child: Row(children: [
                Icon(appIcon('globe'), size: 20, color: c.green700),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Fonte oficial', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.ink)),
                  Text(n.sourceUrl!, style: TextStyle(fontSize: 11.5, color: c.green700)),
                ])),
                AppButton('Abrir', size: AppButtonSize.sm, onTap: () => openExternalUrl(context, n.sourceUrl)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

/// Resolve a notícia por id (deep-link / sem `extra`).
class NewsById extends ConsumerWidget {
  final String id;
  const NewsById({super.key, required this.id});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(publishedNewsProvider).when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const NewsDetailScreen(news: null),
      data: (list) {
        final match = list.where((n) => n.id == id);
        return NewsDetailScreen(news: match.isEmpty ? null : match.first);
      },
    );
  }
}
```
NOTA: confirme `openExternalUrl(BuildContext, String?)` em `lib/core/utils/launch.dart` (usado na vaga). Se a assinatura diferir, use a real. Confirme `AppButton` aceita `size: AppButtonSize.sm`.

- [ ] **Step 3:** `flutter analyze lib/features/news/` → limpo.
- [ ] **Step 4:** Commit — `git add lib/features/news/screens/ && git commit -m "feat(news): tela de lista e de detalhe (aluno)"`

---

### Task 5: Bloco de Notícias na Home

**Files:** Modify `lib/features/home/screens/home_screen.dart`

- [ ] **Step 1:** Adicionar imports no topo:
```dart
import '../../../core/providers/repository_provider.dart';
import '../../../data/models/news.dart';
import '../../news/widgets/news_card.dart';
```
- [ ] **Step 2:** Dentro do `Column` do `body`, logo após `_HighlightCard(...)` e o `SizedBox(height: 22)`, **antes** do `SectionTitle('Explorar')`, inserir o bloco de notícias:
```dart
        // Notícias (carrossel) — só aparece se houver publicadas
        ...(() {
          final news = ref.watch(publishedNewsProvider).valueOrNull ?? const <News>[];
          if (news.isEmpty) return const <Widget>[];
          final top = news.take(6).toList();
          return [
            Row(children: [
              Expanded(child: SectionTitle('Notícias')),
              GestureDetector(
                onTap: () => context.push('/noticias'),
                child: Text('Ver todas', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.green700)),
              ),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: top.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => NewsCard(news: top[i], compact: true, onTap: () => context.push('/noticias/${top[i].id}', extra: top[i])),
              ),
            ),
            const SizedBox(height: 22),
          ];
        }()),
```
(`SectionTitle` já está importado na Home.)
- [ ] **Step 3:** `flutter analyze lib/features/home/screens/home_screen.dart` → limpo. Ajustar a altura (132) se o card compacto estourar.
- [ ] **Step 4:** Commit — `git add lib/features/home/screens/home_screen.dart && git commit -m "feat(news): bloco de noticias na Home"`

---

### Task 6: Admin (hub + lista + editor) + rotas

**Files:** Modify `admin_hub_screen.dart`, `app_router.dart`; Create `admin_news_list_screen.dart`, `admin_news_edit_screen.dart`; Test `test/features/admin_news_edit_test.dart`

- [ ] **Step 1: Hub** — em `admin_hub_screen.dart`, adicionar o 3º card na lista `cards`:
```dart
      (icon: 'bell', title: 'Notícias', sub: 'Avisos e novidades do campus', route: '/admin/noticias'),
```
- [ ] **Step 2: AdminNewsListScreen** — `lib/features/admin/screens/admin_news_list_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/news.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_toggle.dart';
import '../../../shared/widgets/async_view.dart';

class AdminNewsListScreen extends ConsumerWidget {
  const AdminNewsListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final async = ref.watch(allNewsProvider);
    final repo = ref.read(universeRepositoryProvider);
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: 'Notícias', subtitle: 'Publique avisos e novidades', icon: 'bell', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppButton('Nova notícia', full: true, icon: 'plus', onTap: () => context.push('/admin/noticias/editar')),
          const SizedBox(height: 14),
          AsyncListView<News>(
            value: async,
            onRetry: () => ref.invalidate(allNewsProvider),
            emptyTitle: 'Nenhuma notícia ainda',
            data: (list) => Column(children: [
              for (final n in list) Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Opacity(
                  opacity: n.published ? 1 : 0.6,
                  child: AppCard(
                    onTap: () => context.push('/admin/noticias/editar', extra: n),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(n.title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink)),
                        const SizedBox(height: 4),
                        Text('${n.category} · ${n.source}${n.published ? '' : ' · Rascunho'}', style: TextStyle(fontSize: 11.5, color: c.ink3)),
                      ])),
                      AppToggle(on: n.published, onChanged: (v) => repo.upsertNews(News(
                        id: n.id, category: n.category, source: n.source, readTime: n.readTime,
                        title: n.title, summary: n.summary, body: n.body, date: n.date,
                        facts: n.facts, sourceUrl: n.sourceUrl, imageUrl: n.imageUrl,
                        published: v, pinned: n.pinned,
                      ))),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
```
- [ ] **Step 3: AdminNewsEditScreen** — `lib/features/admin/screens/admin_news_edit_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/news.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/content/image_picker_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/app_toggle.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/section_title.dart';

const _categorias = ['Campus', 'SiSU', 'Enem', 'Geral'];

class AdminNewsEditScreen extends ConsumerStatefulWidget {
  final News? news;
  const AdminNewsEditScreen({super.key, required this.news});
  @override
  ConsumerState<AdminNewsEditScreen> createState() => _AdminNewsEditScreenState();
}

class _AdminNewsEditScreenState extends ConsumerState<AdminNewsEditScreen> {
  late final _n = widget.news;
  late String _title = _n?.title ?? '';
  late String _category = _n?.category ?? 'Campus';
  late String _source = _n?.source ?? 'IFSP Pirituba';
  late String _readTime = _n?.readTime ?? '2 min';
  late String _summary = _n?.summary ?? '';
  late String _body = _n?.body ?? '';
  late String _sourceUrl = _n?.sourceUrl ?? '';
  late String? _imageUrl = _n?.imageUrl;
  late List<({String label, String value})> _facts = List.of(_n?.facts ?? const []);
  late bool _pinned = _n?.pinned ?? false;
  late bool _published = _n?.published ?? true;
  bool _saving = false;
  bool get _isNew => _n == null;
  bool get _valid => _title.trim().isNotEmpty && _body.trim().length > 10;

  Future<void> _save() async {
    if (!_valid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe título e corpo da notícia.')));
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(universeRepositoryProvider);
    final id = _n?.id ?? repo.newId('news');
    final news = News(
      id: id, category: _category.trim().isEmpty ? 'Geral' : _category.trim(),
      source: _source.trim(), readTime: _readTime.trim(), title: _title.trim(),
      summary: _summary.trim(), body: _body.trim(), date: _n?.date ?? DateTime.now(),
      facts: _facts, sourceUrl: _sourceUrl.trim().isEmpty ? null : _sourceUrl.trim(),
      imageUrl: _imageUrl, published: _published, pinned: _pinned,
    );
    try {
      await repo.upsertNews(news);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notícia salva!'))); context.pop(); }
    } catch (_) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar. Tente novamente.'))); setState(() => _saving = false); }
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Excluir notícia'),
      content: Text('Excluir "$_title"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Excluir')),
      ],
    ));
    if (ok == true) {
      try {
        await ref.read(universeRepositoryProvider).deleteNews(_n!.id);
        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notícia excluída'))); context.pop(); }
      } catch (_) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao excluir.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: _isNew ? 'Nova notícia' : 'Editar notícia', subtitle: _isNew ? null : _title, icon: 'edit', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppField(label: 'Título', icon: 'edit', value: _title, onChanged: (v) => setState(() => _title = v)),
          const SizedBox(height: 12),
          Text('Categoria', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
          const SizedBox(height: 7),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final cat in _categorias)
              GestureDetector(
                onTap: () => setState(() => _category = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(color: _category == cat ? c.green800 : c.bg2, borderRadius: BorderRadius.circular(999)),
                  child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _category == cat ? Colors.white : c.ink2)),
                ),
              ),
          ]),
          const SizedBox(height: 8),
          AppField(label: 'Categoria (livre, opcional)', value: _category, onChanged: (v) => setState(() => _category = v)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AppField(label: 'Fonte', icon: 'institution', value: _source, onChanged: (v) => setState(() => _source = v))),
            const SizedBox(width: 10),
            Expanded(child: AppField(label: 'Tempo de leitura', icon: 'clock', value: _readTime, onChanged: (v) => setState(() => _readTime = v))),
          ]),
          const SizedBox(height: 12),
          AppField(label: 'Resumo (aparece no card)', multiline: true, value: _summary, onChanged: (v) => setState(() => _summary = v)),
          const SizedBox(height: 12),
          AppField(label: 'Texto completo (use [[termos]] para links)', multiline: true, value: _body, onChanged: (v) => setState(() => _body = v)),
          const SizedBox(height: 18),
          const SectionTitle('Fatos rápidos'),
          for (var i = 0; i < _facts.length; i++) Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: AppField(hint: 'Rótulo', value: _facts[i].label, onChanged: (v) => setState(() => _facts[i] = (label: v, value: _facts[i].value)))),
              const SizedBox(width: 8),
              Expanded(child: AppField(hint: 'Valor', value: _facts[i].value, onChanged: (v) => setState(() => _facts[i] = (label: _facts[i].label, value: v)))),
              IconButton(onPressed: () => setState(() => _facts.removeAt(i)), icon: Icon(Icons.delete_outline, size: 19, color: c.error)),
            ]),
          ),
          Align(alignment: Alignment.centerLeft, child: TextButton.icon(
            onPressed: () => setState(() => _facts.add((label: '', value: ''))),
            icon: Icon(appIcon('plus'), size: 16, color: c.green700),
            label: Text('Adicionar fato', style: TextStyle(color: c.green700, fontWeight: FontWeight.w700, fontSize: 12.5)),
          )),
          const SizedBox(height: 14),
          const SectionTitle('Imagem (opcional)'),
          ImagePickerField(imageUrl: _imageUrl, onChanged: (url) => setState(() => _imageUrl = url)),
          const SizedBox(height: 14),
          AppField(label: 'Link da fonte oficial', icon: 'globe', value: _sourceUrl, onChanged: (v) => setState(() => _sourceUrl = v)),
          const SizedBox(height: 14),
          AppCard(child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Destaque na Home', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink)),
              Text('Marca a notícia como prioritária', style: TextStyle(fontSize: 11.5, color: c.ink3)),
            ])),
            AppToggle(on: _pinned, onChanged: (v) => setState(() => _pinned = v)),
          ])),
          const SizedBox(height: 10),
          AppCard(child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Publicar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink)),
              Text(_published ? 'Visível para os alunos' : 'Salva como rascunho', style: TextStyle(fontSize: 11.5, color: c.ink3)),
            ])),
            AppToggle(on: _published, onChanged: (v) => setState(() => _published = v)),
          ])),
          const SizedBox(height: 18),
          AppButton(_saving ? 'Salvando…' : 'Salvar notícia', full: true, icon: 'check', onTap: _saving ? null : _save),
          if (!_isNew) ...[
            const SizedBox(height: 10),
            AppButton('Excluir notícia', full: true, variant: AppButtonVariant.outline, onTap: _delete),
          ],
        ]),
      ),
    );
  }
}
```
- [ ] **Step 4: Rotas** — em `app_router.dart`, adicionar imports e rotas (junto às de admin/conteúdo):
```dart
import '../../data/models/news.dart';
import '../../features/news/screens/news_list_screen.dart';
import '../../features/news/screens/news_detail_screen.dart';
import '../../features/admin/screens/admin_news_list_screen.dart';
import '../../features/admin/screens/admin_news_edit_screen.dart';
```
```dart
      GoRoute(path: '/noticias', pageBuilder: (c, s) => fadeSlide(s, const NewsListScreen())),
      GoRoute(path: '/noticias/:id', pageBuilder: (c, s) {
        final extra = s.extra;
        if (extra is News) return fadeSlide(s, NewsDetailScreen(news: extra));
        return fadeSlide(s, NewsById(id: s.pathParameters['id']!));
      }),
      GoRoute(path: '/admin/noticias', pageBuilder: (c, s) => fadeSlide(s, const AdminNewsListScreen())),
      GoRoute(path: '/admin/noticias/editar', pageBuilder: (c, s) => fadeSlide(s, AdminNewsEditScreen(news: s.extra is News ? s.extra as News : null))),
```
- [ ] **Step 5: Teste do editor** — `test/features/admin_news_edit_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/providers/repository_provider.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';
import 'package:universe_app/data/storage/storage_service.dart';
import 'package:universe_app/features/admin/screens/admin_news_edit_screen.dart';

void main() {
  testWidgets('publicar nova notícia chama upsertNews', (t) async {
    await t.binding.setSurfaceSize(const Size(900, 1800));
    final repo = FakeUniverseRepository();
    await t.pumpWidget(ProviderScope(
      overrides: [
        universeRepositoryProvider.overrideWithValue(repo),
        storageServiceProvider.overrideWithValue(FakeStorageService()),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const Scaffold(body: AdminNewsEditScreen(news: null))),
    ));
    await t.pumpAndSettle();

    await t.enterText(find.byType(TextField).first, 'Notícia Teste');
    // o corpo é o 5º TextField (título, categoria-livre, fonte, tempo, resumo, corpo) — usar um texto >10 chars
    final fields = find.byType(TextField);
    await t.enterText(fields.at(5), 'Corpo de teste com mais de dez caracteres.');
    await t.tap(find.text('Salvar notícia'));
    await t.pumpAndSettle();

    final all = await repo.watchAllNews().first;
    expect(all.where((n) => n.title == 'Notícia Teste'), isNotEmpty);
  });
}
```
NOTA: o índice do campo de corpo (`fields.at(5)`) depende da ordem dos `AppField`. Conte os `AppField` antes do corpo (Título, Categoria-livre, Fonte, Tempo, Resumo, Corpo). Se a contagem diferir, ajuste o índice ou use `find.widgetWithText`. Garanta o teste verde sem enfraquecê-lo.

- [ ] **Step 6:** `flutter analyze` (projeto) → 0 erros. `flutter test test/features/admin_news_edit_test.dart` → PASS.
- [ ] **Step 7:** Commit — `git add lib/features/admin/ lib/core/router/app_router.dart test/features/admin_news_edit_test.dart && git commit -m "feat(news): hub + lista admin + editor de noticias + rotas"`

---

### Task 7: Regra de leitura + seed + verificação + diário

**Files:** Modify `firestore.rules`, `lib/data/repositories/seed.dart`, `docs/desenvolvimento/diario-de-desenvolvimento.md`

- [ ] **Step 1: Regra do Firestore** — em `firestore.rules`, **substituir** o bloco catch-all atual
```
    match /{col}/{id} {
      allow read: if signedIn();
      allow write: if isAdmin();
    }
```
por (condiciona a leitura de `news` a publicado/admin; demais coleções inalteradas):
```
    match /{col}/{id} {
      allow read: if signedIn() && (col != 'news' || isAdmin() || resource.data.published == true);
      allow write: if isAdmin();
    }
```
> Por que assim: as regras do Firestore concedem acesso por **união** — uma regra
> específica de `news` mais restrita NÃO reduziria o acesso, pois o catch-all ainda
> liberaria. Condicionar o próprio catch-all pelo nome da coleção (`col`) é o jeito
> correto de restringir rascunhos. A query do app já filtra `published == true`.
- [ ] **Step 2: Seed** — em `seed.dart`, adicionar (após o bloco de `contentDocs`):
```dart
  for (final n in fake.allNews) {
    batch.set(db.collection('news').doc(n.id), n.toMap());
  }
```
- [ ] **Step 3:** `flutter analyze` → 0 erros. `flutter test` → todos PASS.
- [ ] **Step 4:** Execução no navegador (admin): Home mostra o carrossel de notícias → "Ver todas" abre `/noticias` (filtro por categoria) → abrir uma notícia (capa, fatos, corpo com wikilink, fonte). Painel → **Notícias** → criar/editar (imagem, fatos, destaque, publicar/rascunho) → conferir reflexo na Home/lista. **Re-rodar "Popular dados (dev)"** para criar a coleção `news`. **Publicar a regra do Firestore** no console (passo operacional).
- [ ] **Step 5: Diário** — nova entrada SP3c (notícias) no estilo das anteriores.
- [ ] **Step 6:** Commit — `git add firestore.rules lib/data/repositories/seed.dart docs/ && git commit -m "feat(news): regra de leitura de news + seed; docs SP3c"`

---

## Self-Review (cobertura da spec)
- **§2 modelo:** Task 1 ✓. **§3 repositório/providers:** Task 2 ✓.
- **§4 telas do aluno (home/lista/detalhe/NewsCard):** Tasks 3,4,5 ✓.
- **§5 admin (hub/lista/editor):** Task 6 ✓. **§6 navegação:** Task 6 ✓.
- **§7 regra de news:** Task 7 ✓. **§8 seed/testes:** Tasks 2,6,7 ✓. **§9 reuso:** em todas.

**Riscos/notas:**
1. **Regra de `news`** via condição no catch-all (`col`) — não criar um `match /news` separado (a união reabriria a leitura). Publicar a regra é passo operacional.
2. **Assinaturas a confirmar na execução:** `AppChip(active:)`, `AppButton(size:)`, `openExternalUrl(BuildContext,String?)`. Adaptar ao real se diferirem (estão indicadas com NOTA).
3. **Índice do campo de corpo no teste do editor** — conferir contagem de `AppField` e ajustar.
4. **`facts` como lista de mapas** `{label,value}` (Firestore não aceita array aninhado).
5. **Re-seed** cria `news`; sem ele a coleção não existe.
