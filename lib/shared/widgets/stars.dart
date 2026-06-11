import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class Stars extends StatelessWidget {
  final int n;
  final double size;
  const Stars(this.n, {super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < 5; i++)
        Icon(i < n ? Icons.star : Icons.star_border, size: size, color: i < n ? c.star : c.line),
    ]);
  }
}
