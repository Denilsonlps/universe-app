# SP4 — Pipeline de Vagas Automatizado · Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) ou superpowers:executing-plans. Steps usam checkbox (`- [ ]`).

**Goal:** Pipeline Python (scraping Gupy + Gemini enriquece) grava **sugestões** de vaga no Firestore; no app, o Setor **aprova/edita/recusa** e só então a vaga aparece para o aluno.

**Architecture:** Coleção de staging `vagas_sugeridas` (id = sha1(link)) é o contrato. App: `VagaSugerida` (envolve `Internship`) + tela de curadoria no admin reusando `upsertInternship`. Pipeline: `firebase-admin` escreve as sugestões (idempotente, com dedup contra aprovadas/recusadas), agendado por GitHub Actions.

**Tech Stack:** Dart/Flutter (Riverpod, go_router, cloud_firestore); Python (selenium, google-genai, firebase-admin); GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-06-22-sp4-pipeline-vagas-design.md`.

**Reuso (assinaturas reais):** `Internship` (`lib/data/models/internship.dart`, com `fromMap(id,map)`/`toMap()`, campos role/companyName/area/duration/jobDescription/requirements/niceToHave/companyDescription/benefits/grant/course/mode/link/tag/imageUrl/open/closedAt); `universeRepositoryProvider.upsertInternship(Internship)`/`newId`; `AsyncListView<T>`; `AppCard`/`AppButton`/`IconTile`/`appIcon`/`GreenHero`/`PageShell`; `VagaFormScreen({Internship? vaga})` (`lib/features/admin/screens/vaga_form_screen.dart`); `AdminHubScreen` (cards list); router em `app_router.dart` (rota `/admin/vaga` existe).

---

## Estrutura de arquivos

```
lib/data/models/vaga_sugerida.dart                         VagaSugerida (envolve Internship)
lib/data/repositories/universe_repository.dart             + watch/rejeitar/delete vagasSugeridas
lib/data/repositories/firestore_universe_repository.dart   impl
lib/data/repositories/fake_universe_repository.dart        impl + 2 exemplos
lib/core/providers/repository_provider.dart                + vagasSugeridasProvider
lib/features/admin/screens/admin_sugestoes_screen.dart     tela de curadoria
lib/features/admin/screens/admin_hub_screen.dart           + card "Vagas sugeridas" (contagem)
lib/features/admin/screens/vaga_form_screen.dart           + fromSuggestionId
lib/core/router/app_router.dart                            rota /admin/sugestoes + extra do /admin/vaga
lib/data/repositories/seed.dart                            seeda vagas_sugeridas
firestore.rules                                            leitura de vagas_sugeridas só admin
pipeline/main.py                                           script evoluído
pipeline/requirements.txt
pipeline/README.md                                         setup (secrets, service account, execução)
pipeline/test_pipeline.py                                  teste de map_course (pytest, opcional)
.github/workflows/pipeline-vagas.yml                       cron
.gitignore                                                 ignora a service account
test/data/vaga_sugerida_test.dart  ·  test/data/vagas_sugeridas_repo_test.dart  ·  test/features/admin_sugestoes_test.dart
```

---

### Task 1: Modelo VagaSugerida

**Files:** Create `lib/data/models/vaga_sugerida.dart`; Test `test/data/vaga_sugerida_test.dart`

- [ ] **Step 1: Teste (FALHA)** — `test/data/vaga_sugerida_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/internship.dart';
import 'package:universe_app/data/models/vaga_sugerida.dart';

void main() {
  test('VagaSugerida round-trip (payload Internship + metadados)', () {
    const vaga = Internship(
      id: 'abc', role: 'Estágio Dev', companyName: 'ACME', area: 'TI',
      duration: '6h/dia', jobDescription: 'desc', requirements: ['req1'],
      niceToHave: ['nice1'], companyDescription: 'empresa', benefits: ['VT'],
      grant: 'R\$ 1.000', course: 'ADS', mode: 'Híbrido', link: 'https://x/y',
    );
    final s = VagaSugerida(id: 'abc', vaga: vaga, scrapedAt: DateTime(2026, 6, 22), source: 'gupy-auto');
    final back = VagaSugerida.fromMap('abc', s.toMap());
    expect(back.id, 'abc');
    expect(back.status, 'pendente');
    expect(back.source, 'gupy-auto');
    expect(back.scrapedAt, DateTime(2026, 6, 22));
    expect(back.vaga.role, 'Estágio Dev');
    expect(back.vaga.course, 'ADS');
    expect(back.vaga.requirements, ['req1']);
    expect(back.vaga.link, 'https://x/y');
  });
}
```
- [ ] **Step 2:** `flutter test test/data/vaga_sugerida_test.dart` → FAIL.
- [ ] **Step 3: Implementar** — `lib/data/models/vaga_sugerida.dart`:
```dart
import 'internship.dart';

/// Vaga coletada pelo pipeline, aguardando curadoria do Setor de Estágios.
/// Envolve um [Internship] (payload) + metadados de procedência/estado.
class VagaSugerida {
  final String id; // = sha1(link), igual ao id da Internship ao aprovar
  final Internship vaga;
  final DateTime scrapedAt;
  final String source; // 'gupy-auto'
  final String status; // 'pendente' | 'recusada'
  const VagaSugerida({
    required this.id, required this.vaga, required this.scrapedAt,
    required this.source, this.status = 'pendente',
  });

  Map<String, dynamic> toMap() => {
        ...vaga.toMap(),
        'scrapedAt': scrapedAt.millisecondsSinceEpoch,
        'source': source,
        'status': status,
      };

  factory VagaSugerida.fromMap(String id, Map<String, dynamic> m) => VagaSugerida(
        id: id,
        vaga: Internship.fromMap(id, m),
        scrapedAt: DateTime.fromMillisecondsSinceEpoch((m['scrapedAt'] as num? ?? 0).toInt()),
        source: m['source'] ?? 'gupy-auto',
        status: m['status'] ?? 'pendente',
      );
}
```
- [ ] **Step 4:** `flutter test test/data/vaga_sugerida_test.dart` → PASS. `flutter analyze lib/data/models/vaga_sugerida.dart` → limpo.
- [ ] **Step 5:** Commit — `git add lib/data/models/vaga_sugerida.dart test/data/vaga_sugerida_test.dart && git commit -m "feat(pipeline): modelo VagaSugerida"`

---

### Task 2: Repositório + providers + Fake

**Files:** Modify `universe_repository.dart`, `firestore_universe_repository.dart`, `fake_universe_repository.dart`, `repository_provider.dart`; Test `test/data/vagas_sugeridas_repo_test.dart`

- [ ] **Step 1: Teste (FALHA)** — `test/data/vagas_sugeridas_repo_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/internship.dart';
import 'package:universe_app/data/models/vaga_sugerida.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';

Internship _v(String id) => Internship(
      id: id, role: 'R $id', companyName: 'C', area: 'A', duration: 'd',
      jobDescription: 'j', requirements: const [], niceToHave: const [],
      companyDescription: 'cd', benefits: const [], grant: 'g', course: 'ADS',
      mode: 'Híbrido', link: 'https://x/$id');

void main() {
  test('watchVagasSugeridas só pendentes, scrapedAt desc; rejeitar/remover', () async {
    final repo = FakeUniverseRepository();
    final base = (await repo.watchVagasSugeridas().first).length;
    await repo.upsertVagaSugerida(VagaSugerida(id: 's1', vaga: _v('s1'), scrapedAt: DateTime(2026, 1, 1), source: 'gupy-auto'));
    await repo.upsertVagaSugerida(VagaSugerida(id: 's2', vaga: _v('s2'), scrapedAt: DateTime(2026, 3, 1), source: 'gupy-auto'));
    var pend = await repo.watchVagasSugeridas().first;
    final mine = pend.where((s) => s.id == 's1' || s.id == 's2').toList();
    expect(mine.first.id, 's2'); // scrapedAt desc
    expect(pend.length, base + 2);

    await repo.rejeitarVagaSugerida('s2');
    pend = await repo.watchVagasSugeridas().first;
    expect(pend.where((s) => s.id == 's2'), isEmpty); // recusada sai dos pendentes

    await repo.deleteVagaSugerida('s1');
    pend = await repo.watchVagasSugeridas().first;
    expect(pend.where((s) => s.id == 's1'), isEmpty);
  });
}
```
(Inclui `upsertVagaSugerida` no Fake para os testes/seed — não está na interface pública do repo, mas é um método do Fake; ver Step 4.)
- [ ] **Step 2:** `flutter test test/data/vagas_sugeridas_repo_test.dart` → FAIL.
- [ ] **Step 3: Interface** (`universe_repository.dart`) — add `import '../models/vaga_sugerida.dart';` e:
```dart
  Stream<List<VagaSugerida>> watchVagasSugeridas();
  Future<void> rejeitarVagaSugerida(String id);
  Future<void> deleteVagaSugerida(String id);
```
- [ ] **Step 4: Firestore impl** (`firestore_universe_repository.dart`) — add `import '../models/vaga_sugerida.dart';` e:
```dart
  @override
  Stream<List<VagaSugerida>> watchVagasSugeridas() =>
      _db.collection('vagas_sugeridas').snapshots().map((s) {
        final list = _map(s, VagaSugerida.fromMap).where((v) => v.status == 'pendente').toList();
        list.sort((a, b) => b.scrapedAt.compareTo(a.scrapedAt));
        return list;
      });
  @override
  Future<void> rejeitarVagaSugerida(String id) =>
      _db.collection('vagas_sugeridas').doc(id).set({'status': 'recusada'}, SetOptions(merge: true));
  @override
  Future<void> deleteVagaSugerida(String id) => _db.collection('vagas_sugeridas').doc(id).delete();
```
- [ ] **Step 5: Fake impl** (`fake_universe_repository.dart`) — add `import '../models/vaga_sugerida.dart';`. Add instance list com 2 exemplos + métodos + getter:
```dart
  // ── Vagas sugeridas (pipeline) ──────────────────────────────────────────────
  static final List<VagaSugerida> _seedSugeridas = [
    VagaSugerida(
      id: 'sug-exemplo-1',
      scrapedAt: DateTime(2026, 6, 20), source: 'gupy-auto',
      vaga: const Internship(
        id: 'sug-exemplo-1', role: 'Estágio em Front-end', companyName: 'TechCorp',
        area: 'Tecnologia da Informação', duration: '6h/dia · 12 meses',
        jobDescription: 'Desenvolvimento de interfaces web com foco em acessibilidade.',
        requirements: ['Cursando ADS', 'HTML, CSS e JS', 'Git'],
        niceToHave: ['React', 'Figma'], companyDescription: 'Software house de SP.',
        benefits: ['Vale-transporte', 'Vale-refeição'], grant: 'R\$ 1.200',
        course: 'ADS', mode: 'Híbrido', link: 'https://portal.gupy.io/job/exemplo-1'),
    ),
    VagaSugerida(
      id: 'sug-exemplo-2',
      scrapedAt: DateTime(2026, 6, 21), source: 'gupy-auto',
      vaga: const Internship(
        id: 'sug-exemplo-2', role: 'Estágio em Logística', companyName: 'TransLog',
        area: 'Operações', duration: '6h/dia · 12 meses',
        jobDescription: 'Apoio ao controle de estoque e roteirização.',
        requirements: ['Cursando Logística', 'Excel intermediário'],
        niceToHave: ['WMS'], companyDescription: 'Operadora logística.',
        benefits: ['Vale-transporte'], grant: 'R\$ 1.050',
        course: 'Logística', mode: 'Presencial', link: 'https://portal.gupy.io/job/exemplo-2'),
    ),
  ];
  final List<VagaSugerida> _vagasSugeridas = List.of(_seedSugeridas);

  @override
  Stream<List<VagaSugerida>> watchVagasSugeridas() {
    final list = _vagasSugeridas.where((v) => v.status == 'pendente').toList()
      ..sort((a, b) => b.scrapedAt.compareTo(a.scrapedAt));
    return Stream.value(list);
  }
  @override
  Future<void> rejeitarVagaSugerida(String id) async {
    final i = _vagasSugeridas.indexWhere((v) => v.id == id);
    if (i >= 0) {
      final old = _vagasSugeridas[i];
      _vagasSugeridas[i] = VagaSugerida(id: old.id, vaga: old.vaga, scrapedAt: old.scrapedAt, source: old.source, status: 'recusada');
    }
  }
  @override
  Future<void> deleteVagaSugerida(String id) async => _vagasSugeridas.removeWhere((v) => v.id == id);

  /// Usado por testes/seed para inserir sugestões.
  Future<void> upsertVagaSugerida(VagaSugerida v) async {
    final i = _vagasSugeridas.indexWhere((e) => e.id == v.id);
    if (i >= 0) { _vagasSugeridas[i] = v; } else { _vagasSugeridas.add(v); }
  }
  List<VagaSugerida> get allVagasSugeridas => _vagasSugeridas;
```
- [ ] **Step 6: Provider** (`repository_provider.dart`) — add `import '../../data/models/vaga_sugerida.dart';` e:
```dart
final vagasSugeridasProvider = StreamProvider<List<VagaSugerida>>((ref) => ref.watch(universeRepositoryProvider).watchVagasSugeridas());
```
- [ ] **Step 7:** `flutter test test/data/vagas_sugeridas_repo_test.dart` → PASS. `flutter analyze` → limpo.
- [ ] **Step 8:** Commit — `git add lib/data/ lib/core/providers/repository_provider.dart test/data/vagas_sugeridas_repo_test.dart && git commit -m "feat(pipeline): repositorio de vagas_sugeridas + providers + exemplos no Fake"`

---

### Task 3: VagaFormScreen.fromSuggestionId + tela de curadoria + hub + rota

**Files:** Modify `vaga_form_screen.dart`, `admin_hub_screen.dart`, `app_router.dart`; Create `admin_sugestoes_screen.dart`; Test `test/features/admin_sugestoes_test.dart`

- [ ] **Step 1: `VagaFormScreen` ganha `fromSuggestionId`.** Em `vaga_form_screen.dart`:
  - No `StatefulWidget`: adicionar campo e construtor:
```dart
  final Internship? vaga; // null = nova
  final String? fromSuggestionId; // se veio de uma sugestão, removê-la ao salvar
  const VagaFormScreen({super.key, this.vaga, this.fromSuggestionId});
```
  - No `_save()`, após `await repo.upsertInternship(vaga);` e antes do `context.pop()`, adicionar:
```dart
      if (widget.fromSuggestionId != null) {
        await repo.deleteVagaSugerida(widget.fromSuggestionId!);
      }
```
- [ ] **Step 2: `AdminSugestoesScreen`** — `lib/features/admin/screens/admin_sugestoes_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/vaga_sugerida.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/icon_tile.dart';

class AdminSugestoesScreen extends ConsumerWidget {
  const AdminSugestoesScreen({super.key});

  Future<void> _aprovar(BuildContext context, WidgetRef ref, VagaSugerida s) async {
    final repo = ref.read(universeRepositoryProvider);
    await repo.upsertInternship(s.vaga); // mesmo id = sha1(link)
    await repo.deleteVagaSugerida(s.id);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaga aprovada e publicada')));
  }

  Future<void> _recusar(BuildContext context, WidgetRef ref, VagaSugerida s) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Recusar sugestão'),
      content: Text('Recusar "${s.vaga.role}"? Não será sugerida novamente.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Recusar')),
      ],
    ));
    if (ok == true) {
      await ref.read(universeRepositoryProvider).rejeitarVagaSugerida(s.id);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sugestão recusada')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final async = ref.watch(vagasSugeridasProvider);
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: 'Vagas sugeridas', subtitle: 'Coletadas automaticamente — revise e publique', icon: 'briefcase', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AsyncListView<VagaSugerida>(
          value: async,
          onRetry: () => ref.invalidate(vagasSugeridasProvider),
          emptyTitle: 'Nenhuma sugestão pendente',
          data: (list) => Column(children: [
            for (final s in list) Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  IconTile('briefcase', size: 46),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.vaga.role, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.ink)),
                    const SizedBox(height: 2),
                    Text('${s.vaga.companyName} · ${s.vaga.course}', style: TextStyle(fontSize: 12, color: c.ink3)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(999)),
                    child: Text('auto', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.green700)),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(s.vaga.jobDescription, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, height: 1.45, color: c.ink2)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: AppButton('Aprovar', size: AppButtonSize.sm, icon: 'check', onTap: () => _aprovar(context, ref, s))),
                  const SizedBox(width: 8),
                  Expanded(child: AppButton('Editar', size: AppButtonSize.sm, variant: AppButtonVariant.outline, icon: 'edit',
                    onTap: () => context.push('/admin/vaga', extra: (vaga: s.vaga, suggestionId: s.id)))),
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
- [ ] **Step 3: Hub** (`admin_hub_screen.dart`) — torná-lo `ConsumerWidget` (se ainda for `StatelessWidget`) para ler a contagem; adicionar o 4º card. Substituir a assinatura e a montagem da lista:
```dart
class AdminHubScreen extends ConsumerWidget {
  const AdminHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final pend = ref.watch(vagasSugeridasProvider).valueOrNull?.length ?? 0;
    final cards = <({String icon, String title, String sub, String route})>[
      (icon: 'briefcase', title: 'Vagas e concursos', sub: 'Estágios, jovem aprendiz e concursos', route: '/admin/vagas'),
      (icon: 'briefcase', title: 'Vagas sugeridas', sub: pend == 0 ? 'Nenhuma pendente' : '$pend aguardando revisão', route: '/admin/sugestoes'),
      (icon: 'book', title: 'Páginas de conteúdo', sub: 'Edite os benefícios que os alunos veem', route: '/admin/conteudo'),
      (icon: 'bell', title: 'Notícias', sub: 'Avisos e novidades do campus', route: '/admin/noticias'),
    ];
    // ... resto do build inalterado (usa `cards`)
```
Adicionar os imports `package:flutter_riverpod/flutter_riverpod.dart` e `../../../core/providers/repository_provider.dart`. Manter o restante do widget (header, ListView dos cards) como está.
- [ ] **Step 4: Rotas** (`app_router.dart`):
  - Imports: `import '../../features/admin/screens/admin_sugestoes_screen.dart';` (e garantir `import '../../data/models/internship.dart';` já existe — sim).
  - Add a rota:
```dart
      GoRoute(path: '/admin/sugestoes', pageBuilder: (c, s) => fadeSlide(s, const AdminSugestoesScreen())),
```
  - Trocar a rota `/admin/vaga` para aceitar o record de edição-de-sugestão:
```dart
      GoRoute(path: '/admin/vaga', pageBuilder: (c, s) {
        final x = s.extra;
        if (x is ({Internship vaga, String suggestionId})) return fadeSlide(s, VagaFormScreen(vaga: x.vaga, fromSuggestionId: x.suggestionId));
        return fadeSlide(s, VagaFormScreen(vaga: x is Internship ? x : null));
      }),
```
- [ ] **Step 5: Teste smoke** — `test/features/admin_sugestoes_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/providers/repository_provider.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';
import 'package:universe_app/features/admin/screens/admin_sugestoes_screen.dart';

void main() {
  testWidgets('lista sugestões pendentes e aprova (remove da lista, cria vaga)', (t) async {
    await t.binding.setSurfaceSize(const Size(900, 1600));
    final repo = FakeUniverseRepository();
    await t.pumpWidget(ProviderScope(
      overrides: [universeRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(theme: AppTheme.light, home: const AdminSugestoesScreen()),
    ));
    await t.pumpAndSettle();

    // As 2 sugestões de exemplo aparecem.
    expect(find.text('Estágio em Front-end'), findsOneWidget);
    expect(find.text('Estágio em Logística'), findsOneWidget);

    final antesVagas = (await repo.watchAllInternships().first).length;
    await t.tap(find.text('Aprovar').first);
    await t.pumpAndSettle();

    // virou Internship e saiu das sugestões
    expect((await repo.watchAllInternships().first).length, antesVagas + 1);
  });
}
```
- [ ] **Step 6:** `flutter analyze` (projeto) → 0 erros. `flutter test test/features/admin_sugestoes_test.dart` → PASS.
- [ ] **Step 7:** Commit — `git add lib/features/admin/ lib/core/router/app_router.dart test/features/admin_sugestoes_test.dart && git commit -m "feat(pipeline): tela de curadoria de sugestoes + card no hub + edicao via form"`

---

### Task 4: Regra do Firestore + seed dos exemplos

**Files:** Modify `firestore.rules`, `lib/data/repositories/seed.dart`

- [ ] **Step 1: Regra** — em `firestore.rules`, **substituir** o `match /{col}/{id}` atual por (adiciona a restrição de `vagas_sugeridas` à condição existente de `news`):
```
    match /{col}/{id} {
      allow read: if signedIn()
        && (col != 'vagas_sugeridas' || isAdmin())
        && (col != 'news' || isAdmin() || resource.data.published == true);
      allow write: if isAdmin();
    }
```
- [ ] **Step 2: Seed** — em `seed.dart`, antes do `await batch.commit();`, adicionar:
```dart
  for (final s in fake.allVagasSugeridas) {
    batch.set(db.collection('vagas_sugeridas').doc(s.id), s.toMap());
  }
```
- [ ] **Step 3:** `flutter analyze` → limpo. Validar a regra (se possível) ou conferir visualmente. Commit — `git add firestore.rules lib/data/repositories/seed.dart && git commit -m "feat(pipeline): regra de vagas_sugeridas (so admin) + seed de exemplos"`

---

### Task 5: Pipeline Python (scraping + Gemini estruturado + firebase-admin)

**Files:** Create `pipeline/main.py`, `pipeline/requirements.txt`, `pipeline/README.md`, `pipeline/test_pipeline.py`; Modify `.gitignore`

- [ ] **Step 1: `pipeline/requirements.txt`**:
```
selenium==4.25.0
google-genai==0.3.0
firebase-admin==6.5.0
python-dotenv==1.0.1
```
- [ ] **Step 2: `pipeline/main.py`** — evolui o script atual. Estrutura: `map_course` (puro, testável), `extrair_estruturado` (Gemini JSON), `processar` (scraping + dedup + escrita). Versão completa:
```python
import os, time, json, re, hashlib
import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv
from google import genai
from google.genai import types
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException

load_dotenv()

# Rótulos curtos de curso usados no app (devem casar com o VagaFormScreen).
CURSOS_APP = ["ADS", "Gestão Pública", "Eng. de Produção", "Redes", "Administração", "Logística", "Todos"]

def map_course(valor: str) -> str:
    """Normaliza o curso retornado pelo modelo para um rótulo do app."""
    if not valor:
        return "Todos"
    v = valor.strip().lower()
    tabela = {
        "ads": "ADS", "análise e desenvolvimento": "ADS", "analise e desenvolvimento": "ADS",
        "gestão pública": "Gestão Pública", "gestao publica": "Gestão Pública",
        "produção": "Eng. de Produção", "producao": "Eng. de Produção", "engenharia": "Eng. de Produção",
        "redes": "Redes", "administração": "Administração", "administracao": "Administração",
        "logística": "Logística", "logistica": "Logística",
    }
    for chave, rotulo in tabela.items():
        if chave in v:
            return rotulo
    for rotulo in CURSOS_APP:
        if rotulo.lower() == v:
            return rotulo
    return "Todos"

def vaga_id(link: str) -> str:
    return hashlib.sha1(link.encode("utf-8")).hexdigest()

def init_firestore():
    cred_path = os.getenv("FIREBASE_SERVICE_ACCOUNT", "service-account.json")
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)
    return firestore.client()

def init_gemini():
    return genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

PROMPT_EXTRACAO = """Você extrai dados de uma vaga de estágio para um app acadêmico.
Cursos do campus (use EXATAMENTE um destes em "course"): {cursos}
Se nenhum servir, use "Todos".

Texto da vaga:
\"\"\"{texto}\"\"\"

Responda em JSON com as chaves:
course (string), area (string), duration (string), grant (string, bolsa/remuneração),
jobDescription (string, 1-3 frases), companyDescription (string, 1-2 frases),
requirements (array de strings), niceToHave (array de strings), benefits (array de strings).
Use "" ou [] quando não houver a informação. Responda só o JSON."""

def extrair_estruturado(client, texto: str) -> dict:
    prompt = PROMPT_EXTRACAO.format(cursos=", ".join(CURSOS_APP), texto=texto[:6000])
    for tentativa in range(3):
        try:
            resp = client.models.generate_content(
                model="gemini-2.5-flash",
                contents=prompt,
                config=types.GenerateContentConfig(response_mime_type="application/json"),
            )
            data = json.loads(resp.text)
            return {
                "course": map_course(str(data.get("course", ""))),
                "area": str(data.get("area", "")),
                "duration": str(data.get("duration", "")),
                "grant": str(data.get("grant", "")),
                "jobDescription": str(data.get("jobDescription", "")),
                "companyDescription": str(data.get("companyDescription", "")),
                "requirements": [str(x) for x in (data.get("requirements") or [])],
                "niceToHave": [str(x) for x in (data.get("niceToHave") or [])],
                "benefits": [str(x) for x in (data.get("benefits") or [])],
            }
        except Exception as e:
            erro = str(e)
            m = re.search(r"retry in (\d+)", erro)
            if m:
                time.sleep(int(m.group(1)) + 5)
            else:
                print(f"❌ Erro no Gemini: {e}")
                break
    return {"course": "Todos", "area": "", "duration": "", "grant": "",
            "jobDescription": "", "companyDescription": "", "requirements": [], "niceToHave": [], "benefits": []}

def ja_tratada(db, vid: str) -> bool:
    if db.collection("internships").document(vid).get().exists:
        return True
    sug = db.collection("vagas_sugeridas").document(vid).get()
    return sug.exists and sug.to_dict().get("status") == "recusada"

def coletar_listagem(driver, max_vagas: int):
    """Retorna [(titulo, empresa, modalidade, link)] da listagem da Gupy."""
    driver.get("https://portal.gupy.io/job-search/term=estágio")
    time.sleep(3)
    try:
        b = driver.find_element(By.ID, "privacytools-banner-consent")
        b.find_element(By.TAG_NAME, "button").click()
        time.sleep(1)
    except NoSuchElementException:
        pass
    vagas = []
    while len(vagas) < max_vagas:
        try:
            WebDriverWait(driver, 10).until(EC.presence_of_all_elements_located((By.TAG_NAME, "h3")))
        except TimeoutException:
            break
        cards = driver.find_elements(By.CSS_SELECTOR, "div[aria-label^='Empresa']")
        for card in cards:
            if len(vagas) >= max_vagas:
                break
            try:
                pai = card.find_element(By.XPATH, "./parent::*")
                titulo = pai.find_element(By.TAG_NAME, "h3").text
                empresa = card.find_element(By.TAG_NAME, "p").text
                try:
                    spans = pai.find_elements(By.CSS_SELECTOR, "span.sc-23336bc7-1")
                    modalidade = spans[1].text if len(spans) > 1 else "Presencial"
                except Exception:
                    modalidade = "Presencial"
                link = pai.find_element(By.XPATH, "./ancestor::a[1]").get_attribute("href")
                if titulo and link:
                    vagas.append((titulo, empresa, modalidade, link))
            except Exception:
                continue
        try:
            botao = driver.find_element(By.XPATH, "//button[@aria-label='Próxima página']")
            if not botao.is_enabled():
                break
            driver.execute_script("arguments[0].click();", botao)
            time.sleep(2)
        except NoSuchElementException:
            break
    return vagas

def texto_da_vaga(driver, link: str) -> str:
    driver.get(link)
    time.sleep(2)
    try:
        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.TAG_NAME, "main")))
        return driver.find_element(By.TAG_NAME, "main").text
    except Exception:
        return driver.find_element(By.TAG_NAME, "body").text

def main():
    db = init_firestore()
    client = init_gemini()
    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=1920,1080")
    driver = webdriver.Chrome(options=options)
    max_vagas = int(os.getenv("MAX_VAGAS", "30"))

    novas = 0
    try:
        listagem = coletar_listagem(driver, max_vagas)
        print(f"🔎 {len(listagem)} vagas na listagem.")
        for titulo, empresa, modalidade, link in listagem:
            vid = vaga_id(link)
            if ja_tratada(db, vid):
                print(f"⏭️  Pulando (já tratada): {titulo}")
                continue
            print(f"🤖 Enriquecendo: {titulo}")
            extra = extrair_estruturado(client, texto_da_vaga(driver, link))
            doc = {
                "role": titulo, "companyName": empresa, "mode": modalidade, "link": link,
                "tag": "Novo", "open": True, "closedAt": None,
                "source": "gupy-auto", "scrapedAt": int(time.time() * 1000), "status": "pendente",
                **extra,
            }
            db.collection("vagas_sugeridas").document(vid).set(doc, merge=True)
            novas += 1
            time.sleep(2)
    finally:
        driver.quit()
    print(f"✅ {novas} sugestões gravadas em 'vagas_sugeridas'.")

if __name__ == "__main__":
    main()
```
- [ ] **Step 3: Teste Python (opcional, pytest)** — `pipeline/test_pipeline.py`:
```python
from main import map_course, vaga_id

def test_map_course():
    assert map_course("Tecnologia em Análise e Desenvolvimento de Sistemas") == "ADS"
    assert map_course("Técnico em Redes de Computadores") == "Redes"
    assert map_course("Bacharelado em Engenharia de Produção") == "Eng. de Produção"
    assert map_course("") == "Todos"
    assert map_course("Curso inexistente") == "Todos"

def test_vaga_id_estavel():
    a = vaga_id("https://x/1")
    b = vaga_id("https://x/1")
    assert a == b and len(a) == 40
```
- [ ] **Step 4: `.gitignore`** — adicionar (proteger a credencial e artefatos):
```
# Pipeline
pipeline/service-account.json
pipeline/.env
pipeline/vagas_gupy.csv
pipeline/__pycache__/
```
- [ ] **Step 5: `pipeline/README.md`** — instruções de setup:
```markdown
# Pipeline de Vagas — Universe

Coleta vagas de estágio (Gupy), enriquece com o Gemini e grava **sugestões** na
coleção `vagas_sugeridas` do Firestore, para o Setor de Estágios aprovar no app.

## Pré-requisitos
- Python 3.11+, Google Chrome instalado.
- `pip install -r requirements.txt`

## Credenciais (nunca versionar)
1. **Service account:** Firebase Console → Configurações do projeto → Contas de
   serviço → "Gerar nova chave privada". Salve como `pipeline/service-account.json`
   (já no `.gitignore`).
2. **Gemini:** crie uma API key e exporte `GEMINI_API_KEY`.
3. Variáveis (ou um `pipeline/.env`):
   - `GEMINI_API_KEY=...`
   - `FIREBASE_SERVICE_ACCOUNT=service-account.json`
   - `MAX_VAGAS=30` (opcional)

## Rodar local
```
cd pipeline
python main.py
```

## Agendado (GitHub Actions)
Veja `.github/workflows/pipeline-vagas.yml`. Configure os secrets do repositório:
- `GEMINI_API_KEY`
- `FIREBASE_SERVICE_ACCOUNT` (cole o JSON inteiro da service account)

## Testes
`cd pipeline && pip install pytest && pytest`
```
- [ ] **Step 6:** Conferir que `pipeline/main.py` compila: `cd pipeline && python -c "import ast; ast.parse(open('main.py',encoding='utf-8').read()); print('OK')"` (não executa Selenium; só valida sintaxe). Se Python disponível e quiser, `pytest`.
- [ ] **Step 7:** Commit — `git add pipeline/ .gitignore && git commit -m "feat(pipeline): script Python (scraping + Gemini estruturado + firebase-admin)"`

---

### Task 6: GitHub Actions (agendamento)

**Files:** Create `.github/workflows/pipeline-vagas.yml`

- [ ] **Step 1: Workflow**:
```yaml
name: Pipeline de Vagas
on:
  schedule:
    - cron: '0 6 * * *'   # diariamente às 06:00 UTC (03:00 BRT)
  workflow_dispatch: {}     # permite rodar manualmente

jobs:
  coletar-vagas:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - name: Instalar Chrome
        uses: browser-actions/setup-chrome@v1
      - name: Instalar dependências
        run: pip install -r pipeline/requirements.txt
      - name: Gravar service account
        run: printf '%s' "$FIREBASE_SERVICE_ACCOUNT" > pipeline/service-account.json
        env:
          FIREBASE_SERVICE_ACCOUNT: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
      - name: Rodar pipeline
        working-directory: pipeline
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
          FIREBASE_SERVICE_ACCOUNT: service-account.json
          MAX_VAGAS: '30'
        run: python main.py
```
- [ ] **Step 2:** Commit — `git add .github/workflows/pipeline-vagas.yml && git commit -m "ci(pipeline): agenda coleta de vagas (GitHub Actions)"`

> Passo operacional do usuário: criar os secrets `GEMINI_API_KEY` e
> `FIREBASE_SERVICE_ACCOUNT` no repositório e habilitar Actions.

---

### Task 7: Verificação + diário

- [ ] **Step 1:** `flutter analyze` → 0 erros. `flutter test` → todos PASS.
- [ ] **Step 2:** App (admin): **Popular dados (dev)** cria `vagas_sugeridas` (2 exemplos). Hub mostra **"Vagas sugeridas (2)"** → `/admin/sugestoes` → **Aprovar** (vira vaga em Estágio), **Editar** (abre form pré-preenchido, salva e remove a sugestão), **Recusar** (some da lista). Publicar a regra do Firestore atualizada (passo operacional).
- [ ] **Step 3:** Diário — entrada SP4 (pipeline de vagas) no estilo das anteriores.
- [ ] **Step 4:** Commit — `git add docs/ && git commit -m "docs: registra SP4 (pipeline de vagas)"`

---

## Self-Review (cobertura da spec)
- **§2 contrato `vagas_sugeridas`:** Tasks 1,2,4,5 ✓.
- **§3 pipeline Python (dedup, enriquecimento, firebase-admin, Actions):** Tasks 5,6 ✓.
- **§4 app (modelo, repo, providers, tela, hub, form.fromSuggestionId):** Tasks 1,2,3 ✓.
- **§5 segurança/regra + service account no .gitignore:** Tasks 4,5 ✓.
- **§7 testes:** Tasks 1,2,3 (app) + 5 (python) ✓.

**Riscos/notas:**
1. **`AdminHubScreen`** pode já ser `ConsumerWidget` ou `StatelessWidget` — adaptar a conversão sem quebrar o build atual dos cards.
2. **Record como `extra`** no `/admin/vaga` (`({Internship vaga, String suggestionId})`) — manter a compatibilidade com o uso atual (extra `Internship`).
3. **Regra de leitura** estende a condição existente do `news` (não criar match separado — união reabriria).
4. **Pipeline depende de credenciais/secret** do usuário; o agendamento real é passo operacional. O código deve **compilar/parsear** mesmo sem rede (Task 5 Step 6).
5. **Seletores da Gupy** podem variar — try/except por vaga; é manutenção esperada.
6. **`firebase-admin` ignora as regras** (credencial de servidor) — por isso o pipeline grava em `vagas_sugeridas` sem depender da regra de cliente.
