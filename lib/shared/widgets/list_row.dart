import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'app_card.dart';
import 'icon_tile.dart';

class ListRow extends StatelessWidget {
  final String? icon, title, subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showChevron;
  const ListRow({super.key, this.icon, this.title, this.subtitle, this.onTap, this.trailing, this.showChevron = true});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          if (icon != null) ...[IconTile(icon!), const SizedBox(width: 14)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) Text(title!, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.ink)),
                if (subtitle != null) Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle!, style: TextStyle(fontSize: 12, color: c.ink3, height: 1.4)),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing! else if (showChevron) Icon(appIcon('chevR'), size: 18, color: c.ink3),
        ],
      ),
    );
  }
}
