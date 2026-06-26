import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/vaga_sugerida.dart';
import '../../../data/models/app_notification.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/icon_tile.dart';

class AdminSugestoesScreen extends ConsumerWidget {
  const AdminSugestoesScreen({super.key});

  Future<void> _aprovar(BuildContext context, WidgetRef ref, VagaSugerida s) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Aprovar vaga'),
      content: Text('Publicar "${s.vaga.role}" e avisar os alunos do curso?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Aprovar')),
      ],
    ));
    if (ok != true) return;
    final repo = ref.read(universeRepositoryProvider);
    await repo.upsertInternship(s.vaga); // mesmo id = sha1(link)
    await repo.addNotification(AppNotification(
      id: 'n${DateTime.now().millisecondsSinceEpoch}', type: 'vaga', targetCourse: s.vaga.course,
      title: 'Nova vaga: ${s.vaga.role}', body: '${s.vaga.companyName} · ${s.vaga.grant}',
      route: '/estagio/vaga/${s.vaga.id}', createdAt: DateTime.now()));
    await repo.deleteVagaSugerida(s.id);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaga aprovada e publicada')));
  }

  Future<void> _recusar(BuildContext context, WidgetRef ref, VagaSugerida s) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Recusar sugestão'),
      content: Text('Recusar "${s.vaga.role}"? Não será sugerida novamente.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Recusar')),
      ],
    ));
    if (ok == true) {
      await ref.read(universeRepositoryProvider).rejeitarVagaSugerida(s.id);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sugestão recusada')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final async = ref.watch(vagasSugeridasProvider);
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: 'Vagas sugeridas', subtitle: 'Coletadas automaticamente — revise e publique', icon: 'briefcase', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AsyncListView<VagaSugerida>(
          value: async,
          onRetry: () => ref.invalidate(vagasSugeridasProvider),
          emptyTitle: 'Nenhuma sugestão pendente',
          data: (list) => Column(children: [
            for (final s in list) Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  IconTile('briefcase', size: 46),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.vaga.role, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.ink)),
                    const SizedBox(height: 2),
                    Text('${s.vaga.companyName} · ${s.vaga.course}', style: TextStyle(fontSize: 12, color: c.ink3)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(999)),
                    child: Text('auto', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.green700)),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(s.vaga.jobDescription, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, height: 1.45, color: c.ink2)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: AppButton('Aprovar', size: AppButtonSize.sm, onTap: () => _aprovar(context, ref, s))),
                  const SizedBox(width: 8),
                  Expanded(child: AppButton('Editar', size: AppButtonSize.sm, variant: AppButtonVariant.outline,
                    onTap: () => context.push('/admin/vaga', extra: (vaga: s.vaga, suggestionId: s.id)))),
                  const SizedBox(width: 8),
                  Expanded(child: AppButton('Recusar', size: AppButtonSize.sm, variant: AppButtonVariant.ghost, onTap: () => _recusar(context, ref, s))),
                ]),
              ])),
            ),
          ]),
        ),
      ),
    );
  }
}
