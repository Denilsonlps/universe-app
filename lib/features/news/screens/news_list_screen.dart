import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../data/models/news.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/async_view.dart';
import '../widgets/news_card.dart';

class NewsListScreen extends ConsumerStatefulWidget {
  const NewsListScreen({super.key});
  @override
  ConsumerState<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends ConsumerState<NewsListScreen> {
  String _cat = 'Todas';
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(publishedNewsProvider);
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: 'Notícias', subtitle: 'Avisos do campus e do mundo acadêmico', icon: 'bell', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AsyncListView<News>(
          value: async,
          onRetry: () => ref.invalidate(publishedNewsProvider),
          emptyTitle: 'Nenhuma notícia',
          data: (all) {
            final cats = ['Todas', ...{for (final n in all) n.category}];
            if (!cats.contains(_cat)) _cat = 'Todas';
            final list = _cat == 'Todas' ? all : all.where((n) => n.category == _cat).toList();
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: cats.length,
                  separatorBuilder: (context2, i2) => const SizedBox(width: 9),
                  itemBuilder: (_, i) => AppChip(cats[i], active: _cat == cats[i], onTap: () => setState(() => _cat = cats[i])),
                ),
              ),
              const SizedBox(height: 16),
              for (final n in list) Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NewsCard(news: n, onTap: () => context.push('/noticias/${n.id}', extra: n)),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
