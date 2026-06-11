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
