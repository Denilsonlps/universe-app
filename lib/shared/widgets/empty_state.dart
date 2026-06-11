import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_button.dart';
import 'icon_tile.dart';

class EmptyState extends StatelessWidget {
  final String icon, title;
  final String? body, action;
  final VoidCallback? onAction;
  const EmptyState({super.key, this.icon = 'search', required this.title, this.body, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 76, height: 76,
            decoration: BoxDecoration(color: c.bg2, borderRadius: BorderRadius.circular(24)),
            child: Icon(appIcon(icon), size: 34, color: c.ink3),
          ),
          const SizedBox(height: 18),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.ink)),
          if (body != null) Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(body!, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.ink3, height: 1.5)),
          ),
          if (action != null) Padding(
            padding: const EdgeInsets.only(top: 18),
            child: AppButton(action!, variant: AppButtonVariant.outline, onTap: onAction),
          ),
        ]),
      ),
    );
  }
}
