# SP5 — Pipeline de Notícias automatizado · Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) ou superpowers:executing-plans. Steps usam checkbox (`- [ ]`).

**Goal:** Pipeline Python (RSS + Gemini) grava **sugestões de notícia** no Firestore; no app, o Setor aprova/edita/recusa e só então a notícia aparece para o aluno.

**Architecture:** Coleção de staging `noticias_sugeridas` (id = sha1(link)) é o contrato. App: `NoticiaSugerida` (envolve `News`) + tela de curadoria no admin reusando `upsertNews`. Pipeline: `feedparser` lê fontes RSS, pré-filtra por palavra-chave, Gemini decide relevância/categoria/resumo e grava via `firebase-admin` (dedup), agendado por GitHub Actions.

**Tech Stack:** Dart/Flutter (Riverpod, go_router, cloud_firestore); Python (feedparser, google-genai, firebase-admin); GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-06-23-sp5-pipeline-noticias-design.md`.

**Reuso (assinaturas reais):** `News` (`lib/data/models/news.dart`, `fromMap(id,map)`/`toMap()`, campos category/source/readTime/title/summary/body/date/facts/sourceUrl/imageUrl/published/pinned); `universeRepositoryProvider.upsertNews(News)`/`newId`; `AsyncListView<T>`; `AppCard`/`AppButton`(size/variant)/`IconTile`/`appIcon`/`GreenHero`/`PageShell`; `AdminNewsEditScreen({News? news})` (`lib/features/admin/screens/admin_news_edit_screen.dart`); `AdminHubScreen` (ConsumerWidget, lista `cards`); rota `/admin/noticias/editar` em `app_router.dart`; pipeline `init_firestore`/`init_gemini` em `pipeline/main.py`.

---

## Estrutura de arquivos

```
lib/data/models/noticia_sugerida.dart                      NoticiaSugerida (envolve News)
lib/data/repositories/universe_repository.dart             + watch/rejeitar/delete noticiasSugeridas
lib/data/repositories/firestore_universe_repository.dart   impl
lib/data/repositories/fake_universe_repository.dart        impl + 2 exemplos
lib/core/providers/repository_provider.dart                + noticiasSugeridasProvider
lib/features/admin/screens/admin_noticias_sugeridas_screen.dart  tela de curadoria
lib/features/admin/screens/admin_hub_screen.dart           + card "Notícias sugeridas"
lib/features/admin/screens/admin_news_edit_screen.dart     + fromSuggestionId
lib/core/router/app_router.dart                            rota + extra record do /admin/noticias/editar
lib/data/repositories/seed.dart                            seeda noticias_sugeridas
firestore.rules                                            leitura de noticias_sugeridas só admin
pipeline/news.py                                           script RSS + Gemini
pipeline/requirements.txt                                  + feedparser
pipeline/README.md                                         doc do pipeline de notícias
pipeline/test_news.py                                      casa_keyword/news_doc_id (pytest)
.github/workflows/pipeline-noticias.yml                    cron
test/data/noticia_sugerida_test.dart  ·  test/data/noticias_sugeridas_repo_test.dart  ·  test/features/admin_noticias_sugeridas_test.dart
```

---

### Task 1: Modelo NoticiaSugerida

**Files:** Create `lib/data/models/noticia_sugerida.dart`; Test `test/data/noticia_sugerida_test.dart`

- [ ] **Step 1: Teste (FALHA)** — `test/data/noticia_sugerida_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/news.dart';
import 'package:universe_app/data/models/noticia_sugerida.dart';

void main() {
  test('NoticiaSugerida round-trip (payload News + metadados)', () {
    final n = News(
      id: 'abc', category: 'SiSU', source: 'G1', readTime: '1 min',
      title: 'T', summary: 's', body: 's', date: DateTime(2026, 6, 23),
      facts: const [], sourceUrl: 'https://g1/x', imageUrl: null,
      published: false, pinned: false,
    );
    final s = NoticiaSugerida(id: 'abc', noticia: n, scrapedAt: DateTime(2026, 6, 23), status: 'pendente');
    final back = NoticiaSugerida.fromMap('abc', s.toMap());
    expect(back.id, 'abc');
    expect(back.status, 'pendente');
    expect(back.scrapedAt, DateTime(2026, 6, 23));
    expect(back.noticia.title, 'T');
    expect(back.noticia.category, 'SiSU');
    expect(back.noticia.sourceUrl, 'https://g1/x');
  });
}
```
- [ ] **Step 2:** `flutter test test/data/noticia_sugerida_test.dart` → FAIL.
- [ ] **Step 3: Implementar** — `lib/data/models/noticia_sugerida.dart`:
```dart
import 'news.dart';

/// Notícia coletada pelo pipeline, aguardando curadoria do Setor.
/// Envolve uma [News] (payload) + metadados de estado.
class NoticiaSugerida {
  final String id; // = sha1(link), igual ao id da News ao aprovar
  final News noticia;
  final DateTime scrapedAt;
  final String status; // 'pendente' | 'recusada'
  const NoticiaSugerida({required this.id, required this.noticia, required this.scrapedAt, this.status = 'pendente'});

  Map<String, dynamic> toMap() => {
        ...noticia.toMap(),
        'scrapedAt': scrapedAt.millisecondsSinceEpoch,
        'status': status,
      };

  factory NoticiaSugerida.fromMap(String id, Map<String, dynamic> m) => NoticiaSugerida(
        id: id,
        noticia: News.fromMap(id, m),
        scrapedAt: DateTime.fromMillisecondsSinceEpoch((m['scrapedAt'] as num? ?? 0).toInt()),
        status: m['status'] ?? 'pendente',
      );
}
```
- [ ] **Step 4:** `flutter test test/data/noticia_sugerida_test.dart` → PASS. `flutter analyze lib/data/models/noticia_sugerida.dart` → limpo.
- [ ] **Step 5:** Commit — `git add lib/data/models/noticia_sugerida.dart test/data/noticia_sugerida_test.dart && git commit -m "feat(noticias): modelo NoticiaSugerida"`

---

### Task 2: Repositório + provider + Fake

**Files:** Modify `universe_repository.dart`, `firestore_universe_repository.dart`, `fake_universe_repository.dart`, `repository_provider.dart`; Test `test/data/noticias_sugeridas_repo_test.dart`

- [ ] **Step 1: Teste (FALHA)** — `test/data/noticias_sugeridas_repo_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/news.dart';
import 'package:universe_app/data/models/noticia_sugerida.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';

News _n(String id, DateTime d) => News(
      id: id, category: 'Geral', source: 'G1', readTime: '1 min',
      title: 'T $id', summary: 's', body: 's', date: d, facts: const []);

void main() {
  test('watchNoticiasSugeridas só pendentes (scrapedAt desc); rejeitar/remover', () async {
    final repo = FakeUniverseRepository();
    final base = (await repo.watchNoticiasSugeridas().first).length;
    await repo.upsertNoticiaSugerida(NoticiaSugerida(id: 'x1', noticia: _n('x1', DateTime(2026, 1, 1)), scrapedAt: DateTime(2026, 1, 1)));
    await repo.upsertNoticiaSugerida(NoticiaSugerida(id: 'x2', noticia: _n('x2', DateTime(2026, 3, 1)), scrapedAt: DateTime(2026, 3, 1)));
    var pend = await repo.watchNoticiasSugeridas().first;
    final mine = pend.where((s) => s.id == 'x1' || s.id == 'x2').toList();
    expect(mine.first.id, 'x2'); // scrapedAt desc
    expect(pend.length, base + 2);

    await repo.rejeitarNoticiaSugerida('x2');
    pend = await repo.watchNoticiasSugeridas().first;
    expect(pend.where((s) => s.id == 'x2'), isEmpty);

    await repo.deleteNoticiaSugerida('x1');
    pend = await repo.watchNoticiasSugeridas().first;
    expect(pend.where((s) => s.id == 'x1'), isEmpty);
  });
}
```
- [ ] **Step 2:** `flutter test test/data/noticias_sugeridas_repo_test.dart` → FAIL.
- [ ] **Step 3: Interface** (`universe_repository.dart`) — add `import '../models/noticia_sugerida.dart';` e:
```dart
  Stream<List<NoticiaSugerida>> watchNoticiasSugeridas();
  Future<void> rejeitarNoticiaSugerida(String id);
  Future<void> deleteNoticiaSugerida(String id);
```
- [ ] **Step 4: Firestore impl** (`firestore_universe_repository.dart`) — add `import '../models/noticia_sugerida.dart';` e:
```dart
  @override
  Stream<List<NoticiaSugerida>> watchNoticiasSugeridas() =>
      _db.collection('noticias_sugeridas').snapshots().map((s) {
        final list = _map(s, NoticiaSugerida.fromMap).where((n) => n.status == 'pendente').toList();
        list.sort((a, b) => b.scrapedAt.compareTo(a.scrapedAt));
        return list;
      });
  @override
  Future<void> rejeitarNoticiaSugerida(String id) =>
      _db.collection('noticias_sugeridas').doc(id).set({'status': 'recusada'}, SetOptions(merge: true));
  @override
  Future<void> deleteNoticiaSugerida(String id) => _db.collection('noticias_sugeridas').doc(id).delete();
```
- [ ] **Step 5: Fake impl** (`fake_universe_repository.dart`) — add `import '../models/noticia_sugerida.dart';`. Add lista de instância com 2 exemplos + métodos + getter:
```dart
  // ── Notícias sugeridas (pipeline) ───────────────────────────────────────────
  static final List<NoticiaSugerida> _seedNoticiasSugeridas = [
    NoticiaSugerida(
      id: 'noticia-sug-1', scrapedAt: DateTime(2026, 6, 22),
      noticia: News(
        id: 'noticia-sug-1', category: 'SiSU', source: 'G1', readTime: '1 min',
        title: 'Sisu+: prazo de inscrição encerra nesta sexta', summary: 'Etapa complementar do SiSU recebe inscrições até sexta-feira.',
        body: 'Etapa complementar do SiSU recebe inscrições até sexta-feira.', date: DateTime(2026, 6, 22),
        facts: const [], sourceUrl: 'https://g1.globo.com/educacao/exemplo-1', published: false),
    ),
    NoticiaSugerida(
      id: 'noticia-sug-2', scrapedAt: DateTime(2026, 6, 21),
      noticia: News(
        id: 'noticia-sug-2', category: 'Concurso', source: 'PCI Concursos', readTime: '1 min',
        title: 'Concurso abre vagas de nível médio e superior', summary: 'Edital prevê vagas com salários de até R\$ 6 mil; inscrições abertas.',
        body: 'Edital prevê vagas com salários de até R\$ 6 mil; inscrições abertas.', date: DateTime(2026, 6, 21),
        facts: const [], sourceUrl: 'https://www.pciconcursos.com.br/exemplo-2', published: false),
    ),
  ];
  final List<NoticiaSugerida> _noticiasSugeridas = List.of(_seedNoticiasSugeridas);

  @override
  Stream<List<NoticiaSugerida>> watchNoticiasSugeridas() {
    final list = _noticiasSugeridas.where((n) => n.status == 'pendente').toList()
      ..sort((a, b) => b.scrapedAt.compareTo(a.scrapedAt));
    return Stream.value(list);
  }
  @override
  Future<void> rejeitarNoticiaSugerida(String id) async {
    final i = _noticiasSugeridas.indexWhere((n) => n.id == id);
    if (i >= 0) {
      final old = _noticiasSugeridas[i];
      _noticiasSugeridas[i] = NoticiaSugerida(id: old.id, noticia: old.noticia, scrapedAt: old.scrapedAt, status: 'recusada');
    }
  }
  @override
  Future<void> deleteNoticiaSugerida(String id) async => _noticiasSugeridas.removeWhere((n) => n.id == id);

  /// Usado por testes/seed para inserir sugestões de notícia.
  Future<void> upsertNoticiaSugerida(NoticiaSugerida n) async {
    final i = _noticiasSugeridas.indexWhere((e) => e.id == n.id);
    if (i >= 0) { _noticiasSugeridas[i] = n; } else { _noticiasSugeridas.add(n); }
  }
  List<NoticiaSugerida> get allNoticiasSugeridas => _noticiasSugeridas;
```
- [ ] **Step 6: Provider** (`repository_provider.dart`) — add `import '../../data/models/noticia_sugerida.dart';` e:
```dart
final noticiasSugeridasProvider = StreamProvider<List<NoticiaSugerida>>((ref) => ref.watch(universeRepositoryProvider).watchNoticiasSugeridas());
```
- [ ] **Step 7:** `flutter test test/data/noticias_sugeridas_repo_test.dart` → PASS. `flutter analyze` → limpo.
- [ ] **Step 8:** Commit — `git add lib/data/ lib/core/providers/repository_provider.dart test/data/noticias_sugeridas_repo_test.dart && git commit -m "feat(noticias): repositorio de noticias_sugeridas + provider + exemplos no Fake"`

---

### Task 3: AdminNewsEditScreen.fromSuggestionId + tela de curadoria + hub + rota

**Files:** Modify `admin_news_edit_screen.dart`, `admin_hub_screen.dart`, `app_router.dart`; Create `admin_noticias_sugeridas_screen.dart`; Test `test/features/admin_noticias_sugeridas_test.dart`

- [ ] **Step 1: `AdminNewsEditScreen` ganha `fromSuggestionId`.** Em `admin_news_edit_screen.dart`:
  - No `StatefulWidget`, adicionar o campo e o construtor:
```dart
  final News? news;
  final String? fromSuggestionId; // se veio de uma sugestão, removê-la ao salvar
  const AdminNewsEditScreen({super.key, required this.news, this.fromSuggestionId});
```
  - No `_save()`, após `await repo.upsertNews(news);` e antes do `context.pop()`, adicionar:
```dart
      if (widget.fromSuggestionId != null) {
        await repo.deleteNoticiaSugerida(widget.fromSuggestionId!);
      }
```
  (Confirme o nome real da variável local do repo no `_save` — no SP3c é `repo`. Se o `_save` referencia `ref.read(universeRepositoryProvider)` inline, capture em `repo` antes.)
- [ ] **Step 2: `AdminNoticiasSugeridasScreen`** — `lib/features/admin/screens/admin_noticias_sugeridas_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/noticia_sugerida.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/icon_tile.dart';

class AdminNoticiasSugeridasScreen extends ConsumerWidget {
  const AdminNoticiasSugeridasScreen({super.key});

  Future<void> _aprovar(BuildContext context, WidgetRef ref, NoticiaSugerida s) async {
    final repo = ref.read(universeRepositoryProvider);
    await repo.upsertNews(s.noticia);
    await repo.deleteNoticiaSugerida(s.id);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notícia aprovada e publicada')));
  }

  Future<void> _recusar(BuildContext context, WidgetRef ref, NoticiaSugerida s) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Recusar sugestão'),
      content: Text('Recusar "${s.noticia.title}"? Não será sugerida novamente.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Recusar')),
      ],
    ));
    if (ok == true) {
      await ref.read(universeRepositoryProvider).rejeitarNoticiaSugerida(s.id);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sugestão recusada')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final async = ref.watch(noticiasSugeridasProvider);
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: 'Notícias sugeridas', subtitle: 'Coletadas automaticamente — revise e publique', icon: 'bell', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AsyncListView<NoticiaSugerida>(
          value: async,
          onRetry: () => ref.invalidate(noticiasSugeridasProvider),
          emptyTitle: 'Nenhuma sugestão pendente',
          data: (list) => Column(children: [
            for (final s in list) Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  IconTile('bell', size: 46),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.noticia.title, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.ink)),
                    const SizedBox(height: 2),
                    Text('${s.noticia.category} · ${s.noticia.source}', style: TextStyle(fontSize: 12, color: c.ink3)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(999)),
                    child: Text('auto', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.green700)),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(s.noticia.summary, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, height: 1.45, color: c.ink2)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: AppButton('Aprovar', size: AppButtonSize.sm, icon: 'check', onTap: () => _aprovar(context, ref, s))),
                  const SizedBox(width: 8),
                  Expanded(child: AppButton('Editar', size: AppButtonSize.sm, variant: AppButtonVariant.outline, icon: 'edit',
                    onTap: () => context.push('/admin/noticias/editar', extra: (noticia: s.noticia, suggestionId: s.id)))),
                  const SizedBox(width: 8),
                  Expanded(child: AppButton('Recusar', size: AppButtonSize.sm, variant: AppButtonVariant.ghost, onTap: () => _recusar(context, ref, s))),
                ]),
              ])),
            ),
          ]),
        ),
      ),
    );
  }
}
```
- [ ] **Step 3: Hub** (`admin_hub_screen.dart`) — adicionar o card de notícias sugeridas com contagem. Adicionar ao topo, junto da contagem de vagas:
```dart
    final pendVagas = ref.watch(vagasSugeridasProvider).valueOrNull?.length ?? 0;
    final pendNoticias = ref.watch(noticiasSugeridasProvider).valueOrNull?.length ?? 0;
```
E inserir, na lista `cards`, logo após o card "Vagas sugeridas":
```dart
      (icon: 'bell', title: 'Notícias sugeridas', sub: pendNoticias == 0 ? 'Nenhuma pendente' : '$pendNoticias aguardando revisão', route: '/admin/noticias-sugeridas'),
```
(O hub já é `ConsumerWidget` e importa `repository_provider.dart` desde o SP4.)
- [ ] **Step 4: Rotas** (`app_router.dart`):
  - Import: `import '../../features/admin/screens/admin_noticias_sugeridas_screen.dart';`.
  - Add a rota: `GoRoute(path: '/admin/noticias-sugeridas', pageBuilder: (c, s) => fadeSlide(s, const AdminNoticiasSugeridasScreen())),`
  - Trocar a rota `/admin/noticias/editar` para aceitar o record de edição-de-sugestão:
```dart
      GoRoute(path: '/admin/noticias/editar', pageBuilder: (c, s) {
        final x = s.extra;
        if (x is ({News noticia, String suggestionId})) return fadeSlide(s, AdminNewsEditScreen(news: x.noticia, fromSuggestionId: x.suggestionId));
        return fadeSlide(s, AdminNewsEditScreen(news: x is News ? x : null));
      }),
```
  (Garantir `import '../../data/models/news.dart';` no router — já existe do SP3c.)
- [ ] **Step 5: Teste smoke** — `test/features/admin_noticias_sugeridas_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/providers/repository_provider.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';
import 'package:universe_app/features/admin/screens/admin_noticias_sugeridas_screen.dart';

void main() {
  testWidgets('lista sugestões e aprova (cria News, remove da lista)', (t) async {
    await t.binding.setSurfaceSize(const Size(900, 1600));
    final repo = FakeUniverseRepository();
    await t.pumpWidget(ProviderScope(
      overrides: [universeRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(theme: AppTheme.light, home: const Scaffold(body: AdminNoticiasSugeridasScreen())),
    ));
    await t.pumpAndSettle();

    expect(find.text('Sisu+: prazo de inscrição encerra nesta sexta'), findsOneWidget);
    final antes = (await repo.watchAllNews().first).length;
    await t.tap(find.text('Aprovar').first);
    await t.pumpAndSettle();
    expect((await repo.watchAllNews().first).length, antes + 1);
  });
}
```
- [ ] **Step 6:** `flutter analyze` → 0 erros. `flutter test test/features/admin_noticias_sugeridas_test.dart` → PASS; `flutter test` (suíte) → todos PASS.
- [ ] **Step 7:** Commit — `git add lib/features/admin/ lib/core/router/app_router.dart test/features/admin_noticias_sugeridas_test.dart && git commit -m "feat(noticias): curadoria de noticias sugeridas + card no hub + edicao via editor"`

---

### Task 4: Regra do Firestore + seed

**Files:** Modify `firestore.rules`, `lib/data/repositories/seed.dart`

- [ ] **Step 1: Regra** — em `firestore.rules`, **substituir** o bloco atual do catch-all por (adiciona `noticias_sugeridas` à condição existente):
```
    match /{col}/{id} {
      allow read: if signedIn()
        && (col != 'vagas_sugeridas' || isAdmin())
        && (col != 'noticias_sugeridas' || isAdmin())
        && (col != 'news' || isAdmin() || resource.data.published == true);
      allow write: if isAdmin();
    }
```
- [ ] **Step 2: Seed** — em `seed.dart`, antes do `await batch.commit();`, adicionar:
```dart
  for (final n in fake.allNoticiasSugeridas) {
    batch.set(db.collection('noticias_sugeridas').doc(n.id), n.toMap());
  }
```
- [ ] **Step 3:** `flutter analyze` → limpo. Commit — `git add firestore.rules lib/data/repositories/seed.dart && git commit -m "feat(noticias): regra de noticias_sugeridas (so admin) + seed de exemplos"`

> Passo operacional do usuário: publicar a regra atualizada do Firestore.

---

### Task 5: Pipeline Python (`pipeline/news.py`)

**Files:** Create `pipeline/news.py`, `pipeline/test_news.py`; Modify `pipeline/requirements.txt`, `pipeline/README.md`

- [ ] **Step 1: requirements** — em `pipeline/requirements.txt`, adicionar `feedparser`:
```
google-genai==0.3.0
firebase-admin==6.5.0
python-dotenv==1.0.1
feedparser==6.0.11
```
- [ ] **Step 2: `pipeline/news.py`**:
```python
import os, sys, time, json, re, hashlib, unicodedata
try:
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
except Exception:
    pass
import feedparser
from google.genai import types
from main import init_firestore, init_gemini  # reaproveita inicialização

# Fontes RSS (rótulo + url). Ajuste/expanda conforme necessário.
FEEDS = [
    {"source": "G1 Educação", "url": "https://g1.globo.com/rss/g1/educacao/"},
    {"source": "MEC", "url": "https://www.gov.br/mec/pt-br/assuntos/noticias/RSS"},
    {"source": "PCI Concursos", "url": "https://www.pciconcursos.com.br/noticias/rss"},
    {"source": "IFSP", "url": "https://www.ifsp.edu.br/component/content/?format=feed&type=rss"},
]

KEYWORDS = ["ifsp", "sisu", "enem", "prouni", "fies", "concurso", "edital",
            "estagio", "bolsa", "vestibular", "matricula", "faculdade", "universidade"]

CATEGORIAS = ["Campus", "SiSU", "Enem", "Concurso", "Geral"]


def _sem_acento(s: str) -> str:
    return "".join(c for c in unicodedata.normalize("NFD", s or "") if unicodedata.category(c) != "Mn").lower()


def casa_keyword(texto: str) -> bool:
    t = _sem_acento(texto)
    return any(k in t for k in KEYWORDS)


def news_doc_id(link: str) -> str:
    return hashlib.sha1((link or "").encode("utf-8")).hexdigest()


def _entry_data(entry, etiqueta):
    titulo = (entry.get("title") or "").strip()
    link = (entry.get("link") or "").strip()
    resumo_feed = re.sub(r"<[^>]+>", " ", entry.get("summary", "")).strip()
    # data
    dt_ms = int(time.time() * 1000)
    if entry.get("published_parsed"):
        dt_ms = int(time.mktime(entry["published_parsed"]) * 1000)
    # imagem (media:content ou enclosure)
    img = None
    if entry.get("media_content"):
        img = entry["media_content"][0].get("url")
    elif entry.get("links"):
        for l in entry["links"]:
            if (l.get("type") or "").startswith("image"):
                img = l.get("href")
                break
    return titulo, link, resumo_feed, dt_ms, img


PROMPT = """Você cura notícias para um app de estudantes do IFSP.
Categorias possíveis: {cats}.

Notícia:
Título: {titulo}
Resumo: {resumo}

Responda em JSON:
- relevante (bool): é útil para estudantes (vestibular, Enem, SiSU, concurso, bolsa, IFSP, educação)?
- category (string): uma das categorias acima.
- summary (string): resumo curto e neutro, 2-3 frases, sem copiar o texto literal.
Responda só o JSON."""


def avaliar(client, titulo, resumo):
    p = PROMPT.format(cats=", ".join(CATEGORIAS), titulo=titulo, resumo=resumo[:2000])
    for tentativa in range(4):
        try:
            r = client.models.generate_content(
                model="gemini-2.5-flash", contents=p,
                config=types.GenerateContentConfig(response_mime_type="application/json"))
            d = json.loads(r.text)
            cat = d.get("category", "Geral")
            return {
                "relevante": bool(d.get("relevante", False)),
                "category": cat if cat in CATEGORIAS else "Geral",
                "summary": str(d.get("summary", "")).strip(),
            }
        except Exception as e:
            erro = str(e)
            m = re.search(r"retry in (\d+)", erro)
            if m:
                time.sleep(int(m.group(1)) + 5)
            elif "503" in erro or "UNAVAILABLE" in erro or "overloaded" in erro.lower():
                time.sleep(10 * (tentativa + 1))
            else:
                print(f"❌ Erro no Gemini: {e}")
                break
    return {"relevante": False, "category": "Geral", "summary": ""}


def ja_tratada(db, vid):
    if db.collection("news").document(vid).get().exists:
        return True
    s = db.collection("noticias_sugeridas").document(vid).get()
    return s.exists and s.to_dict().get("status") == "recusada"


def main():
    db = init_firestore()
    client = init_gemini()
    max_noticias = int(os.getenv("MAX_NOTICIAS", "15"))
    novas = 0
    for feed in FEEDS:
        if novas >= max_noticias:
            break
        try:
            parsed = feedparser.parse(feed["url"])
        except Exception as e:
            print(f"⚠️  Falha no feed {feed['source']}: {e}")
            continue
        for entry in parsed.entries:
            if novas >= max_noticias:
                break
            titulo, link, resumo_feed, dt_ms, img = _entry_data(entry, feed["source"])
            if not titulo or not link:
                continue
            if not casa_keyword(titulo + " " + resumo_feed):
                continue
            vid = news_doc_id(link)
            if ja_tratada(db, vid):
                continue
            aval = avaliar(client, titulo, resumo_feed)
            if not aval["relevante"]:
                continue
            resumo = aval["summary"] or resumo_feed[:300]
            doc = {
                "category": aval["category"], "source": feed["source"], "readTime": "1 min",
                "title": titulo, "summary": resumo, "body": resumo,
                "date": dt_ms, "facts": [], "sourceUrl": link, "imageUrl": img,
                "published": False, "pinned": False,
                "scrapedAt": int(time.time() * 1000), "status": "pendente",
            }
            db.collection("noticias_sugeridas").document(vid).set(doc)
            novas += 1
            print(f"📰 {feed['source']}: {titulo}")
            time.sleep(1)
    print(f"✅ {novas} notícias sugeridas gravadas em 'noticias_sugeridas'.")


if __name__ == "__main__":
    main()
```
- [ ] **Step 3: `pipeline/test_news.py`**:
```python
from news import casa_keyword, news_doc_id

def test_casa_keyword():
    assert casa_keyword("Inscrições do Sisu começam hoje")
    assert casa_keyword("Concurso público abre vagas")
    assert casa_keyword("IFSP divulga edital")
    assert not casa_keyword("Receita de bolo de cenoura")

def test_news_doc_id():
    a = news_doc_id("https://x/1")
    assert a == news_doc_id("https://x/1") and len(a) == 40
```
- [ ] **Step 4: README** — em `pipeline/README.md`, adicionar uma seção:
```markdown
## Pipeline de Notícias (news.py)
Coleta notícias de fontes RSS (G1 Educação, MEC, concursos, IFSP), filtra por
palavra-chave, usa o Gemini para relevância/categoria/resumo e grava em
`noticias_sugeridas` (curadoria no app). Rodar:
```
cd pipeline
python news.py
```
Variáveis: `GEMINI_API_KEY`, `FIREBASE_SERVICE_ACCOUNT`, `MAX_NOTICIAS` (padrão 15).
Agendado em `.github/workflows/pipeline-noticias.yml`. Só título + resumo + link são
guardados (sem texto integral). Feeds que mudarem são manutenção esperada.
```
- [ ] **Step 5: Verificar** — `cd pipeline && python -c "import ast; ast.parse(open('news.py',encoding='utf-8').read()); print('news.py OK')"`. As funções puras `casa_keyword`/`news_doc_id` não dependem de rede; se quiser, com deps instaladas: `python -m pytest test_news.py -q`. (Importar `news` puxa `feedparser`/`main`; rode os testes só com as deps instaladas.)
- [ ] **Step 6:** Commit — `git add pipeline/news.py pipeline/test_news.py pipeline/requirements.txt pipeline/README.md && git commit -m "feat(noticias): pipeline RSS + Gemini (relevancia/categoria/resumo)"`

---

### Task 6: GitHub Actions (agendamento)

**Files:** Create `.github/workflows/pipeline-noticias.yml`

- [ ] **Step 1: Workflow**:
```yaml
name: Pipeline de Notícias
on:
  workflow_dispatch: {}
  schedule:
    - cron: '30 6 * * *'   # diariamente às 06:30 UTC (03:30 BRT)

jobs:
  coletar-noticias:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - name: Instalar dependências
        run: pip install -r pipeline/requirements.txt
      - name: Gravar service account
        run: printf '%s' "$FIREBASE_SERVICE_ACCOUNT" > pipeline/service-account.json
        env:
          FIREBASE_SERVICE_ACCOUNT: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
      - name: Rodar pipeline de notícias
        working-directory: pipeline
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
          FIREBASE_SERVICE_ACCOUNT: service-account.json
          MAX_NOTICIAS: '15'
        run: python news.py
```
- [ ] **Step 2:** Commit — `git add .github/workflows/pipeline-noticias.yml && git commit -m "ci(noticias): agenda coleta de noticias (GitHub Actions)"`

---

### Task 7: Verificação + diário

- [ ] **Step 1:** `flutter analyze` → 0 erros. `flutter test` → todos PASS.
- [ ] **Step 2:** App (admin): **Popular dados (dev)** cria `noticias_sugeridas` (2 exemplos). Hub mostra **"Notícias sugeridas (2)"** → `/admin/noticias-sugeridas` → **Aprovar** (vira notícia publicada → aparece na aba Notícias), **Editar** (abre o editor pré-preenchido, salva e remove a sugestão), **Recusar**. Publicar a regra do Firestore atualizada (passo operacional).
- [ ] **Step 3:** Diário — entrada SP5 (pipeline de notícias).
- [ ] **Step 4:** Commit — `git add docs/ && git commit -m "docs: registra SP5 (pipeline de noticias)"`

---

## Self-Review (cobertura da spec)
- **§2 contrato `noticias_sugeridas`:** Tasks 1,2,4,5 ✓.
- **§3 pipeline (RSS, keyword, Gemini relevância/categoria/resumo, dedup, Actions):** Tasks 5,6 ✓.
- **§4 app (modelo, repo, provider, tela, hub, editor.fromSuggestionId):** Tasks 1,2,3 ✓.
- **§5 regra:** Task 4 ✓. **§6 testes:** Tasks 1,2,3 (app) + 5 (python) ✓.

**Riscos/notas:**
1. **`AdminNewsEditScreen._save`:** confirmar o nome da variável do repo (capturar `repo` antes do await) para inserir o `deleteNoticiaSugerida`.
2. **Record `extra`** em `/admin/noticias/editar` (`({News noticia, String suggestionId})`) — preservar a compatibilidade com o `News`/null atual.
3. **Regra de leitura** estende a condição existente (não criar match separado — união reabriria).
4. **Feeds RSS** podem variar (MEC/IFSP em especial); try/except por feed + filtro do Gemini. Se um feed estiver fora do ar, o lote continua.
5. **Reaproveitar secrets** já criados (`FIREBASE_SERVICE_ACCOUNT`, `GEMINI_API_KEY`).
6. **`news.py` importa `main`** (para `init_firestore`/`init_gemini`); como `main` só executa sob `__main__`, o import é seguro.
