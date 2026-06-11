import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/green_hero_header.dart';

class HousingScreen extends StatelessWidget {
  const HousingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const GreenHeroHeader(
            title: 'Moradia Estudantil',
            subtitle: 'Opções próximas ao campus',
            icon: Icons.home_rounded,
          ),
          Expanded(
            child: Center(
              child: Text('Em breve', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.ink3)),
            ),
          ),
        ],
      ),
    );
  }
}
