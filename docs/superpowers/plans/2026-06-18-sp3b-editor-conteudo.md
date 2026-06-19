# SP3b — Editor de conteúdo no admin + upload ao Storage · Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans. Steps usam checkbox (`- [ ]`).

**Goal:** Admin cria/edita/exclui páginas de conteúdo rico (`contentDocs`) e suas seções pela UI, com upload de imagem ao Firebase Storage.

**Architecture:** Hub admin (`/admin`) com cards. Editor mantém um **rascunho local** das seções como `List<Map<String,dynamic>>` (mesma abordagem JSON do protótipo), convertendo para `ContentSection` via `fromMap` só ao publicar. Imagem → `StorageService` (Firebase Storage); vídeo → link. Repositório ganha escrita de `contentDocs`.

**Tech Stack:** flutter_riverpod, go_router, cloud_firestore, firebase_storage, **image_picker** (nova dep), cached_network_image.

**Spec:** `docs/superpowers/specs/2026-06-18-sp3b-editor-conteudo-design.md`.

**Estado atual relevante:**
- `ContentDoc{id,kind:ContentKind,icon,title,tag,summary,updatedAt,sections}` + sealed `ContentSection` (7 tipos) com `fromMap`/`toMap` (`lib/data/models/content_doc.dart`).
- `UniverseRepository` (interface + `FirestoreUniverseRepository` + `FakeUniverseRepository`) já tem `watchContentDocs(kind)`/`watchContentDoc(id)`, `newId(col)`, e o padrão `_map`. Fake tem `allContentDocs` getter.
- `repository_provider.dart`: `universeRepositoryProvider`, `contentDocsProvider`, `contentDocProvider`.
- `AdminPanelScreen` (vagas/concursos) na rota `/admin`; forms em `/admin/vaga`, `/admin/concurso`. Router em `lib/core/router/app_router.dart`.
- DS: `AppField` (sem multiline), `AppButton` (variants primary/accent/outline/ghost; sizes sm/md/lg; `icon`), `AppCard`, `IconTile`/`appIcon`/`appIcons`, `PageShell`, `PageHeader`/`GreenHero`, `AsyncListView`.
- `firebase_storage`/`cached_network_image` no pubspec; `image_picker` NÃO.
- Regras Firestore: catch-all já gate-ia `contentDocs` (leitura logado, escrita admin). Não há `storage.rules`.

---

## Estrutura de arquivos

```
pubspec.yaml                                   + image_picker
lib/data/repositories/universe_repository.dart + upsertContentDoc/deleteContentDoc/watchAllContentDocs
lib/data/repositories/firestore_universe_repository.dart  impl
lib/data/repositories/fake_universe_repository.dart       impl
lib/core/providers/repository_provider.dart    + allContentDocsProvider
lib/data/content/content_id.dart               slugify + generateDocId (puro)
lib/data/storage/storage_service.dart          StorageService + Firebase/Fake + provider
lib/shared/widgets/app_field.dart              + modo multiline
lib/shared/content/icon_picker.dart            grid de ícones selecionável
lib/features/admin/screens/admin_hub_screen.dart          hub com cards
lib/features/admin/screens/admin_content_list_screen.dart lista de páginas
lib/features/admin/screens/admin_content_edit_screen.dart editor (criar/editar/excluir)
lib/shared/content/media_uploader.dart         upload imagem / link vídeo
lib/core/router/app_router.dart                rotas /admin (hub), /admin/vagas, /admin/conteudo[/editar]
storage.rules                                  novo
firebase.json                                  registra storage.rules (criar/atualizar)
test/data/content_admin_repo_test.dart
test/data/content_id_test.dart
test/data/storage_service_test.dart
test/features/admin_content_edit_test.dart
```

---

### Task 1: Adicionar dependência image_picker

**Files:** Modify `pubspec.yaml`

- [ ] **Step 1:** Em `pubspec.yaml`, na seção `dependencies:`, após `firebase_storage:`, adicionar:
```yaml
  image_picker: ^1.1.2
```
- [ ] **Step 2:** Rodar `flutter pub get`. Esperado: resolve sem conflito.
- [ ] **Step 3:** `flutter analyze` → sem novos erros.
- [ ] **Step 4:** Commit — `git add pubspec.yaml pubspec.lock && git commit -m "build: adiciona image_picker para upload de midia"`

---

### Task 2: Repositório — escrita de contentDocs

**Files:** Modify `universe_repository.dart`, `firestore_universe_repository.dart`, `fake_universe_repository.dart`, `repository_provider.dart`; Test `test/data/content_admin_repo_test.dart`

- [ ] **Step 1: Teste (FALHA primeiro)** — `test/data/content_admin_repo_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/content_doc.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';

ContentDoc _doc(String id, ContentKind k) => ContentDoc(
      id: id, kind: k, icon: 'doc', title: 'T $id', tag: 'x', summary: 's',
      updatedAt: DateTime(2026, 1, 1), sections: const [RichSection(body: 'b')]);

void main() {
  test('upsert insere e atualiza; delete remove; watchAll retorna todos', () async {
    final repo = FakeUniverseRepository();
    final before = (await repo.watchAllContentDocs().first).length;

    await repo.upsertContentDoc(_doc('gov-novo', ContentKind.gov));
    var all = await repo.watchAllContentDocs().first;
    expect(all.length, before + 1);
    expect(all.firstWhere((d) => d.id == 'gov-novo').title, 'T gov-novo');

    await repo.upsertContentDoc(_doc('gov-novo', ContentKind.gov)..toString());
    await repo.upsertContentDoc(ContentDoc(
      id: 'gov-novo', kind: ContentKind.gov, icon: 'doc', title: 'EDIT', tag: 'x',
      summary: 's', updatedAt: DateTime(2026, 1, 2), sections: const [RichSection(body: 'b')]));
    all = await repo.watchAllContentDocs().first;
    expect(all.where((d) => d.id == 'gov-novo').length, 1);
    expect(all.firstWhere((d) => d.id == 'gov-novo').title, 'EDIT');

    await repo.deleteContentDoc('gov-novo');
    all = await repo.watchAllContentDocs().first;
    expect(all.where((d) => d.id == 'gov-novo'), isEmpty);
  });
}
```
- [ ] **Step 2:** `flutter test test/data/content_admin_repo_test.dart` → FAIL (métodos não existem).
- [ ] **Step 3: Interface** — em `universe_repository.dart`, adicionar (junto aos outros de content):
```dart
  Stream<List<ContentDoc>> watchAllContentDocs();
  Future<void> upsertContentDoc(ContentDoc d);
  Future<void> deleteContentDoc(String id);
```
- [ ] **Step 4: Firestore impl** — em `firestore_universe_repository.dart`:
```dart
  @override
  Stream<List<ContentDoc>> watchAllContentDocs() =>
      _db.collection('contentDocs').snapshots().map((s) => _map(s, ContentDoc.fromMap));
  @override
  Future<void> upsertContentDoc(ContentDoc d) =>
      _db.collection('contentDocs').doc(d.id).set(d.toMap());
  @override
  Future<void> deleteContentDoc(String id) => _db.collection('contentDocs').doc(id).delete();
```
- [ ] **Step 5: Fake impl** — em `fake_universe_repository.dart`:
```dart
  @override
  Stream<List<ContentDoc>> watchAllContentDocs() => Stream.value(List.of(_contentDocs));
  @override
  Future<void> upsertContentDoc(ContentDoc d) async {
    final i = _contentDocs.indexWhere((e) => e.id == d.id);
    if (i >= 0) { _contentDocs[i] = d; } else { _contentDocs.add(d); }
  }
  @override
  Future<void> deleteContentDoc(String id) async => _contentDocs.removeWhere((e) => e.id == id);
```
(O campo `_contentDocs` já existe e é `final List<ContentDoc>` de instância.)
- [ ] **Step 6: Provider** — em `repository_provider.dart`:
```dart
final allContentDocsProvider = StreamProvider<List<ContentDoc>>((ref) => ref.watch(universeRepositoryProvider).watchAllContentDocs());
```
- [ ] **Step 7:** `flutter test test/data/content_admin_repo_test.dart` → PASS. `flutter analyze` → limpo.
- [ ] **Step 8:** Commit — `git add lib/data/repositories/ lib/core/providers/repository_provider.dart test/data/content_admin_repo_test.dart && git commit -m "feat(admin): escrita de contentDocs no repositorio + allContentDocsProvider"`

---

### Task 3: Util de slug/id

**Files:** Create `lib/data/content/content_id.dart`; Test `test/data/content_id_test.dart`

- [ ] **Step 1: Teste (FALHA)** — `test/data/content_id_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/content/content_id.dart';
import 'package:universe_app/data/models/content_doc.dart';

void main() {
  test('slugify normaliza acentos, espaços e símbolos', () {
    expect(slugify('Cadastro Único'), 'cadastro-unico');
    expect(slugify('PAP — Auxílio Permanência'), 'pap-auxilio-permanencia');
    expect(slugify('  Olá!! Mundo  '), 'ola-mundo');
  });

  test('generateDocId prefixa por kind e evita colisão', () {
    expect(generateDocId(ContentKind.gov, 'ID Jovem', const {}), 'gov-id-jovem');
    expect(generateDocId(ContentKind.inst, 'Monitoria', const {'inst-monitoria'}), 'inst-monitoria-2');
    expect(generateDocId(ContentKind.gov, 'X', const {'gov-x', 'gov-x-2'}), 'gov-x-3');
  });
}
```
- [ ] **Step 2:** `flutter test test/data/content_id_test.dart` → FAIL.
- [ ] **Step 3: Implementar** — `lib/data/content/content_id.dart`:
```dart
import '../models/content_doc.dart';

const _accents = {
  'á':'a','à':'a','â':'a','ã':'a','ä':'a','é':'e','è':'e','ê':'e','ë':'e',
  'í':'i','ì':'i','î':'i','ï':'i','ó':'o','ò':'o','ô':'o','õ':'o','ö':'o',
  'ú':'u','ù':'u','û':'u','ü':'u','ç':'c','ñ':'n',
};

/// Converte um texto em slug ASCII minúsculo com hífens.
String slugify(String input) {
  var s = input.toLowerCase().trim();
  s = s.split('').map((ch) => _accents[ch] ?? ch).join();
  s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  s = s.replaceAll(RegExp(r'-+'), '-');
  s = s.replaceAll(RegExp(r'^-|-$'), '');
  return s;
}

/// Gera um id único `<kind>-<slug>` evitando os ids já existentes.
String generateDocId(ContentKind kind, String title, Set<String> existing) {
  final base = '${kind.name}-${slugify(title)}';
  if (!existing.contains(base)) return base;
  var n = 2;
  while (existing.contains('$base-$n')) {
    n++;
  }
  return '$base-$n';
}
```
- [ ] **Step 4:** `flutter test test/data/content_id_test.dart` → PASS. `flutter analyze` → limpo.
- [ ] **Step 5:** Commit — `git add lib/data/content/content_id.dart test/data/content_id_test.dart && git commit -m "feat(admin): util de slug/id para contentDocs"`

---

### Task 4: StorageService (upload de imagem)

**Files:** Create `lib/data/storage/storage_service.dart`; Test `test/data/storage_service_test.dart`

- [ ] **Step 1: Teste (FALHA)** — `test/data/storage_service_test.dart`:
```dart
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/storage/storage_service.dart';

void main() {
  test('FakeStorageService retorna URL não vazia', () async {
    final s = FakeStorageService();
    final url = await s.uploadContentImage(Uint8List.fromList([1, 2, 3]), ext: 'png');
    expect(url, isNotEmpty);
    expect(url.startsWith('http'), isTrue);
  });
}
```
- [ ] **Step 2:** `flutter test test/data/storage_service_test.dart` → FAIL.
- [ ] **Step 3: Implementar** — `lib/data/storage/storage_service.dart`:
```dart
import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// Upload de mídia do app (camada de dados).
abstract interface class StorageService {
  /// Sobe uma imagem e devolve a URL pública (de leitura) dela.
  Future<String> uploadContentImage(Uint8List bytes, {required String ext, void Function(double progress)? onProgress});
}

String _uuid() {
  final r = Random();
  final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  final rand = List.generate(6, (_) => r.nextInt(16).toRadixString(16)).join();
  return '$ts$rand';
}

class FirebaseStorageService implements StorageService {
  FirebaseStorageService(this._storage);
  final FirebaseStorage _storage;

  @override
  Future<String> uploadContentImage(Uint8List bytes, {required String ext, void Function(double)? onProgress}) async {
    final safeExt = ext.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    final ref = _storage.ref('content_images/${_uuid()}.${safeExt.isEmpty ? 'jpg' : safeExt}');
    final task = ref.putData(bytes, SettableMetadata(contentType: 'image/${safeExt == 'jpg' ? 'jpeg' : safeExt}'));
    if (onProgress != null) {
      task.snapshotEvents.listen((s) {
        if (s.totalBytes > 0) onProgress(s.bytesTransferred / s.totalBytes);
      });
    }
    await task;
    return ref.getDownloadURL();
  }
}

class FakeStorageService implements StorageService {
  @override
  Future<String> uploadContentImage(Uint8List bytes, {required String ext, void Function(double)? onProgress}) async {
    onProgress?.call(1.0);
    return 'https://fake.storage/content_images/${_uuid()}.$ext';
  }
}
```
- [ ] **Step 4: Provider** — adicionar em `lib/core/providers/repository_provider.dart`:
```dart
// (no topo) import 'package:firebase_storage/firebase_storage.dart';
//           import '../../data/storage/storage_service.dart';
final storageServiceProvider = Provider<StorageService>((ref) => FirebaseStorageService(FirebaseStorage.instance));
```
- [ ] **Step 5:** `flutter test test/data/storage_service_test.dart` → PASS. `flutter analyze` → limpo.
- [ ] **Step 6:** Commit — `git add lib/data/storage/ lib/core/providers/repository_provider.dart test/data/storage_service_test.dart && git commit -m "feat(admin): StorageService (upload de imagem ao Firebase Storage)"`

---

### Task 5: AppField multiline + IconPicker

**Files:** Modify `lib/shared/widgets/app_field.dart`; Create `lib/shared/content/icon_picker.dart`

- [ ] **Step 1: AppField multiline** — em `app_field.dart`, adicionar o parâmetro `multiline` e adaptar o container. Substituir a declaração do construtor e os campos:
```dart
  final String? label, hint, icon, error;
  final String value;
  final ValueChanged<String> onChanged;
  final bool obscure, valid, multiline;
  final Widget? trailing;
  final TextInputType? keyboardType;
  const AppField({
    super.key, this.label, this.hint, this.icon, this.error,
    required this.value, required this.onChanged,
    this.obscure = false, this.valid = false, this.multiline = false,
    this.trailing, this.keyboardType,
  });
```
Trocar o `Container` do campo (o que tem `height: 50`) por uma versão que respeita `multiline`:
```dart
      Container(
        constraints: BoxConstraints(minHeight: widget.multiline ? 92 : 50),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: widget.multiline ? 12 : 0),
        decoration: BoxDecoration(
          color: c.card, borderRadius: BorderRadius.circular(13),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(crossAxisAlignment: widget.multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: [
          if (widget.icon != null) ...[
            Icon(appIcon(widget.icon!), size: 19, color: _focus ? c.green600 : c.ink3),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Focus(
              onFocusChange: (f) => setState(() => _focus = f),
              child: TextField(
                controller: _ctrl,
                onChanged: widget.onChanged,
                obscureText: widget.obscure,
                keyboardType: widget.multiline ? TextInputType.multiline : widget.keyboardType,
                minLines: widget.multiline ? 3 : 1,
                maxLines: widget.multiline ? null : 1,
                style: TextStyle(fontSize: 15, color: c.ink, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  isCollapsed: true, border: InputBorder.none,
                  hintText: widget.hint,
                  hintStyle: TextStyle(fontSize: 14, color: c.ink3, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
          if (widget.valid && widget.trailing == null) Icon(Icons.check, size: 18, color: c.green500),
          if (widget.trailing != null) widget.trailing!,
        ]),
      ),
```
- [ ] **Step 2:** `flutter test` (suite inteira) → ainda PASS (mudança retrocompatível: `multiline` default false). `flutter analyze` → limpo.
- [ ] **Step 3: IconPicker** — `lib/shared/content/icon_picker.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/icon_tile.dart';

/// Ícones oferecidos ao admin para representar uma página de conteúdo.
const contentIconChoices = <String>[
  'card', 'user', 'bus', 'doc', 'benefits', 'award', 'book', 'globe',
  'institution', 'briefcase', 'flag', 'star', 'shield', 'phone', 'mail', 'cap', 'house', 'settings',
];

/// Grid de ícones selecionável (sem digitar nomes).
class IconPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const IconPicker({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: [
        for (final name in contentIconChoices)
          GestureDetector(
            onTap: () => onSelect(name),
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: name == selected ? c.green800 : c.bg2,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: name == selected ? c.green800 : c.line, width: 1.5),
              ),
              child: Icon(appIcon(name), size: 23, color: name == selected ? Colors.white : c.ink2),
            ),
          ),
      ],
    );
  }
}
```
- [ ] **Step 4:** `flutter analyze lib/shared/widgets/app_field.dart lib/shared/content/icon_picker.dart` → limpo.
- [ ] **Step 5:** Commit — `git add lib/shared/widgets/app_field.dart lib/shared/content/icon_picker.dart && git commit -m "feat(admin): AppField multiline + IconPicker"`

---

### Task 6: Hub admin + reestruturação de rotas

**Files:** Create `lib/features/admin/screens/admin_hub_screen.dart`; Modify `lib/core/router/app_router.dart`

- [ ] **Step 1: Hub** — `lib/features/admin/screens/admin_hub_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/icon_tile.dart';

class AdminHubScreen extends StatelessWidget {
  const AdminHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final cards = <({String icon, String title, String sub, String route})>[
      (icon: 'briefcase', title: 'Vagas e concursos', sub: 'Estágios, jovem aprendiz e concursos', route: '/admin/vagas'),
      (icon: 'book', title: 'Páginas de conteúdo', sub: 'Edite os benefícios que os alunos veem', route: '/admin/conteudo'),
    ];
    return PageShell(
      bodyPadding: const EdgeInsets.all(16),
      header: GreenHero(title: 'Painel administrativo', subtitle: 'Setor de Estágios e Comunicação', icon: 'shield', onBack: () => context.pop()),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('O que você publica aparece para os alunos na hora.', style: TextStyle(fontSize: 12.5, color: c.ink3)),
        const SizedBox(height: 14),
        for (final card in cards) Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: AppCard(
            onTap: () => context.push(card.route),
            child: Row(children: [
              IconTile(card.icon, size: 50),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(card.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
                const SizedBox(height: 2),
                Text(card.sub, style: TextStyle(fontSize: 12, color: c.ink3)),
              ])),
              Icon(appIcon('chevR'), size: 18, color: c.ink3),
            ]),
          ),
        ),
      ]),
    );
  }
}
```
- [ ] **Step 2: Router** — em `app_router.dart`:
  - Adicionar imports: `import '../../features/admin/screens/admin_hub_screen.dart';`, `import '../../features/admin/screens/admin_content_list_screen.dart';`, `import '../../features/admin/screens/admin_content_edit_screen.dart';`.
  - Trocar a rota `/admin` (que apontava para `AdminPanelScreen`) por:
```dart
      GoRoute(path: '/admin', pageBuilder: (c, s) => fadeSlide(s, const AdminHubScreen())),
      GoRoute(path: '/admin/vagas', pageBuilder: (c, s) => fadeSlide(s, const AdminPanelScreen())),
      GoRoute(path: '/admin/conteudo', pageBuilder: (c, s) => fadeSlide(s, const AdminContentListScreen())),
      GoRoute(path: '/admin/conteudo/editar', pageBuilder: (c, s) => fadeSlide(s, AdminContentEditScreen(doc: s.extra is ContentDoc ? s.extra as ContentDoc : null))),
```
  - Garantir o import de `ContentDoc` (`import '../../data/models/content_doc.dart';` — já deve existir do SP3a; se não, adicionar).
  - Manter as rotas `/admin/vaga` e `/admin/concurso` como estão.
- [ ] **Step 3:** Como `AdminContentListScreen`/`AdminContentEditScreen` ainda não existem, este passo só compila após as Tasks 7–8. **Não commitar ainda** — seguir para a Task 7 e commitar o hub+rotas junto da lista (Task 7 Step final). (Se preferir compilar agora: criar stubs vazios; mas a ordem recomendada é commitar Task 6+7 juntas.)

> NOTA de execução: as Tasks 6, 7 e 8 são interdependentes (rotas ↔ telas). Implemente 6→7→8 e rode `flutter analyze` ao final da 8; faça os commits ao fim de cada uma quando compilar. Para evitar estado não-compilável, crie as telas (7 e 8) antes de rodar o analyze do router.

---

### Task 7: Lista de páginas (AdminContentListScreen)

**Files:** Create `lib/features/admin/screens/admin_content_list_screen.dart`

- [ ] **Step 1: Implementar**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_doc.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/icon_tile.dart';

class AdminContentListScreen extends ConsumerWidget {
  const AdminContentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final docsAsync = ref.watch(allContentDocsProvider);

    Widget group(String label, List<ContentDoc> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(2, 4, 2, 9),
          child: Text(label.toUpperCase(), style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: c.ink3))),
        for (final d in items) Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            onTap: () => context.push('/admin/conteudo/editar', extra: d),
            child: Row(children: [
              IconTile(d.icon, size: 44),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink)),
                const SizedBox(height: 2),
                Text('${d.sections.length} seções · atualizado ${d.updatedAt.day.toString().padLeft(2, '0')}/${d.updatedAt.month.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 11, color: c.ink3)),
              ])),
              Icon(appIcon('edit'), size: 19, color: c.green700),
            ]),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: 'Páginas de conteúdo', subtitle: 'Edite o que os alunos veem', icon: 'book', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppButton('Nova página', full: true, icon: 'plus',
            onTap: () => context.push('/admin/conteudo/editar')),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(13)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(appIcon('book'), size: 18, color: c.green700),
              const SizedBox(width: 10),
              Expanded(child: Text('Use [[colchetes duplos]] no texto para criar links internos. Ex.: [[PIBIC]] vira link para a página de Iniciação Científica.',
                  style: TextStyle(fontSize: 12, height: 1.5, color: c.ink2))),
            ]),
          ),
          const SizedBox(height: 18),
          AsyncListView<ContentDoc>(
            value: docsAsync,
            onRetry: () => ref.invalidate(allContentDocsProvider),
            emptyTitle: 'Nenhuma página ainda',
            data: (docs) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              group('Governamentais', docs.where((d) => d.kind == ContentKind.gov).toList()),
              group('Institucionais', docs.where((d) => d.kind == ContentKind.inst).toList()),
            ]),
          ),
        ]),
      ),
    );
  }
}
```
- [ ] **Step 2:** `flutter analyze lib/features/admin/screens/admin_content_list_screen.dart lib/features/admin/screens/admin_hub_screen.dart` → limpo (ignora erro do router enquanto o editor da Task 8 não existir).

---

### Task 8: MediaUploader

**Files:** Create `lib/shared/content/media_uploader.dart`

- [ ] **Step 1: Implementar** — opera sobre um mapa de seção `media` (`mediaType`/`imageUrl`/`videoUrl`), chamando `onChange` com o mapa atualizado:
```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/providers/repository_provider.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/app_field.dart';
import '../widgets/icon_tile.dart';

/// Editor de mídia de uma seção: imagem (upload) ou vídeo (link).
class MediaUploader extends ConsumerStatefulWidget {
  final String mediaType; // 'image' | 'video'
  final String? imageUrl, videoUrl;
  final void Function({required String mediaType, String? imageUrl, String? videoUrl}) onChange;
  const MediaUploader({super.key, required this.mediaType, this.imageUrl, this.videoUrl, required this.onChange});

  @override
  ConsumerState<MediaUploader> createState() => _MediaUploaderState();
}

class _MediaUploaderState extends ConsumerState<MediaUploader> {
  bool _uploading = false;
  String? _error;

  Future<void> _pick() async {
    setState(() { _error = null; });
    try {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
      if (x == null) return;
      setState(() => _uploading = true);
      final bytes = await x.readAsBytes();
      final ext = x.name.contains('.') ? x.name.split('.').last : 'jpg';
      final url = await ref.read(storageServiceProvider).uploadContentImage(bytes, ext: ext);
      widget.onChange(mediaType: 'image', imageUrl: url, videoUrl: null);
    } catch (e) {
      setState(() => _error = 'Falha no upload. Tente novamente.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isImage = widget.mediaType == 'image';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Alternância imagem / vídeo
      Row(children: [
        for (final opt in const [('image', 'Imagem'), ('video', 'Vídeo')])
          Expanded(child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => widget.onChange(mediaType: opt.$1, imageUrl: widget.imageUrl, videoUrl: widget.videoUrl),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.mediaType == opt.$1 ? c.green800 : c.bg2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(opt.$2, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: widget.mediaType == opt.$1 ? Colors.white : c.ink2)),
              ),
            ),
          )),
      ]),
      const SizedBox(height: 11),
      if (isImage) ...[
        if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
          ClipRRect(borderRadius: BorderRadius.circular(12), child: CachedNetworkImage(imageUrl: widget.imageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover)),
        const SizedBox(height: 9),
        GestureDetector(
          onTap: _uploading ? null : _pick,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(11)),
            child: _uploading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(appIcon('plus'), size: 17, color: c.green700),
                    const SizedBox(width: 7),
                    Text(widget.imageUrl == null ? 'Escolher imagem' : 'Trocar imagem', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.green700)),
                  ]),
          ),
        ),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 7), child: Text(_error!, style: TextStyle(fontSize: 11.5, color: c.error, fontWeight: FontWeight.w600))),
      ] else
        AppField(
          label: 'Link do vídeo (YouTube/Vimeo)', icon: 'globe',
          value: widget.videoUrl ?? '',
          onChanged: (v) => widget.onChange(mediaType: 'video', imageUrl: null, videoUrl: v),
        ),
    ]);
  }
}
```
- [ ] **Step 2:** `flutter analyze lib/shared/content/media_uploader.dart` → limpo.

---

### Task 9: Editor de página (AdminContentEditScreen)

**Files:** Create `lib/features/admin/screens/admin_content_edit_screen.dart`; Test `test/features/admin_content_edit_test.dart`

- [ ] **Step 1: Implementar a tela**. O editor mantém um rascunho local: campos do doc + `List<Map<String,dynamic>>` das seções (deep copy de `doc.sections.map((s)=>s.toMap())`). Publicar converte de volta via `ContentSection.fromMap`.
`lib/features/admin/screens/admin_content_edit_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/content/content_id.dart';
import '../../../data/models/content_doc.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/content/icon_picker.dart';
import '../../../shared/content/media_uploader.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/icon_tile.dart';

const _sectionTypes = <({String type, String label})>[
  (type: 'rich', label: 'Texto'),
  (type: 'steps', label: 'Passo a passo'),
  (type: 'docs', label: 'Lista / documentos'),
  (type: 'media', label: 'Vídeo / imagem'),
  (type: 'callout', label: 'Destaque'),
  (type: 'faq', label: 'Dúvidas'),
  (type: 'sources', label: 'Fontes oficiais'),
];

String _labelOf(String type) => _sectionTypes.firstWhere((e) => e.type == type, orElse: () => (type: type, label: type)).label;

Map<String, dynamic> _newSection(String type) => switch (type) {
  'rich' => {'type': 'rich', 'heading': 'Novo título', 'body': 'Escreva aqui. Use [[termos]] para links internos.'},
  'steps' => {'type': 'steps', 'heading': 'Como solicitar', 'items': ['Primeiro passo', 'Segundo passo']},
  'docs' => {'type': 'docs', 'heading': 'Documentos necessários', 'items': ['Documento 1']},
  'media' => {'type': 'media', 'mediaType': 'image', 'heading': 'Vídeo ou imagem', 'caption': ''},
  'callout' => {'type': 'callout', 'variant': 'info', 'body': 'Aviso importante.'},
  'faq' => {'type': 'faq', 'heading': 'Dúvidas frequentes', 'items': [{'q': 'Pergunta?', 'a': 'Resposta.'}]},
  'sources' => {'type': 'sources', 'heading': 'Canais oficiais', 'items': [{'label': 'Site oficial', 'url': 'gov.br'}]},
  _ => {'type': 'rich', 'heading': '', 'body': ''},
};

class AdminContentEditScreen extends ConsumerStatefulWidget {
  final ContentDoc? doc;
  const AdminContentEditScreen({super.key, required this.doc});
  @override
  ConsumerState<AdminContentEditScreen> createState() => _AdminContentEditScreenState();
}

class _AdminContentEditScreenState extends ConsumerState<AdminContentEditScreen> {
  late String _title, _tag, _summary, _icon;
  late ContentKind _kind;
  late List<Map<String, dynamic>> _sections;
  bool get _isNew => widget.doc == null;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.doc;
    _title = d?.title ?? '';
    _tag = d?.tag ?? '';
    _summary = d?.summary ?? '';
    _icon = d?.icon ?? 'doc';
    _kind = d?.kind ?? ContentKind.gov;
    _sections = (d?.sections ?? const <ContentSection>[]).map((s) => _deep(s.toMap())).toList();
  }

  Map<String, dynamic> _deep(Map<String, dynamic> m) => {
    for (final e in m.entries)
      e.key: e.value is List
          ? [for (final i in e.value as List) i is Map ? Map<String, dynamic>.from(i) : i]
          : e.value,
  };

  void _mut(VoidCallback fn) => setState(fn);
  void _move(int i, int dir) {
    final j = i + dir;
    if (j < 0 || j >= _sections.length) return;
    _mut(() { final t = _sections[i]; _sections[i] = _sections[j]; _sections[j] = t; });
  }

  Future<void> _publish() async {
    if (_title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um título.')));
      return;
    }
    if (_sections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicione ao menos uma seção.')));
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(universeRepositoryProvider);
    final existingIds = (ref.read(allContentDocsProvider).valueOrNull ?? const <ContentDoc>[]).map((d) => d.id).toSet();
    final id = _isNew ? generateDocId(_kind, _title, existingIds) : widget.doc!.id;
    final doc = ContentDoc(
      id: id, kind: _kind, icon: _icon, title: _title.trim(), tag: _tag.trim(), summary: _summary.trim(),
      updatedAt: DateTime.now(),
      sections: _sections.map((m) => ContentSection.fromMap(Map<String, dynamic>.from(m))).whereType<ContentSection>().toList(),
    );
    await repo.upsertContentDoc(doc);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conteúdo publicado!')));
      context.pop();
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Excluir página'),
      content: Text('Excluir "$_title"? Esta ação não pode ser desfeita.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Excluir')),
      ],
    ));
    if (ok == true) {
      await ref.read(universeRepositoryProvider).deleteContentDoc(widget.doc!.id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Página excluída'))); context.pop(); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: _isNew ? 'Nova página' : 'Editar página', subtitle: _isNew ? null : _title, icon: 'edit', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Cabeçalho do doc
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_isNew) ...[
              Text('Tipo', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
              const SizedBox(height: 7),
              Row(children: [
                for (final k in ContentKind.values) Expanded(child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _mut(() => _kind = k),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9), alignment: Alignment.center,
                      decoration: BoxDecoration(color: _kind == k ? c.green800 : c.bg2, borderRadius: BorderRadius.circular(10)),
                      child: Text(k == ContentKind.gov ? 'Governamental' : 'Institucional', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _kind == k ? Colors.white : c.ink2)),
                    ),
                  ),
                )),
              ]),
              const SizedBox(height: 12),
            ],
            AppField(label: 'Título', icon: 'edit', value: _title, onChanged: (v) => _mut(() => _title = v)),
            const SizedBox(height: 11),
            AppField(label: 'Etiqueta (tag)', value: _tag, onChanged: (v) => _mut(() => _tag = v)),
            const SizedBox(height: 11),
            AppField(label: 'Resumo (aparece na lista)', multiline: true, value: _summary, onChanged: (v) => _mut(() => _summary = v)),
            const SizedBox(height: 13),
            Text('Ícone', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
            const SizedBox(height: 9),
            IconPicker(selected: _icon, onSelect: (n) => _mut(() => _icon = n)),
          ])),
          const SizedBox(height: 14),
          // Seções
          for (var i = 0; i < _sections.length; i++) Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SectionEditor(
              key: ValueKey(_sections[i]),
              section: _sections[i],
              first: i == 0, last: i == _sections.length - 1,
              onUp: () => _move(i, -1), onDown: () => _move(i, 1),
              onDelete: () => _mut(() => _sections.removeAt(i)),
              onChanged: () => _mut(() {}),
            ),
          ),
          // Adicionar seção
          _AddSection(onAdd: (type) => _mut(() => _sections.add(_newSection(type)))),
          const SizedBox(height: 18),
          AppButton(_saving ? 'Publicando…' : 'Publicar', full: true, icon: 'check', onTap: _saving ? null : _publish),
          if (!_isNew) ...[
            const SizedBox(height: 10),
            AppButton('Excluir página', full: true, variant: AppButtonVariant.outline, onTap: _delete),
          ],
          const SizedBox(height: 10),
          Center(child: Text('A data de atualização será definida para hoje.', style: TextStyle(fontSize: 11, color: c.ink3))),
        ]),
      ),
    );
  }
}

/// Editor de uma seção (muta o mapa in-place; chama onChanged p/ rebuild).
class _SectionEditor extends StatelessWidget {
  final Map<String, dynamic> section;
  final bool first, last;
  final VoidCallback onUp, onDown, onDelete, onChanged;
  const _SectionEditor({super.key, required this.section, required this.first, required this.last, required this.onUp, required this.onDown, required this.onDelete, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final type = section['type'] as String;
    Widget headerRow = Row(children: [
      Expanded(child: Text(_labelOf(type).toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: c.ink3))),
      IconButton(onPressed: first ? null : onUp, icon: const Icon(Icons.keyboard_arrow_up), iconSize: 20, color: c.ink3),
      IconButton(onPressed: last ? null : onDown, icon: const Icon(Icons.keyboard_arrow_down), iconSize: 20, color: c.ink3),
      IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline), iconSize: 19, color: c.error),
    ]);

    final children = <Widget>[headerRow];
    if (section.containsKey('heading')) {
      children.add(Padding(padding: const EdgeInsets.only(top: 6), child: AppField(
        hint: 'Título da seção', value: (section['heading'] ?? '') as String,
        onChanged: (v) { section['heading'] = v; onChanged(); })));
    }

    if (type == 'rich' || type == 'callout') {
      children.add(const SizedBox(height: 10));
      children.add(AppField(label: type == 'callout' ? 'Texto do destaque' : 'Texto', multiline: true,
        value: (section['body'] ?? '') as String, onChanged: (v) { section['body'] = v; onChanged(); }));
    }
    if (type == 'callout') {
      children.add(const SizedBox(height: 10));
      children.add(Row(children: [
        for (final v in const [('info', 'Informação'), ('warn', 'Atenção')]) Expanded(child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () { section['variant'] = v.$1; onChanged(); },
            child: Container(padding: const EdgeInsets.symmetric(vertical: 9), alignment: Alignment.center,
              decoration: BoxDecoration(color: section['variant'] == v.$1 ? c.green800 : c.bg2, borderRadius: BorderRadius.circular(10)),
              child: Text(v.$2, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: section['variant'] == v.$1 ? Colors.white : c.ink2))),
          ),
        )),
      ]));
    }
    if (type == 'steps' || type == 'docs') {
      final items = List<String>.from(section['items'] ?? const []);
      children.add(const SizedBox(height: 10));
      children.add(AppField(label: 'Itens (um por linha)', multiline: true, value: items.join('\n'),
        onChanged: (v) { section['items'] = v.split('\n').where((e) => e.trim().isNotEmpty).toList(); onChanged(); }));
    }
    if (type == 'media') {
      children.add(const SizedBox(height: 10));
      children.add(MediaUploader(
        mediaType: (section['mediaType'] ?? 'image') as String,
        imageUrl: section['imageUrl'] as String?, videoUrl: section['videoUrl'] as String?,
        onChange: ({required mediaType, imageUrl, videoUrl}) { section['mediaType'] = mediaType; section['imageUrl'] = imageUrl; section['videoUrl'] = videoUrl; onChanged(); }));
      children.add(const SizedBox(height: 10));
      children.add(AppField(hint: 'Legenda (opcional)', value: (section['caption'] ?? '') as String,
        onChanged: (v) { section['caption'] = v; onChanged(); }));
    }
    if (type == 'faq') {
      final items = (section['items'] as List).cast<Map>();
      for (var j = 0; j < items.length; j++) {
        children.add(const SizedBox(height: 10));
        children.add(AppField(hint: 'Pergunta', value: (items[j]['q'] ?? '') as String, onChanged: (v) { items[j]['q'] = v; onChanged(); }));
        children.add(const SizedBox(height: 6));
        children.add(AppField(hint: 'Resposta', multiline: true, value: (items[j]['a'] ?? '') as String, onChanged: (v) { items[j]['a'] = v; onChanged(); }));
      }
      children.add(Align(alignment: Alignment.centerLeft, child: TextButton.icon(
        onPressed: () { items.add({'q': 'Pergunta?', 'a': 'Resposta.'}); section['items'] = items; onChanged(); },
        icon: Icon(appIcon('plus'), size: 16, color: c.green700), label: Text('Adicionar pergunta', style: TextStyle(color: c.green700, fontWeight: FontWeight.w700, fontSize: 12.5)))));
    }
    if (type == 'sources') {
      final items = (section['items'] as List).cast<Map>();
      for (var j = 0; j < items.length; j++) {
        children.add(const SizedBox(height: 10));
        children.add(AppField(hint: 'Nome', value: (items[j]['label'] ?? '') as String, onChanged: (v) { items[j]['label'] = v; onChanged(); }));
        children.add(const SizedBox(height: 6));
        children.add(AppField(hint: 'endereco.gov.br', value: (items[j]['url'] ?? '') as String, onChanged: (v) { items[j]['url'] = v; onChanged(); }));
      }
      children.add(Align(alignment: Alignment.centerLeft, child: TextButton.icon(
        onPressed: () { items.add({'label': 'Site oficial', 'url': 'gov.br'}); section['items'] = items; onChanged(); },
        icon: Icon(appIcon('plus'), size: 16, color: c.green700), label: Text('Adicionar fonte', style: TextStyle(color: c.green700, fontWeight: FontWeight.w700, fontSize: 12.5)))));
    }

    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));
  }
}

class _AddSection extends StatefulWidget {
  final ValueChanged<String> onAdd;
  const _AddSection({required this.onAdd});
  @override
  State<_AddSection> createState() => _AddSectionState();
}

class _AddSectionState extends State<_AddSection> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    if (!_open) {
      return AppButton('Adicionar seção', full: true, variant: AppButtonVariant.outline, icon: 'plus', onTap: () => setState(() => _open = true));
    }
    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('TIPO DE SEÇÃO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c.ink3)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final s in _sectionTypes)
          GestureDetector(
            onTap: () { widget.onAdd(s.type); setState(() => _open = false); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: c.bg2, borderRadius: BorderRadius.circular(11)),
              child: Text(s.label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink)),
            ),
          ),
      ]),
      const SizedBox(height: 8),
      TextButton(onPressed: () => setState(() => _open = false), child: Text('Cancelar', style: TextStyle(color: c.ink3))),
    ]));
  }
}
```
- [ ] **Step 2: Teste (widget smoke)** — `test/features/admin_content_edit_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/providers/repository_provider.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/models/content_doc.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';
import 'package:universe_app/data/repositories/universe_repository.dart';
import 'package:universe_app/data/storage/storage_service.dart';
import 'package:universe_app/features/admin/screens/admin_content_edit_screen.dart';

void main() {
  testWidgets('adicionar seção aumenta a contagem do rascunho', (t) async {
    final repo = FakeUniverseRepository();
    await t.pumpWidget(ProviderScope(
      overrides: [
        universeRepositoryProvider.overrideWithValue(repo),
        storageServiceProvider.overrideWithValue(FakeStorageService()),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const AdminContentEditScreen(doc: null)),
    ));
    await t.pumpAndSettle();

    expect(find.text('Adicionar seção'), findsOneWidget);
    await t.tap(find.text('Adicionar seção'));
    await t.pumpAndSettle();
    // escolhe "Texto"
    await t.tap(find.text('Texto').last);
    await t.pumpAndSettle();
    // a seção de texto agora aparece (rótulo TEXTO no card)
    expect(find.text('TEXTO'), findsOneWidget);
  });

  testWidgets('publicar nova página chama upsert com updatedAt de hoje', (t) async {
    final repo = FakeUniverseRepository();
    await t.pumpWidget(ProviderScope(
      overrides: [
        universeRepositoryProvider.overrideWithValue(repo),
        storageServiceProvider.overrideWithValue(FakeStorageService()),
      ],
      child: const MaterialApp(home: _Harness()),
    ));
    await t.pumpAndSettle();

    // preenche título
    await t.enterText(find.byType(TextField).first, 'Página Teste');
    // adiciona uma seção de texto
    await t.tap(find.text('Adicionar seção'));
    await t.pumpAndSettle();
    await t.tap(find.text('Texto').last);
    await t.pumpAndSettle();
    // publica
    await t.tap(find.text('Publicar'));
    await t.pumpAndSettle();

    final all = await repo.watchAllContentDocs().first;
    final created = all.where((d) => d.title == 'Página Teste');
    expect(created, isNotEmpty);
    expect(created.first.updatedAt.day, DateTime.now().day);
  });
}

class _Harness extends StatelessWidget {
  const _Harness();
  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.light,
    child: const Scaffold(body: AdminContentEditScreen(doc: null)),
  );
}
```
> Nota: se o `find.text('Texto')` ambíguo causar problema, usar `find.widgetWithText(GestureDetector, 'Texto')`. O harness garante o tema. Caso `context.pop()` exija um Navigator/GoRouter no segundo teste, envolver em `MaterialApp(home: Navigator(onGenerateRoute: ...))` ou usar `MaterialApp.router`; ajuste mínimo aceitável é checar o `upsert` antes do pop (o `await repo...` ocorre após `pop`, mas o estado do Fake já foi alterado no `_publish` antes do pop).
- [ ] **Step 3:** Rodar `flutter test test/features/admin_content_edit_test.dart`. Se o segundo teste falhar por causa do `context.pop()` sem rota, simplificar: remover o `context.pop()` do fluxo de teste envolvendo a tela em um `MaterialApp` com `home` e uma rota inicial que permita pop, OU asseverar o efeito no repo (o upsert ocorre antes do pop). Garantir AMBOS verdes.
- [ ] **Step 4: Fechar a Task 6** — agora que as telas existem, rodar `flutter analyze` (projeto todo) → **0 erros**. Conferir o router compila.
- [ ] **Step 5:** Commit — `git add -A && git commit -m "feat(admin): editor de conteudo (criar/editar/excluir paginas e secoes) + hub + lista + MediaUploader"`

---

### Task 10: Regras do Storage

**Files:** Create `storage.rules`; Modify/Create `firebase.json`

- [ ] **Step 1: storage.rules** — criar na raiz:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    function signedIn() { return request.auth != null; }
    function isAdmin() {
      return signedIn() && firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    match /content_images/{file} {
      allow read: if signedIn();
      allow write: if isAdmin();
    }
  }
}
```
- [ ] **Step 2: firebase.json** — se existir, adicionar a chave `"storage": { "rules": "storage.rules" }`; se não existir, criar:
```json
{
  "firestore": { "rules": "firestore.rules" },
  "storage": { "rules": "storage.rules" }
}
```
(Se `firebase.json` já tiver outras chaves, apenas inserir a chave `storage` sem remover as demais.)
- [ ] **Step 3:** `flutter analyze` → inalterado (arquivos de config não afetam). Commit — `git add storage.rules firebase.json && git commit -m "chore(rules): storage.rules (content_images: leitura logada, escrita admin)"`

> **Passo operacional do usuário:** publicar as regras de Storage no console Firebase (ou `firebase deploy --only storage`) — sem isso o upload falha.

---

### Task 11: Verificação + diário

- [ ] **Step 1:** `flutter analyze` → 0 erros. `flutter test` → todos PASS.
- [ ] **Step 2:** Execução no navegador (admin): **Menu/escudo → Painel administrativo** → "Páginas de conteúdo" → editar um benefício (mudar título, reordenar uma seção, **trocar a imagem** numa seção de mídia → upload) → **Publicar** → conferir que a tela do aluno reflete a mudança. Criar uma **nova página** (escolher tipo, ícone, adicionar seções) e conferir na aba Benefícios. (Requer regras de Storage publicadas.)
- [ ] **Step 3:** Diário — nova entrada SP3b (editor de conteúdo + upload). Seguir o estilo das entradas anteriores em `docs/desenvolvimento/diario-de-desenvolvimento.md`.
- [ ] **Step 4:** Commit — `git add docs/ && git commit -m "docs: registra SP3b (editor de conteudo + upload) no diario"`

---

## Self-Review (cobertura da spec)
- **§2 hub/rotas:** Task 6 ✓. **§3 repo/storage:** Tasks 2,4 ✓ (+ id util Task 3). **§4 lista:** Task 7 ✓.
- **§5 editor (criar/editar/excluir/seções):** Task 9 ✓. **§6 seletor de ícone:** Task 5 ✓. **§7 upload:** Tasks 4,8 ✓.
- **§8 regras:** Task 10 ✓. **§9 deps:** Task 1 ✓. **§10 testes:** Tasks 2,3,4,9 ✓.

**Riscos/notas:**
1. **Interdependência 6↔7↔9:** criar as telas antes de rodar o analyze do router (a NOTA na Task 6).
2. **`image_picker` no web:** usa `readAsBytes()` + `putData` (não `putFile`). Já refletido no `MediaUploader`/`StorageService`.
3. **Edição não altera `id`/`kind`** (campos fixos no modo edição) — preserva wikilinks.
4. **Teste do editor + `context.pop()`:** ver a nota na Task 9 Step 2/3 (asseverar o efeito no repo, que ocorre antes do pop).
5. **Rascunho como `List<Map>`:** evita `copyWith` nas 7 classes seladas; conversão final via `ContentSection.fromMap`.
6. **Regras de Storage** exigem publicação manual (passo operacional) — sem isso o upload falha.
