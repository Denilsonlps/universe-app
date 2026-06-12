# Plano 4A — Telas: Home, Cursos e IFSP (Universe)

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`).

**Goal:** Substituir os placeholders das abas Início e Cursos pelas telas reais, e implementar a seção IFSP (campus), consumindo o `UniverseRepository` e o design system existentes.

**Architecture:** Telas em `features/`, `ConsumerWidget`/`ConsumerStatefulWidget` lendo `universeRepositoryProvider` e `currentProfileProvider`. Reusa `PageShell`, `HomeHeader`, `GreenHero`, `AppCard`, `ListRow`, `IconTile`, `AppChip`, `EmptyState`, `AppField`, marca. Navegação por `go_router` (novas rotas para detalhes).

**Tech Stack:** flutter_riverpod, go_router. Sem novas dependências.

**Fonte de design:** `design_reference/project/universe/screens-main.jsx` (Home, IfspScreen, CursosScreen, CourseDetailScreen) e `chrome.jsx` (HomeHeader, GreenHero, quick actions, highlight card).

**Pré-requisitos prontos:** design system + chrome (Planos 1, 3.5), `UniverseRepository`/mock + modelos (Plano 3), auth/perfil (Planos 2–3), router com shell de 4 abas + placeholders.

**Decisão de layout:** Home = **lista** (decisão da spec: layout fixo). Quick actions e card de destaque do protótipo são mantidos.

---

## Estrutura de arquivos (Plano 4A)

```
lib/features/home/screens/home_screen.dart           HomeScreen (aba Início)
lib/features/courses/screens/courses_screen.dart     CoursesScreen (aba Cursos)
lib/features/courses/screens/course_detail_screen.dart CourseDetailScreen
lib/features/campus/screens/ifsp_screen.dart         IfspScreen
lib/features/campus/screens/ifsp_detail_screen.dart  IfspDetailScreen
lib/core/router/app_router.dart                       MODIFICA: usa as telas reais + rotas
```

> O `_Tab` placeholder das abas home/cursos é trocado pelas telas reais; abrem-se rotas
> `/ifsp`, `/ifsp/:key`, `/cursos/:name` (detalhe). A aba Início e Cursos ficam dentro do ShellRoute.

---

### Task 1: HomeScreen (aba Início)

**Files:** Create `lib/features/home/screens/home_screen.dart`

Layout (de `screens-main.jsx` HomeScreen, layout 'list'): saudação com avatar + nome do
usuário; barra de busca (placeholder, navega para nada por ora — abre toast "em breve");
chips de ações rápidas (Moradia, Dúvidas, ID Jovem, Endereço); card de destaque "Estágio
em Dev Web" → `/estagio` (rota ainda não existe no 4A → por ora navega e cai no
placeholder/ć; use toast "em breve" se a rota não existir); seção "Explorar" com `ListRow`
para cada item de `DATA.home` (IFSP, Cursos, Benefícios Gov, Benefícios Inst, Estágio,
Cadastrar). Header = `HomeHeader` (menu abre drawer, sino → toast "em breve" por ora).

> No 4A só existem as rotas `/home`, `/cursos`, `/ifsp`. Itens que apontam para rotas ainda
> não criadas (benefícios, estágio, cadastrar, moradia) devem mostrar um `SnackBar`
> "Em breve" em vez de navegar. Implemente um helper `_go(context, route)` que navega se a
> rota existir no conjunto conhecido, senão mostra o SnackBar.

- [ ] **Step 1: Criar a tela**

`lib/features/home/screens/home_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/bottom_nav.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/list_row.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/user_avatar.dart';

const _availableRoutes = {'/home', '/cursos', '/ifsp', '/duvidas', '/perfil'};

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _go(BuildContext context, String route) {
    if (_availableRoutes.contains(route)) {
      context.go(route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final user = ref.watch(authStateProvider).valueOrNull;
    final firstName = (user?.name ?? 'Estudante').split(' ').first;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bom dia' : hour < 18 ? 'Boa tarde' : 'Boa noite';

    final homeItems = <({String route, String icon, String title, String sub})>[
      (route: '/ifsp', icon: 'institution', title: 'IFSP Pirituba', sub: 'Conheça o campus, estrutura e contatos'),
      (route: '/cursos', icon: 'cap', title: 'Cursos', sub: 'Graduações, técnicos e pós-graduação'),
      (route: '/beneficios/gov', icon: 'benefits', title: 'Benefícios Governamentais', sub: 'Cadastro Único, ID Jovem, transporte e isenções'),
      (route: '/beneficios/inst', icon: 'award', title: 'Benefícios Institucionais', sub: 'PAP, monitoria, iniciação científica e extensão'),
      (route: '/estagio', icon: 'briefcase', title: 'Estágio e Concursos', sub: 'Vagas, editais e concursos públicos'),
      (route: '/cadastrar', icon: 'edit', title: 'Cadastrar informações', sub: 'Atualize seus dados e documentos'),
    ];
    final quick = <({String route, String icon, String label})>[
      (route: '/moradia', icon: 'house', label: 'Moradia'),
      (route: '/duvidas', icon: 'question', label: 'Dúvidas'),
      (route: '/beneficios/gov', icon: 'card', label: 'ID Jovem'),
      (route: '/ifsp', icon: 'pin', label: 'Endereço'),
    ];

    return PageShell(
      bodyPadding: const EdgeInsets.all(16),
      header: HomeHeader(
        onMenu: () => Scaffold.of(context).openDrawer(),
        onBell: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve'))),
      ),
      bottomNav: AppBottomNav(current: 'home', onTap: (k) => context.go('/$k')),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // saudação
        Row(children: [
          UserAvatar(user?.name ?? 'Estudante', size: 46),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$greeting,', style: TextStyle(fontSize: 12.5, color: c.ink3, fontWeight: FontWeight.w600)),
            Text(firstName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.ink, letterSpacing: -0.3)),
          ])),
        ]),
        const SizedBox(height: 16),
        // busca (placeholder)
        AppCard(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve'))),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          radius: 14,
          child: Row(children: [
            Icon(appIcon('search'), size: 19, color: c.ink3),
            const SizedBox(width: 10),
            Text('Buscar cursos, benefícios, dúvidas…', style: TextStyle(fontSize: 14, color: c.ink3)),
          ]),
        ),
        const SizedBox(height: 18),
        // ações rápidas
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: quick.length,
            separatorBuilder: (_, __) => const SizedBox(width: 9),
            itemBuilder: (_, i) => AppChip(quick[i].label, onTap: () => _go(context, quick[i].route)),
          ),
        ),
        const SizedBox(height: 20),
        // card de destaque
        _HighlightCard(onTap: () => _go(context, '/estagio')),
        const SizedBox(height: 22),
        const SectionTitle('Explorar'),
        for (final it in homeItems) Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: ListRow(icon: it.icon, title: it.title, subtitle: it.sub, onTap: () => _go(context, it.route)),
        ),
      ]),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final VoidCallback onTap;
  const _HighlightCard({required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.green600, c.green900]),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
            child: const Text('EM DESTAQUE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: Colors.white)),
          ),
          const SizedBox(height: 12),
          const Text('Estágio em Dev Web', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
          const SizedBox(height: 4),
          Text('Prefeitura de SP · bolsa R\$ 1.100 + VT', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 14),
          Row(children: [
            const Text('Ver vaga', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(width: 5),
            Icon(appIcon('chevR'), size: 16, color: Colors.white),
          ]),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 2:** `flutter analyze lib/features/home/screens/home_screen.dart` — sem erros.
- [ ] **Step 3:** Commit — `git add lib/features/home/screens/home_screen.dart && git commit -m "feat(home): tela inicial real (saudacao, busca, acoes, destaque, explorar)"`

---

### Task 2: CoursesScreen (aba Cursos) + CourseDetailScreen

**Files:** Create `lib/features/courses/screens/courses_screen.dart`, `course_detail_screen.dart`

CoursesScreen: header próprio (título "Cursos" grande + `AppField` de busca), chips de
categoria (`DATA.courseCats`: Todos/Graduação/Técnico/Pós-graduação), lista de cursos
filtrada por categoria+busca (cards com `IconTile` + nome + chip de categoria + período·duração),
`EmptyState` quando vazio. Toca no curso → `/cursos/<name>` (detalhe).

- [ ] **Step 1: CoursesScreen**

`lib/features/courses/screens/courses_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/course.dart';
import '../../../shared/chrome/bottom_nav.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/icon_tile.dart';

const _courseCats = ['Todos', 'Graduação', 'Técnico', 'Pós-graduação'];

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});
  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  String _cat = 'Todos';
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final all = ref.watch(universeRepositoryProvider).courses();
    final list = all.where((e) =>
        (_cat == 'Todos' || e.category == _cat) &&
        e.name.toLowerCase().contains(_q.toLowerCase())).toList();

    return PageShell(
      bodyPadding: const EdgeInsets.all(16),
      bottomNav: AppBottomNav(current: 'cursos', onTap: (k) => context.go('/$k')),
      header: Container(
        color: c.bg,
        padding: const EdgeInsets.fromLTRB(16, kStatusH, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Cursos', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: c.ink, letterSpacing: -0.4)),
          const SizedBox(height: 12),
          AppField(icon: 'search', hint: 'Buscar curso…', value: _q, onChanged: (v) => setState(() => _q = v)),
        ]),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _courseCats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 9),
            itemBuilder: (_, i) => AppChip(_courseCats[i], active: _cat == _courseCats[i], onTap: () => setState(() => _cat = _courseCats[i])),
          ),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          EmptyState(icon: 'search', title: 'Nenhum curso encontrado', body: 'Tente outro termo ou categoria.', action: 'Limpar filtros', onAction: () => setState(() { _cat = 'Todos'; _q = ''; }))
        else
          for (final course in list) Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _CourseCard(course: course, onTap: () => context.go('/cursos/${Uri.encodeComponent(course.name)}')),
          ),
      ]),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  const _CourseCard({required this.course, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      onTap: onTap, padding: const EdgeInsets.all(15),
      child: Row(children: [
        IconTile(course.icon, size: 48, iconSize: 24),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(course.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink, height: 1.25)),
          const SizedBox(height: 6),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(999)),
              child: Text(course.category, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: c.green700)),
            ),
            const SizedBox(width: 8),
            Flexible(child: Text('${course.period} · ${course.duration}', style: TextStyle(fontSize: 11, color: c.ink3), overflow: TextOverflow.ellipsis)),
          ]),
        ])),
        Icon(appIcon('chevR'), size: 18, color: c.ink3),
      ]),
    );
  }
}
```

- [ ] **Step 2: CourseDetailScreen**

`lib/features/courses/screens/course_detail_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/list_row.dart';
import '../../../shared/widgets/section_title.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseName;
  const CourseDetailScreen({super.key, required this.courseName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final courses = ref.watch(universeRepositoryProvider).courses();
    final course = courses.where((e) => e.name == courseName).firstOrNull ?? courses.first;
    final meta = [('Tipo', course.type), ('Duração', course.duration), ('Período', course.period), ('Modalidade', 'Presencial')];

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: course.name, subtitle: '${course.category} · ${course.type}', icon: course.icon, onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, childAspectRatio: 2.6, mainAxisSpacing: 10, crossAxisSpacing: 10,
            children: [
              for (final (k, v) in meta) AppCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(k, style: TextStyle(fontSize: 11, color: c.ink3, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(v, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.ink)),
              ])),
            ],
          ),
          const SizedBox(height: 18),
          const SectionTitle('Sobre o curso'),
          AppCard(child: Text(
            'O curso de ${course.name} forma profissionais com sólida base teórica e prática, preparados para o mercado de trabalho e para a continuidade dos estudos. As aulas acontecem no período ${course.period.toLowerCase()}, no campus Pirituba.',
            style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2),
          )),
          const SizedBox(height: 18),
          const SectionTitle('Formas de ingresso'),
          for (final (t, s) in const [('Vestibular IFSP', 'Prova realizada no fim do ano'), ('SiSU / Enem', 'Parte das vagas via nota do Enem'), ('Transferência', 'Para alunos de outras instituições')])
            Padding(padding: const EdgeInsets.only(bottom: 10), child: ListRow(icon: 'flag', title: t, subtitle: s, showChevron: false)),
          const SizedBox(height: 10),
          AppButton('Ver estágios para este curso', full: true, icon: 'briefcase',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve')))),
        ]),
      ),
    );
  }
}
```

> `firstOrNull`: se o analyzer reclamar, troque por `(courses.where((e) => e.name == courseName).toList()..add(courses.first)).first` — ou simplesmente `courses.firstWhere((e) => e.name == courseName, orElse: () => courses.first)`. Prefira `firstWhere(orElse:)`.

- [ ] **Step 3:** `flutter analyze lib/features/courses/` — sem erros (use `firstWhere(orElse:)`).
- [ ] **Step 4:** Commit — `git add lib/features/courses/ && git commit -m "feat(courses): tela de cursos e detalhe do curso"`

---

### Task 3: IfspScreen + IfspDetailScreen

**Files:** Create `lib/features/campus/screens/ifsp_screen.dart`, `ifsp_detail_screen.dart`

IfspScreen: `GreenHero` "IFSP Pirituba" com 3 estatísticas (Fundado 1909 · Cursos 10+ ·
Alunos 1.2k); seção "Sobre o campus" com `ListRow` para cada `ifspInfo()` → `/ifsp/<key>`.
IfspDetailScreen: `GreenHero` com título do item; corpo conforme `IfspDetail` (body como
texto em `AppCard`; rows como lista de pares).

- [ ] **Step 1: IfspScreen**

`lib/features/campus/screens/ifsp_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/list_row.dart';
import '../../../shared/widgets/section_title.dart';

class IfspScreen extends ConsumerWidget {
  const IfspScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(universeRepositoryProvider).ifspInfo();
    const stats = [('1909', 'Fundado'), ('10+', 'Cursos'), ('1.2k', 'Alunos')];
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(
        title: 'IFSP Pirituba', subtitle: 'Campus São Paulo Pirituba', icon: 'institution',
        onBack: () => context.pop(),
        child: Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Row(children: [
            for (final (v, k) in stats) Expanded(child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
              child: Column(children: [
                Text(v, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 2),
                Text(k, style: TextStyle(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.75))),
              ]),
            )),
          ]),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('Sobre o campus'),
          for (final it in info) Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ListRow(icon: it.icon, title: it.title, subtitle: it.subtitle, onTap: () => context.go('/ifsp/${it.key}')),
          ),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 2: IfspDetailScreen**

`lib/features/campus/screens/ifsp_detail_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';

class IfspDetailScreen extends ConsumerWidget {
  final String detailKey;
  const IfspDetailScreen({super.key, required this.detailKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final detail = ref.watch(universeRepositoryProvider).ifspDetail(detailKey);
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: detail?.title ?? 'Campus', icon: detail?.icon, onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: detail == null
            ? Text('Informação indisponível.', style: TextStyle(color: c.ink2))
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (detail.body != null)
                  AppCard(child: Text(detail.body!, style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2))),
                if (detail.rows.isNotEmpty) ...[
                  if (detail.body != null) const SizedBox(height: 12),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      for (var i = 0; i < detail.rows.length; i++) ...[
                        if (i > 0) Divider(height: 1, color: c.line),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(flex: 2, child: Text(detail.rows[i].$1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink2))),
                            const SizedBox(width: 12),
                            Expanded(flex: 3, child: Text(detail.rows[i].$2, style: TextStyle(fontSize: 13, color: c.ink, fontWeight: FontWeight.w500))),
                          ]),
                        ),
                      ],
                    ]),
                  ),
                ],
              ]),
      ),
    );
  }
}
```

- [ ] **Step 3:** `flutter analyze lib/features/campus/` — sem erros.
- [ ] **Step 4:** Commit — `git add lib/features/campus/ && git commit -m "feat(campus): tela do IFSP e detalhe do campus"`

---

### Task 4: Ligar as telas no router

**Files:** Modify `lib/core/router/app_router.dart`

Trocar os placeholders das abas home/cursos pelas telas reais; adicionar rotas IFSP e
detalhe de curso. Manter `duvidas`/`perfil` como placeholders por ora (4C).

- [ ] **Step 1: Editar o router**

Importar as novas telas e ajustar:
- `import '../../features/home/screens/home_screen.dart';`
- `import '../../features/courses/screens/courses_screen.dart';`
- `import '../../features/courses/screens/course_detail_screen.dart';`
- `import '../../features/campus/screens/ifsp_screen.dart';`
- `import '../../features/campus/screens/ifsp_detail_screen.dart';`

Dentro do `ShellRoute.routes`, trocar os builders de `/home` e `/cursos`:
```dart
GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
GoRoute(path: '/cursos', builder: (c, s) => const CoursesScreen()),
GoRoute(path: '/duvidas', builder: (c, s) => const _Tab('Dúvidas', 'duvidas')),
GoRoute(path: '/perfil', builder: (c, s) => const _Tab('Perfil', 'perfil')),
```
Adicionar, FORA do ShellRoute (telas full-screen com GreenHero, sem bottom nav), no array
de rotas de topo (irmãs do ShellRoute):
```dart
GoRoute(path: '/ifsp', builder: (c, s) => const IfspScreen()),
GoRoute(path: '/ifsp/:key', builder: (c, s) => IfspDetailScreen(detailKey: s.pathParameters['key']!)),
GoRoute(path: '/cursos/:name', builder: (c, s) => CourseDetailScreen(courseName: Uri.decodeComponent(s.pathParameters['name']!))),
```
> Importante: a rota `/cursos/:name` precisa ficar FORA do ShellRoute (senão conflita com a
> aba `/cursos`). Como o redirect de auth manda logados para fora das rotas de auth, e essas
> são telas autenticadas, mantê-las como rotas de topo (irmãs do ShellRoute) já funciona — o
> redirect só intervém em `_authRoutes` e `/splash`. Verifique que navegar de Cursos→detalhe
> e voltar funciona.

Atualizar o conjunto `_availableRoutes` da Home **não** é necessário (já inclui /ifsp).

- [ ] **Step 2:** `flutter analyze` — limpo. `flutter test` — toda a suíte PASS. (O `navigation_test` troca de aba e abre o drawer; como /home e /cursos agora são telas reais, confirmar que ainda acha 'Cursos' e 'IFSP Pirituba'. Se o teste do drawer buscava 'IFSP Pirituba' e agora a Home também tem esse texto, ajustar o teste para um seletor único, ex.: abrir o drawer e checar 'Benefícios Governamentais'.)
- [ ] **Step 3:** Commit — `git add lib/core/router/app_router.dart test/ && git commit -m "feat(nav): liga Home, Cursos e IFSP no router"`

---

### Task 5: Verificação + diário

- [ ] **Step 1:** `flutter analyze` (limpo) + `flutter test` (tudo PASS).
- [ ] **Step 2:** Rodar no navegador (`flutter run -d chrome --web-port 5000 --web-hostname localhost`); após login, conferir: Home com saudação/itens; abrir IFSP + um detalhe; aba Cursos com filtro/busca; abrir um curso. (Itens sem rota mostram "Em breve".)
- [ ] **Step 3:** Entrada no diário resumindo o 4A.
- [ ] **Step 4:** Commit — `git add docs/ && git commit -m "docs: registra Plano 4A (Home, Cursos, IFSP)"`

---

## Self-Review
- **Home (aba Início):** saudação com nome do usuário (auth), busca placeholder, ações rápidas, card de destaque, "Explorar" — Task 1.
- **Cursos + detalhe:** filtro por categoria/busca, cards, detalhe com metadados/ingresso — Task 2.
- **IFSP + detalhe:** hero com stats, lista "sobre o campus", detalhe (body/rows) — Task 3.
- **Consome a camada de dados** (`universeRepositoryProvider`) e o design system/marca — sem novas deps.
- **Rotas não implementadas ainda** (benefícios, estágio, cadastrar, moradia) → SnackBar "Em breve" (sem links quebrados).

**Riscos/notas:**
1. `firstOrNull` → preferir `firstWhere(orElse:)` (Task 2).
2. `navigation_test` pode precisar de seletor único após /home virar tela real (Task 4) — ajustar sem enfraquecer.
3. Rota `/cursos/:name` deve ficar fora do ShellRoute para não conflitar com a aba.
