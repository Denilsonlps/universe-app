import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_doc.dart';
import '../../../data/models/course.dart';
import '../../../data/models/internship.dart';
import '../../../data/models/news.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/list_row.dart';
import '../../../shared/widgets/section_title.dart';

/// Resultado de busca unificado (rótulo + ação de navegação).
class _Hit {
  final String icon, title, subtitle;
  final VoidCallback onTap;
  const _Hit({required this.icon, required this.title, required this.subtitle, required this.onTap});
}

class BuscaScreen extends ConsumerStatefulWidget {
  const BuscaScreen({super.key});
  @override
  ConsumerState<BuscaScreen> createState() => _BuscaScreenState();
}

class _BuscaScreenState extends ConsumerState<BuscaScreen> {
  String _q = '';

  bool _match(String haystack) => haystack.toLowerCase().contains(_q.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final query = _q.trim();
    final groups = query.length < 2 ? const <(String, List<_Hit>)>[] : _search();

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: 'Buscar', subtitle: 'Cursos, benefícios, vagas e notícias', icon: 'search', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppField(
            icon: 'search', hint: 'O que você procura?', value: _q,
            onChanged: (v) => setState(() => _q = v),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: query.length < 2
                ? Center(child: Text('Digite ao menos 2 letras para buscar.', style: TextStyle(fontSize: 13, color: c.ink3)))
                : groups.isEmpty
                    ? const EmptyState(icon: 'search', title: 'Nada encontrado', body: 'Tente outras palavras.')
                    : ListView(children: [
                        for (final (label, hits) in groups) ...[
                          SectionTitle('$label (${hits.length})'),
                          const SizedBox(height: 10),
                          for (final h in hits) Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ListRow(icon: h.icon, title: h.title, subtitle: h.subtitle, onTap: h.onTap),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ]),
          ),
        ]),
      ),
    );
  }

  List<(String, List<_Hit>)> _search() {
    final courses = ref.watch(coursesProvider).valueOrNull ?? const <Course>[];
    final gov = ref.watch(contentDocsProvider(ContentKind.gov)).valueOrNull ?? const <ContentDoc>[];
    final inst = ref.watch(contentDocsProvider(ContentKind.inst)).valueOrNull ?? const <ContentDoc>[];
    final vagas = ref.watch(allInternshipsProvider).valueOrNull ?? const <Internship>[];
    final news = ref.watch(publishedNewsProvider).valueOrNull ?? const <News>[];

    final cursoHits = [
      for (final cur in courses)
        if (_match('${cur.name} ${cur.category} ${cur.type}'))
          _Hit(icon: cur.icon, title: cur.name, subtitle: '${cur.type} · ${cur.period}',
              onTap: () => context.push('/cursos/detail', extra: cur)),
    ];
    final benefHits = [
      for (final d in [...gov, ...inst])
        if (_match('${d.title} ${d.summary} ${d.tag}'))
          _Hit(icon: d.icon, title: d.title, subtitle: d.summary,
              onTap: () => context.push('/conteudo/${d.id}', extra: d)),
    ];
    final now = DateTime.now();
    final vagaHits = [
      for (final v in vagas)
        if (v.visibleAt(now) && _match('${v.role} ${v.companyName} ${v.area}'))
          _Hit(icon: 'briefcase', title: v.role, subtitle: '${v.companyName} · ${v.grant}',
              onTap: () => context.push('/estagio/vaga', extra: v)),
    ];
    final newsHits = [
      for (final n in news)
        if (_match('${n.title} ${n.summary} ${n.category}'))
          _Hit(icon: 'bell', title: n.title, subtitle: '${n.category} · ${n.source}',
              onTap: () => context.push('/noticias/${n.id}', extra: n)),
    ];

    return [
      if (cursoHits.isNotEmpty) ('Cursos', cursoHits),
      if (benefHits.isNotEmpty) ('Benefícios', benefHits),
      if (vagaHits.isNotEmpty) ('Vagas e concursos', vagaHits),
      if (newsHits.isNotEmpty) ('Notícias', newsHits),
    ];
  }
}
