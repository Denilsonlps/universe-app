import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/green_hero_header.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../data/repositories/mock_repository.dart';

class ContestDetailScreen extends StatelessWidget {
  final String contestId;
  const ContestDetailScreen({super.key, required this.contestId});

  @override
  Widget build(BuildContext context) {
    final item = MockRepository.contests.firstWhere(
      (c) => c.id == contestId,
      orElse: () => MockRepository.contests.first,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          GreenHeroHeader(
            title: item.role,
            subtitle: item.organization,
            icon: Icons.emoji_events_rounded,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AppCard(
                  child: Column(
                    children: [
                      _InfoRow(Icons.attach_money_rounded, 'Remuneração', item.salaryFormatted),
                      const Divider(height: 20),
                      _InfoRow(Icons.people_outline_rounded, 'Vagas', '${item.vacancies}'),
                      if (item.deadline != null) ...[
                        const Divider(height: 20),
                        _InfoRow(
                          Icons.calendar_today_outlined,
                          'Inscrições até',
                          DateFormat('dd/MM/yyyy').format(item.deadline!),
                        ),
                      ],
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.green600),
                          const SizedBox(width: 8),
                          Text('Status', style: Theme.of(context).textTheme.bodySmall),
                          const Spacer(),
                          StatusBadge(status: item.isOpen ? BadgeStatus.open : BadgeStatus.closed),
                        ],
                      ),
                    ],
                  ),
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sobre o concurso', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Text(item.description!, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
                if (item.isOpen) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Ver edital'),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.green600),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
