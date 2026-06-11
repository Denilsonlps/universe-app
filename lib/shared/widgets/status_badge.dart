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
