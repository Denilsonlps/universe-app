# Plano 3 — Camada de Dados & Perfil do Aluno (Universe)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modelar todo o conteúdo do app (cursos, benefícios, estágios, concursos, depoimentos, FAQ, IFSP) atrás de uma interface `UniverseRepository` com implementação mock fiel ao protótipo, aplicando as regras dos requisitos (RF031/RF034/RF036); e introduzir o **perfil do aluno** (curso/matrícula) no Firestore, capturado no cadastro e editável depois.

**Architecture:** Models imutáveis em `data/models`. `UniverseRepository` (interface) + `MockUniverseRepository` (em memória, conteúdo portado de `design_reference/.../data.jsx`). Perfil do aluno: `StudentProfile` + `ProfileRepository` (interface) com `FirestoreProfileRepository` (real) e `FakeProfileRepository` (testes). Tudo exposto por providers Riverpod. **Nenhuma tela de conteúdo nova** — isso é o Plano 4; aqui entregamos a camada de dados testada + a captura de curso no cadastro.

**Tech Stack:** flutter_riverpod, cloud_firestore (perfil), firebase_auth (uid). Reusa design system/auth dos Planos 1–2.

**Spec:** `docs/superpowers/specs/2026-06-11-universe-rebuild-design.md` §3 (modelo de dados/RF033-037), §4 (repositório/papéis). **Conteúdo fonte (versionado no repo):** `design_reference/project/universe/data.jsx`. **Identidade/dados do aluno:** `docs/desenvolvimento/integracao-suap.md` (decisão híbrida: perfil auto-declarado agora; SUAP OAuth2 futuro).

**Pré-requisitos prontos:** `AppUser`/`AuthRole`, `authStateProvider`/`authRepositoryProvider`, design system, `AppField`, telas de auth.

---

## Estrutura de arquivos (Plano 3)

```
lib/data/models/
  course.dart            Course
  benefit.dart           Benefit + BenefitKind
  internship.dart        Internship (RF033: 10 campos + status/closedAt)
  contest.dart           Contest (deadline/status — RF036)
  testimonial.dart       Testimonial
  faq.dart               Faq
  ifsp_info.dart         IfspInfo (item de lista) + IfspDetail (detalhe)
lib/data/repositories/
  universe_repository.dart        interface UniverseRepository
  mock_universe_repository.dart   conteúdo + regras RF031/RF034/RF036
lib/data/profile/
  student_profile.dart            StudentProfile (uid, course, enrollment)
  profile_repository.dart         interface ProfileRepository
  fake_profile_repository.dart    em memória (testes/dev)
  firestore_profile_repository.dart  Firestore users/{uid}
lib/core/providers/
  repository_provider.dart        universeRepositoryProvider + listas derivadas
  profile_provider.dart           profileRepositoryProvider + currentProfileProvider
lib/data/courses.dart             catálogo de cursos do campus (constante compartilhada)
test/data/
  internship_rules_test.dart      RF034 (1 mês) + RF031 (curso)
  contest_rules_test.dart         RF036 (período)
  fake_profile_repository_test.dart
```

> A captura do curso no **cadastro** (Task 9) modifica `register_screen.dart` (Plano 2).

---

### Task 1: Catálogo de cursos do campus

**Files:** Create `lib/data/courses.dart`

Lista única de cursos usada por filtros e pelo seletor de curso do cadastro. Os
nomes vêm de `design_reference/.../data.jsx` (`DATA.courses`).

- [ ] **Step 1: Criar o catálogo**

`lib/data/courses.dart`:
```dart
/// Cursos oferecidos pelo campus (rótulos curtos usados em filtros e no perfil).
/// Fonte: design_reference/project/universe/data.jsx (DATA.estagioCourses/courses).
const campusCourses = <String>[
  'Análise e Desenvolvimento de Sistemas',
  'Gestão Pública',
  'Letras — Português / Inglês',
  'Engenharia de Produção',
  'Administração',
  'Redes de Computadores',
  'Logística',
  'PROEJA — Administração',
  'Gestão de Projetos',
  'Humanidades',
];

/// Rótulo curto do curso usado nos filtros de estágio (ex.: 'ADS').
const courseShortLabels = <String>[
  'Todos', 'ADS', 'Gestão Pública', 'Eng. de Produção', 'Redes', 'Administração', 'Logística',
];

/// Mapeia o nome completo do curso para o rótulo curto de filtro de estágios.
String courseShort(String fullName) => switch (fullName) {
      'Análise e Desenvolvimento de Sistemas' => 'ADS',
      'Gestão Pública' => 'Gestão Pública',
      'Engenharia de Produção' => 'Eng. de Produção',
      'Redes de Computadores' => 'Redes',
      'Administração' => 'Administração',
      'Logística' => 'Logística',
      _ => 'Todos',
    };
```

- [ ] **Step 2:** `flutter analyze lib/data/courses.dart` — sem erros.
- [ ] **Step 3:** Commit — `git add lib/data/courses.dart && git commit -m "feat(data): catalogo de cursos do campus"`

---

### Task 2: Modelos simples (Course, Benefit, Testimonial, Faq)

**Files:** Create `lib/data/models/course.dart`, `benefit.dart`, `testimonial.dart`, `faq.dart`

- [ ] **Step 1: Course**

`lib/data/models/course.dart`:
```dart
class Course {
  final String name, category, type, duration, period, icon;
  const Course({
    required this.name, required this.category, required this.type,
    required this.duration, required this.period, required this.icon,
  });
}
```

- [ ] **Step 2: Benefit (+kind)**

`lib/data/models/benefit.dart`:
```dart
enum BenefitKind { gov, inst }

class Benefit {
  final String icon, title, tag, description;
  final List<String> steps; // forma de obtenção (RF011)
  const Benefit({
    required this.icon, required this.title, required this.tag,
    required this.description, required this.steps,
  });
}
```

- [ ] **Step 3: Testimonial**

`lib/data/models/testimonial.dart`:
```dart
class Testimonial {
  final String name, course, org, text;
  final int stars;
  const Testimonial({
    required this.name, required this.course, required this.org,
    required this.text, required this.stars,
  });
}
```

- [ ] **Step 4: Faq**

`lib/data/models/faq.dart`:
```dart
class Faq {
  final String category, question, answer;
  const Faq({required this.category, required this.question, required this.answer});
}
```

- [ ] **Step 5:** `flutter analyze lib/data/models/` — sem erros.
- [ ] **Step 6:** Commit — `git add lib/data/models/ && git commit -m "feat(data): modelos Course, Benefit, Testimonial, Faq"`

---

### Task 3: Modelo Internship (RF033/RF034) + teste de regra

**Files:** Create `lib/data/models/internship.dart`; Test `test/data/internship_rules_test.dart`

- [ ] **Step 1: Modelo com os 10 campos do RF033 + status/closedAt**

`lib/data/models/internship.dart`:
```dart
/// Vaga de estágio. Campos i–x conforme RF033 do TCC.
class Internship {
  final String id;
  final String role;             // iii cargo
  final String companyName;      // i empresa
  final String area;             // ii área de atuação
  final String duration;         // iv duração
  final String jobDescription;   // v descrição da vaga
  final List<String> requirements; // vi pré-requisitos
  final List<String> niceToHave;   // vii diferenciais
  final String companyDescription; // viii descrição da empresa
  final List<String> benefits;     // ix benefícios
  final String grant;              // x salário/bolsa
  // auxiliares
  final String course;   // RF031: organização por curso (rótulo curto)
  final String mode;     // presencial/híbrido
  final String? link;
  final String? tag;     // ex.: 'Novo'
  final bool open;       // RF034: disponível ou não
  final DateTime? closedAt; // quando foi encerrada (RF034)

  const Internship({
    required this.id, required this.role, required this.companyName, required this.area,
    required this.duration, required this.jobDescription, required this.requirements,
    required this.niceToHave, required this.companyDescription, required this.benefits,
    required this.grant, required this.course, required this.mode,
    this.link, this.tag, this.open = true, this.closedAt,
  });

  /// RF034: vaga encerrada permanece visível por até 30 dias após `closedAt`.
  bool visibleAt(DateTime now) {
    if (open) return true;
    final since = closedAt;
    if (since == null) return true; // sem data → mantém visível
    return now.difference(since).inDays <= 30;
  }
}
```

- [ ] **Step 2: Teste das regras RF034 + filtro por curso (RF031)**

`test/data/internship_rules_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/internship.dart';

Internship _vaga({bool open = true, DateTime? closedAt, String course = 'ADS'}) => Internship(
  id: 'x', role: 'Dev', companyName: 'Org', area: 'TI', duration: '12m',
  jobDescription: 'desc', requirements: const [], niceToHave: const [],
  companyDescription: 'sobre', benefits: const [], grant: 'R\$ 1.000',
  course: course, mode: 'Híbrido', open: open, closedAt: closedAt,
);

void main() {
  final now = DateTime(2026, 6, 11);

  test('vaga aberta é sempre visível', () {
    expect(_vaga(open: true).visibleAt(now), isTrue);
  });

  test('vaga encerrada há menos de 30 dias permanece visível (RF034)', () {
    expect(_vaga(open: false, closedAt: now.subtract(const Duration(days: 20))).visibleAt(now), isTrue);
  });

  test('vaga encerrada há mais de 30 dias some (RF034)', () {
    expect(_vaga(open: false, closedAt: now.subtract(const Duration(days: 40))).visibleAt(now), isFalse);
  });
}
```

- [ ] **Step 3:** `flutter test test/data/internship_rules_test.dart` — PASS. `flutter analyze` sem erros.
- [ ] **Step 4:** Commit — `git add lib/data/models/internship.dart test/data/internship_rules_test.dart && git commit -m "feat(data): modelo Internship (RF033) + regra de visibilidade (RF034)"`

---

### Task 4: Modelo Contest (RF036) + teste

**Files:** Create `lib/data/models/contest.dart`; Test `test/data/contest_rules_test.dart`

- [ ] **Step 1: Modelo**

`lib/data/models/contest.dart`:
```dart
/// Concurso público / edital. RF035-RF036.
class Contest {
  final String id, role, org, vagas, salary, level, about;
  final String? link;
  final DateTime deadline; // fim do período de inscrição (RF036)

  const Contest({
    required this.id, required this.role, required this.org, required this.vagas,
    required this.salary, required this.level, required this.about,
    required this.deadline, this.link,
  });

  /// RF036: edital visível apenas durante o período de inscrição.
  bool get open => true; // status textual; visibilidade real via visibleAt
  bool visibleAt(DateTime now) => !now.isAfter(deadline.add(const Duration(days: 30)));
  bool isOpenAt(DateTime now) => !now.isAfter(deadline);
}
```

- [ ] **Step 2: Teste RF036**

`test/data/contest_rules_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/contest.dart';

Contest _c(DateTime deadline) => Contest(
  id: 'c', role: 'Analista', org: 'IFSP', vagas: '10', salary: 'R\$ 4.000',
  level: 'Superior', about: 'x', deadline: deadline,
);

void main() {
  final now = DateTime(2026, 6, 11);
  test('edital dentro do prazo está aberto (RF036)', () {
    expect(_c(now.add(const Duration(days: 10))).isOpenAt(now), isTrue);
  });
  test('edital após o prazo não está mais aberto (RF036)', () {
    expect(_c(now.subtract(const Duration(days: 1))).isOpenAt(now), isFalse);
  });
}
```

- [ ] **Step 3:** `flutter test test/data/contest_rules_test.dart` — PASS.
- [ ] **Step 4:** Commit — `git add lib/data/models/contest.dart test/data/contest_rules_test.dart && git commit -m "feat(data): modelo Contest + regra de período (RF036)"`

---

### Task 5: Modelos IFSP (info + detalhe)

**Files:** Create `lib/data/models/ifsp_info.dart`

- [ ] **Step 1: Modelos**

`lib/data/models/ifsp_info.dart`:
```dart
/// Item da lista "Sobre o campus".
class IfspInfo {
  final String key, icon, title, subtitle;
  const IfspInfo({required this.key, required this.icon, required this.title, required this.subtitle});
}

/// Detalhe de um item do campus. `body` para texto livre; `rows` para pares chave/valor.
class IfspDetail {
  final String key, icon, title;
  final String? body;
  final List<(String, String)> rows; // ex.: horários, contatos
  const IfspDetail({required this.key, required this.icon, required this.title, this.body, this.rows = const []});
}
```

- [ ] **Step 2:** `flutter analyze lib/data/models/ifsp_info.dart` — sem erros.
- [ ] **Step 3:** Commit — `git add lib/data/models/ifsp_info.dart && git commit -m "feat(data): modelos IfspInfo e IfspDetail"`

---

### Task 6: Interface UniverseRepository

**Files:** Create `lib/data/repositories/universe_repository.dart`

- [ ] **Step 1: Interface**

`lib/data/repositories/universe_repository.dart`:
```dart
import '../models/course.dart';
import '../models/benefit.dart';
import '../models/internship.dart';
import '../models/contest.dart';
import '../models/testimonial.dart';
import '../models/faq.dart';
import '../models/ifsp_info.dart';

/// Acesso ao conteúdo do app (camada de dados). Mock agora; Firestore depois.
abstract interface class UniverseRepository {
  List<Course> courses();
  List<Benefit> benefits(BenefitKind kind);
  List<Testimonial> testimonials();
  List<Faq> faqs();
  List<IfspInfo> ifspInfo();
  IfspDetail? ifspDetail(String key);

  /// Estágios visíveis (aplica RF034) — opcionalmente filtrados por curso (RF031).
  List<Internship> internships({String courseFilter = 'Todos', DateTime? now});
  Internship? internship(String id);

  /// Concursos visíveis (aplica RF036).
  List<Contest> contests({DateTime? now});
  Contest? contest(String id);
}
```

- [ ] **Step 2:** `flutter analyze` — sem erros.
- [ ] **Step 3:** Commit — `git add lib/data/repositories/universe_repository.dart && git commit -m "feat(data): interface UniverseRepository"`

---

### Task 7: MockUniverseRepository (conteúdo + regras)

**Files:** Create `lib/data/repositories/mock_universe_repository.dart`

O conteúdo (textos pt-BR) deve ser **transcrito fielmente** de
`design_reference/project/universe/data.jsx` (arquivo versionado no repo). Mapeie
os campos de cada vaga para os 10 do RF033: o `about` do protótipo é a **descrição
da empresa** (`companyDescription`); crie uma **descrição da vaga** (`jobDescription`)
curta e coerente por vaga (ex.: a partir do cargo/área), já que o protótipo unia os dois.

- [ ] **Step 1: Implementar o repositório com o conteúdo**

`lib/data/repositories/mock_universe_repository.dart` — estrutura completa abaixo;
**preencha todas as listas** transcrevendo de `data.jsx`:
```dart
import '../models/course.dart';
import '../models/benefit.dart';
import '../models/internship.dart';
import '../models/contest.dart';
import '../models/testimonial.dart';
import '../models/faq.dart';
import '../models/ifsp_info.dart';
import 'universe_repository.dart';

class MockUniverseRepository implements UniverseRepository {
  @override
  List<Course> courses() => const [
        Course(name: 'Análise e Desenvolvimento de Sistemas', category: 'Graduação', type: 'Tecnólogo', duration: '3 anos', period: 'Noturno', icon: 'doc'),
        Course(name: 'Gestão Pública', category: 'Graduação', type: 'Tecnólogo', duration: '2,5 anos', period: 'Noturno', icon: 'institution'),
        // … TRANSCREVER os demais de DATA.courses (Letras, Eng. de Produção,
        //   Administração, Redes, Logística, PROEJA, Gestão de Projetos, Humanidades)
      ];

  @override
  List<Benefit> benefits(BenefitKind kind) => kind == BenefitKind.gov ? _benGov : _benInst;

  static const _benGov = [
        Benefit(icon: 'card', title: 'Cadastro Único', tag: 'Federal',
          description: 'Porta de entrada para programas sociais do governo federal. Permite acesso a tarifas sociais, ID Jovem e isenções.',
          steps: ['Reúna documentos de todos do domicílio', 'Procure um posto do CRAS da sua região', 'Mantenha o cadastro atualizado a cada 2 anos']),
        // … TRANSCREVER ID Jovem, Transporte, Isenções de DATA.benGov
      ];
  static const _benInst = [
        Benefit(icon: 'benefits', title: 'PAP', tag: 'Auxílio',
          description: 'Programa de Auxílio Permanência — apoio financeiro para estudantes em vulnerabilidade socioeconômica.',
          steps: ['Inscreva-se no edital de assistência', 'Anexe documentação socioeconômica', 'Aguarde a análise do serviço social']),
        // … TRANSCREVER Monitoria, Iniciação Científica, Projeto de Extensão de DATA.benInst
      ];

  @override
  List<Testimonial> testimonials() => const [
        Testimonial(name: 'Lucas Pereira', course: 'ADS', org: 'Prefeitura de SP', stars: 5,
          text: 'Estagiar no setor de TI da Prefeitura foi um divisor de águas. Aprendi na prática o que via em sala e fui efetivado depois de um ano.'),
        // … TRANSCREVER Mariana Costa, Rafael Souza de DATA.testimonials
      ];

  @override
  List<Faq> faqs() => const [
        Faq(category: 'Campus', question: 'Como é viver em Pirituba?', answer: 'Pirituba é uma região tranquila da Zona Noroeste de São Paulo, bem servida por transporte público (CPTM Linha 7-Rubi e diversas linhas de ônibus), comércio local e áreas verdes como o Parque da Cidade.'),
        // … TRANSCREVER os demais de DATA.faqs
      ];

  @override
  List<IfspInfo> ifspInfo() => const [
        IfspInfo(key: 'historia', icon: 'book', title: 'História', subtitle: 'Fundado em 1909, mais de um século de educação pública'),
        // … TRANSCREVER os demais de DATA.ifspInfo (endereco, horario, estrutura, contatos, site)
      ];

  @override
  IfspDetail? ifspDetail(String key) => _details[key];
  static final Map<String, IfspDetail> _details = {
    'historia': const IfspDetail(key: 'historia', icon: 'book', title: 'História',
      body: 'A Rede Federal de Educação nasceu em 1909, com as Escolas de Aprendizes Artífices. O IFSP é herdeiro dessa tradição centenária de ensino público, gratuito e de qualidade.\n\nO Campus Pirituba integra essa rede na Zona Noroeste de São Paulo, oferecendo cursos técnicos, de graduação e de pós-graduação.'),
    // … TRANSCREVER endereco (rows com endereço), horario (rows), estrutura, contatos (rows), site
  };

  // Fonte das vagas. about(protótipo) → companyDescription; jobDescription = nova descrição curta da vaga.
  static final List<Internship> _internships = [
    Internship(
      id: 'e1', role: 'Estágio em Desenvolvimento Web', companyName: 'Prefeitura de São Paulo',
      area: 'Tecnologia da Informação', course: 'ADS', mode: 'Híbrido', grant: 'R\$ 1.100',
      benefits: const ['Vale-transporte', 'Recesso remunerado', 'Seguro de vida'],
      duration: '6h/dia · 12 meses', tag: 'Novo', open: true, link: 'sp.gov.br/estagios',
      requirements: const ['Cursando a partir do 2º semestre de ADS', 'Conhecimento em HTML, CSS e JavaScript', 'Noções de Git'],
      niceToHave: const ['React ou Vue', 'Experiência com APIs REST', 'Figma'],
      jobDescription: 'Desenvolvimento e manutenção de interfaces web dos serviços digitais ao cidadão, em squads com mentoria técnica.',
      companyDescription: 'A Prefeitura de São Paulo mantém um programa de estágio voltado à modernização dos serviços digitais ao cidadão, com mentoria técnica e rotação entre squads.'),
    // … TRANSCREVER e2..e6 de DATA.estagios (e5 e e6 têm status 'closed' → open:false,
    //   closedAt: DateTime.now().subtract(const Duration(days: 10)) para permanecerem visíveis por ora)
  ];

  static final List<Contest> _contests = [
    Contest(id: 'c1', role: 'Técnico Administrativo em Educação', org: 'IFSP — Reitoria',
      vagas: '24 vagas', salary: 'R\$ 4.180,66', level: 'Ensino Médio Técnico',
      deadline: DateTime(2026, 7, 30), link: 'ifsp.edu.br/concursos',
      about: 'Concurso para provimento de cargos técnico-administrativos nos campi do IFSP, com prova objetiva e discursiva.'),
    // … TRANSCREVER c2..c4 de DATA.concursos (c4 tem deadline passado → naturalmente filtrado)
  ];

  @override
  List<Internship> internships({String courseFilter = 'Todos', DateTime? now}) {
    final ref = now ?? DateTime.now();
    return _internships
        .where((e) => e.visibleAt(ref))                         // RF034
        .where((e) => courseFilter == 'Todos' || e.course == courseFilter) // RF031
        .toList();
  }

  @override
  Internship? internship(String id) => _internships.where((e) => e.id == id).firstOrNull;

  @override
  List<Contest> contests({DateTime? now}) {
    final ref = now ?? DateTime.now();
    return _contests.where((c) => c.visibleAt(ref)).toList(); // RF036 (+30d consulta)
  }

  @override
  Contest? contest(String id) => _contests.where((c) => c.id == id).firstOrNull;
}
```

> `firstOrNull` vem de `dart:core` via `package:collection`? Não — use `cast`/`where().isEmpty` se necessário, ou adicione `import 'package:collection/collection.dart';`. Verifique no analyze; se faltar, troque por: `final m = _internships.where((e) => e.id == id); return m.isEmpty ? null : m.first;`.

- [ ] **Step 2: Transcrever todo o conteúdo** de `design_reference/project/universe/data.jsx` para as listas marcadas com `…`. Não inventar dados além do necessário (jobDescription é a única síntese permitida, curta).
- [ ] **Step 3:** `flutter analyze lib/data/repositories/` — sem erros (resolver `firstOrNull`).
- [ ] **Step 4:** Commit — `git add lib/data/repositories/mock_universe_repository.dart && git commit -m "feat(data): MockUniverseRepository com conteudo e regras RF031/RF034/RF036"`

---

### Task 8: Provider do repositório de conteúdo

**Files:** Create `lib/core/providers/repository_provider.dart`

- [ ] **Step 1: Provider**

`lib/core/providers/repository_provider.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/universe_repository.dart';
import '../../data/repositories/mock_universe_repository.dart';

/// Conteúdo do app. Sobrescrito nos testes; trocar por FirestoreUniverseRepository depois.
final universeRepositoryProvider = Provider<UniverseRepository>((ref) => MockUniverseRepository());
```

- [ ] **Step 2:** `flutter analyze` — sem erros.
- [ ] **Step 3:** Commit — `git add lib/core/providers/repository_provider.dart && git commit -m "feat(data): universeRepositoryProvider"`

---

### Task 9: Perfil do aluno — modelo, repositório (Fake+Firestore), provider (TDD)

**Files:**
- Create `lib/data/profile/student_profile.dart`, `profile_repository.dart`, `fake_profile_repository.dart`, `firestore_profile_repository.dart`
- Create `lib/core/providers/profile_provider.dart`
- Test `test/data/fake_profile_repository_test.dart`

- [ ] **Step 1: Modelo**

`lib/data/profile/student_profile.dart`:
```dart
class StudentProfile {
  final String uid;
  final String? course;     // nome completo do curso (campusCourses)
  final String? enrollment; // matrícula
  const StudentProfile({required this.uid, this.course, this.enrollment});

  StudentProfile copyWith({String? course, String? enrollment}) =>
      StudentProfile(uid: uid, course: course ?? this.course, enrollment: enrollment ?? this.enrollment);

  Map<String, dynamic> toMap() => {'course': course, 'enrollment': enrollment};
  factory StudentProfile.fromMap(String uid, Map<String, dynamic> m) =>
      StudentProfile(uid: uid, course: m['course'] as String?, enrollment: m['enrollment'] as String?);
}
```

- [ ] **Step 2: Interface**

`lib/data/profile/profile_repository.dart`:
```dart
import 'student_profile.dart';

abstract interface class ProfileRepository {
  Future<StudentProfile?> get(String uid);
  Future<void> save(StudentProfile profile);
}
```

- [ ] **Step 3: Teste do fake (FALHA primeiro)**

`test/data/fake_profile_repository_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/profile/student_profile.dart';
import 'package:universe_app/data/profile/fake_profile_repository.dart';

void main() {
  test('save e get retornam o perfil', () async {
    final repo = FakeProfileRepository();
    expect(await repo.get('u1'), isNull);
    await repo.save(const StudentProfile(uid: 'u1', course: 'Análise e Desenvolvimento de Sistemas', enrollment: 'PT3024187'));
    final p = await repo.get('u1');
    expect(p?.course, 'Análise e Desenvolvimento de Sistemas');
    expect(p?.enrollment, 'PT3024187');
  });
}
```

- [ ] **Step 4: Rodar e confirmar a falha**, depois implementar o fake.

`lib/data/profile/fake_profile_repository.dart`:
```dart
import 'student_profile.dart';
import 'profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  final Map<String, StudentProfile> _store = {};
  @override
  Future<StudentProfile?> get(String uid) async => _store[uid];
  @override
  Future<void> save(StudentProfile profile) async => _store[profile.uid] = profile;
}
```

- [ ] **Step 5: Implementar o Firestore**

`lib/data/profile/firestore_profile_repository.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_profile.dart';
import 'profile_repository.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._db);
  final FirebaseFirestore _db;

  @override
  Future<StudentProfile?> get(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    return data == null ? null : StudentProfile.fromMap(uid, data);
  }

  @override
  Future<void> save(StudentProfile profile) async =>
      _db.collection('users').doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
}
```

- [ ] **Step 6: Provider**

`lib/core/providers/profile_provider.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/profile/profile_repository.dart';
import '../../data/profile/firestore_profile_repository.dart';
import '../../data/profile/student_profile.dart';
import 'auth_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) =>
    FirestoreProfileRepository(FirebaseFirestore.instance));

/// Perfil do usuário autenticado (null se deslogado ou sem perfil ainda).
final currentProfileProvider = FutureProvider<StudentProfile?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return ref.watch(profileRepositoryProvider).get(user.id);
});
```

- [ ] **Step 7: Rodar `flutter test test/data/fake_profile_repository_test.dart`** — PASS. `flutter analyze` sem erros.
- [ ] **Step 8:** Commit — `git add lib/data/profile/ lib/core/providers/profile_provider.dart test/data/fake_profile_repository_test.dart && git commit -m "feat(data): perfil do aluno (StudentProfile + repos + provider, TDD)"`

---

### Task 10: Capturar curso no cadastro

**Files:** Modify `lib/features/auth/screens/register_screen.dart`

Adiciona um seletor de curso (opcional) no registro; ao criar a conta, grava o
perfil via `ProfileRepository`. Mantém o cadastro simples (curso opcional — também
editável no perfil depois, conforme decisão "Ambos").

- [ ] **Step 1: Adicionar estado e seletor**

No `_RegisterScreenState`, adicionar campo `String? _course;` e, **antes** do botão
CRIAR CONTA, um seletor usando `campusCourses` (`lib/data/courses.dart`). Use um
`DropdownButtonFormField<String>` estilizado de forma simples (rótulo "Curso
(opcional)"). Import: `import '../../../data/courses.dart';`.

```dart
const SizedBox(height: 13),
DropdownButtonFormField<String>(
  initialValue: _course,
  isExpanded: true,
  decoration: InputDecoration(
    labelText: 'Curso (opcional)',
    filled: true, fillColor: c.card,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
  ),
  items: [for (final n in campusCourses) DropdownMenuItem(value: n, child: Text(n, overflow: TextOverflow.ellipsis))],
  onChanged: (v) => setState(() => _course = v),
),
```

- [ ] **Step 2: Gravar o perfil ao registrar**

No `_submit`, após `register(...)` ter sucesso, gravar o perfil quando houver curso:
```dart
final user = await ref.read(authRepositoryProvider).register(name: _name, email: _email, password: _pw);
if (_course != null) {
  await ref.read(profileRepositoryProvider).save(StudentProfile(uid: user.id, course: _course));
}
```
Imports: `profile_provider.dart` e `student_profile.dart`.

- [ ] **Step 3:** `flutter analyze lib/features/auth/screens/register_screen.dart` — sem erros. `flutter test` (suíte completa) — tudo PASS (o teste de registro existente não usa curso; continua válido).
- [ ] **Step 4:** Commit — `git add lib/features/auth/screens/register_screen.dart && git commit -m "feat(auth): captura opcional de curso no cadastro (perfil)"`

---

### Task 11: Verificação + diário

**Files:** atualização do diário.

- [ ] **Step 1: Suíte completa** — `flutter test` (todos PASS) e `flutter analyze` (limpo).
- [ ] **Step 2:** Registrar entrada no diário resumindo o Plano 3 (camada de dados + perfil), decisões e regras (RF031/RF034/RF036) e o estado entregue.
- [ ] **Step 3:** Commit — `git add docs/desenvolvimento/diario-de-desenvolvimento.md && git commit -m "docs: registra conclusao do Plano 3 (camada de dados e perfil)"`

---

## Self-Review (cobertura)

- **Spec §3 (modelos + RF033-037):** Tasks 2–5 ✓ (Internship com 10 campos; regras RF034/RF036 testadas).
- **RF031 (estágios por curso):** filtro em `internships(courseFilter:)` (Task 7) ✓.
- **Spec §4 (interface de repositório):** `UniverseRepository` + mock (Tasks 6–7) ✓; troca p/ Firestore = um provider.
- **Dados do aluno (decisão híbrida):** `StudentProfile` + `ProfileRepository` (Firestore+Fake) + captura no cadastro (Tasks 9–10) ✓; SUAP fica para integração futura (`integracao-suap.md`).
- **Sem telas de conteúdo novas:** correto — é o Plano 4.

**Riscos/notas:**
1. `firstOrNull` pode exigir `package:collection`; a Task 7 dá o fallback sem dependência.
2. Conteúdo do mock é **transcrição** do `data.jsx` versionado (não é placeholder): a Task 7 lista exatamente o que falta preencher e a fonte.
3. Regras Firestore por papel (aluno lê / admin escreve; perfil só do próprio uid) entram quando a leitura migrar para Firestore (fase de dados) — fora do escopo deste plano (mock).
