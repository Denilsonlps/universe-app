import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/internship.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/content/content_image.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/utils/launch.dart';

class VagaDetailScreen extends StatelessWidget {
  final Internship? vaga;
  const VagaDetailScreen({super.key, required this.vaga});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final e = vaga;
    if (e == null) {
      return PageShell(
        bodyPadding: EdgeInsets.zero,
        header: PageHeader(title: 'Vaga', onBack: () => context.pop()),
        body: const EmptyState(icon: 'briefcase', title: 'Vaga não encontrada'),
      );
    }
    final closed = !e.open;
    final meta = [('Modalidade', e.mode), ('Bolsa', '${e.grant}/mês'), ('Duração', e.duration)];

    Widget block(String title, List<String> items, String icon, {bool muted = false}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionTitle(title),
        AppCard(child: Column(children: [
          for (final r in items) Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(appIcon(icon), size: 18, color: muted ? c.ink3 : c.green500),
              const SizedBox(width: 11),
              Expanded(child: Text(r, style: TextStyle(fontSize: 13.5, height: 1.45, color: muted ? c.ink2 : c.ink))),
            ]),
          ),
        ])),
        const SizedBox(height: 16),
      ],
    );

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(
        title: e.role, subtitle: '${e.companyName} · ${e.area}', icon: 'briefcase', onBack: () => context.pop(),
        child: Padding(padding: const EdgeInsets.only(top: 14), child: Align(alignment: Alignment.centerLeft, child: StatusBadge(closed: closed))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (e.imageUrl != null && e.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: c.bg2, width: double.infinity, constraints: const BoxConstraints(minHeight: 170),
                child: ContentImage(e.imageUrl!, height: 170, width: double.infinity),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (closed) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: c.error.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Icon(appIcon('clock'), size: 20, color: c.error),
                const SizedBox(width: 11),
                Expanded(child: Text('Esta vaga está encerrada. Mantemos visível por 1 mês como referência.',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.4, color: c.error))),
              ]),
            ),
            const SizedBox(height: 16),
          ],
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
          const SectionTitle('Descrição da vaga'),
          AppCard(child: Text(e.jobDescription, style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2))),
          const SizedBox(height: 16),
          if (e.benefits.isNotEmpty) ...[
            const SectionTitle('Benefícios'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final b in e.benefits) Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(appIcon('check'), size: 14, color: c.green600),
                  const SizedBox(width: 6),
                  Text(b, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.green700)),
                ]),
              ),
            ]),
            const SizedBox(height: 18),
          ],
          if (e.requirements.isNotEmpty) block('Pré-requisitos', e.requirements, 'checkCircle'),
          if (e.niceToHave.isNotEmpty) block('Diferenciais desejáveis', e.niceToHave, 'check', muted: true),
          const SectionTitle('Sobre a empresa'),
          AppCard(child: Text(e.companyDescription, style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2))),
          const SizedBox(height: 16),
          // RF037 — o app só divulga
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: c.bg2, borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(appIcon('shield'), size: 16, color: c.ink3),
              const SizedBox(width: 8),
              Expanded(child: Text('O app apenas divulga a vaga. O processo seletivo é conduzido pela empresa responsável.',
                  style: TextStyle(fontSize: 11.5, height: 1.45, color: c.ink3))),
            ]),
          ),
          const SizedBox(height: 16),
          if (closed)
            const AppButton('Vaga encerrada', full: true, variant: AppButtonVariant.ghost)
          else
            AppButton('Quero me candidatar', full: true, icon: 'send',
              onTap: () => openExternalUrl(context, e.link)),
          if (e.link != null) Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(child: Text('Você será direcionado para ${e.link}', style: TextStyle(fontSize: 11.5, color: c.ink3))),
          ),
        ]),
      ),
    );
  }
}
