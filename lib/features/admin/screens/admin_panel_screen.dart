import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Painel Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _AdminCard(icon: Icons.business_center_rounded, label: 'Gerenciar Estágios', count: 6),
          const SizedBox(height: 10),
          _AdminCard(icon: Icons.emoji_events_rounded, label: 'Gerenciar Concursos', count: 4),
          const SizedBox(height: 10),
          _AdminCard(icon: Icons.school_rounded, label: 'Gerenciar Cursos', count: 10),
          const SizedBox(height: 10),
          _AdminCard(icon: Icons.card_giftcard_rounded, label: 'Gerenciar Benefícios', count: 6),
          const SizedBox(height: 10),
          _AdminCard(icon: Icons.help_rounded, label: 'Gerenciar FAQs', count: 7),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  const _AdminCard({required this.icon, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.green700),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.titleSmall)),
          Text('$count', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.green600)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.ink3),
        ],
      ),
    );
  }
}
