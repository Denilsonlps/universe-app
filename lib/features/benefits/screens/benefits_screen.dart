import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_doc.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/icon_tile.dart';

class BenefitsScreen extends ConsumerWidget {
  final ContentKind kind;
  const BenefitsScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final isGov = kind == ContentKind.gov;
    final itemsAsync = ref.watch(contentDocsProvider(kind));
    final intro = isGov
        ? 'Conheça os principais benefícios oferecidos pelo governo a estudantes. Toque para ver como solicitar.'
        : 'O IFSP oferece auxílios e bolsas para apoiar sua permanência e desenvolvimento acadêmico.';

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(
        title: isGov ? 'Benefícios Governamentais' : 'Benefícios Institucionais',
        subtitle: isGov ? 'Programas e auxílios do governo' : 'Auxílios e bolsas do IFSP',
        icon: isGov ? 'benefits' : 'award',
        onBack: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(intro, style: TextStyle(fontSize: 13, height: 1.55, color: c.ink2)),
          const SizedBox(height: 16),
          AsyncListView<ContentDoc>(
            value: itemsAsync,
            onRetry: () => ref.invalidate(contentDocsProvider(kind)),
            emptyTitle: 'Nenhum benefício disponível',
            data: (items) => Column(children: [
              for (final d in items) Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  onTap: () => context.push('/conteudo/${d.id}', extra: d),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      IconTile(d.icon, size: 46),
                      const SizedBox(width: 13),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(d.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(999)),
                          child: Text(d.tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c.green700)),
                        ),
                      ])),
                      Icon(appIcon('chevR'), size: 18, color: c.ink3),
                    ]),
                    const SizedBox(height: 10),
                    Text(d.summary, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.5, height: 1.5, color: c.ink2)),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 4),
          // RF012 — o app não cria/gere benefícios
          _Disclaimer('O app apenas informa os benefícios — não realiza a inscrição nem gerencia os programas. Dúvidas e solicitações devem ser feitas pelos canais oficiais do campus.'),
        ]),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  final String text;
  const _Disclaimer(this.text);
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.bg2, borderRadius: BorderRadius.circular(12)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(appIcon('shield'), size: 16, color: c.ink3),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 11.5, height: 1.45, color: c.ink3))),
      ]),
    );
  }
}
