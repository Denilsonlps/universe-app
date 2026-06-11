import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/green_hero_header.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../data/repositories/mock_repository.dart';

class RepublicasScreen extends StatelessWidget {
  const RepublicasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reps = MockRepository.republicas;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const GreenHeroHeader(
            title: 'Repúblicas',
            subtitle: 'Moradia compartilhada perto do IFSP',
            icon: Icons.home_work_rounded,
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: reps.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final r = reps[i];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r['name'] as String, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(r['address'] as String, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _Chip(Icons.directions_walk_rounded, r['distance'] as String),
                          const SizedBox(width: 8),
                          _Chip(Icons.attach_money_rounded, r['priceRange'] as String),
                          const SizedBox(width: 8),
                          _Chip(Icons.bed_rounded, '${r['rooms']} quartos'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.green050, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.green700),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.green800)),
        ],
      ),
    );
  }
}
