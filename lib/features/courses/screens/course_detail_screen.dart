import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/course.dart';
import '../../../data/courses.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/list_row.dart';
import '../../../shared/widgets/section_title.dart';

/// Recebe o curso via `extra` do go_router (evita encoding de nomes com '/' e acentos).
class CourseDetailScreen extends StatelessWidget {
  final Course? course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final course = this.course;
    if (course == null) {
      return PageShell(
        bodyPadding: EdgeInsets.zero,
        header: PageHeader(title: 'Curso', onBack: () => context.pop()),
        body: const EmptyState(icon: 'doc', title: 'Curso não encontrado'),
      );
    }
    final meta = [('Tipo', course.type), ('Duração', course.duration), ('Período', course.period), ('Modalidade', 'Presencial')];

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: course.name, subtitle: '${course.category} · ${course.type}', icon: course.icon, onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, childAspectRatio: 2.6, mainAxisSpacing: 10, crossAxisSpacing: 10,
            children: [
              for (final (k, v) in meta) AppCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(k, style: TextStyle(fontSize: 11, color: c.ink3, fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(v, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.ink)),
              ])),
            ],
          ),
          const SizedBox(height: 18),
          const SectionTitle('Sobre o curso'),
          AppCard(child: Text(
            'O curso de ${course.name} forma profissionais com sólida base teórica e prática, preparados para o mercado de trabalho e para a continuidade dos estudos. As aulas acontecem no período ${course.period.toLowerCase()}, no campus Pirituba.',
            style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2),
          )),
          const SizedBox(height: 18),
          const SectionTitle('Formas de ingresso'),
          for (final (t, s) in const [('Vestibular IFSP', 'Prova realizada no fim do ano'), ('SiSU / Enem', 'Parte das vagas via nota do Enem'), ('Transferência', 'Para alunos de outras instituições')])
            Padding(padding: const EdgeInsets.only(bottom: 10), child: ListRow(icon: 'flag', title: t, subtitle: s, showChevron: false)),
          const SizedBox(height: 10),
          AppButton('Ver estágios para este curso', full: true, icon: 'briefcase',
            onTap: () => context.push('/estagio', extra: courseShort(course.name))),
        ]),
      ),
    );
  }
}
