# Plano 4C — Telas: Dúvidas (FAQ) e Perfil (Universe)

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`).

**Goal:** Implementar as abas Dúvidas (FAQ com busca/categorias/accordion + encaminhar dúvida) e Perfil (dados do aluno, alternador de tema claro/escuro, edição de perfil com curso/matrícula persistidos), fechando as telas de conteúdo do app no mock.

**Architecture:** Telas em `features/faqs` e `features/profile`. Lêem `universeRepositoryProvider`, `authStateProvider`, `currentProfileProvider`/`profileRepositoryProvider`, `themeModeProvider`. Adiciona 2 primitivos ao design system: `Accordion` e `AppToggle`. Substitui os placeholders das abas `/duvidas` e `/perfil`.

**Tech Stack:** flutter_riverpod, go_router. Sem novas dependências.

**Fonte de design:** `design_reference/project/universe/screens-misc.jsx` (DuvidasScreen, PerfilScreen, CadastrarScreen) e `ui.jsx` (Accordion, Toggle).

**Pré-requisitos prontos:** design system + chrome; `Faq` model + `faqs()`; `StudentProfile` + `ProfileRepository` + `currentProfileProvider`/`profileRepositoryProvider`; `themeModeProvider` (toggle); `campusCourses`/`courseShort`; router com push/extra.

**Decisão:** dark mode é exposto no Perfil (decisão da spec: dark mode sim).

---

## Estrutura de arquivos (Plano 4C)

```
lib/shared/widgets/accordion.dart            Accordion (FAQ expand/collapse)
lib/shared/widgets/app_toggle.dart           AppToggle (switch verde)
lib/features/faqs/screens/duvidas_screen.dart   DuvidasScreen (aba Dúvidas)
lib/features/profile/screens/perfil_screen.dart CadastrarScreen está em profile/ também
lib/features/profile/screens/cadastrar_screen.dart  edição de perfil (curso/matrícula)
lib/core/router/app_router.dart              MODIFICA: telas reais + /cadastrar
test/widgets/accordion_test.dart
```

---

### Task 1: Widgets Accordion + AppToggle

**Files:** Create `lib/shared/widgets/accordion.dart`, `lib/shared/widgets/app_toggle.dart`; Test `test/widgets/accordion_test.dart`

- [ ] **Step 1: Accordion**

`lib/shared/widgets/accordion.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_tile.dart';

class Accordion extends StatelessWidget {
  final String question, answer;
  final bool open;
  final VoidCallback onToggle;
  const Accordion({super.key, required this.question, required this.answer, required this.open, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        color: c.card, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFF0D281C).withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
            child: Row(children: [
              Expanded(child: Text(question, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.ink, height: 1.35))),
              const SizedBox(width: 12),
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: Icon(appIcon('chevD'), size: 18, color: c.green600),
              ),
            ]),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(alignment: Alignment.centerLeft, child: Text(answer, style: TextStyle(fontSize: 13, height: 1.55, color: c.ink2))),
          ),
          crossFadeState: open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ]),
    );
  }
}
```

- [ ] **Step 2: AppToggle**

`lib/shared/widgets/app_toggle.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppToggle extends StatelessWidget {
  final bool on;
  final ValueChanged<bool> onChanged;
  const AppToggle({super.key, required this.on, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46, height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: on ? c.green500 : const Color(0xFFD7DDD8), borderRadius: BorderRadius.circular(999)),
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 3, offset: Offset(0, 1))])),
      ),
    );
  }
}
```

- [ ] **Step 3: Teste do Accordion**

`test/widgets/accordion_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/shared/widgets/accordion.dart';

void main() {
  testWidgets('Accordion alterna ao tocar', (t) async {
    var open = false;
    await t.pumpWidget(MaterialApp(theme: AppTheme.light, home: Scaffold(body: StatefulBuilder(
      builder: (c, setState) => Accordion(question: 'Pergunta?', answer: 'Resposta.', open: open, onToggle: () => setState(() => open = !open)),
    ))));
    expect(find.text('Pergunta?'), findsOneWidget);
    await t.tap(find.text('Pergunta?'));
    await t.pumpAndSettle();
    expect(open, isTrue);
    expect(find.text('Resposta.'), findsOneWidget);
  });
}
```

- [ ] **Step 4:** `flutter test test/widgets/accordion_test.dart` (PASS) + `flutter analyze lib/shared/widgets/` (limpo).
- [ ] **Step 5:** Commit — `git add lib/shared/widgets/accordion.dart lib/shared/widgets/app_toggle.dart test/widgets/accordion_test.dart && git commit -m "feat(ui): Accordion e AppToggle"`

---

### Task 2: DuvidasScreen (aba Dúvidas / FAQ)

**Files:** Create `lib/features/faqs/screens/duvidas_screen.dart`

Header próprio ("Dúvidas" + busca). Chips de categoria (`faqCats`: Todas/Campus/Enem/Gerais).
Lista de `Accordion` (um aberto por vez). `EmptyState` quando vazio. Card "Encaminhe sua
dúvida" com categoria + mensagem (até 500) → envia (snackbar).

- [ ] **Step 1: DuvidasScreen**

`lib/features/faqs/screens/duvidas_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/chrome/bottom_nav.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/accordion.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/icon_tile.dart';

const _faqCats = ['Todas', 'Campus', 'Enem', 'Gerais'];

class DuvidasScreen extends ConsumerStatefulWidget {
  const DuvidasScreen({super.key});
  @override
  ConsumerState<DuvidasScreen> createState() => _DuvidasScreenState();
}

class _DuvidasScreenState extends ConsumerState<DuvidasScreen> {
  String _cat = 'Todas';
  String _q = '';
  int _openIdx = 0;
  String _msg = '';
  String _formCat = 'Dúvidas gerais';

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final all = ref.watch(universeRepositoryProvider).faqs();
    final list = all.where((f) =>
        (_cat == 'Todas' || f.category == _cat) &&
        f.question.toLowerCase().contains(_q.toLowerCase())).toList();

    return PageShell(
      bodyPadding: const EdgeInsets.all(16),
      bottomNav: AppBottomNav(current: 'duvidas', onTap: (k) => context.go('/$k')),
      header: Container(
        color: c.bg,
        padding: const EdgeInsets.fromLTRB(16, kStatusH, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Dúvidas', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: c.ink, letterSpacing: -0.4)),
          const SizedBox(height: 12),
          AppField(icon: 'search', hint: 'Pesquisar dúvidas…', value: _q, onChanged: (v) => setState(() => _q = v)),
        ]),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _faqCats.length,
            separatorBuilder: (context, i) => const SizedBox(width: 9),
            itemBuilder: (context, i) => AppChip(_faqCats[i], active: _cat == _faqCats[i], onTap: () => setState(() { _cat = _faqCats[i]; _openIdx = 0; })),
          ),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          const EmptyState(icon: 'question', title: 'Nenhuma dúvida encontrada', body: 'Não achamos resultados. Encaminhe sua pergunta abaixo.')
        else
          for (var i = 0; i < list.length; i++) Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Accordion(question: list[i].question, answer: list[i].answer, open: _openIdx == i, onToggle: () => setState(() => _openIdx = _openIdx == i ? -1 : i)),
          ),
        const SizedBox(height: 16),
        // Encaminhe sua dúvida
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              IconTile('send', size: 42, iconSize: 20, bg: c.green100),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Não achou sua dúvida?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.ink)),
                Text('Encaminhe direto para o campus', style: TextStyle(fontSize: 12, color: c.ink2)),
              ])),
            ]),
            const SizedBox(height: 14),
            Text('Categoria', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
            const SizedBox(height: 7),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final cat in const ['Dúvidas gerais', 'Campus', 'Enem'])
                AppChip(cat, active: _formCat == cat, onTap: () => setState(() => _formCat = cat)),
            ]),
            const SizedBox(height: 12),
            AppField(hint: 'Digite sua mensagem…', value: _msg, onChanged: (v) => setState(() => _msg = v)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${_msg.length}/500', style: TextStyle(fontSize: 11.5, color: c.ink3)),
              AppButton('Enviar', size: AppButtonSize.sm, icon: 'send',
                onTap: _msg.trim().length < 5 ? null : () { setState(() => _msg = ''); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dúvida enviada ao campus!'))); }),
            ]),
          ]),
        ),
      ]),
    );
  }
}
```

> Nota: o `send` icon precisa existir no mapa de ícones. Se `appIcon('send')` cair no
> fallback, adicione `'send': Icons.send` ao mapa em `icon_tile.dart` (Task 1 do implementador
> pode incluir, se necessário).

- [ ] **Step 2:** `flutter analyze lib/features/faqs/` — sem erros. Se `send` faltar no mapa de ícones, adicionar `'send': Icons.send` em `lib/shared/widgets/icon_tile.dart`.
- [ ] **Step 3:** Commit — `git add lib/features/faqs/ lib/shared/widgets/icon_tile.dart && git commit -m "feat(faqs): tela de duvidas (FAQ com busca, categorias, encaminhar)"`

---

### Task 3: PerfilScreen (aba Perfil)

**Files:** Create `lib/features/profile/screens/perfil_screen.dart`

Hero verde com avatar, nome, e-mail (do auth) e estatísticas (Curso/Matrícula do
`currentProfileProvider`; "—" se não preenchido). Botão de tema (sol/lua) no topo do hero.
Card de configurações: Notificações (toggle local) + Modo escuro (toggle → `themeModeProvider`).
Grupos de itens (Editar perfil → /cadastrar; Carteirinha → em breve; Alterar senha → em breve;
Central de dúvidas → aba duvidas; Sobre o IFSP → /ifsp; Termos → em breve). Botão Sair.

- [ ] **Step 1: PerfilScreen**

`lib/features/profile/screens/perfil_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/courses.dart';
import '../../../shared/chrome/bottom_nav.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_toggle.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/user_avatar.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});
  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  bool _notif = true;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final user = ref.watch(authStateProvider).valueOrNull;
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final name = user?.name ?? 'Estudante';
    final stats = [
      ('Curso', profile?.course == null ? '—' : courseShort(profile!.course!)),
      ('Matrícula', profile?.enrollment ?? '—'),
    ];

    Widget rowItem(String icon, String label, VoidCallback onTap, {bool last = false}) => InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: c.line))),
        child: Row(children: [
          Icon(appIcon(icon), size: 21, color: c.green700),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: c.ink))),
          Icon(appIcon('chevR'), size: 17, color: c.ink3),
        ]),
      ),
    );

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      bottomNav: AppBottomNav(current: 'perfil', onTap: (k) => context.go('/$k')),
      header: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.heroFrom, c.heroTo]),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, kStatusH, 20, 24),
        child: Column(children: [
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => ref.read(themeModeProvider.notifier).toggle(),
              child: Padding(padding: const EdgeInsets.all(6), child: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 22, color: Colors.white)),
            ),
          ),
          UserAvatar(name, size: 84),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          if (user?.email != null) Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(user!.email, style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.78))),
          ),
          const SizedBox(height: 18),
          Row(children: [
            for (final (k, v) in stats) Expanded(child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
              child: Column(children: [
                Text(v, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 3),
                Text(k, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.72))),
              ]),
            )),
          ]),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          AppCard(padding: EdgeInsets.zero, child: Column(children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
              child: Row(children: [
                Icon(appIcon('bell'), size: 21, color: c.green700),
                const SizedBox(width: 14),
                Expanded(child: Text('Notificações', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: c.ink))),
                AppToggle(on: _notif, onChanged: (v) => setState(() => _notif = v)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
              child: Row(children: [
                Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, size: 21, color: c.green700),
                const SizedBox(width: 14),
                Expanded(child: Text('Modo escuro', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: c.ink))),
                AppToggle(on: isDark, onChanged: (_) => ref.read(themeModeProvider.notifier).toggle()),
              ]),
            ),
          ])),
          const SizedBox(height: 14),
          AppCard(padding: EdgeInsets.zero, child: Column(children: [
            rowItem('edit', 'Editar perfil', () => context.push('/cadastrar')),
            rowItem('card', 'Carteirinha digital', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve')))),
            rowItem('shield', 'Alterar senha', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve'))), last: true),
          ])),
          const SizedBox(height: 14),
          AppCard(padding: EdgeInsets.zero, child: Column(children: [
            rowItem('question', 'Central de dúvidas', () => context.go('/duvidas')),
            rowItem('institution', 'Sobre o IFSP Pirituba', () => context.push('/ifsp')),
            rowItem('doc', 'Termos e privacidade', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve'))), last: true),
          ])),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => ref.read(authRepositoryProvider).signOut(),
            child: AppCard(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(appIcon('logout'), size: 20, color: c.error),
              const SizedBox(width: 9),
              Text('Sair da conta', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.error)),
            ])),
          ),
          const SizedBox(height: 18),
          Text('UNIVERSE · v1.0 · IFSP Pirituba', style: TextStyle(fontSize: 11, color: c.ink3)),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 2:** `flutter analyze lib/features/profile/screens/perfil_screen.dart` — sem erros.
- [ ] **Step 3:** Commit — `git add lib/features/profile/screens/perfil_screen.dart && git commit -m "feat(profile): tela de perfil (dados, tema claro/escuro, acoes)"`

---

### Task 4: CadastrarScreen (editar perfil — curso/matrícula persistidos)

**Files:** Create `lib/features/profile/screens/cadastrar_screen.dart`

Formulário: Nome (somente leitura, vem do auth), Curso (dropdown `campusCourses`), Nº de
matrícula. Salvar grava o `StudentProfile` (curso/matrícula) via `profileRepository`, invalida
`currentProfileProvider` e volta. (Telefone/cidade ficam para quando o modelo de perfil crescer.)

- [ ] **Step 1: CadastrarScreen**

`lib/features/profile/screens/cadastrar_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/courses.dart';
import '../../../data/profile/student_profile.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/user_avatar.dart';

class CadastrarScreen extends ConsumerStatefulWidget {
  const CadastrarScreen({super.key});
  @override
  ConsumerState<CadastrarScreen> createState() => _CadastrarScreenState();
}

class _CadastrarScreenState extends ConsumerState<CadastrarScreen> {
  String? _course;
  String _enroll = '';
  bool _loading = false;
  bool _init = false;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final user = ref.watch(authStateProvider).valueOrNull;
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    // pré-preenche uma vez quando o perfil chega
    if (!_init && profile != null) {
      _course = profile.course;
      _enroll = profile.enrollment ?? '';
      _init = true;
    }

    Future<void> save() async {
      final uid = user?.id;
      if (uid == null) return;
      setState(() => _loading = true);
      await ref.read(profileRepositoryProvider).save(StudentProfile(uid: uid, course: _course, enrollment: _enroll.trim().isEmpty ? null : _enroll.trim()));
      ref.invalidate(currentProfileProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informações salvas!')));
        context.pop();
      }
    }

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: PageHeader(title: 'Editar perfil', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Column(children: [
            UserAvatar(user?.name ?? 'Estudante', size: 88),
            const SizedBox(height: 10),
            Text(user?.name ?? '', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
            if (user?.email != null) Text(user!.email, style: TextStyle(fontSize: 12.5, color: c.ink3)),
          ])),
          const SizedBox(height: 22),
          Text('Curso', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            initialValue: _course,
            isExpanded: true,
            decoration: InputDecoration(filled: true, fillColor: c.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(13))),
            items: [for (final n in campusCourses) DropdownMenuItem(value: n, child: Text(n, overflow: TextOverflow.ellipsis))],
            onChanged: (v) => setState(() => _course = v),
          ),
          const SizedBox(height: 14),
          AppField(label: 'Nº de matrícula', icon: 'card', value: _enroll, onChanged: (v) => setState(() => _enroll = v)),
          const SizedBox(height: 24),
          AppButton(_loading ? 'Salvando…' : 'Salvar alterações', full: true, icon: 'check', onTap: _loading ? null : save),
          const SizedBox(height: 10),
          AppButton('Cancelar', full: true, variant: AppButtonVariant.ghost, onTap: () => context.pop()),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 2:** `flutter analyze lib/features/profile/screens/cadastrar_screen.dart` — sem erros.
- [ ] **Step 3:** Commit — `git add lib/features/profile/screens/cadastrar_screen.dart && git commit -m "feat(profile): edicao de perfil com curso/matricula persistidos"`

---

### Task 5: Ligar no router

**Files:** Modify `lib/core/router/app_router.dart`

- [ ] **Step 1:** Imports:
```dart
import '../../features/faqs/screens/duvidas_screen.dart';
import '../../features/profile/screens/perfil_screen.dart';
import '../../features/profile/screens/cadastrar_screen.dart';
```
Trocar os builders das abas no ShellRoute:
```dart
GoRoute(path: '/duvidas', builder: (c, s) => const DuvidasScreen()),
GoRoute(path: '/perfil', builder: (c, s) => const PerfilScreen()),
```
Adicionar rota top-level:
```dart
GoRoute(path: '/cadastrar', builder: (c, s) => const CadastrarScreen()),
```
No `onNavigate` do drawer, `/cadastrar` cai no "Em breve"? Não — o drawer não lista cadastrar.
Mas a Home lista "Cadastrar informações" (`/cadastrar`). Atualizar `_pushRoutes` da Home para
incluir `/cadastrar` (Task abaixo).

- [ ] **Step 2: HomeScreen** — em `_pushRoutes`, adicionar `/cadastrar`:
```dart
  static const _pushRoutes = {'/ifsp', '/beneficios/gov', '/beneficios/inst', '/estagio', '/cadastrar'};
```

- [ ] **Step 3:** `flutter analyze` — limpo. `flutter test` — toda a suíte PASS. O `navigation_test` abre o drawer e troca de aba; como `/duvidas` e `/perfil` agora são telas reais, confirmar que ainda passa (o teste toca aba Cursos e abre drawer — não depende de duvidas/perfil). Se algum texto ficou ambíguo, ajustar com seletor único.
- [ ] **Step 4:** Commit — `git add lib/core/router/app_router.dart lib/features/home/screens/home_screen.dart && git commit -m "feat(nav): liga Duvidas, Perfil e Cadastrar no router"`

---

### Task 6: Verificação + diário

- [ ] **Step 1:** `flutter analyze` (limpo) + `flutter test` (tudo PASS).
- [ ] **Step 2:** Rodar no navegador; conferir: aba Dúvidas (busca, categorias, accordion abre/fecha, enviar); aba Perfil (dados, **alternar tema claro/escuro funciona**, editar perfil); Editar perfil → escolher curso + matrícula → salvar → volta e o Perfil mostra o curso.
- [ ] **Step 3:** Entrada no diário resumindo o 4C (fecha as telas de conteúdo; dark mode exposto; perfil editável com persistência de curso/matrícula).
- [ ] **Step 4:** Commit — `git add docs/ && git commit -m "docs: registra Plano 4C (Duvidas e Perfil)"`

---

## Self-Review
- **Dúvidas (FAQ):** busca + categorias + accordion (1 aberto por vez) + encaminhar dúvida — Task 2.
- **Perfil:** dados do aluno (curso/matrícula do perfil), **dark mode** exposto (themeModeProvider), ações, logout — Task 3.
- **Editar perfil:** curso (dropdown) + matrícula **persistidos** no Firestore (via ProfileRepository), invalida o provider — Task 4.
- **Design system:** Accordion + AppToggle adicionados — Task 1.
- Fecha as 4 abas e as telas de conteúdo no mock.

**Riscos/notas:**
1. Ícone `send` pode faltar no mapa — adicionar `'send': Icons.send` (Task 2).
2. Dark mode agora visível em todo o app (já suportado pelo tema desde o Plano 1).
3. `currentProfileProvider` é `FutureProvider`; usar `.valueOrNull` evita travar a UI enquanto carrega. Após salvar, `ref.invalidate(currentProfileProvider)` recarrega.
