import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/noticia_sugerida.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/icon_tile.dart';

class AdminNoticiasSugeridasScreen extends ConsumerWidget {
  const AdminNoticiasSugeridasScreen({super.key});

  Future<void> _aprovar(BuildContext context, WidgetRef ref, NoticiaSugerida s) async {
    final repo = ref.read(universeRepositoryProvider);
    await repo.upsertNews(s.noticia);
    await repo.deleteNoticiaSugerida(s.id);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notícia aprovada e publicada')));
  }

  Future<void> _recusar(BuildContext context, WidgetRef ref, NoticiaSugerida s) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Recusar sugestão'),
      content: Text('Recusar "${s.noticia.title}"? Não será sugerida novamente.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Recusar')),
      ],
    ));
    if (ok == true) {
      await ref.read(universeRepositoryProvider).rejeitarNoticiaSugerida(s.id);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sugestão recusada')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final async = ref.watch(noticiasSugeridasProvider);
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: 'Notícias sugeridas', subtitle: 'Coletadas automaticamente — revise e publique', icon: 'bell', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AsyncListView<NoticiaSugerida>(
          value: async,
          onRetry: () => ref.invalidate(noticiasSugeridasProvider),
          emptyTitle: 'Nenhuma sugestão pendente',
          data: (list) => Column(children: [
            for (final s in list) Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  IconTile('bell', size: 46),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.noticia.title, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.ink)),
                    const SizedBox(height: 2),
                    Text('${s.noticia.category} · ${s.noticia.source}', style: TextStyle(fontSize: 12, color: c.ink3)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(999)),
                    child: Text('auto', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.green700)),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(s.noticia.summary, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, height: 1.45, color: c.ink2)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: AppButton('Aprovar', size: AppButtonSize.sm, icon: 'check', onTap: () => _aprovar(context, ref, s))),
                  const SizedBox(width: 8),
                  Expanded(child: AppButton('Editar', size: AppButtonSize.sm, variant: AppButtonVariant.outline, icon: 'edit',
                    onTap: () => context.push('/admin/noticias/editar', extra: (noticia: s.noticia, suggestionId: s.id)))),
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
