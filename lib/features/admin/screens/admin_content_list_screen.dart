import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_doc.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/icon_tile.dart';

class AdminContentListScreen extends ConsumerWidget {
  const AdminContentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final docsAsync = ref.watch(allContentDocsProvider);

    Widget group(String label, List<ContentDoc> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(2, 4, 2, 9),
          child: Text(label.toUpperCase(), style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: c.ink3))),
        for (final d in items) Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            onTap: () => context.push('/admin/conteudo/editar', extra: d),
            child: Row(children: [
              IconTile(d.icon, size: 44),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.ink)),
                const SizedBox(height: 2),
                Text('${d.sections.length} seções · atualizado ${d.updatedAt.day.toString().padLeft(2, '0')}/${d.updatedAt.month.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 11, color: c.ink3)),
              ])),
              Icon(appIcon('edit'), size: 19, color: c.green700),
            ]),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: 'Páginas de conteúdo', subtitle: 'Edite o que os alunos veem', icon: 'book', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppButton('Nova página', full: true, icon: 'plus',
            onTap: () => context.push('/admin/conteudo/editar')),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(13)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(appIcon('book'), size: 18, color: c.green700),
              const SizedBox(width: 10),
              Expanded(child: Text('Use [[colchetes duplos]] no texto para criar links internos. Ex.: [[PIBIC]] vira link para a página de Iniciação Científica.',
                  style: TextStyle(fontSize: 12, height: 1.5, color: c.ink2))),
            ]),
          ),
          const SizedBox(height: 18),
          AsyncListView<ContentDoc>(
            value: docsAsync,
            onRetry: () => ref.invalidate(allContentDocsProvider),
            emptyTitle: 'Nenhuma página ainda',
            data: (docs) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              group('Governamentais', docs.where((d) => d.kind == ContentKind.gov).toList()),
              group('Institucionais', docs.where((d) => d.kind == ContentKind.inst).toList()),
            ]),
          ),
        ]),
      ),
    );
  }
}
