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
