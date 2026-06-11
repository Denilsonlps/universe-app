import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../data/repositories/mock_repository.dart';
import '../../../data/models/course_model.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _selectedCat = 'Todos';
  String _query = '';
  final _searchController = TextEditingController();

  static const _cats = ['Todos', 'Graduação', 'Técnico', 'Pós-graduação'];

  String _catForLevel(CourseLevel level) {
    switch (level) {
      case CourseLevel.tecnologo:
      case CourseLevel.bacharelado:
      case CourseLevel.licenciatura:
        return 'Graduação';
      case CourseLevel.tecnicoIntegrado:
      case CourseLevel.tecnicoConcomitante:
      case CourseLevel.tecnicoSubsequente:
      case CourseLevel.proeja:
        return 'Técnico';
      case CourseLevel.especializacao:
        return 'Pós-graduação';
    }
  }

  IconData _iconForCourse(String id) {
    switch (id) {
      case 'ads': return Icons.description_rounded;
      case 'gestao-publica': return Icons.account_balance_rounded;
      case 'letras': return Icons.menu_book_rounded;
      case 'eng-producao': return Icons.settings_rounded;
      case 'administracao-tec': return Icons.work_rounded;
      case 'redes': return Icons.language_rounded;
      case 'logistica': return Icons.directions_bus_rounded;
      case 'proeja-admin': return Icons.flag_rounded;
      case 'gestao-projetos': return Icons.emoji_events_rounded;
      case 'humanidades': return Icons.menu_book_rounded;
      default: return Icons.school_rounded;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCourses = MockRepository.courses;
    final filtered = allCourses.where((c) {
      final matchesCat = _selectedCat == 'Todos' || _catForLevel(c.level) == _selectedCat;
      final matchesQuery = _query.isEmpty || c.name.toLowerCase().contains(_query.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();

    return ColoredBox(
      color: AppColors.bg,
      child: Column(
        children: [
          // Header
          Container(
            color: AppColors.bg,
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top,
              16,
              12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                const Text(
                  'Cursos',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 12),
                _SearchField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ],
            ),
          ),
          // Category chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: _cats.length,
              separatorBuilder: (_, _) => const SizedBox(width: 9),
              itemBuilder: (_, i) => AppChip(
                label: _cats[i],
                active: _selectedCat == _cats[i],
                onTap: () => setState(() => _selectedCat = _cats[i]),
              ),
            ),
          ),
          // Course list
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 11),
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      return AppCard(
                        padding: const EdgeInsets.all(15),
                        onTap: () => context.go('/courses/${c.id}'),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.green050,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(_iconForCourse(c.id), color: AppColors.green700, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.green050,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          _catForLevel(c.level),
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.green700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${c.shift.label} · ${c.duration}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.ink3),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 18, color: AppColors.ink3),
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

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(color: AppColors.line, blurRadius: 0, spreadRadius: 1.5),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 19, color: AppColors.ink3),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 15, color: AppColors.ink, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: 'Buscar curso…',
                hintStyle: TextStyle(fontSize: 15, color: AppColors.ink3),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: AppColors.ink3),
          SizedBox(height: 12),
          Text('Nenhum curso encontrado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
          SizedBox(height: 4),
          Text('Tente outro termo ou categoria.', style: TextStyle(fontSize: 13, color: AppColors.ink3)),
        ],
      ),
    );
  }
}
