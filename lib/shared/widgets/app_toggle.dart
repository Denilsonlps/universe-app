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
