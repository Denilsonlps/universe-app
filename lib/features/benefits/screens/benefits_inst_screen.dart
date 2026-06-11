import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/green_hero_header.dart';
import '../../../data/repositories/mock_repository.dart';
import '../../../data/models/benefit_model.dart';

class BenefitsInstScreen extends StatelessWidget {
  const BenefitsInstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final benefits = MockRepository.benefits.where((b) => b.kind == BenefitKind.inst).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const GreenHeroHeader(
            title: 'Benefícios Institucionais',
            subtitle: 'Serviços e programas do IFSP',
            icon: Icons.school_rounded,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: benefits.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: () => context.go('/benefits/inst/${b.id}'),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.green050,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.school_rounded, color: AppColors.green700, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.name, style: Theme.of(context).textTheme.titleSmall),
                                Text(b.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.ink3),
                        ],
                      ),
                    ),
                  )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
