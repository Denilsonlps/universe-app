import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/green_hero_header.dart';

class ProfileCardScreen extends StatelessWidget {
  const ProfileCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const GreenHeroHeader(
            title: 'Carteirinha Estudantil',
            subtitle: 'Seu documento digital',
            icon: Icons.badge_rounded,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.green800, AppColors.green600],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppTheme.cardShadow,
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 10),
                        Text('IFSP', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                      ],
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text('Estudante Universe', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                    Text('ADS', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text('RA: 000000000', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60)),
                    const Spacer(),
                    Text('Campus Pirituba', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white60)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
