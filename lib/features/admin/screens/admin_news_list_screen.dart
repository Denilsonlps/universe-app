import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/news.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_toggle.dart';
import '../../../shared/widgets/async_view.dart';

class AdminNewsListScreen extends ConsumerWidget {
  const AdminNewsListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final async = ref.watch(allNewsProvider);
    final repo = ref.read(universeRepositoryProvider);
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: 'Notícias', subtitle: 'Publique avisos e novidades', icon: 'bell', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppButton('Nova notícia', full: true, icon: 'plus', onTap: () => context.push('/admin/noticias/editar')),
          const SizedBox(height: 14),
          AsyncListView<News>(
            value: async,
            onRetry: () => ref.invalidate(allNewsProvider),
            emptyTitle: 'Nenhuma notícia ainda',
            data: (list) => Column(children: [
              for (final n in list) Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Opacity(
                  opacity: n.published ? 1 : 0.6,
                  child: AppCard(
                    onTap: () => context.push('/admin/noticias/editar', extra: n),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(n.title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink)),
                        const SizedBox(height: 4),
                        Text('${n.category} · ${n.source}${n.published ? '' : ' · Rascunho'}', style: TextStyle(fontSize: 11.5, color: c.ink3)),
                      ])),
                      AppToggle(on: n.published, onChanged: (v) => repo.upsertNews(News(
                        id: n.id, category: n.category, source: n.source, readTime: n.readTime,
                        title: n.title, summary: n.summary, body: n.body, date: n.date,
                        facts: n.facts, sourceUrl: n.sourceUrl, imageUrl: n.imageUrl,
                        published: v, pinned: n.pinned,
                      ))),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
