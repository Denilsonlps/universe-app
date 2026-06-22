import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/launch.dart';
import '../../../data/models/content_doc.dart';
import '../../../data/models/news.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/content/content_image.dart';
import '../../../shared/content/term_sheet.dart';
import '../../../shared/content/wiki_text.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/icon_tile.dart';

class NewsDetailScreen extends ConsumerWidget {
  final News? news;
  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final n = news;
    if (n == null) {
      return PageShell(
        bodyPadding: EdgeInsets.zero,
        header: PageHeader(title: 'Notícia', onBack: () => context.pop()),
        body: const EmptyState(icon: 'bell', title: 'Notícia não encontrada'),
      );
    }
    void openDoc(String id) => context.push('/conteudo/$id');
    void openTerm(String key) => showTermSheet(context, key, onOpenDoc: openDoc);
    final all = ref.watch(allContentDocsProvider).valueOrNull ?? const <ContentDoc>[];
    final byTitle = {for (final p in all) p.title.toLowerCase().trim(): p.id};
    String? resolveDoc(String key) => byTitle[key.toLowerCase().trim()];
    final date = '${n.date.day.toString().padLeft(2, '0')}/${n.date.month.toString().padLeft(2, '0')}/${n.date.year}';

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: n.title, subtitle: n.category, icon: 'bell', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (n.imageUrl != null && n.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(color: c.bg2, width: double.infinity, constraints: const BoxConstraints(minHeight: 180),
                child: ContentImage(n.imageUrl!, height: 180, width: double.infinity)),
            ),
            const SizedBox(height: 16),
          ],
          Text('${n.source} · $date · ${n.readTime} de leitura', style: TextStyle(fontSize: 12, color: c.ink3, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (n.facts.isNotEmpty) ...[
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final f in n.facts) Container(
                width: 150,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: c.green050, borderRadius: BorderRadius.circular(13)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(f.label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: c.green700)),
                  const SizedBox(height: 3),
                  Text(f.value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.25, color: c.ink)),
                ]),
              ),
            ]),
            const SizedBox(height: 18),
          ],
          WikiParagraphs(n.body, onOpenDoc: openDoc, onOpenTerm: openTerm, resolveDoc: resolveDoc),
          if (n.sourceUrl != null && n.sourceUrl!.isNotEmpty) ...[
            const SizedBox(height: 22),
            AppCard(
              child: Row(children: [
                Icon(appIcon('globe'), size: 20, color: c.green700),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Fonte oficial', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.ink)),
                  Text(n.sourceUrl!, style: TextStyle(fontSize: 11.5, color: c.green700)),
                ])),
                AppButton('Abrir', size: AppButtonSize.sm, onTap: () => openExternalUrl(context, n.sourceUrl)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

/// Resolve a notícia por id (deep-link / sem `extra`).
class NewsById extends ConsumerWidget {
  final String id;
  const NewsById({super.key, required this.id});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(publishedNewsProvider).when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const NewsDetailScreen(news: null),
      data: (list) {
        final match = list.where((n) => n.id == id);
        return NewsDetailScreen(news: match.isEmpty ? null : match.first);
      },
    );
  }
}
