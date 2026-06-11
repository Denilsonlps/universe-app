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
  AppColorsX copyWith({
    Color? green900, Color? green800, Color? green700, Color? green600,
    Color? green500, Color? green400, Color? green100, Color? green050,
    Color? navy, Color? bg, Color? bg2, Color? card,
    Color? ink, Color? ink2, Color? ink3, Color? line,
    Color? heroFrom, Color? heroTo, Color? error, Color? star,
  }) => AppColorsX(
    green900: green900 ?? this.green900, green800: green800 ?? this.green800,
    green700: green700 ?? this.green700, green600: green600 ?? this.green600,
    green500: green500 ?? this.green500, green400: green400 ?? this.green400,
    green100: green100 ?? this.green100, green050: green050 ?? this.green050,
    navy: navy ?? this.navy,
    bg: bg ?? this.bg, bg2: bg2 ?? this.bg2, card: card ?? this.card,
    ink: ink ?? this.ink, ink2: ink2 ?? this.ink2, ink3: ink3 ?? this.ink3,
    line: line ?? this.line,
    heroFrom: heroFrom ?? this.heroFrom, heroTo: heroTo ?? this.heroTo,
    error: error ?? this.error, star: star ?? this.star,
  );

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
