import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'app_card.dart';

class ListRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconBg;
  final Color? iconColor;
  final Widget? trailing;

  const ListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconBg,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBg ?? AppColors.green050,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor ?? AppColors.green700,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.ink3,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.ink3,
              ),
        ],
      ),
    );
  }
}
