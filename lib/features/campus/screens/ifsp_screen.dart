import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../data/models/ifsp_info.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/list_row.dart';
import '../../../shared/widgets/section_title.dart';

class IfspScreen extends ConsumerWidget {
  const IfspScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoAsync = ref.watch(ifspInfoProvider);
    final cursosCount = ref.watch(coursesProvider).valueOrNull?.length;
    final stats = [('2016', 'Fundado'), (cursosCount == null ? '—' : '$cursosCount', 'Cursos'), ('1.2k', 'Alunos')];
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(
        title: 'IFSP Pirituba', subtitle: 'Campus São Paulo Pirituba', icon: 'institution',
        onBack: () => context.pop(),
        child: Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Row(children: [
            for (final (v, k) in stats) Expanded(child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
              child: Column(children: [
                Text(v, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 2),
                Text(k, style: TextStyle(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.75))),
              ]),
            )),
          ]),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('Sobre o campus'),
          AsyncListView<IfspInfo>(
            value: infoAsync,
            onRetry: () => ref.invalidate(ifspInfoProvider),
            emptyTitle: 'Nenhuma informação disponível',
            data: (info) => Column(children: [
              for (final it in info) Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListRow(icon: it.icon, title: it.title, subtitle: it.subtitle, onTap: () => context.push('/ifsp/${it.key}')),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
