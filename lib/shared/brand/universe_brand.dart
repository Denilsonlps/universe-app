import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// O "mark" da Universe: chevron em V (capelo/visto) coroado por um ponto
/// (cabeça do formando). Geometria portada de brand.jsx (viewBox 64×64).
class UniverseMark extends StatelessWidget {
  final double size;
  final Color color;
  final Color? dotColor;
  const UniverseMark({super.key, this.size = 64, this.color = const Color(0xFF00573A), this.dotColor});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _MarkPainter(color, dotColor ?? color)));
}

class _MarkPainter extends CustomPainter {
  final Color color, dotColor;
  _MarkPainter(this.color, this.dotColor);
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64.0;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(13 * s, 17 * s)
      ..lineTo(32 * s, 51 * s)
      ..lineTo(51 * s, 17 * s);
    canvas.drawPath(path, stroke);
    canvas.drawCircle(Offset(32 * s, 12.5 * s), 7 * s, Paint()..color = dotColor);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.color != color || old.dotColor != dotColor;
}

/// Selo circular (monograma do mark). Geometria de brand.jsx (viewBox 44×44).
class UniverseBadge extends StatelessWidget {
  final double size;
  final Color color;
  final Color? ring;
  const UniverseBadge({super.key, this.size = 44, this.color = const Color(0xFF1FA971), this.ring});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size, height: size, child: CustomPaint(painter: _BadgePainter(color, ring ?? color)));
}

class _BadgePainter extends CustomPainter {
  final Color color, ring;
  _BadgePainter(this.color, this.ring);
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 44.0;
    canvas.drawCircle(
      Offset(22 * s, 22 * s), 20 * s,
      Paint()..color = ring.withValues(alpha: 0.55)..style = PaintingStyle.stroke..strokeWidth = 2.4 * s,
    );
    final v = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.4 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()..moveTo(13 * s, 18 * s)..lineTo(22 * s, 34 * s)..lineTo(31 * s, 18 * s), v,
    );
    canvas.drawCircle(Offset(22 * s, 13.5 * s), 3.4 * s, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BadgePainter old) => old.color != color || old.ring != ring;
}

/// Ícone do app: squircle verde com gradiente, brilho e o mark em branco.
class UniverseAppIcon extends StatelessWidget {
  final double size;
  final double? radius;
  const UniverseAppIcon({super.key, this.size = 96, this.radius});

  @override
  Widget build(BuildContext context) {
    final r = radius ?? size * 0.235;
    return Container(
      width: size, height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        gradient: const LinearGradient(
          begin: Alignment.topRight, end: Alignment.bottomLeft,
          colors: [Color(0xFF00734D), Color(0xFF00573A), Color(0xFF003D28)], stops: [0, 0.55, 1],
        ),
      ),
      child: Stack(alignment: Alignment.center, children: [
        Positioned(
          top: -size * 0.35, left: -size * 0.2,
          child: Container(
            width: size * 0.9, height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [const Color(0xFF26C17D).withValues(alpha: 0.55), Colors.transparent], stops: const [0, 0.7]),
            ),
          ),
        ),
        UniverseMark(size: size * 0.62, color: Colors.white, dotColor: const Color(0xFF26C17D)),
      ]),
    );
  }
}

/// Wordmark completo: UNI + mark + RSE, recriado em tipografia (Montserrat 800).
class UniverseWordmark extends StatelessWidget {
  final double height;
  final Color color;
  const UniverseWordmark({super.key, this.height = 28, this.color = const Color(0xFF00573A)});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.montserrat(
      fontSize: height, fontWeight: FontWeight.w800, letterSpacing: height * 0.02, color: color, height: 1,
    );
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text('UNI', style: style),
      UniverseMark(size: height * 1.18, color: color, dotColor: color),
      Text('RSE', style: style),
    ]);
  }
}
