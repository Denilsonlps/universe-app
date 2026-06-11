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
