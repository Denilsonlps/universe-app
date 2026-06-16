import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/course.dart';
import '../../../shared/chrome/bottom_nav.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/icon_tile.dart';

const _courseCats = ['Todos', 'Graduação', 'Técnico', 'Pós-graduação'];

class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});
  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  String _cat = 'Todos';
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final coursesAsync = ref.watch(coursesProvider);

    return PageShell(
      bodyPadding: const EdgeInsets.all(16),
      bottomNav: AppBottomNav(current: 'cursos', onTap: (k) => context.go('/$k')),
      header: Container(
        color: c.bg,
        padding: const EdgeInsets.fromLTRB(16, kStatusH, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Cursos', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: c.ink, letterSpacing: -0.4)),
          const SizedBox(height: 12),
          AppField(icon: 'search', hint: 'Buscar curso…', value: _q, onChanged: (v) => setState(() => _q = v)),
        ]),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _courseCats.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 9),
            itemBuilder: (ctx, i) => AppChip(_courseCats[i], active: _cat == _courseCats[i], onTap: () => setState(() => _cat = _courseCats[i])),
          ),
        ),
        const SizedBox(height: 16),
        AsyncListView<Course>(
          value: coursesAsync,
          onRetry: () => ref.invalidate(coursesProvider),
          emptyTitle: 'Nenhum curso encontrado',
          emptyBody: 'Tente outro termo ou categoria.',
          data: (all) {
            final list = all.where((e) =>
                (_cat == 'Todos' || e.category == _cat) &&
                e.name.toLowerCase().contains(_q.toLowerCase())).toList();
            if (list.isEmpty) {
              return EmptyState(icon: 'search', title: 'Nenhum curso encontrado', body: 'Tente outro termo ou categoria.', action: 'Limpar filtros', onAction: () => setState(() { _cat = 'Todos'; _q = ''; }));
            }
            return Column(children: [
              for (final course in list) Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: _CourseCard(course: course, onTap: () => context.push('/cursos/detail', extra: course)),
              ),
            ]);
          },
        ),
      ]),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  const _CourseCard({required this.course, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      onTap: onTap, padding: const EdgeInsets.all(15),
      child: Row(children: [
        IconTile(course.icon, size: 48, iconSize: 24),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(course.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink, height: 1.25)),
          const SizedBox(height: 6),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(999)),
              child: Text(course.category, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: c.green700)),
            ),
            const SizedBox(width: 8),
            Flexible(child: Text('${course.period} · ${course.duration}', style: TextStyle(fontSize: 11, color: c.ink3), overflow: TextOverflow.ellipsis)),
          ]),
        ])),
        Icon(appIcon('chevR'), size: 18, color: c.ink3),
      ]),
    );
  }
}
