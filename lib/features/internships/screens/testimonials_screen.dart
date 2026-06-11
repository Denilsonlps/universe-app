import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/green_hero_header.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../data/repositories/mock_repository.dart';

class TestimonialsScreen extends StatelessWidget {
  const TestimonialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final testimonials = MockRepository.testimonials;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const GreenHeroHeader(
            title: 'Depoimentos',
            subtitle: 'O que os estudantes dizem',
            icon: Icons.people_rounded,
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: testimonials.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final t = testimonials[i];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.green100,
                            child: Text(
                              t.authorName[0],
                              style: const TextStyle(color: AppColors.green800, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.authorName, style: Theme.of(context).textTheme.titleSmall),
                                if (t.authorCourse != null)
                                  Text(t.authorCourse!, style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          if (t.company != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.green050,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t.company!,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.green800),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '"${t.content}"',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.ink2,
                            ),
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
