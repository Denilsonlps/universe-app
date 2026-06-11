import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class UniverseWordmark extends StatelessWidget {
  final double height;
  final Color? color;

  const UniverseWordmark({
    super.key,
    this.height = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.green800;
    final fontSize = height * 0.85;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'UNI',
            style: GoogleFonts.montserrat(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 1.0,
            ),
          ),
          TextSpan(
            text: 'VERSE',
            style: GoogleFonts.montserrat(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
