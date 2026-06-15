import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/benefit.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_title.dart';
import '../../../core/utils/launch.dart';

class BenefitDetailScreen extends StatelessWidget {
  final Benefit? benefit;
  final bool isGov;
  const BenefitDetailScreen({super.key, required this.benefit, required this.isGov});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final b = benefit;
    if (b == null) {
      return PageShell(
        bodyPadding: EdgeInsets.zero,
        header: PageHeader(title: 'Benefício', onBack: () => context.pop()),
        body: const EmptyState(icon: 'doc', title: 'Benefício não encontrado'),
      );
    }
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(
        title: b.title,
        subtitle: isGov ? 'Benefício governamental' : 'Benefício institucional',
        icon: b.icon,
        onBack: () => context.pop(),
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Align(alignment: Alignment.centerLeft, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(999)),
            child: Text(b.tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          )),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('O que é'),
          AppCard(child: Text(b.description, style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2))),
          const SizedBox(height: 18),
          const SectionTitle('Como solicitar'),
          for (var i = 0; i < b.steps.length; i++) Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 28, height: 28, alignment: Alignment.center,
                decoration: BoxDecoration(color: c.green800, shape: BoxShape.circle),
                child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 13),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(b.steps[i], style: TextStyle(fontSize: 13.5, height: 1.45, color: c.ink)),
              )),
            ]),
          ),
          const SizedBox(height: 10),
          AppButton('Acessar portal oficial', full: true, icon: 'globe',
            onTap: () => openExternalUrl(context, b.url)),
          const SizedBox(height: 8),
          Center(child: TextButton(
            onPressed: () => context.go('/duvidas'),
            child: Text('Tenho uma dúvida sobre isso', style: TextStyle(fontWeight: FontWeight.w700, color: c.green700)),
          )),
        ]),
      ),
    );
  }
}
