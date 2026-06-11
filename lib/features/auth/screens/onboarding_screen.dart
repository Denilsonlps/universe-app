import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green800,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 28),
              Text(
                'Tudo que você precisa no IFSP Pirituba',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Estágios, concursos, benefícios, informações do campus e muito mais — em um só lugar.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.green800,
                  ),
                  onPressed: () => context.go('/register'),
                  child: const Text('Criar conta'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  onPressed: () => context.go('/login'),
                  child: const Text('Já tenho conta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
