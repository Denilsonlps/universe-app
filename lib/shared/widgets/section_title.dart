import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'icon_tile.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.text, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.ink, letterSpacing: -0.2))),
          if (action != null)
            InkWell(
              onTap: onAction,
              child: Row(children: [
                Text(action!, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.green600)),
                Icon(appIcon('chevR'), size: 14, color: c.green600),
              ]),
            ),
        ],
      ),
    );
  }
}
