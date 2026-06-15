import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/contest.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/status_badge.dart';

class ConcursoDetailScreen extends StatelessWidget {
  final Contest? contest;
  const ConcursoDetailScreen({super.key, required this.contest});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final ct = contest;
    if (ct == null) {
      return PageShell(
        bodyPadding: EdgeInsets.zero,
        header: PageHeader(title: 'Concurso', onBack: () => context.pop()),
        body: const EmptyState(icon: 'doc', title: 'Concurso não encontrado'),
      );
    }
    final open = ct.isOpenAt(DateTime.now());
    final prazo = '${ct.deadline.day.toString().padLeft(2, '0')}/${ct.deadline.month.toString().padLeft(2, '0')}/${ct.deadline.year}';
    final meta = [('Vagas', ct.vagas), ('Salário', ct.salary), ('Escolaridade', ct.level), ('Inscrições até', prazo)];

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(
        title: ct.role, subtitle: ct.org, icon: 'doc', onBack: () => context.pop(),
        child: Padding(padding: const EdgeInsets.only(top: 14), child: Align(alignment: Alignment.centerLeft,
          child: StatusBadge(closed: !open, openLabel: 'Inscrições abertas', closedLabel: 'Inscrições encerradas'))),
      ),
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
                Text(v, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink)),
              ])),
            ],
          ),
          const SizedBox(height: 18),
          const SectionTitle('Sobre o concurso'),
          AppCard(child: Text(ct.about, style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: c.bg2, borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(appIcon('shield'), size: 16, color: c.ink3),
              const SizedBox(width: 8),
              Expanded(child: Text('O app apenas divulga o edital. Inscrições e seleção são de responsabilidade do órgão organizador.',
                  style: TextStyle(fontSize: 11.5, height: 1.45, color: c.ink3))),
            ]),
          ),
          const SizedBox(height: 16),
          if (open)
            AppButton('Acessar edital', full: true, icon: 'doc',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abrindo edital… (em breve)'))))
          else
            const AppButton('Inscrições encerradas', full: true, variant: AppButtonVariant.ghost),
        ]),
      ),
    );
  }
}
