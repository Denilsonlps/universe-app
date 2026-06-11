import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/green_hero_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../data/models/internship_model.dart';
import '../../../data/models/contest_model.dart';
import '../../../data/repositories/mock_repository.dart';

class InternshipsScreen extends StatefulWidget {
  const InternshipsScreen({super.key});

  @override
  State<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends State<InternshipsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final internships = MockRepository.internships;
    final contests = MockRepository.contests;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          GreenHeroHeader(
            title: 'Oportunidades',
            subtitle: 'Estágios e concursos para você',
            icon: Icons.business_center_rounded,
            actions: [
              IconButton(
                icon: const Icon(Icons.people_rounded, color: Colors.white),
                onPressed: () => context.go('/internships/testimonials'),
              ),
            ],
          ),
          Container(
            color: AppColors.green800,
            child: TabBar(
              controller: _tab,
              indicatorColor: AppColors.green400,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'Estágios'),
                Tab(text: 'Concursos'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _InternshipList(internships: internships),
                _ContestList(contests: contests),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InternshipList extends StatelessWidget {
  final List<InternshipModel> internships;
  const _InternshipList({required this.internships});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: internships.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = internships[i];
        return AppCard(
          onTap: () => context.go('/internships/${item.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.role, style: Theme.of(context).textTheme.titleSmall),
                        Text(item.company, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  StatusBadge(status: item.isOpen ? BadgeStatus.open : BadgeStatus.closed),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Chip(icon: Icons.attach_money_rounded, label: item.stipendFormatted),
                  const SizedBox(width: 8),
                  _Chip(icon: Icons.location_on_outlined, label: item.modality.label),
                  const SizedBox(width: 8),
                  _Chip(icon: Icons.school_outlined, label: item.targetCourse),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContestList extends StatelessWidget {
  final List<ContestModel> contests;
  const _ContestList({required this.contests});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: contests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = contests[i];
        return AppCard(
          onTap: () => context.go('/contests/${item.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.role, style: Theme.of(context).textTheme.titleSmall),
                        Text(item.organization, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  StatusBadge(status: item.isOpen ? BadgeStatus.open : BadgeStatus.closed),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Chip(icon: Icons.attach_money_rounded, label: item.salaryFormatted),
                  const SizedBox(width: 8),
                  _Chip(icon: Icons.people_outline_rounded, label: '${item.vacancies} vagas'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.green050,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.green700),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.green800),
          ),
        ],
      ),
    );
  }
}
