# SP1 — Fundação Firestore · Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrar a leitura do app do `MockUniverseRepository` (dados embutidos) para o **Cloud Firestore em tempo real**, com persistência real de depoimentos/perfil e regras de segurança.

**Architecture:** `UniverseRepository` passa a expor **streams** (`watch…`). `FirestoreUniverseRepository` (produção, via `snapshots()`) e `FakeUniverseRepository` (em memória, para seed/testes). Telas consomem por `StreamProvider` + um widget helper `AsyncView` (loading/erro/vazio/dados). Regras de segurança: aluno lê / admin escreve (campo `role` em `users/{uid}`). Seeder dev sobe o conteúdo do Fake para o Firestore.

**Tech Stack:** cloud_firestore, firebase_auth, flutter_riverpod, shimmer. Sem novas dependências.

**Spec:** `docs/superpowers/specs/2026-06-11-sp1-fundacao-firestore-design.md`.

**Estado atual:** `UniverseRepository` é síncrono (retorna `List`); `MockUniverseRepository` tem o conteúdo. Telas leem listas síncronas. `FirestoreProfileRepository` já existe (perfil). `cloud_firestore` já no pubspec.

---

## Estrutura de arquivos (SP1)

```
lib/data/models/*.dart                 + fromDoc()/toMap() em cada modelo; AppNotification (novo)
lib/data/repositories/universe_repository.dart      interface → streams (watch…)
lib/data/repositories/fake_universe_repository.dart RENOMEIA mock_universe_repository → Fake, streams
lib/data/repositories/firestore_universe_repository.dart  NOVO (snapshots)
lib/data/repositories/seed.dart        seedFirestore(FakeUniverseRepository → Firestore) idempotente
lib/core/providers/repository_provider.dart  → Firestore + StreamProviders derivados
lib/shared/widgets/async_view.dart     AsyncView<T> (loading/erro/vazio/dados)
firestore.rules                        regras de segurança
lib/features/**/screens/*.dart         telas → AsyncView + providers
test/data/firestore_mapping_test.dart  round-trip fromDoc/toMap
```

---

### Task 1: (De)serialização dos modelos

**Files:** Modify `lib/data/models/{course,benefit,internship,contest,testimonial,faq,ifsp_info}.dart`; Create `lib/data/models/app_notification.dart`; Test `test/data/firestore_mapping_test.dart`

Adiciona `toMap()` e `factory fromMap(String id, Map)` a cada modelo (sem acoplar a
`cloud_firestore` nos modelos — recebem `Map<String,dynamic>`; o repositório converte
`DocumentSnapshot`→Map e Timestamp→DateTime). Datas (`closedAt`, `deadline`,
`createdAt`) trafegam como `int` epoch-ms no Map (o repositório Firestore converte
de/para `Timestamp`), mantendo os modelos livres de dependência do Firestore.

- [ ] **Step 1: Escrever o teste de round-trip (FALHA primeiro)**

`test/data/firestore_mapping_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/internship.dart';
import 'package:universe_app/data/models/contest.dart';
import 'package:universe_app/data/models/benefit.dart';
import 'package:universe_app/data/models/course.dart';

void main() {
  test('Internship round-trip toMap/fromMap', () {
    final e = Internship(
      id: 'e1', role: 'Dev', companyName: 'Org', area: 'TI', duration: '12m',
      jobDescription: 'desc', requirements: const ['a'], niceToHave: const ['b'],
      companyDescription: 'sobre', benefits: const ['VT'], grant: 'R\$ 1.000',
      course: 'ADS', mode: 'Híbrido', open: false, closedAt: DateTime(2026, 6, 1),
    );
    final back = Internship.fromMap('e1', e.toMap());
    expect(back.role, 'Dev');
    expect(back.companyName, 'Org');
    expect(back.requirements, ['a']);
    expect(back.open, false);
    expect(back.closedAt, DateTime(2026, 6, 1));
  });

  test('Contest round-trip', () {
    final c = Contest(id: 'c1', role: 'Analista', org: 'IFSP', vagas: '10', salary: 'R\$ 4.000', level: 'Superior', about: 'x', deadline: DateTime(2026, 7, 30));
    final back = Contest.fromMap('c1', c.toMap());
    expect(back.deadline, DateTime(2026, 7, 30));
    expect(back.role, 'Analista');
  });

  test('Benefit e Course round-trip', () {
    const b = Benefit(icon: 'card', title: 'ID Jovem', tag: 'Federal', description: 'd', steps: ['s1'], url: 'https://x');
    final bb = Benefit.fromMap('id', b.toMap());
    expect(bb.title, 'ID Jovem');
    expect(bb.steps, ['s1']);
    expect(bb.url, 'https://x');
    const co = Course(name: 'ADS', category: 'Graduação', type: 'Tecnólogo', duration: '3 anos', period: 'Noturno', icon: 'doc');
    expect(Course.fromMap('id', co.toMap()).name, 'ADS');
  });
}
```

- [ ] **Step 2: Rodar e confirmar a falha** — `flutter test test/data/firestore_mapping_test.dart` → FAIL (sem `toMap`/`fromMap`).

- [ ] **Step 3: Implementar (de)serialização em cada modelo.** Exemplos (aplicar o mesmo padrão aos demais):

`internship.dart` — adicionar dentro da classe:
```dart
  Map<String, dynamic> toMap() => {
        'role': role, 'companyName': companyName, 'area': area, 'duration': duration,
        'jobDescription': jobDescription, 'requirements': requirements, 'niceToHave': niceToHave,
        'companyDescription': companyDescription, 'benefits': benefits, 'grant': grant,
        'course': course, 'mode': mode, 'link': link, 'tag': tag, 'open': open,
        'closedAt': closedAt?.millisecondsSinceEpoch,
      };

  factory Internship.fromMap(String id, Map<String, dynamic> m) => Internship(
        id: id, role: m['role'] ?? '', companyName: m['companyName'] ?? '', area: m['area'] ?? '',
        duration: m['duration'] ?? '', jobDescription: m['jobDescription'] ?? '',
        requirements: List<String>.from(m['requirements'] ?? const []),
        niceToHave: List<String>.from(m['niceToHave'] ?? const []),
        companyDescription: m['companyDescription'] ?? '',
        benefits: List<String>.from(m['benefits'] ?? const []),
        grant: m['grant'] ?? '', course: m['course'] ?? 'Todos', mode: m['mode'] ?? '',
        link: m['link'], tag: m['tag'], open: m['open'] ?? true,
        closedAt: m['closedAt'] == null ? null : DateTime.fromMillisecondsSinceEpoch(m['closedAt'] as int),
      );
```
`contest.dart`:
```dart
  Map<String, dynamic> toMap() => {
        'role': role, 'org': org, 'vagas': vagas, 'salary': salary, 'level': level,
        'about': about, 'link': link, 'deadline': deadline.millisecondsSinceEpoch,
      };
  factory Contest.fromMap(String id, Map<String, dynamic> m) => Contest(
        id: id, role: m['role'] ?? '', org: m['org'] ?? '', vagas: m['vagas'] ?? '',
        salary: m['salary'] ?? '', level: m['level'] ?? '', about: m['about'] ?? '', link: m['link'],
        deadline: DateTime.fromMillisecondsSinceEpoch((m['deadline'] ?? 0) as int),
      );
```
`benefit.dart` (mantém enum):
```dart
  Map<String, dynamic> toMap() => {'icon': icon, 'title': title, 'tag': tag, 'description': description, 'steps': steps, 'url': url};
  factory Benefit.fromMap(String id, Map<String, dynamic> m) => Benefit(
        icon: m['icon'] ?? 'doc', title: m['title'] ?? '', tag: m['tag'] ?? '',
        description: m['description'] ?? '', steps: List<String>.from(m['steps'] ?? const []), url: m['url']);
```
`course.dart`:
```dart
  Map<String, dynamic> toMap() => {'name': name, 'category': category, 'type': type, 'duration': duration, 'period': period, 'icon': icon};
  factory Course.fromMap(String id, Map<String, dynamic> m) => Course(
        name: m['name'] ?? '', category: m['category'] ?? '', type: m['type'] ?? '',
        duration: m['duration'] ?? '', period: m['period'] ?? '', icon: m['icon'] ?? 'doc');
```
`testimonial.dart` (adicionar `authorUid` e `createdAt` opcionais):
```dart
class Testimonial {
  final String name, course, org, text;
  final int stars;
  final String? authorUid;
  final DateTime? createdAt;
  const Testimonial({required this.name, required this.course, required this.org, required this.text, required this.stars, this.authorUid, this.createdAt});
  Map<String, dynamic> toMap() => {'name': name, 'course': course, 'org': org, 'text': text, 'stars': stars, 'authorUid': authorUid, 'createdAt': (createdAt ?? DateTime.now()).millisecondsSinceEpoch};
  factory Testimonial.fromMap(String id, Map<String, dynamic> m) => Testimonial(
        name: m['name'] ?? '', course: m['course'] ?? '', org: m['org'] ?? '', text: m['text'] ?? '',
        stars: (m['stars'] ?? 5) as int, authorUid: m['authorUid'],
        createdAt: m['createdAt'] == null ? null : DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int));
}
```
`faq.dart`:
```dart
  Map<String, dynamic> toMap() => {'category': category, 'question': question, 'answer': answer};
  factory Faq.fromMap(String id, Map<String, dynamic> m) => Faq(category: m['category'] ?? 'Gerais', question: m['question'] ?? '', answer: m['answer'] ?? '');
```
`ifsp_info.dart` — unificar info+detalhe num doc por `key`:
```dart
  // IfspInfo
  Map<String, dynamic> toMap() => {'icon': icon, 'title': title, 'subtitle': subtitle, 'detail': detail?.toMap()};
  factory IfspInfo.fromMap(String key, Map<String, dynamic> m) => IfspInfo(
        key: key, icon: m['icon'] ?? 'doc', title: m['title'] ?? '', subtitle: m['subtitle'] ?? '',
        detail: m['detail'] == null ? null : IfspDetail.fromMap(key, Map<String, dynamic>.from(m['detail'])));
  // (adicionar campo `final IfspDetail? detail;` a IfspInfo)
  // IfspDetail
  Map<String, dynamic> toMap() => {'icon': icon, 'title': title, 'body': body, 'rows': rows.map((r) => [r.$1, r.$2]).toList()};
  factory IfspDetail.fromMap(String key, Map<String, dynamic> m) => IfspDetail(
        key: key, icon: m['icon'] ?? 'doc', title: m['title'] ?? '', body: m['body'],
        rows: ((m['rows'] ?? const []) as List).map((r) => (r[0] as String, r[1] as String)).toList());
```
Criar `lib/data/models/app_notification.dart`:
```dart
class AppNotification {
  final String id, icon, title, body, time;
  final String? route;
  final bool unread;
  const AppNotification({required this.id, required this.icon, required this.title, required this.body, required this.time, this.route, this.unread = true});
  Map<String, dynamic> toMap() => {'icon': icon, 'title': title, 'body': body, 'time': time, 'route': route, 'unread': unread};
  factory AppNotification.fromMap(String id, Map<String, dynamic> m) => AppNotification(
        id: id, icon: m['icon'] ?? 'bell', title: m['title'] ?? '', body: m['body'] ?? '', time: m['time'] ?? '', route: m['route'], unread: m['unread'] ?? true);
}
```

- [ ] **Step 4:** `flutter test test/data/firestore_mapping_test.dart` → PASS. `flutter analyze lib/data/models/` → limpo.
- [ ] **Step 5:** Commit — `git add lib/data/models/ test/data/firestore_mapping_test.dart && git commit -m "feat(data): (de)serializacao dos modelos para Firestore"`

---

### Task 2: Widget `AsyncView`

**Files:** Create `lib/shared/widgets/async_view.dart`

Helper para o padrão loading/erro/vazio/dados, evitando repetição nas telas.

- [ ] **Step 1: Criar o widget**

`lib/shared/widgets/async_view.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'app_button.dart';
import 'empty_state.dart';

/// Renderiza um AsyncValue<List<T>> com estados padrão.
class AsyncListView<T> extends StatelessWidget {
  final AsyncValue<List<T>> value;
  final Widget Function(List<T> items) data;
  final String emptyTitle;
  final String? emptyBody;
  final VoidCallback onRetry;
  const AsyncListView({super.key, required this.value, required this.data, required this.onRetry, this.emptyTitle = 'Nada por aqui', this.emptyBody});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return value.when(
      loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          Text('Não foi possível carregar.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink)),
          const SizedBox(height: 6),
          Text('Verifique sua conexão e tente novamente.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: c.ink3)),
          const SizedBox(height: 16),
          AppButton('Tentar novamente', variant: AppButtonVariant.outline, onTap: onRetry),
        ]),
      ),
      data: (items) => items.isEmpty ? EmptyState(icon: 'search', title: emptyTitle, body: emptyBody) : data(items),
    );
  }
}
```

- [ ] **Step 2:** `flutter analyze lib/shared/widgets/async_view.dart` → limpo.
- [ ] **Step 3:** Commit — `git add lib/shared/widgets/async_view.dart && git commit -m "feat(ui): AsyncListView (loading/erro/vazio/dados)"`

---

### Task 3: Interface streams + `FakeUniverseRepository`

**Files:** Modify `lib/data/repositories/universe_repository.dart`; Rename `mock_universe_repository.dart` → `fake_universe_repository.dart` (classe `FakeUniverseRepository`)

- [ ] **Step 1: Reescrever a interface**

`lib/data/repositories/universe_repository.dart`:
```dart
import '../models/course.dart';
import '../models/benefit.dart';
import '../models/internship.dart';
import '../models/contest.dart';
import '../models/testimonial.dart';
import '../models/faq.dart';
import '../models/ifsp_info.dart';

/// Acesso ao conteúdo do app (camada de dados) — tempo real via streams.
abstract interface class UniverseRepository {
  Stream<List<Course>> watchCourses();
  Stream<List<Benefit>> watchBenefits(BenefitKind kind);
  /// Estágios visíveis (RF034) opcionalmente filtrados por curso (RF031).
  Stream<List<Internship>> watchInternships({String courseFilter = 'Todos'});
  /// Concursos visíveis (RF036).
  Stream<List<Contest>> watchContests();
  Stream<List<Testimonial>> watchTestimonials();
  Stream<List<Faq>> watchFaqs();
  Stream<List<IfspInfo>> watchIfspInfo();

  Future<void> addTestimonial(Testimonial t);
}
```

- [ ] **Step 2: Renomear o mock para Fake e adaptar a streams.** `git mv lib/data/repositories/mock_universe_repository.dart lib/data/repositories/fake_universe_repository.dart`. Renomear a classe para `FakeUniverseRepository implements UniverseRepository`. Manter o conteúdo (`_internships`, `_contests`, listas etc.). Trocar os métodos para retornarem streams de um valor (com os filtros RF aplicados), e adicionar `addTestimonial` em memória:
```dart
class FakeUniverseRepository implements UniverseRepository {
  final List<Testimonial> _extraTestimonials = [];
  // ... (manter courses()/benefits()/etc. como listas privadas internas) ...

  @override
  Stream<List<Course>> watchCourses() => Stream.value(_courses);
  @override
  Stream<List<Benefit>> watchBenefits(BenefitKind kind) => Stream.value(kind == BenefitKind.gov ? _benGov : _benInst);
  @override
  Stream<List<Internship>> watchInternships({String courseFilter = 'Todos'}) {
    final now = DateTime.now();
    return Stream.value(_internships.where((e) => e.visibleAt(now)).where((e) => courseFilter == 'Todos' || e.course == courseFilter).toList());
  }
  @override
  Stream<List<Contest>> watchContests() {
    final now = DateTime.now();
    return Stream.value(_contests.where((c) => c.visibleAt(now)).toList());
  }
  @override
  Stream<List<Testimonial>> watchTestimonials() => Stream.value([..._extraTestimonials, ..._testimonials]);
  @override
  Stream<List<Faq>> watchFaqs() => Stream.value(_faqs);
  @override
  Stream<List<IfspInfo>> watchIfspInfo() => Stream.value(_ifspInfo);
  @override
  Future<void> addTestimonial(Testimonial t) async => _extraTestimonials.insert(0, t);

  // Getters para o seeder lerem todo o conteúdo bruto:
  List<Course> get allCourses => _courses;
  List<Benefit> get allBenGov => _benGov;
  List<Benefit> get allBenInst => _benInst;
  List<Internship> get allInternships => _internships;
  List<Contest> get allContests => _contests;
  List<Testimonial> get allTestimonials => _testimonials;
  List<Faq> get allFaqs => _faqs;
  List<IfspInfo> get allIfspInfo => _ifspInfo;
}
```
> Ajustar o conteúdo interno: hoje `courses()` é método; renomeie as listas para campos
> `_courses`, `_faqs`, `_ifspInfo` etc. (mantendo os dados). Onde havia `ifspDetail(key)`,
> embutir o detalhe em cada `IfspInfo.detail` (campo novo do modelo — Task 1).

- [ ] **Step 3:** `flutter analyze lib/data/repositories/` → resolver erros de assinatura. (As telas ainda quebram aqui — serão refatoradas nas Tasks 8–11; mas o pacote deve compilar a camada de dados.)
- [ ] **Step 4:** Commit — `git add lib/data/repositories/ && git commit -m "feat(data): UniverseRepository por streams + FakeUniverseRepository"`

---

### Task 4: `FirestoreUniverseRepository`

**Files:** Create `lib/data/repositories/firestore_universe_repository.dart`

- [ ] **Step 1: Implementar via snapshots**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';
import '../models/benefit.dart';
import '../models/internship.dart';
import '../models/contest.dart';
import '../models/testimonial.dart';
import '../models/faq.dart';
import '../models/ifsp_info.dart';
import 'universe_repository.dart';

class FirestoreUniverseRepository implements UniverseRepository {
  FirestoreUniverseRepository(this._db);
  final FirebaseFirestore _db;

  List<T> _map<T>(QuerySnapshot s, T Function(String, Map<String, dynamic>) f) =>
      s.docs.map((d) => f(d.id, d.data() as Map<String, dynamic>)).toList();

  @override
  Stream<List<Course>> watchCourses() =>
      _db.collection('courses').snapshots().map((s) => _map(s, Course.fromMap));

  @override
  Stream<List<Benefit>> watchBenefits(BenefitKind kind) => _db.collection('benefits')
      .where('kind', isEqualTo: kind == BenefitKind.gov ? 'gov' : 'inst')
      .snapshots().map((s) => _map(s, Benefit.fromMap));

  @override
  Stream<List<Internship>> watchInternships({String courseFilter = 'Todos'}) =>
      _db.collection('internships').snapshots().map((s) {
        final now = DateTime.now();
        return _map(s, Internship.fromMap)
            .where((e) => e.visibleAt(now))
            .where((e) => courseFilter == 'Todos' || e.course == courseFilter)
            .toList();
      });

  @override
  Stream<List<Contest>> watchContests() => _db.collection('contests').snapshots().map((s) {
        final now = DateTime.now();
        return _map(s, Contest.fromMap).where((c) => c.visibleAt(now)).toList();
      });

  @override
  Stream<List<Testimonial>> watchTestimonials() =>
      _db.collection('testimonials').orderBy('createdAt', descending: true).snapshots().map((s) => _map(s, Testimonial.fromMap));

  @override
  Stream<List<Faq>> watchFaqs() => _db.collection('faqs').snapshots().map((s) => _map(s, Faq.fromMap));

  @override
  Stream<List<IfspInfo>> watchIfspInfo() => _db.collection('ifspInfo').snapshots().map((s) => _map(s, IfspInfo.fromMap));

  @override
  Future<void> addTestimonial(Testimonial t) => _db.collection('testimonials').add(t.toMap());
}
```
> Nota: o Firestore guarda `closedAt/deadline/createdAt` como `int` (epoch-ms) via
> `toMap()` — consistente com `fromMap()`. (Se preferir `Timestamp` nativo, converter no
> repositório; manter `int` é mais simples e suficiente.)

- [ ] **Step 2:** `flutter analyze lib/data/repositories/firestore_universe_repository.dart` → limpo.
- [ ] **Step 3:** Commit — `git add lib/data/repositories/firestore_universe_repository.dart && git commit -m "feat(data): FirestoreUniverseRepository (snapshots em tempo real)"`

---

### Task 5: Providers (stream) + troca para Firestore

**Files:** Modify `lib/core/providers/repository_provider.dart`

- [ ] **Step 1: Reescrever os providers**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/course.dart';
import '../../data/models/benefit.dart';
import '../../data/models/internship.dart';
import '../../data/models/contest.dart';
import '../../data/models/testimonial.dart';
import '../../data/models/faq.dart';
import '../../data/models/ifsp_info.dart';
import '../../data/repositories/universe_repository.dart';
import '../../data/repositories/firestore_universe_repository.dart';

final universeRepositoryProvider = Provider<UniverseRepository>((ref) =>
    FirestoreUniverseRepository(FirebaseFirestore.instance));

final coursesProvider = StreamProvider<List<Course>>((ref) => ref.watch(universeRepositoryProvider).watchCourses());
final benefitsProvider = StreamProvider.family<List<Benefit>, BenefitKind>((ref, k) => ref.watch(universeRepositoryProvider).watchBenefits(k));
final internshipsProvider = StreamProvider.family<List<Internship>, String>((ref, course) => ref.watch(universeRepositoryProvider).watchInternships(courseFilter: course));
final contestsProvider = StreamProvider<List<Contest>>((ref) => ref.watch(universeRepositoryProvider).watchContests());
final testimonialsProvider = StreamProvider<List<Testimonial>>((ref) => ref.watch(universeRepositoryProvider).watchTestimonials());
final faqsProvider = StreamProvider<List<Faq>>((ref) => ref.watch(universeRepositoryProvider).watchFaqs());
final ifspInfoProvider = StreamProvider<List<IfspInfo>>((ref) => ref.watch(universeRepositoryProvider).watchIfspInfo());
```

- [ ] **Step 2:** `flutter analyze lib/core/providers/repository_provider.dart` → limpo.
- [ ] **Step 3:** Commit — `git add lib/core/providers/repository_provider.dart && git commit -m "feat(data): stream providers + repositorio Firestore por padrao"`

---

### Task 6: Refatorar Home, Cursos e IFSP para streams

**Files:** Modify `home_screen.dart`, `courses_screen.dart`, `ifsp_screen.dart`, `ifsp_detail_screen.dart`

Padrão: trocar `ref.watch(universeRepositoryProvider).<método síncrono>` por
`ref.watch(<streamProvider>)` (um `AsyncValue`) e renderizar listas com `AsyncListView`.

- [ ] **Step 1: CoursesScreen** — substituir `final all = ref.watch(universeRepositoryProvider).courses();` por `final coursesAsync = ref.watch(coursesProvider);`. Envolver a lista filtrada:
```dart
AsyncListView<Course>(
  value: coursesAsync,
  onRetry: () => ref.invalidate(coursesProvider),
  emptyTitle: 'Nenhum curso encontrado', emptyBody: 'Tente outro termo ou categoria.',
  data: (all) {
    final list = all.where((e) => (_cat == 'Todos' || e.category == _cat) && e.name.toLowerCase().contains(_q.toLowerCase())).toList();
    if (list.isEmpty) return EmptyState(icon: 'search', title: 'Nenhum curso encontrado', body: 'Tente outro termo ou categoria.', action: 'Limpar filtros', onAction: () => setState(() { _cat = 'Todos'; _q = ''; }));
    return Column(children: [for (final course in list) Padding(padding: const EdgeInsets.only(bottom: 11), child: _CourseCard(course: course, onTap: () => context.push('/cursos/detail', extra: course)))]);
  },
)
```
- [ ] **Step 2: HomeScreen** — o card de destaque e os itens "Explorar" são estáticos (não dependem do repo). Manter como estão. (Sem mudança de dados; a Home não lê listas do repo hoje.)
- [ ] **Step 3: IfspScreen** — trocar `ref.watch(universeRepositoryProvider).ifspInfo()` por `ref.watch(ifspInfoProvider)` + `AsyncListView<IfspInfo>` ao redor da lista "Sobre o campus".
- [ ] **Step 4: IfspDetailScreen** — em vez de `ifspDetail(key)`, ler de `ifspInfoProvider` e achar por `key` (`infos.firstWhere((i) => i.key == key)` → `.detail`); ou continuar recebendo via `extra` quando navegado da lista. Implementar via `ifspInfoProvider` + `.when`, exibindo `IfspDetail` do item. Tratar não encontrado com `EmptyState`.
- [ ] **Step 5:** `flutter analyze` nas 4 telas → limpo.
- [ ] **Step 6:** Commit — `git add lib/features/home lib/features/courses lib/features/campus && git commit -m "feat(ui): Home/Cursos/IFSP consumindo streams (async)"`

---

### Task 7: Refatorar Benefícios e Estágio/Concursos/Depoimentos

**Files:** Modify `benefits_screen.dart`, `estagio_screen.dart`, `depoimentos_screen.dart`

- [ ] **Step 1: BenefitsScreen** — `ref.watch(benefitsProvider(kind))` + `AsyncListView<Benefit>` ao redor dos cards. Manter o disclaimer RF012.
- [ ] **Step 2: EstagioScreen** — vagas: `ref.watch(internshipsProvider(_course))`; concursos: `ref.watch(contestsProvider)`; depoimentos: `ref.watch(testimonialsProvider)`. Envolver cada lista com `.when`/`AsyncListView`. Remover o uso de `userTestimonialsProvider` (a lista vem do stream).
- [ ] **Step 3: DepoimentosScreen** — lista de `ref.watch(testimonialsProvider)` (`.when`); `_submit` chama `await ref.read(universeRepositoryProvider).addTestimonial(Testimonial(name: ..., course: 'IFSP', org: _org, stars: _stars, text: _text, authorUid: user?.id))`. Remover `userTestimonialsProvider` e o arquivo `lib/core/providers/testimonials_provider.dart` (agora obsoleto).
- [ ] **Step 4:** `flutter analyze` nas telas + remover import órfão de `testimonials_provider.dart` em `estagio_screen.dart`. `git rm lib/core/providers/testimonials_provider.dart`.
- [ ] **Step 5:** Commit — `git add -A && git commit -m "feat(ui): Beneficios/Estagio/Depoimentos via streams; depoimentos persistidos"`

---

### Task 8: Refatorar Dúvidas + garantir papel no perfil

**Files:** Modify `duvidas_screen.dart`; `lib/data/auth/firebase_auth_repository.dart` (criar doc users/{uid} com role no registro); `lib/data/profile/student_profile.dart` (incluir role? — manter role só no doc users)

- [ ] **Step 1: DuvidasScreen** — `ref.watch(faqsProvider)` + `AsyncListView<Faq>` ao redor da lista de accordions (aplicar filtro de categoria/busca dentro do `data:`).
- [ ] **Step 2: Criar doc do usuário no registro com `role: 'student'`** — em `FirebaseAuthRepository.register`, após criar a conta, gravar `users/{uid}` com `{name, email, role: 'student'}` (via `FirebaseFirestore.instance.collection('users').doc(uid).set(..., merge:true)`), para as regras reconhecerem o papel. (Alternativa: fazer no `ProfileRepository`; manter coeso com auth.)
- [ ] **Step 3:** `flutter analyze` → limpo. `flutter test` → suíte (ajustar testes que usavam o repositório síncrono: os widget tests que dependiam de `MockUniverseRepository` devem passar a sobrescrever `universeRepositoryProvider` com `FakeUniverseRepository`; o `login_screen_test`/`auth_redirect_test` não dependem do conteúdo). Atualizar/!remover testes obsoletos conforme necessário, sem enfraquecer.
- [ ] **Step 4:** Commit — `git add -A && git commit -m "feat(ui): Duvidas via stream; cria users/{uid} com role no registro"`

---

### Task 9: Seeder (dev) + regras de segurança

**Files:** Create `lib/data/repositories/seed.dart`, `firestore.rules`

- [ ] **Step 1: Seeder idempotente**

`lib/data/repositories/seed.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/benefit.dart';
import 'fake_universe_repository.dart';

/// Sobe o conteúdo do FakeUniverseRepository para o Firestore (idempotente).
/// Uso dev/admin apenas. IDs determinísticos via set(merge:true) onde houver id.
Future<void> seedFirestore() async {
  final db = FirebaseFirestore.instance;
  final fake = FakeUniverseRepository();
  final batch = db.batch();

  for (var i = 0; i < fake.allCourses.length; i++) {
    batch.set(db.collection('courses').doc('c$i'), fake.allCourses[i].toMap());
  }
  for (final b in fake.allBenGov) {
    batch.set(db.collection('benefits').doc('gov_${b.title.hashCode}'), {...b.toMap(), 'kind': 'gov'});
  }
  for (final b in fake.allBenInst) {
    batch.set(db.collection('benefits').doc('inst_${b.title.hashCode}'), {...b.toMap(), 'kind': 'inst'});
  }
  for (final e in fake.allInternships) {
    batch.set(db.collection('internships').doc(e.id), e.toMap());
  }
  for (final ct in fake.allContests) {
    batch.set(db.collection('contests').doc(ct.id), ct.toMap());
  }
  for (var i = 0; i < fake.allFaqs.length; i++) {
    batch.set(db.collection('faqs').doc('f$i'), fake.allFaqs[i].toMap());
  }
  for (final info in fake.allIfspInfo) {
    batch.set(db.collection('ifspInfo').doc(info.key), info.toMap());
  }
  await batch.commit();
}
```
> Acionamento: por enquanto, chamar `seedFirestore()` a partir de um ponto dev (ex.: um
> botão temporário no Perfil visível só em `kDebugMode`, ou via console do Firebase
> importando os dados). O botão dev é opcional; documentar como rodar.

- [ ] **Step 2: Regras de segurança**

`firestore.rules` (na raiz do projeto):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() { return request.auth != null; }
    function isAdmin() {
      return signedIn() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    match /users/{uid} {
      allow read: if signedIn() && request.auth.uid == uid;
      allow create: if request.auth.uid == uid;
      allow update: if request.auth.uid == uid
        && (!('role' in request.resource.data) || request.resource.data.role == resource.data.role);
    }
    match /testimonials/{id} {
      allow read: if signedIn();
      allow create: if signedIn() && request.resource.data.authorUid == request.auth.uid;
      allow update, delete: if isAdmin();
    }
    match /{col}/{id} {
      allow read: if signedIn();
      allow write: if isAdmin();
    }
  }
}
```
> Nota: a regra genérica `/{col}/{id}` cobre courses/benefits/internships/contests/faqs/
> ifspInfo/notifications (leitura autenticada, escrita admin). `users` e `testimonials`
> têm regras específicas acima (precedência por match mais específico). Publicar via
> console do Firebase (Firestore → Regras) ou `firebase deploy --only firestore:rules`.

- [ ] **Step 3:** `flutter analyze lib/data/repositories/seed.dart` → limpo. (firestore.rules não é Dart.)
- [ ] **Step 4:** Commit — `git add lib/data/repositories/seed.dart firestore.rules && git commit -m "feat(data): seeder dev + regras de seguranca do Firestore"`

---

### Task 10: Verificação, seed e diário

**Files:** atualização do diário.

- [ ] **Step 1:** `flutter analyze` (limpo) + `flutter test` (todos PASS — ajustando testes para `FakeUniverseRepository` onde liam conteúdo).
- [ ] **Step 2:** Publicar as **regras** no console do Firebase; rodar o **seed** uma vez (botão dev ou import). Conferir no console que as coleções foram criadas.
- [ ] **Step 3:** Rodar `flutter run -d chrome --web-port 5000`; logar; confirmar que as telas carregam do Firestore (estado de loading aparece e depois os dados); publicar um depoimento e vê-lo persistir após sair/voltar e em outra sessão; alterar uma vaga no console e ver atualizar **em tempo real** no app.
- [ ] **Step 4:** Registrar no diário (conclusão do SP1: Firestore + tempo real + persistência + regras). Commit — `git add docs/ && git commit -m "docs: registra SP1 (fundacao Firestore)"`

---

## Self-Review (cobertura da spec)
- **§2 streams:** Tasks 3–5 ✓. **§3 modelo de dados:** Task 1 (de/serialização) + Task 9 (seed das coleções) ✓.
- **§4 interface/impl Fake+Firestore:** Tasks 3–4 ✓.
- **§5 telas assíncronas:** Tasks 6–8 (+AsyncListView Task 2) ✓.
- **§6 persistência (depoimentos/perfil):** Task 7 (depoimentos) + Task 8 (users/role) ✓; perfil já era Firestore.
- **§7 regras:** Task 9 ✓. **§8 seeding:** Task 9 ✓. **§9 offline:** padrão do Firestore (sem código). **§10 testes:** Tasks 1, 8, 10 ✓.

**Riscos/notas:**
1. **Testes de tela existentes** que liam o conteúdo via repositório síncrono precisam migrar para sobrescrever `universeRepositoryProvider` com `FakeUniverseRepository` (Task 8 Step 3). Não enfraquecer asserções.
2. **`ifspDetail` deixou de existir na interface** — IFSP detalhe agora vem de `IfspInfo.detail` (Task 1 add campo; Task 6 Step 4).
3. **Seed/regras** exigem o projeto Firebase com Firestore habilitado (pré-requisito operacional); o app em si compila e os testes rodam com o Fake sem tocar a rede.
4. Datas como epoch-ms (int) no Firestore — simples e consistente; migrar para `Timestamp` é opcional futuro.
