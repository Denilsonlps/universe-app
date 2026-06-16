import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';

class IfspDetailScreen extends ConsumerWidget {
  final String detailKey;
  const IfspDetailScreen({super.key, required this.detailKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final infoAsync = ref.watch(ifspInfoProvider);
    return infoAsync.when(
      loading: () => PageShell(
        bodyPadding: EdgeInsets.zero,
        header: GreenHero(title: 'Campus', onBack: () => context.pop()),
        body: const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => PageShell(
        bodyPadding: EdgeInsets.zero,
        header: GreenHero(title: 'Campus', onBack: () => context.pop()),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: EmptyState(icon: 'search', title: 'Não foi possível carregar', body: 'Verifique sua conexão e tente novamente.'),
        ),
      ),
      data: (infos) {
        final matches = infos.where((i) => i.key == detailKey);
        final detail = matches.isEmpty ? null : matches.first.detail;
        return PageShell(
          bodyPadding: EdgeInsets.zero,
          header: GreenHero(title: detail?.title ?? 'Campus', icon: detail?.icon, onBack: () => context.pop()),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: detail == null
                ? EmptyState(icon: 'search', title: 'Informação indisponível', body: 'Não encontramos detalhes para este item.')
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (detail.body != null)
                      AppCard(child: Text(detail.body!, style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2))),
                    if (detail.rows.isNotEmpty) ...[
                      if (detail.body != null) const SizedBox(height: 12),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(children: [
                          for (var i = 0; i < detail.rows.length; i++) ...[
                            if (i > 0) Divider(height: 1, color: c.line),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Expanded(flex: 2, child: Text(detail.rows[i].$1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink2))),
                                const SizedBox(width: 12),
                                Expanded(flex: 3, child: Text(detail.rows[i].$2, style: TextStyle(fontSize: 13, color: c.ink, fontWeight: FontWeight.w500))),
                              ]),
                            ),
                          ],
                        ]),
                      ),
                    ],
                  ]),
          ),
        );
      },
    );
  }
}
