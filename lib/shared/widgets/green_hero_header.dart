import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GreenHeroHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? child;

  const GreenHeroHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.showBack = true,
    this.actions,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0, -1),
          end: Alignment(0.4, 1),
          colors: [AppColors.green700, AppColors.green900],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x38003D28),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, topPad, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showBack)
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(Icons.chevron_left, size: 24, color: Colors.white),
                  ),
                ),
              const Spacer(),
              ...?actions,
              if (actions == null || actions!.isEmpty)
                Opacity(
                  opacity: 0.9,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, size: 28, color: Colors.white),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.78),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          ?child,
        ],
      ),
    );
  }
}
