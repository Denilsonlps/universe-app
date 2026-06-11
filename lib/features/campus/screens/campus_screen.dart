import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/green_hero_header.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../data/repositories/mock_repository.dart';

class CampusScreen extends StatelessWidget {
  const CampusScreen({super.key});

  static const _sections = [
    {'key': 'about', 'label': 'Sobre o Campus', 'icon': Icons.info_outline_rounded},
    {'key': 'address', 'label': 'Endereço e Contato', 'icon': Icons.location_on_outlined},
    {'key': 'hours', 'label': 'Horário de Funcionamento', 'icon': Icons.access_time_rounded},
    {'key': 'secretary', 'label': 'Secretaria Acadêmica', 'icon': Icons.article_outlined},
    {'key': 'library', 'label': 'Biblioteca', 'icon': Icons.local_library_outlined},
    {'key': 'eventos', 'label': 'Eventos', 'icon': Icons.event_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final info = MockRepository.campusInfo;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          GreenHeroHeader(
            title: 'Campus Pirituba',
            subtitle: info['address'] as String,
            icon: Icons.location_city_rounded,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SectionTitle(label: 'Informações'),
                const SizedBox(height: 12),
                ..._sections.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        onTap: () => context.go('/campus/detail/${s['key']}'),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.green050,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(s['icon'] as IconData, color: AppColors.green700, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(s['label'] as String, style: Theme.of(context).textTheme.titleSmall),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.ink3),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
