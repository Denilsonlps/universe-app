import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum BadgeStatus { open, closed }

class StatusBadge extends StatelessWidget {
  final BadgeStatus status;
  final String? customLabel;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
  });

  const StatusBadge.open({super.key, this.customLabel})
      : status = BadgeStatus.open;

  const StatusBadge.closed({super.key, this.customLabel})
      : status = BadgeStatus.closed;

  @override
  Widget build(BuildContext context) {
    final isOpen = status == BadgeStatus.open;
    final label = customLabel ?? (isOpen ? 'Aberta' : 'Encerrada');
    final bg = isOpen ? AppColors.green050 : const Color(0xFFFDE9E8);
    final fg = isOpen ? AppColors.green700 : AppColors.error;
    final dot = isOpen ? AppColors.green400 : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
