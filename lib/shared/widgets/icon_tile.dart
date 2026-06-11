import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class IconTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;

  const IconTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.green050,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.cardShadowSmall,
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.green800,
              size: size * 0.45,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: size + 16,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.ink2,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
