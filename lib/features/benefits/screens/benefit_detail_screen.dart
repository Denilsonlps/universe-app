import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/green_hero_header.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../data/repositories/mock_repository.dart';

class BenefitDetailScreen extends StatelessWidget {
  final String kind;
  final String benefitId;
  const BenefitDetailScreen({super.key, required this.kind, required this.benefitId});

  @override
  Widget build(BuildContext context) {
    final benefit = MockRepository.benefits.firstWhere(
      (b) => b.id == benefitId,
      orElse: () => MockRepository.benefits.first,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          GreenHeroHeader(
            title: benefit.name,
            subtitle: kind == 'gov' ? 'Benefício Governamental' : 'Benefício Institucional',
            icon: Icons.card_giftcard_rounded,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descrição', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(benefit.description, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                if (benefit.howToAccess != null) ...[
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppColors.green600, size: 18),
                            const SizedBox(width: 8),
                            Text('Como acessar', style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(benefit.howToAccess!, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
