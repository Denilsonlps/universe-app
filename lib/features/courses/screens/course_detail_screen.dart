import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/green_hero_header.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../data/repositories/mock_repository.dart';
import '../../../data/models/course_model.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final course = MockRepository.courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => MockRepository.courses.first,
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          GreenHeroHeader(
            title: course.name,
            subtitle: course.level.label,
            icon: Icons.school_rounded,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AppCard(
                  child: Column(
                    children: [
                      _InfoRow(icon: Icons.access_time, label: 'Duração', value: course.duration),
                      const Divider(height: 20),
                      _InfoRow(icon: Icons.wb_sunny_outlined, label: 'Turno', value: course.shift.label),
                      const Divider(height: 20),
                      _InfoRow(icon: Icons.school_outlined, label: 'Modalidade', value: course.level.label),
                    ],
                  ),
                ),
                if (course.description != null) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sobre o curso', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Text(course.description!, style: Theme.of(context).textTheme.bodyMedium),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.green600),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
