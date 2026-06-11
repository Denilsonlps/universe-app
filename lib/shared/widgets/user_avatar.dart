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
