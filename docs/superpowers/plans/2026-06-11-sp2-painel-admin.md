# SP2 — Painel Admin (Vagas & Concursos) · Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Permitir que o admin (Setor de Estágios) cadastre/edite/encerre/exclua vagas e concursos pela UI, com as entradas de admin visíveis só para `role == 'admin'`.

**Architecture:** `StudentProfile` ganha `role`; `isAdminProvider` deriva disso. `UniverseRepository` ganha escrita (`upsert`/`delete`) e leitura admin sem filtro (`watchAll…`), nas impls Firestore e Fake. Painel `/admin` com abas Vagas|Concursos (listas + excluir + FAB) e formulários de vaga/concurso. Segurança já garantida pelas regras do SP1.

**Tech Stack:** cloud_firestore, flutter_riverpod, go_router. Sem novas dependências.

**Spec:** `docs/superpowers/specs/2026-06-11-sp2-painel-admin-design.md`.

**Estado atual (confirmado):** `StudentProfile{uid,course?,enrollment?}` (toMap omite campos nulos); `FirestoreUniverseRepository` com `_map` helper + coleções; `currentProfileProvider` (FutureProvider); `EstagioScreen` mostra o escudo sempre (`GreenHero action:`); `MenuDrawer` usa `drawerItems` const.

---

## Estrutura de arquivos (SP2)

```
lib/data/profile/student_profile.dart          + campo role (fromMap lê; toMap NÃO grava)
lib/core/providers/profile_provider.dart        + isAdminProvider
lib/data/repositories/universe_repository.dart  + watchAll/upsert/delete
lib/data/repositories/firestore_universe_repository.dart  impl
lib/data/repositories/fake_universe_repository.dart       impl (+ getters já existem)
lib/core/providers/repository_provider.dart     + allInternshipsProvider/allContestsProvider
lib/features/admin/screens/admin_panel_screen.dart   painel
lib/features/admin/screens/vaga_form_screen.dart     form de vaga
lib/features/admin/screens/concurso_form_screen.dart form de concurso
lib/core/router/app_router.dart                 rotas /admin, /admin/vaga, /admin/concurso + gating do drawer
lib/features/internships/screens/estagio_screen.dart  escudo só p/ admin
lib/shared/chrome/menu_drawer.dart              item admin condicional
test/data/admin_repository_test.dart            CRUD no Fake
test/features/admin_gating_test.dart            entrada some p/ aluno
```

---

### Task 1: `role` no perfil + `isAdminProvider`

**Files:** Modify `lib/data/profile/student_profile.dart`, `lib/core/providers/profile_provider.dart`; Test `test/data/admin_repository_test.dart` (parte 1)

- [ ] **Step 1: Adicionar `role` ao StudentProfile (só-leitura; toMap não grava)**

`lib/data/profile/student_profile.dart`:
```dart
class StudentProfile {
  final String uid;
  final String? course;     // nome completo do curso (campusCourses)
  final String? enrollment; // matrícula
  final String role;        // 'student' | 'admin' (só-leitura no cliente)
  const StudentProfile({required this.uid, this.course, this.enrollment, this.role = 'student'});

  StudentProfile copyWith({String? course, String? enrollment}) =>
      StudentProfile(uid: uid, course: course ?? this.course, enrollment: enrollment ?? this.enrollment, role: role);

  // NÃO grava `role` (a regra do Firestore impede o cliente de alterá-lo).
  Map<String, dynamic> toMap() => {
        if (course != null) 'course': course,
        if (enrollment != null) 'enrollment': enrollment,
      };
  factory StudentProfile.fromMap(String uid, Map<String, dynamic> m) =>
      StudentProfile(uid: uid, course: m['course'] as String?, enrollment: m['enrollment'] as String?, role: (m['role'] as String?) ?? 'student');
}
```

- [ ] **Step 2: `isAdminProvider`**

Em `lib/core/providers/profile_provider.dart`, adicionar ao final:
```dart
/// True se o usuário atual tem papel admin (Setor de Estágios).
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(currentProfileProvider).valueOrNull?.role == 'admin';
});
```

- [ ] **Step 3: Teste do mapeamento de role**

Criar `test/data/admin_repository_test.dart` (parte de profile; a parte do repositório vem na Task 2):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/profile/student_profile.dart';

void main() {
  test('StudentProfile lê role mas não o grava', () {
    final p = StudentProfile.fromMap('u1', {'course': 'ADS', 'role': 'admin'});
    expect(p.role, 'admin');
    expect(p.toMap().containsKey('role'), isFalse); // não sobrescreve role ao salvar
  });

  test('role default é student', () {
    expect(StudentProfile.fromMap('u1', {}).role, 'student');
  });
}
```

- [ ] **Step 4:** `flutter test test/data/admin_repository_test.dart` → PASS. `flutter analyze lib/data/profile/ lib/core/providers/profile_provider.dart` → limpo.
- [ ] **Step 5:** Commit — `git add lib/data/profile/student_profile.dart lib/core/providers/profile_provider.dart test/data/admin_repository_test.dart && git commit -m "feat(admin): role no perfil + isAdminProvider"`

---

### Task 2: Escrita no repositório (interface + Firestore + Fake) + providers

**Files:** Modify `universe_repository.dart`, `firestore_universe_repository.dart`, `fake_universe_repository.dart`, `repository_provider.dart`; Test (append a `admin_repository_test.dart`)

- [ ] **Step 1: Interface** — adicionar a `UniverseRepository`:
```dart
  // Leitura admin (sem filtro de visibilidade)
  Stream<List<Internship>> watchAllInternships();
  Stream<List<Contest>> watchAllContests();
  // Escrita (admin)
  Future<void> upsertInternship(Internship vaga);
  Future<void> deleteInternship(String id);
  Future<void> upsertContest(Contest c);
  Future<void> deleteContest(String id);
  /// Gera um novo id para uma coleção ('internships' | 'contests').
  String newId(String collection);
```

- [ ] **Step 2: Firestore impl** — adicionar em `FirestoreUniverseRepository`:
```dart
  @override
  Stream<List<Internship>> watchAllInternships() =>
      _db.collection('internships').snapshots().map((s) => _map(s, Internship.fromMap));

  @override
  Stream<List<Contest>> watchAllContests() =>
      _db.collection('contests').snapshots().map((s) => _map(s, Contest.fromMap));

  @override
  Future<void> upsertInternship(Internship v) =>
      _db.collection('internships').doc(v.id).set(v.toMap());

  @override
  Future<void> deleteInternship(String id) => _db.collection('internships').doc(id).delete();

  @override
  Future<void> upsertContest(Contest c) => _db.collection('contests').doc(c.id).set(c.toMap());

  @override
  Future<void> deleteContest(String id) => _db.collection('contests').doc(id).delete();

  @override
  String newId(String collection) => _db.collection(collection).doc().id;
```

- [ ] **Step 3: Fake impl** — em `FakeUniverseRepository`, adicionar (mutando as listas internas):
```dart
  var _idSeq = 1000;

  @override
  Stream<List<Internship>> watchAllInternships() => Stream.value(List.of(_internships));
  @override
  Stream<List<Contest>> watchAllContests() => Stream.value(List.of(_contests));
  @override
  Future<void> upsertInternship(Internship v) async {
    final i = _internships.indexWhere((e) => e.id == v.id);
    if (i >= 0) { _internships[i] = v; } else { _internships.add(v); }
  }
  @override
  Future<void> deleteInternship(String id) async => _internships.removeWhere((e) => e.id == id);
  @override
  Future<void> upsertContest(Contest c) async {
    final i = _contests.indexWhere((e) => e.id == c.id);
    if (i >= 0) { _contests[i] = c; } else { _contests.add(c); }
  }
  @override
  Future<void> deleteContest(String id) async => _contests.removeWhere((e) => e.id == id);
  @override
  String newId(String collection) => '${collection}_${_idSeq++}';
```
> Confirmar que `_internships`/`_contests` são `List` mutáveis (não `const`). Se forem
> `final List<...> _internships = [ ... ]` já são mutáveis. Ajustar se necessário.

- [ ] **Step 4: Providers admin** — em `repository_provider.dart`:
```dart
final allInternshipsProvider = StreamProvider<List<Internship>>((ref) => ref.watch(universeRepositoryProvider).watchAllInternships());
final allContestsProvider = StreamProvider<List<Contest>>((ref) => ref.watch(universeRepositoryProvider).watchAllContests());
```

- [ ] **Step 5: Teste de CRUD no Fake** — adicionar a `test/data/admin_repository_test.dart`:
```dart
// (adicionar imports e testes)
import 'package:universe_app/data/models/internship.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';

// dentro de main():
  test('upsert cria e atualiza; delete remove (Fake)', () async {
    final repo = FakeUniverseRepository();
    final id = repo.newId('internships');
    final v = Internship(id: id, role: 'Nova vaga', companyName: 'X', area: 'TI', duration: '6m',
      jobDescription: 'd', requirements: const [], niceToHave: const [], companyDescription: 's',
      benefits: const [], grant: 'R\$ 1.000', course: 'ADS', mode: 'Híbrido');
    await repo.upsertInternship(v);
    var all = await repo.watchAllInternships().first;
    expect(all.any((e) => e.id == id && e.role == 'Nova vaga'), isTrue);
    await repo.upsertInternship(Internship(id: id, role: 'Editada', companyName: 'X', area: 'TI', duration: '6m',
      jobDescription: 'd', requirements: const [], niceToHave: const [], companyDescription: 's',
      benefits: const [], grant: 'R\$ 1.000', course: 'ADS', mode: 'Híbrido'));
    all = await repo.watchAllInternships().first;
    expect(all.firstWhere((e) => e.id == id).role, 'Editada');
    await repo.deleteInternship(id);
    all = await repo.watchAllInternships().first;
    expect(all.any((e) => e.id == id), isFalse);
  });
```

- [ ] **Step 6:** `flutter test test/data/admin_repository_test.dart` → PASS. `flutter analyze` (whole) → limpo.
- [ ] **Step 7:** Commit — `git add lib/data/repositories/ lib/core/providers/repository_provider.dart test/data/admin_repository_test.dart && git commit -m "feat(admin): escrita no repositorio (upsert/delete) + leitura admin"`

---

### Task 3: AdminPanelScreen (abas + listas + excluir)

**Files:** Create `lib/features/admin/screens/admin_panel_screen.dart`

- [ ] **Step 1: Criar o painel**

`lib/features/admin/screens/admin_panel_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/contest.dart';
import '../../../data/models/internship.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/status_badge.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  bool _vagas = true;

  Future<void> _confirmDelete(String titulo, Future<void> Function() onDelete) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Excluir'),
        content: Text('Excluir "$titulo"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true) {
      await onDelete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Excluído')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final repo = ref.read(universeRepositoryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: c.green800, foregroundColor: Colors.white,
        onPressed: () => context.push(_vagas ? '/admin/vaga' : '/admin/concurso'),
        icon: const Icon(Icons.add),
        label: Text(_vagas ? 'Nova vaga' : 'Novo concurso'),
      ),
      body: PageShell(
        bodyPadding: const EdgeInsets.all(16),
        header: PageHeader(title: 'Painel — Setor de Estágios', onBack: () => context.pop()),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: c.bg2, borderRadius: BorderRadius.circular(13)),
            child: Row(children: [
              for (final (label, isV) in const [('Vagas', true), ('Concursos', false)])
                Expanded(child: GestureDetector(
                  onTap: () => setState(() => _vagas = isV),
                  child: Container(
                    height: 38, alignment: Alignment.center,
                    decoration: BoxDecoration(color: _vagas == isV ? c.card : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                    child: Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _vagas == isV ? c.green800 : c.ink3)),
                  ),
                )),
            ]),
          ),
          const SizedBox(height: 16),
          if (_vagas)
            AsyncListView<Internship>(
              value: ref.watch(allInternshipsProvider),
              onRetry: () => ref.invalidate(allInternshipsProvider),
              emptyTitle: 'Nenhuma vaga cadastrada', emptyBody: 'Toque em "Nova vaga" para começar.',
              data: (list) => Column(children: [
                for (final v in list) Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AdminRow(
                    icon: 'briefcase', title: v.role, subtitle: v.companyName,
                    badge: StatusBadge(closed: !v.open),
                    onEdit: () => context.push('/admin/vaga', extra: v),
                    onDelete: () => _confirmDelete(v.role, () => repo.deleteInternship(v.id)),
                  ),
                ),
              ]),
            )
          else
            AsyncListView<Contest>(
              value: ref.watch(allContestsProvider),
              onRetry: () => ref.invalidate(allContestsProvider),
              emptyTitle: 'Nenhum concurso cadastrado', emptyBody: 'Toque em "Novo concurso" para começar.',
              data: (list) => Column(children: [
                for (final ct in list) Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AdminRow(
                    icon: 'doc', title: ct.role, subtitle: ct.org,
                    badge: StatusBadge(closed: !ct.isOpenAt(DateTime.now()), openLabel: 'Abertas', closedLabel: 'Encerradas'),
                    onEdit: () => context.push('/admin/concurso', extra: ct),
                    onDelete: () => _confirmDelete(ct.role, () => repo.deleteContest(ct.id)),
                  ),
                ),
              ]),
            ),
        ]),
      ),
    );
  }
}

class _AdminRow extends StatelessWidget {
  final String icon, title, subtitle;
  final Widget badge;
  final VoidCallback onEdit, onDelete;
  const _AdminRow({required this.icon, required this.title, required this.subtitle, required this.badge, required this.onEdit, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      onTap: onEdit, padding: const EdgeInsets.all(12),
      child: Row(children: [
        IconTile(icon, size: 44),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(fontSize: 12, color: c.ink3), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          badge,
        ])),
        IconButton(onPressed: onDelete, icon: Icon(Icons.delete_outline, color: c.error, size: 22)),
      ]),
    );
  }
}
```

- [ ] **Step 2:** `flutter analyze lib/features/admin/screens/admin_panel_screen.dart` → limpo.
- [ ] **Step 3:** Commit — `git add lib/features/admin/screens/admin_panel_screen.dart && git commit -m "feat(admin): painel com abas, listas e excluir"`

---

### Task 4: VagaFormScreen (criar/editar vaga)

**Files:** Create `lib/features/admin/screens/vaga_form_screen.dart`

- [ ] **Step 1: Criar o formulário**

`lib/features/admin/screens/vaga_form_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/courses.dart';
import '../../../data/models/internship.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/app_toggle.dart';
import '../../../shared/widgets/section_title.dart';

class VagaFormScreen extends ConsumerStatefulWidget {
  final Internship? vaga; // null = nova
  const VagaFormScreen({super.key, this.vaga});
  @override
  ConsumerState<VagaFormScreen> createState() => _VagaFormScreenState();
}

class _VagaFormScreenState extends ConsumerState<VagaFormScreen> {
  late final _v = widget.vaga;
  late String _role = _v?.role ?? '';
  late String _company = _v?.companyName ?? '';
  late String _area = _v?.area ?? '';
  late String _jobDesc = _v?.jobDescription ?? '';
  late String _companyDesc = _v?.companyDescription ?? '';
  late String _grant = _v?.grant ?? '';
  late String _duration = _v?.duration ?? '';
  late String _link = _v?.link ?? '';
  late String _tag = _v?.tag ?? '';
  late String _course = _v?.course ?? 'ADS';
  late String _mode = _v?.mode ?? 'Presencial';
  late bool _open = _v?.open ?? true;
  late List<String> _reqs = List.of(_v?.requirements ?? const []);
  late List<String> _nice = List.of(_v?.niceToHave ?? const []);
  late List<String> _benefits = List.of(_v?.benefits ?? const []);
  bool _saving = false;
  bool _showErrors = false;

  static const _courseOptions = ['ADS', 'Gestão Pública', 'Eng. de Produção', 'Redes', 'Administração', 'Logística'];
  static const _modeOptions = ['Presencial', 'Híbrido', 'Remoto'];

  bool get _valid => _role.trim().isNotEmpty && _company.trim().isNotEmpty && _area.trim().isNotEmpty && _jobDesc.trim().isNotEmpty && _grant.trim().isNotEmpty;

  Future<void> _save() async {
    setState(() => _showErrors = true);
    if (!_valid) return;
    setState(() => _saving = true);
    final repo = ref.read(universeRepositoryProvider);
    final id = _v?.id ?? repo.newId('internships');
    final closedAt = _open ? null : (_v?.closedAt ?? DateTime.now());
    final vaga = Internship(
      id: id, role: _role.trim(), companyName: _company.trim(), area: _area.trim(),
      duration: _duration.trim(), jobDescription: _jobDesc.trim(),
      requirements: _reqs, niceToHave: _nice, companyDescription: _companyDesc.trim(),
      benefits: _benefits, grant: _grant.trim(), course: _course, mode: _mode,
      link: _link.trim().isEmpty ? null : _link.trim(),
      tag: _tag.trim().isEmpty ? null : _tag.trim(), open: _open, closedAt: closedAt,
    );
    try {
      await repo.upsertInternship(vaga);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaga salva!')));
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    String? err(String v) => (_showErrors && v.trim().isEmpty) ? 'Obrigatório' : null;
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: PageHeader(title: _v == null ? 'Nova vaga' : 'Editar vaga', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppField(label: 'Cargo', icon: 'briefcase', value: _role, error: err(_role), onChanged: (v) => setState(() => _role = v)),
          const SizedBox(height: 12),
          AppField(label: 'Empresa', icon: 'institution', value: _company, error: err(_company), onChanged: (v) => setState(() => _company = v)),
          const SizedBox(height: 12),
          AppField(label: 'Área de atuação', icon: 'doc', value: _area, error: err(_area), onChanged: (v) => setState(() => _area = v)),
          const SizedBox(height: 12),
          AppField(label: 'Descrição da vaga', value: _jobDesc, error: err(_jobDesc), onChanged: (v) => setState(() => _jobDesc = v)),
          const SizedBox(height: 12),
          AppField(label: 'Descrição da empresa', value: _companyDesc, onChanged: (v) => setState(() => _companyDesc = v)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AppField(label: 'Bolsa', icon: 'card', value: _grant, error: err(_grant), onChanged: (v) => setState(() => _grant = v))),
            const SizedBox(width: 10),
            Expanded(child: AppField(label: 'Duração', icon: 'clock', value: _duration, onChanged: (v) => setState(() => _duration = v))),
          ]),
          const SizedBox(height: 12),
          _Dropdown(label: 'Curso', value: _course, options: _courseOptions, onChanged: (v) => setState(() => _course = v)),
          const SizedBox(height: 12),
          _Dropdown(label: 'Modalidade', value: _mode, options: _modeOptions, onChanged: (v) => setState(() => _mode = v)),
          const SizedBox(height: 12),
          AppField(label: 'Tag (opcional, ex.: Novo)', value: _tag, onChanged: (v) => setState(() => _tag = v)),
          const SizedBox(height: 12),
          AppField(label: 'Link (opcional)', icon: 'globe', value: _link, onChanged: (v) => setState(() => _link = v)),
          const SizedBox(height: 18),
          _ListEditor(title: 'Pré-requisitos', items: _reqs, onChanged: (l) => setState(() => _reqs = l)),
          _ListEditor(title: 'Diferenciais', items: _nice, onChanged: (l) => setState(() => _nice = l)),
          _ListEditor(title: 'Benefícios', items: _benefits, onChanged: (l) => setState(() => _benefits = l)),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(child: Text('Vaga aberta', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: c.ink))),
            AppToggle(on: _open, onChanged: (v) => setState(() => _open = v)),
          ]),
          const SizedBox(height: 20),
          AppButton(_saving ? 'Salvando…' : 'Salvar vaga', full: true, icon: 'check', onTap: _saving ? null : _save),
          const SizedBox(height: 10),
          AppButton('Cancelar', full: true, variant: AppButtonVariant.ghost, onTap: () => context.pop()),
        ]),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label, value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _Dropdown({required this.label, required this.value, required this.options, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 3, bottom: 7), child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2))),
      DropdownButtonFormField<String>(
        initialValue: options.contains(value) ? value : options.first,
        isExpanded: true,
        decoration: InputDecoration(filled: true, fillColor: c.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13))),
        items: [for (final o in options) DropdownMenuItem(value: o, child: Text(o))],
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    ]);
  }
}

class _ListEditor extends StatefulWidget {
  final String title;
  final List<String> items;
  final ValueChanged<List<String>> onChanged;
  const _ListEditor({required this.title, required this.items, required this.onChanged});
  @override
  State<_ListEditor> createState() => _ListEditorState();
}

class _ListEditorState extends State<_ListEditor> {
  String _draft = '';
  final _ctrl = TextEditingController();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionTitle(widget.title),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final item in widget.items)
            Chip(
              label: Text(item, style: const TextStyle(fontSize: 12)),
              onDeleted: () => widget.onChanged(List.of(widget.items)..remove(item)),
              backgroundColor: c.green050,
            ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(isDense: true, hintText: 'Adicionar item…', border: OutlineInputBorder(borderRadius: BorderRadius.circular(11))),
            onChanged: (v) => _draft = v,
            onSubmitted: (_) => _add(),
          )),
          const SizedBox(width: 8),
          IconButton(onPressed: _add, icon: Icon(Icons.add_circle, color: c.green600)),
        ]),
      ]),
    );
  }
  void _add() {
    final t = _draft.trim();
    if (t.isEmpty) return;
    widget.onChanged(List.of(widget.items)..add(t));
    _ctrl.clear();
    _draft = '';
  }
}
```

- [ ] **Step 2:** `flutter analyze lib/features/admin/screens/vaga_form_screen.dart` → limpo.
- [ ] **Step 3:** Commit — `git add lib/features/admin/screens/vaga_form_screen.dart && git commit -m "feat(admin): formulario de vaga (criar/editar, RF033)"`

---

### Task 5: ConcursoFormScreen (criar/editar concurso)

**Files:** Create `lib/features/admin/screens/concurso_form_screen.dart`

- [ ] **Step 1: Criar o formulário**

`lib/features/admin/screens/concurso_form_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/contest.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_field.dart';

class ConcursoFormScreen extends ConsumerStatefulWidget {
  final Contest? contest;
  const ConcursoFormScreen({super.key, this.contest});
  @override
  ConsumerState<ConcursoFormScreen> createState() => _ConcursoFormScreenState();
}

class _ConcursoFormScreenState extends ConsumerState<ConcursoFormScreen> {
  late final _ct = widget.contest;
  late String _role = _ct?.role ?? '';
  late String _org = _ct?.org ?? '';
  late String _vagas = _ct?.vagas ?? '';
  late String _salary = _ct?.salary ?? '';
  late String _level = _ct?.level ?? '';
  late String _about = _ct?.about ?? '';
  late String _link = _ct?.link ?? '';
  late DateTime _deadline = _ct?.deadline ?? DateTime.now().add(const Duration(days: 30));
  bool _saving = false;
  bool _showErrors = false;

  bool get _valid => _role.trim().isNotEmpty && _org.trim().isNotEmpty;

  Future<void> _save() async {
    setState(() => _showErrors = true);
    if (!_valid) return;
    setState(() => _saving = true);
    final repo = ref.read(universeRepositoryProvider);
    final id = _ct?.id ?? repo.newId('contests');
    final ct = Contest(id: id, role: _role.trim(), org: _org.trim(), vagas: _vagas.trim(),
      salary: _salary.trim(), level: _level.trim(), about: _about.trim(),
      link: _link.trim().isEmpty ? null : _link.trim(), deadline: _deadline);
    try {
      await repo.upsertContest(ct);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Concurso salvo!')));
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    String? err(String v) => (_showErrors && v.trim().isEmpty) ? 'Obrigatório' : null;
    final prazo = '${_deadline.day.toString().padLeft(2, '0')}/${_deadline.month.toString().padLeft(2, '0')}/${_deadline.year}';
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: PageHeader(title: _ct == null ? 'Novo concurso' : 'Editar concurso', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppField(label: 'Cargo', icon: 'doc', value: _role, error: err(_role), onChanged: (v) => setState(() => _role = v)),
          const SizedBox(height: 12),
          AppField(label: 'Órgão', icon: 'institution', value: _org, error: err(_org), onChanged: (v) => setState(() => _org = v)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AppField(label: 'Vagas', value: _vagas, onChanged: (v) => setState(() => _vagas = v))),
            const SizedBox(width: 10),
            Expanded(child: AppField(label: 'Salário', icon: 'card', value: _salary, onChanged: (v) => setState(() => _salary = v))),
          ]),
          const SizedBox(height: 12),
          AppField(label: 'Escolaridade', value: _level, onChanged: (v) => setState(() => _level = v)),
          const SizedBox(height: 12),
          AppField(label: 'Sobre', value: _about, onChanged: (v) => setState(() => _about = v)),
          const SizedBox(height: 12),
          AppField(label: 'Link (opcional)', icon: 'globe', value: _link, onChanged: (v) => setState(() => _link = v)),
          const SizedBox(height: 12),
          Text('Prazo de inscrição', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
          const SizedBox(height: 7),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: _deadline, firstDate: DateTime(2020), lastDate: DateTime(2100));
              if (picked != null) setState(() => _deadline = picked);
            },
            child: Container(
              height: 50, padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.centerLeft,
              decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(13), border: Border.all(color: c.line, width: 1.5)),
              child: Row(children: [Icon(Icons.event, size: 19, color: c.ink3), const SizedBox(width: 10), Text(prazo, style: TextStyle(fontSize: 15, color: c.ink))]),
            ),
          ),
          const SizedBox(height: 20),
          AppButton(_saving ? 'Salvando…' : 'Salvar concurso', full: true, icon: 'check', onTap: _saving ? null : _save),
          const SizedBox(height: 10),
          AppButton('Cancelar', full: true, variant: AppButtonVariant.ghost, onTap: () => context.pop()),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 2:** `flutter analyze lib/features/admin/screens/concurso_form_screen.dart` → limpo.
- [ ] **Step 3:** Commit — `git add lib/features/admin/screens/concurso_form_screen.dart && git commit -m "feat(admin): formulario de concurso (criar/editar)"`

---

### Task 6: Rotas + gating das entradas de admin

**Files:** Modify `lib/core/router/app_router.dart`, `lib/features/internships/screens/estagio_screen.dart`, `lib/shared/chrome/menu_drawer.dart`; Test `test/features/admin_gating_test.dart`

- [ ] **Step 1: Rotas** — em `app_router.dart`, imports + rotas top-level:
```dart
import '../../features/admin/screens/admin_panel_screen.dart';
import '../../features/admin/screens/vaga_form_screen.dart';
import '../../features/admin/screens/concurso_form_screen.dart';
// ...
GoRoute(path: '/admin', builder: (c, s) => const AdminPanelScreen()),
GoRoute(path: '/admin/vaga', builder: (c, s) => VagaFormScreen(vaga: s.extra is Internship ? s.extra as Internship : null)),
GoRoute(path: '/admin/concurso', builder: (c, s) => ConcursoFormScreen(contest: s.extra is Contest ? s.extra as Contest : null)),
```
(Garantir imports de `Internship`/`Contest` — já presentes no router.)

- [ ] **Step 2: Drawer gating** — `menu_drawer.dart`: adicionar parâmetro `final bool isAdmin;` (default false) ao `MenuDrawer`; após os `drawerItems`, se `isAdmin`, inserir um item "Painel do Setor de Estágios" (rota `/admin`). E em `app_router.dart` `_Shell`, ler `final isAdmin = ref.watch(isAdminProvider);` e passar `isAdmin: isAdmin` ao `MenuDrawer`; no `onNavigate`, tratar `/admin` com `context.push`.
  - No `menu_drawer.dart`, dentro do `ListView`, antes do `Divider`/Sair:
```dart
if (isAdmin)
  ListTile(
    leading: Icon(appIcon('shield'), color: c.green700),
    title: Text('Painel do Setor de Estágios', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.ink)),
    trailing: Icon(appIcon('chevR'), size: 16, color: c.ink3),
    onTap: () => onNavigate('/admin'),
  ),
```
  - Em `_Shell.onNavigate`, adicionar `route == '/admin'` ao ramo de `context.push`.

- [ ] **Step 3: Escudo só p/ admin** — `estagio_screen.dart`: o `GreenHero` recebe `action:` com o botão escudo. Tornar condicional: `final isAdmin = ref.watch(isAdminProvider);` e passar `action: isAdmin ? InkWell(... onTap: () => context.push('/admin') ...) : null`. (Trocar o `onTap` atual do escudo, que mostra "em breve", por `context.push('/admin')`.) Import `isAdminProvider`.

- [ ] **Step 4: Teste de gating**

`test/features/admin_gating_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universe_app/core/providers/profile_provider.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/shared/chrome/menu_drawer.dart';

void main() {
  Widget host(bool admin) => ProviderScope(
    overrides: [isAdminProvider.overrideWithValue(admin)],
    child: MaterialApp(theme: AppTheme.light, home: Scaffold(
      drawer: Consumer(builder: (c, ref, _) => MenuDrawer(
        userName: 'Ana', userEmail: 'a@b.com', isAdmin: ref.watch(isAdminProvider),
        onNavigate: (_) {}, onLogout: () {},
      )),
      body: Builder(builder: (c) => TextButton(onPressed: () => Scaffold.of(c).openDrawer(), child: const Text('abrir'))),
    )),
  );

  testWidgets('aluno não vê o painel admin no drawer', (t) async {
    await t.pumpWidget(host(false));
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();
    expect(find.text('Painel do Setor de Estágios'), findsNothing);
  });

  testWidgets('admin vê o painel admin no drawer', (t) async {
    await t.pumpWidget(host(true));
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();
    expect(find.text('Painel do Setor de Estágios'), findsOneWidget);
  });
}
```
> `isAdminProvider` é um `Provider<bool>`; `overrideWithValue` funciona.

- [ ] **Step 5:** `flutter analyze` (whole) → limpo. `flutter test` → todos PASS.
- [ ] **Step 6:** Commit — `git add -A && git commit -m "feat(admin): rotas do painel + gating das entradas (escudo e drawer)"`

---

### Task 7: Verificação + diário

- [ ] **Step 1:** `flutter analyze` (limpo) + `flutter test` (todos PASS).
- [ ] **Step 2:** Rodar no navegador (logado como **admin**): abrir o painel pelo escudo (tela Estágio) ou pelo menu; criar uma vaga → aparece no app do aluno em tempo real; editar/encerrar; criar concurso; excluir com confirmação. Logar como **aluno comum** (ou role student) e confirmar que as entradas de admin **não aparecem**.
- [ ] **Step 3:** Entrada no diário (SP2 concluído: painel admin de vagas/concursos, gating por role).
- [ ] **Step 4:** Commit — `git add docs/ && git commit -m "docs: registra SP2 (painel admin)"`

---

## Self-Review (cobertura da spec)
- **§2 role/isAdmin:** Task 1 ✓. **§3 entradas gated:** Task 6 ✓.
- **§4 painel:** Task 3 ✓. **§5 formulários:** Tasks 4–5 ✓.
- **§6 repositório escrita/admin:** Task 2 ✓. **§7 segurança:** sem mudança (SP1).
- **§9 testes:** CRUD (Task 2), gating (Task 6), validação (forms exigem obrigatórios) ✓.

**Riscos/notas:**
1. **`_internships`/`_contests` do Fake** devem ser listas mutáveis (`final List<X> _x = [...]`). Se forem `const`, tornar mutáveis (Task 2 Step 3).
2. **`role` só-leitura:** `StudentProfile.toMap` não inclui `role` (Task 1) — salvar perfil não sobrescreve o papel.
3. **Escudo:** trocar o antigo `onTap` "em breve" por `/admin` e condicionar a `isAdmin` (Task 6 Step 3).
4. **`newId`** adiciona um método à interface — implementar em Firestore e Fake (Task 2).
