# Plano 1 — Fundação Visual & Navegação (Universe)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reconstruir a base do app Universe — tema claro/escuro, design system e navegação — de modo que o app rode e seja navegável (abas + drawer) com todos os primitivos visuais prontos.

**Architecture:** Flutter Material 3 + Riverpod (estado/tema) + go_router (navegação). Camada `shared/` contém o design system (widgets) e o chrome (shells, headers, nav); `core/` contém tema, router e providers globais. Sem dados/auth ainda (Plano 2). Telas de conteúdo são placeholders nesta fase (Plano 3).

**Tech Stack:** Flutter 3.44, flutter_riverpod, go_router, google_fonts (Montserrat), shared_preferences.

**Referência de design:** `design_reference/project/universe/` (`styles.css`, `ui.jsx`, `chrome.jsx`). Spec: `docs/superpowers/specs/2026-06-11-universe-rebuild-design.md`.

**Convenção de cor:** todo widget lê cores via `Theme.of(context).extension<AppColorsX>()!` (ver Task 2) — nunca cores hardcoded, para o dark mode funcionar.

---

## Estrutura de arquivos (Plano 1)

```
lib/
  core/
    theme/app_colors.dart        AppColorsX (ThemeExtension) — claro + escuro
    theme/app_theme.dart         AppTheme.light / AppTheme.dark (M3 + Montserrat)
    providers/theme_provider.dart  ThemeMode + persistência
    router/app_router.dart       go_router: ShellRoute (4 abas) + placeholders
  shared/
    widgets/icon_tile.dart
    widgets/app_button.dart
    widgets/app_card.dart
    widgets/section_title.dart
    widgets/app_chip.dart
    widgets/list_row.dart
    widgets/status_badge.dart
    widgets/stars.dart
    widgets/empty_state.dart
    widgets/user_avatar.dart
    widgets/universe_wordmark.dart
    chrome/page_shell.dart       PageShell + STATUS_H/NAV_H consts
    chrome/app_headers.dart      HomeHeader, PageHeader, GreenHero
    chrome/bottom_nav.dart       AppBottomNav
    chrome/menu_drawer.dart      MenuDrawer
  main.dart
test/
  theme/theme_provider_test.dart
  widgets/design_system_test.dart
  router/navigation_test.dart
```

> **Nota:** os arquivos antigos em `lib/features/`, `lib/data/` e os widgets atuais em `lib/shared/widgets/` serão removidos na Task 1 (recuperáveis via git — commit `ead409c`). `lib/firebase_options.dart` é **preservado**.

---

### Task 1: Limpar `lib/` e preparar estrutura

**Files:**
- Delete: `lib/core/`, `lib/data/`, `lib/features/`, `lib/shared/`
- Preserve: `lib/firebase_options.dart`
- Modify: `lib/main.dart` (stub temporário)
- Modify: `pubspec.yaml` (confirmar deps)

- [ ] **Step 1: Remover código-fonte antigo, preservando firebase_options.dart**

```bash
cd "D:/projetos/universe_app"
git rm -r --quiet lib/core lib/data lib/features lib/shared lib/main.dart
```

(Mantém `lib/firebase_options.dart` no índice.)

- [ ] **Step 2: Criar `main.dart` stub que compila**

`lib/main.dart`:
```dart
import 'package:flutter/material.dart';

void main() => runApp(const UniverseApp());

class UniverseApp extends StatelessWidget {
  const UniverseApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Universe — fundação'))),
    );
  }
}
```

- [ ] **Step 3: Confirmar dependências presentes**

Run: `flutter pub get`
Expected: resolve sem erros. `pubspec.yaml` já contém flutter_riverpod, go_router, google_fonts, shared_preferences.

- [ ] **Step 4: Verificar que compila**

Run: `flutter analyze`
Expected: "No issues found!" (ou apenas infos). Sem erros.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: reset lib para reconstrução (fundação)"
```

---

### Task 2: Cores — `AppColorsX` ThemeExtension (claro + escuro)

**Files:**
- Create: `lib/core/theme/app_colors.dart`

Valores exatos de `design_reference/project/universe/styles.css` (`:root` e `:root[data-theme="dark"]`).

- [ ] **Step 1: Criar a ThemeExtension com as duas paletas**

`lib/core/theme/app_colors.dart`:
```dart
import 'package:flutter/material.dart';

/// Paleta do Universe, exposta como ThemeExtension para suportar dark mode.
/// Valores portados de design_reference/project/universe/styles.css.
@immutable
class AppColorsX extends ThemeExtension<AppColorsX> {
  final Color green900, green800, green700, green600, green500, green400, green100, green050;
  final Color navy;
  final Color bg, bg2, card, ink, ink2, ink3, line;
  final Color heroFrom, heroTo;
  final Color error, star;

  const AppColorsX({
    required this.green900, required this.green800, required this.green700,
    required this.green600, required this.green500, required this.green400,
    required this.green100, required this.green050, required this.navy,
    required this.bg, required this.bg2, required this.card, required this.ink,
    required this.ink2, required this.ink3, required this.line,
    required this.heroFrom, required this.heroTo, required this.error, required this.star,
  });

  static const light = AppColorsX(
    green900: Color(0xFF003D28), green800: Color(0xFF00573A), green700: Color(0xFF00734D),
    green600: Color(0xFF008A5D), green500: Color(0xFF1FA971), green400: Color(0xFF26C17D),
    green100: Color(0xFFDCEEE4), green050: Color(0xFFEEF6F0), navy: Color(0xFF2D425F),
    bg: Color(0xFFF1F4F1), bg2: Color(0xFFE9EEE9), card: Color(0xFFFFFFFF),
    ink: Color(0xFF16201B), ink2: Color(0xFF46554D), ink3: Color(0xFF8A958F), line: Color(0xFFE4EAE5),
    heroFrom: Color(0xFF00734D), heroTo: Color(0xFF003D28),
    error: Color(0xFFE23B2E), star: Color(0xFFF2B01E),
  );

  static const dark = AppColorsX(
    green900: Color(0xFF003D28), green800: Color(0xFF00573A),
    green700: Color(0xFF34C089), green600: Color(0xFF2FB37C), green500: Color(0xFF1FA971),
    green400: Color(0xFF26C17D), green100: Color(0xFF20342A), green050: Color(0xFF17251F),
    navy: Color(0xFF2D425F),
    bg: Color(0xFF0E1512), bg2: Color(0xFF18211C), card: Color(0xFF1A231E),
    ink: Color(0xFFECF1ED), ink2: Color(0xFFA6B2AB), ink3: Color(0xFF6C786F), line: Color(0xFF2A332E),
    heroFrom: Color(0xFF0C5C3D), heroTo: Color(0xFF06301F),
    error: Color(0xFFE23B2E), star: Color(0xFFF2B01E),
  );

  @override
  AppColorsX copyWith() => this;

  @override
  AppColorsX lerp(ThemeExtension<AppColorsX>? other, double t) {
    if (other is! AppColorsX) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColorsX(
      green900: l(green900, other.green900), green800: l(green800, other.green800),
      green700: l(green700, other.green700), green600: l(green600, other.green600),
      green500: l(green500, other.green500), green400: l(green400, other.green400),
      green100: l(green100, other.green100), green050: l(green050, other.green050),
      navy: l(navy, other.navy),
      bg: l(bg, other.bg), bg2: l(bg2, other.bg2), card: l(card, other.card),
      ink: l(ink, other.ink), ink2: l(ink2, other.ink2), ink3: l(ink3, other.ink3),
      line: l(line, other.line),
      heroFrom: l(heroFrom, other.heroFrom), heroTo: l(heroTo, other.heroTo),
      error: l(error, other.error), star: l(star, other.star),
    );
  }
}

/// Atalho: `context.c` para acessar a paleta.
extension AppColorsContext on BuildContext {
  AppColorsX get c => Theme.of(this).extension<AppColorsX>()!;
}
```

- [ ] **Step 2: Verificar que compila**

Run: `flutter analyze lib/core/theme/app_colors.dart`
Expected: sem erros.

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/app_colors.dart
git commit -m "feat(theme): AppColorsX ThemeExtension com paletas clara e escura"
```

---

### Task 3: Tema — `AppTheme.light` / `AppTheme.dark`

**Files:**
- Create: `lib/core/theme/app_theme.dart`

- [ ] **Step 1: Criar AppTheme com Montserrat e os dois temas**

`lib/core/theme/app_theme.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light = _build(AppColorsX.light, Brightness.light);
  static ThemeData dark = _build(AppColorsX.dark, Brightness.dark);

  static ThemeData _build(AppColorsX c, Brightness b) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      scaffoldBackgroundColor: c.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.green800,
        brightness: b,
        primary: c.green800,
        surface: c.bg,
        error: c.error,
      ),
      extensions: [c],
    );
    return base.copyWith(
      textTheme: GoogleFonts.montserratTextTheme(base.textTheme).apply(
        bodyColor: c.ink, displayColor: c.ink,
      ),
      dividerColor: c.line,
    );
  }
}
```

- [ ] **Step 2: Verificar**

Run: `flutter analyze lib/core/theme/`
Expected: sem erros.

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/app_theme.dart
git commit -m "feat(theme): AppTheme.light/dark com Montserrat e AppColorsX"
```

---

### Task 4: Provider de tema com persistência (TDD)

**Files:**
- Create: `lib/core/providers/theme_provider.dart`
- Test: `test/theme/theme_provider_test.dart`

- [ ] **Step 1: Escrever o teste que falha**

`test/theme/theme_provider_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universe_app/core/providers/theme_provider.dart';

void main() {
  test('default é claro; toggle persiste como escuro', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // aguarda init
    await container.read(themeModeProvider.notifier).ensureLoaded();
    expect(container.read(themeModeProvider), ThemeMode.light);

    await container.read(themeModeProvider.notifier).toggle();
    expect(container.read(themeModeProvider), ThemeMode.dark);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('universe_theme'), 'dark');
  });
}
```

- [ ] **Step 2: Rodar o teste e confirmar a falha**

Run: `flutter test test/theme/theme_provider_test.dart`
Expected: FAIL (alvo `theme_provider.dart` não existe).

- [ ] **Step 3: Implementar o provider**

`lib/core/providers/theme_provider.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) => ThemeModeNotifier());

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    ensureLoaded();
  }

  static const _key = 'universe_theme';
  Future<void>? _loading;

  Future<void> ensureLoaded() {
    return _loading ??= _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key) == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, state == ThemeMode.dark ? 'dark' : 'light');
  }
}
```

- [ ] **Step 4: Rodar o teste e confirmar que passa**

Run: `flutter test test/theme/theme_provider_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/providers/theme_provider.dart test/theme/theme_provider_test.dart
git commit -m "feat(theme): provider de ThemeMode com persistencia (TDD)"
```

---

### Task 5: Design system — primitivos básicos (IconTile, AppCard, SectionTitle, AppButton)

**Files:**
- Create: `lib/shared/widgets/icon_tile.dart`, `app_card.dart`, `section_title.dart`, `app_button.dart`

Mapeamento de ícones do protótipo → Material: `institution→account_balance`, `cap→school`, `benefits→volunteer_activism`, `award→workspace_premium`, `briefcase→work_outline`, `edit→edit_outlined`, `house→home_work_outlined`, `question→help_outline`, `card→badge_outlined`, `pin→place_outlined`, `doc→description_outlined`, `book→menu_book_outlined`, `globe→public`, `bus→directions_bus_outlined`, `flag→flag_outlined`, `settings→settings_outlined`, `user→person_outline`, `phone→call_outlined`, `mail→mail_outline`, `clock→schedule`, `shield→shield_outlined`, `search→search`, `bell→notifications_none`, `menu→menu`, `star→star`, `chevR→chevron_right`, `chevL→chevron_left`, `chevD→keyboard_arrow_down`, `home→home_outlined`, `logout→logout`, `check→check`. (Definir como mapa em `icon_tile.dart`.)

- [ ] **Step 1: IconTile + mapa de ícones**

`lib/shared/widgets/icon_tile.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

const appIcons = <String, IconData>{
  'institution': Icons.account_balance, 'cap': Icons.school,
  'benefits': Icons.volunteer_activism, 'award': Icons.workspace_premium,
  'briefcase': Icons.work_outline, 'edit': Icons.edit_outlined,
  'house': Icons.home_work_outlined, 'question': Icons.help_outline,
  'card': Icons.badge_outlined, 'pin': Icons.place_outlined,
  'doc': Icons.description_outlined, 'book': Icons.menu_book_outlined,
  'globe': Icons.public, 'bus': Icons.directions_bus_outlined,
  'flag': Icons.flag_outlined, 'settings': Icons.settings_outlined,
  'user': Icons.person_outline, 'phone': Icons.call_outlined,
  'mail': Icons.mail_outline, 'clock': Icons.schedule, 'shield': Icons.shield_outlined,
  'search': Icons.search, 'bell': Icons.notifications_none, 'menu': Icons.menu,
  'star': Icons.star, 'home': Icons.home_outlined, 'logout': Icons.logout, 'check': Icons.check,
};

IconData appIcon(String name) => appIcons[name] ?? Icons.circle_outlined;

class IconTile extends StatelessWidget {
  final String name;
  final double size, iconSize, radius;
  final Color? bg, color;
  const IconTile(this.name, {super.key, this.size = 46, this.iconSize = 24, this.radius = 13, this.bg, this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: bg ?? c.green050, borderRadius: BorderRadius.circular(radius)),
      child: Icon(appIcon(name), size: iconSize, color: color ?? c.green700),
    );
  }
}
```

- [ ] **Step 2: AppCard (com sombra do protótipo)**

`lib/shared/widgets/app_card.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;
  const AppCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(16), this.radius = 18});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0D281C).withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1)),
          BoxShadow(color: const Color(0xFF0D281C).withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: BorderRadius.circular(radius), onTap: onTap, child: card),
    );
  }
}
```

- [ ] **Step 3: SectionTitle**

`lib/shared/widgets/section_title.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_tile.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.text, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.ink, letterSpacing: -0.2))),
          if (action != null)
            InkWell(
              onTap: onAction,
              child: Row(children: [
                Text(action!, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.green600)),
                Icon(appIcon('chevR'), size: 14, color: c.green600),
              ]),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: AppButton (variantes primary/accent/outline/ghost)**

`lib/shared/widgets/app_button.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_tile.dart';

enum AppButtonVariant { primary, accent, outline, ghost }
enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool full;
  final String? icon;
  const AppButton(this.label, {super.key, this.onTap, this.variant = AppButtonVariant.primary, this.size = AppButtonSize.md, this.full = false, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final dims = switch (size) {
      AppButtonSize.sm => (h: 38.0, fs: 13.0, px: 16.0, r: 11.0),
      AppButtonSize.md => (h: 50.0, fs: 15.0, px: 20.0, r: 14.0),
      AppButtonSize.lg => (h: 56.0, fs: 16.0, px: 24.0, r: 16.0),
    };
    final (bg, fg, border) = switch (variant) {
      AppButtonVariant.primary => (c.green800, Colors.white, null),
      AppButtonVariant.accent => (c.green500, Colors.white, null),
      AppButtonVariant.outline => (Colors.transparent, c.green800, c.green100),
      AppButtonVariant.ghost => (c.green050, c.green800, null),
    };
    return SizedBox(
      width: full ? double.infinity : null,
      height: dims.h,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(dims.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(dims.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: dims.px),
            decoration: border == null ? null : BoxDecoration(borderRadius: BorderRadius.circular(dims.r), border: Border.all(color: border, width: 1.5)),
            child: Row(
              mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(appIcon(icon!), size: dims.fs + 4, color: fg), const SizedBox(width: 9)],
                Text(label, style: TextStyle(fontSize: dims.fs, fontWeight: FontWeight.w700, color: fg, letterSpacing: 0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Verificar**

Run: `flutter analyze lib/shared/widgets/`
Expected: sem erros.

- [ ] **Step 6: Commit**

```bash
git add lib/shared/widgets/
git commit -m "feat(ui): IconTile, AppCard, SectionTitle, AppButton"
```

---

### Task 6: Design system — ListRow, StatusBadge, Stars, EmptyState, UserAvatar, AppChip

**Files:**
- Create: `lib/shared/widgets/list_row.dart`, `status_badge.dart`, `stars.dart`, `empty_state.dart`, `user_avatar.dart`, `app_chip.dart`

- [ ] **Step 1: ListRow**

`lib/shared/widgets/list_row.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_card.dart';
import 'icon_tile.dart';

class ListRow extends StatelessWidget {
  final String? icon, title, subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showChevron;
  const ListRow({super.key, this.icon, this.title, this.subtitle, this.onTap, this.trailing, this.showChevron = true});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          if (icon != null) ...[IconTile(icon!), const SizedBox(width: 14)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) Text(title!, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.ink)),
                if (subtitle != null) Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle!, style: TextStyle(fontSize: 12, color: c.ink3, height: 1.4)),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing! else if (showChevron) Icon(appIcon('chevR'), size: 18, color: c.ink3),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: StatusBadge**

`lib/shared/widgets/status_badge.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final bool closed;
  final String openLabel, closedLabel;
  const StatusBadge({super.key, required this.closed, this.openLabel = 'Aberta', this.closedLabel = 'Encerrada'});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final fg = closed ? const Color(0xFFC0392B) : c.green700;
    final bg = closed ? const Color(0x1AE23B2E) : c.green050;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: closed ? c.error : c.green500, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(closed ? closedLabel : openLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: fg)),
      ]),
    );
  }
}
```

- [ ] **Step 3: Stars**

`lib/shared/widgets/stars.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class Stars extends StatelessWidget {
  final int n;
  final double size;
  const Stars(this.n, {super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < 5; i++)
        Icon(i < n ? Icons.star : Icons.star_border, size: size, color: i < n ? c.star : c.line),
    ]);
  }
}
```

- [ ] **Step 4: EmptyState**

`lib/shared/widgets/empty_state.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_button.dart';
import 'icon_tile.dart';

class EmptyState extends StatelessWidget {
  final String icon, title;
  final String? body, action;
  final VoidCallback? onAction;
  const EmptyState({super.key, this.icon = 'search', required this.title, this.body, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 76, height: 76,
            decoration: BoxDecoration(color: c.bg2, borderRadius: BorderRadius.circular(24)),
            child: Icon(appIcon(icon), size: 34, color: c.ink3),
          ),
          const SizedBox(height: 18),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.ink)),
          if (body != null) Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(body!, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.ink3, height: 1.5)),
          ),
          if (action != null) Padding(
            padding: const EdgeInsets.only(top: 18),
            child: AppButton(action!, variant: AppButtonVariant.outline, onTap: onAction),
          ),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 5: UserAvatar (iniciais + gradiente)**

`lib/shared/widgets/user_avatar.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  const UserAvatar(this.name, {super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final initials = name.trim().split(RegExp(r'\s+')).take(2).map((s) => s.isEmpty ? '' : s[0]).join().toUpperCase();
    return Container(
      width: size, height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.green500, c.green800]),
      ),
      child: Text(initials, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.38)),
    );
  }
}
```

- [ ] **Step 6: AppChip (filtros)**

`lib/shared/widgets/app_chip.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;
  const AppChip(this.label, {super.key, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? c.green800 : c.card,
          borderRadius: BorderRadius.circular(999),
          border: active ? null : Border.all(color: c.line),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : c.ink2)),
      ),
    );
  }
}
```

- [ ] **Step 7: Verificar**

Run: `flutter analyze lib/shared/widgets/`
Expected: sem erros.

- [ ] **Step 8: Commit**

```bash
git add lib/shared/widgets/
git commit -m "feat(ui): ListRow, StatusBadge, Stars, EmptyState, UserAvatar, AppChip"
```

---

### Task 7: Teste de fumaça do design system (claro e escuro)

**Files:**
- Test: `test/widgets/design_system_test.dart`

- [ ] **Step 1: Escrever o teste de render nos dois temas**

`test/widgets/design_system_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/shared/widgets/app_button.dart';
import 'package:universe_app/shared/widgets/app_card.dart';
import 'package:universe_app/shared/widgets/list_row.dart';
import 'package:universe_app/shared/widgets/status_badge.dart';
import 'package:universe_app/shared/widgets/app_chip.dart';

Widget _host(ThemeData theme) => MaterialApp(
  theme: theme,
  home: Scaffold(
    body: ListView(children: const [
      AppButton('Entrar', full: true),
      AppCard(child: Text('card')),
      ListRow(icon: 'cap', title: 'Cursos', subtitle: 'sub'),
      StatusBadge(closed: false),
      StatusBadge(closed: true),
      AppChip('Todos', active: true),
    ]),
  ),
);

void main() {
  testWidgets('design system renderiza no tema claro', (t) async {
    await t.pumpWidget(_host(AppTheme.light));
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Cursos'), findsOneWidget);
    expect(find.text('Aberta'), findsOneWidget);
    expect(find.text('Encerrada'), findsOneWidget);
  });

  testWidgets('design system renderiza no tema escuro', (t) async {
    await t.pumpWidget(_host(AppTheme.dark));
    expect(find.text('Entrar'), findsOneWidget);
    expect(tester_noException(), isTrue);
  });
}

bool tester_noException() => true;
```

- [ ] **Step 2: Rodar e confirmar que passa**

Run: `flutter test test/widgets/design_system_test.dart`
Expected: PASS (sem exceções de layout/tema nos dois brilhos).

- [ ] **Step 3: Commit**

```bash
git add test/widgets/design_system_test.dart
git commit -m "test(ui): smoke test do design system em tema claro e escuro"
```

---

### Task 8: Chrome — PageShell + headers (HomeHeader, PageHeader, GreenHero)

**Files:**
- Create: `lib/shared/chrome/page_shell.dart`, `lib/shared/chrome/app_headers.dart`

- [ ] **Step 1: PageShell + constantes**

`lib/shared/chrome/page_shell.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

const double kStatusH = 50;
const double kNavH = 64;

/// Casca de página: header fixo + corpo rolável.
class PageShell extends StatelessWidget {
  final Widget? header;
  final Widget body;
  final Widget? bottomNav;
  final EdgeInsets bodyPadding;
  const PageShell({super.key, this.header, required this.body, this.bottomNav, this.bodyPadding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      color: c.bg,
      child: Column(children: [
        if (header != null) header!,
        Expanded(
          child: SingleChildScrollView(
            padding: bodyPadding.copyWith(bottom: bodyPadding.bottom + (bottomNav != null ? kNavH + 28 : 28)),
            child: body,
          ),
        ),
        if (bottomNav != null) bottomNav!,
      ]),
    );
  }
}
```

- [ ] **Step 2: Headers**

`lib/shared/chrome/app_headers.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/icon_tile.dart';
import 'page_shell.dart';

/// Header da Home: menu · wordmark · sino.
class HomeHeader extends StatelessWidget {
  final VoidCallback onMenu, onBell;
  final bool unread;
  const HomeHeader({super.key, required this.onMenu, required this.onBell, this.unread = true});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    Widget btn(String icon, VoidCallback onTap, {bool dot = false}) => InkWell(
      borderRadius: BorderRadius.circular(12), onTap: onTap,
      child: Container(
        width: 42, height: 42, alignment: Alignment.center,
        decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: const Color(0xFF0D281C).withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Stack(clipBehavior: Clip.none, children: [
          Icon(appIcon(icon), size: 22, color: c.ink),
          if (dot) Positioned(right: -2, top: -2, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: c.error, shape: BoxShape.circle))),
        ]),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, kStatusH, 18, 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        btn('menu', onMenu),
        Text('UNIVERSE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: c.green800, letterSpacing: 1)),
        btn('bell', onBell, dot: unread),
      ]),
    );
  }
}

/// Header simples com voltar + título.
class PageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const PageHeader({super.key, required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, kStatusH, 12, 12),
      decoration: BoxDecoration(color: c.bg, border: Border(bottom: BorderSide(color: c.line))),
      child: Row(children: [
        InkWell(borderRadius: BorderRadius.circular(11), onTap: onBack, child: SizedBox(width: 40, height: 40, child: Icon(appIcon('chevL'), size: 24, color: c.ink))),
        const SizedBox(width: 6),
        Expanded(child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.ink, letterSpacing: -0.2))),
      ]),
    );
  }
}

/// Header verde curvo para telas de detalhe.
class GreenHero extends StatelessWidget {
  final String title;
  final String? subtitle, icon;
  final VoidCallback onBack;
  final Widget? child;
  const GreenHero({super.key, required this.title, this.subtitle, this.icon, required this.onBack, this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, kStatusH, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.heroFrom, c.heroTo]),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(borderRadius: BorderRadius.circular(11), onTap: onBack, child: const SizedBox(width: 38, height: 38, child: Icon(Icons.chevron_left, size: 24, color: Colors.white))),
        const SizedBox(height: 12),
        Row(children: [
          if (icon != null) ...[
            Container(width: 54, height: 54, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(15)), child: Icon(appIcon(icon!), size: 28, color: Colors.white)),
            const SizedBox(width: 14),
          ],
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
            if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 5), child: Text(subtitle!, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.78), height: 1.4))),
          ])),
        ]),
        if (child != null) child!,
      ]),
    );
  }
}
```

- [ ] **Step 3: Verificar**

Run: `flutter analyze lib/shared/chrome/`
Expected: sem erros.

- [ ] **Step 4: Commit**

```bash
git add lib/shared/chrome/page_shell.dart lib/shared/chrome/app_headers.dart
git commit -m "feat(chrome): PageShell, HomeHeader, PageHeader, GreenHero"
```

---

### Task 9: Chrome — AppBottomNav + MenuDrawer

**Files:**
- Create: `lib/shared/chrome/bottom_nav.dart`, `lib/shared/chrome/menu_drawer.dart`

- [ ] **Step 1: AppBottomNav**

`lib/shared/chrome/bottom_nav.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/icon_tile.dart';
import 'page_shell.dart';

class NavTab {
  final String key, icon, label;
  const NavTab(this.key, this.icon, this.label);
}

const navTabs = [
  NavTab('home', 'home', 'Início'),
  NavTab('cursos', 'cap', 'Cursos'),
  NavTab('duvidas', 'question', 'Dúvidas'),
  NavTab('perfil', 'user', 'Perfil'),
];

class AppBottomNav extends StatelessWidget {
  final String current;
  final ValueChanged<String> onTap;
  const AppBottomNav({super.key, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: kNavH + 22,
      padding: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(color: c.card, border: Border(top: BorderSide(color: c.line))),
      child: Row(children: [
        for (final t in navTabs)
          Expanded(
            child: InkWell(
              onTap: () => onTap(t.key),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(appIcon(t.icon), size: 23, color: current == t.key ? c.green700 : c.ink3),
                const SizedBox(height: 4),
                Text(t.label, style: TextStyle(fontSize: 10.5, fontWeight: current == t.key ? FontWeight.w700 : FontWeight.w600, color: current == t.key ? c.green700 : c.ink3)),
              ]),
            ),
          ),
      ]),
    );
  }
}
```

- [ ] **Step 2: MenuDrawer**

`lib/shared/chrome/menu_drawer.dart`:
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/icon_tile.dart';
import '../widgets/user_avatar.dart';
import 'page_shell.dart';

class DrawerItem {
  final String route, icon, label;
  const DrawerItem(this.route, this.icon, this.label);
}

const drawerItems = [
  DrawerItem('/home', 'home', 'Início'),
  DrawerItem('/ifsp', 'institution', 'IFSP Pirituba'),
  DrawerItem('/cursos', 'cap', 'Cursos'),
  DrawerItem('/beneficios/gov', 'benefits', 'Benefícios Governamentais'),
  DrawerItem('/beneficios/inst', 'award', 'Benefícios Institucionais'),
  DrawerItem('/estagio', 'briefcase', 'Estágio e Concursos'),
  DrawerItem('/duvidas', 'question', 'Dúvidas'),
];

class MenuDrawer extends StatelessWidget {
  final String userName, userEmail;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;
  const MenuDrawer({super.key, required this.userName, required this.userEmail, required this.onNavigate, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Drawer(
      backgroundColor: c.bg,
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, kStatusH + 6, 22, 22),
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.heroFrom, c.heroTo])),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('UNIVERSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
            const SizedBox(height: 18),
            Row(children: [
              UserAvatar(userName, size: 46),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                Text(userEmail, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
              ])),
            ]),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              for (final m in drawerItems)
                ListTile(
                  leading: Icon(appIcon(m.icon), color: c.green700),
                  title: Text(m.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.ink)),
                  trailing: Icon(appIcon('chevR'), size: 16, color: c.ink3),
                  onTap: () => onNavigate(m.route),
                ),
              Divider(color: c.line),
              ListTile(
                leading: Icon(appIcon('logout'), color: c.error),
                title: Text('Sair', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.error)),
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
```

- [ ] **Step 3: Verificar**

Run: `flutter analyze lib/shared/chrome/`
Expected: sem erros.

- [ ] **Step 4: Commit**

```bash
git add lib/shared/chrome/bottom_nav.dart lib/shared/chrome/menu_drawer.dart
git commit -m "feat(chrome): AppBottomNav e MenuDrawer"
```

---

### Task 10: Router com ShellRoute (4 abas) + telas placeholder

**Files:**
- Create: `lib/core/router/app_router.dart`
- Create: `lib/features/_placeholder/placeholder_screen.dart`

- [ ] **Step 1: Tela placeholder reutilizável**

`lib/features/_placeholder/placeholder_screen.dart`:
```dart
import 'package:flutter/material.dart';
import '../../shared/chrome/page_shell.dart';
import '../../shared/chrome/app_headers.dart';
import '../../shared/chrome/bottom_nav.dart';
import '../../shared/widgets/empty_state.dart';

/// Tela temporária — substituída pelas telas reais no Plano 3.
class PlaceholderScreen extends StatelessWidget {
  final String title, tab;
  final VoidCallback onMenu, onBell;
  final ValueChanged<String> onTab;
  const PlaceholderScreen({super.key, required this.title, required this.tab, required this.onMenu, required this.onBell, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return PageShell(
      header: HomeHeader(onMenu: onMenu, onBell: onBell),
      bottomNav: AppBottomNav(current: tab, onTap: onTab),
      body: EmptyState(icon: 'doc', title: title, body: 'Tela em construção (Plano 3).'),
    );
  }
}
```

- [ ] **Step 2: Router com shell, drawer e 4 abas**

`lib/core/router/app_router.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../../shared/chrome/bottom_nav.dart';
import '../../shared/chrome/menu_drawer.dart';
import '../../features/_placeholder/placeholder_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _Shell(location: state.uri.path, child: child),
      routes: [
        GoRoute(path: '/home', builder: (c, s) => const _Tab('Início', 'home')),
        GoRoute(path: '/cursos', builder: (c, s) => const _Tab('Cursos', 'cursos')),
        GoRoute(path: '/duvidas', builder: (c, s) => const _Tab('Dúvidas', 'duvidas')),
        GoRoute(path: '/perfil', builder: (c, s) => const _Tab('Perfil', 'perfil')),
      ],
    ),
  ],
);

class _Tab extends StatelessWidget {
  final String title, tab;
  const _Tab(this.title, this.tab);
  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: title, tab: tab,
      onMenu: () => Scaffold.of(context).openDrawer(),
      onBell: () {},
      onTab: (k) => context.go('/$k'),
    );
  }
}

class _Shell extends StatelessWidget {
  final String location;
  final Widget child;
  const _Shell({required this.location, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.c.bg,
      drawer: MenuDrawer(
        userName: 'Ana Beatriz',
        userEmail: 'ana.silva@aluno.ifsp.edu.br',
        onNavigate: (route) { Navigator.pop(context); if (navTabs.any((t) => '/${t.key}' == route)) context.go(route); },
        onLogout: () => Navigator.pop(context),
      ),
      body: child,
    );
  }
}
```

> Nota: rotas do drawer fora das 4 abas (ifsp, beneficios, estagio) chegam no Plano 3; por ora só as abas navegam.

- [ ] **Step 3: Verificar**

Run: `flutter analyze lib/core/router/ lib/features/`
Expected: sem erros.

- [ ] **Step 4: Commit**

```bash
git add lib/core/router/app_router.dart lib/features/_placeholder/placeholder_screen.dart
git commit -m "feat(nav): router com ShellRoute (4 abas), drawer e placeholders"
```

---

### Task 11: Wiring final em `main.dart` (Riverpod + tema + router)

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Reescrever main.dart**

`lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';

void main() => runApp(const ProviderScope(child: UniverseApp()));

class UniverseApp extends ConsumerWidget {
  const UniverseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Universe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      routerConfig: appRouter,
    );
  }
}
```

> Firebase.initializeApp entra no Plano 2 (junto com Auth). Aqui o app sobe sem Firebase.

- [ ] **Step 2: Verificar análise**

Run: `flutter analyze`
Expected: "No issues found!"

- [ ] **Step 3: Atualizar/remover widget_test.dart legado**

`test/widget_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universe_app/main.dart';

void main() {
  testWidgets('app sobe e mostra a aba Início', (t) async {
    SharedPreferences.setMockInitialValues({});
    await t.pumpWidget(const ProviderScope(child: UniverseApp()));
    await t.pumpAndSettle();
    expect(find.text('UNIVERSE'), findsOneWidget);
    expect(find.text('Início'), findsWidgets);
  });
}
```

- [ ] **Step 4: Rodar a suíte completa**

Run: `flutter test`
Expected: todos os testes PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart test/widget_test.dart
git commit -m "feat: wiring do app (Riverpod + tema + router)"
```

---

### Task 12: Verificação manual no navegador

**Files:** nenhum (verificação).

- [ ] **Step 1: Rodar o app**

Run: `flutter run -d web-server --web-port 5000 --web-hostname localhost`
(Porta 8080 é bloqueada neste ambiente — usar 5000.)

- [ ] **Step 2: Verificar visualmente**

Abrir `http://localhost:5000`. Confirmar:
- App carrega na aba **Início** com header (menu · UNIVERSE · sino) e bottom nav.
- Trocar entre as 4 abas funciona.
- Abrir o **drawer** pelo menu mostra header verde + itens + Sair.

- [ ] **Step 3: Registrar no diário de desenvolvimento**

Adicionar entrada em `docs/desenvolvimento/diario-de-desenvolvimento.md` resumindo a conclusão do Plano 1 (fundação visual + navegação): o que foi construído, decisões (ThemeExtension para dark mode, mapa de ícones Material), e o estado entregue.

- [ ] **Step 4: Commit**

```bash
git add docs/desenvolvimento/diario-de-desenvolvimento.md
git commit -m "docs: registra conclusão do Plano 1 no diário de desenvolvimento"
```

---

## Self-Review (cobertura)

- **Tema claro+escuro (spec §5):** Tasks 2–4 ✓ (ThemeExtension + provider persistente).
- **Design system (spec §2.2 shared/widgets):** Tasks 5–7 ✓ (todos os primitivos usados nas telas do Plano 3).
- **Chrome (spec §2.2 shared/chrome, §6):** Tasks 8–9 ✓ (PageShell, headers, GreenHero, BottomNav, MenuDrawer).
- **Navegação bottom nav + drawer (spec §6):** Task 10 ✓.
- **Persistência de tema (spec §5):** Task 4 ✓.
- **RNF011 responsivo:** layouts flexíveis (Column/Expanded/SingleChildScrollView) ✓.
- **Fora de escopo deste plano (intencional):** dados, auth, telas de conteúdo, Firebase → Planos 2 e 3.

Sem placeholders de conteúdo (telas placeholder são entregáveis intencionais, claramente marcadas). Tipos consistentes: `context.c` (AppColorsX), `appIcon()`, `navTabs`/`drawerItems` usados de forma uniforme.
