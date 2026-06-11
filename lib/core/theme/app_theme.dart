import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const green900 = Color(0xFF003D28);
  static const green800 = Color(0xFF00573A);
  static const green700 = Color(0xFF00734D);
  static const green600 = Color(0xFF008A5D);
  static const green500 = Color(0xFF1FA971);
  static const green400 = Color(0xFF26C17D);
  static const green100 = Color(0xFFDCEEE4);
  static const green050 = Color(0xFFEEF6F0);
  static const bg = Color(0xFFF1F4F1);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF16201B);
  static const ink2 = Color(0xFF46554D);
  static const ink3 = Color(0xFF8A958F);
  static const line = Color(0xFFE4EAE5);
  static const error = Color(0xFFE23B2E);
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.green800,
        onPrimary: Colors.white,
        primaryContainer: AppColors.green100,
        onPrimaryContainer: AppColors.green900,
        secondary: AppColors.green500,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.green050,
        onSecondaryContainer: AppColors.green800,
        tertiary: AppColors.green400,
        onTertiary: Colors.white,
        surface: AppColors.bg,
        onSurface: AppColors.ink,
        surfaceContainerHighest: AppColors.card,
        onSurfaceVariant: AppColors.ink2,
        outline: AppColors.line,
        outlineVariant: AppColors.line,
        error: AppColors.error,
        onError: Colors.white,
        shadow: Color(0x1A003D28),
      ),
      scaffoldBackgroundColor: AppColors.bg,
    );

    final textTheme = GoogleFonts.montserratTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.ink2,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.ink3,
      ),
      labelLarge: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      labelMedium: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.ink2,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.montserrat(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.ink3,
        letterSpacing: 0.5,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.green800,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        shadowColor: const Color(0x1A003D28),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green800,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.green800,
          side: const BorderSide(color: AppColors.green800, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.green800,
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.green500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.montserrat(
          fontSize: 14,
          color: AppColors.ink3,
        ),
        labelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          color: AppColors.ink2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.green800,
        unselectedItemColor: AppColors.ink3,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.green050,
        labelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.green800,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.green900,
        contentTextStyle: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --shadow-sm: 0 1px 2px rgba(13,40,28,0.05), 0 2px 8px rgba(13,40,28,0.04)
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0D281C).withValues(alpha: 0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: const Color(0xFF0D281C).withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  // --shadow-md: 0 4px 14px rgba(13,40,28,0.08), 0 1px 3px rgba(13,40,28,0.05)
  static List<BoxShadow> get cardShadowMd => [
        BoxShadow(
          color: const Color(0xFF0D281C).withValues(alpha: 0.08),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF0D281C).withValues(alpha: 0.05),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get cardShadowSmall => [
        BoxShadow(
          color: const Color(0xFF0D281C).withValues(alpha: 0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: const Color(0xFF0D281C).withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
