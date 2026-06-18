import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/content_doc.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/content/content_section_view.dart';
import '../../../shared/content/term_sheet.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/icon_tile.dart';

class ContentDocScreen extends StatelessWidget {
  final ContentDoc? doc;
  const ContentDocScreen({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final d = doc;
    if (d == null) {
      return PageShell(
        bodyPadding: EdgeInsets.zero,
        header: PageHeader(title: 'Conteúdo', onBack: () => context.pop()),
        body: const EmptyState(icon: 'doc', title: 'Conteúdo não encontrado'),
      );
    }

    void openDoc(String id) => context.push('/conteudo/$id');
    void openTerm(String key) => showTermSheet(context, key, onOpenDoc: openDoc);

    final updated =
        '${d.updatedAt.day.toString().padLeft(2, '0')}/${d.updatedAt.month.toString().padLeft(2, '0')}/${d.updatedAt.year}';

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: d.title, subtitle: d.tag, icon: d.icon, onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(appIcon('clock'), size: 14, color: c.ink3),
            const SizedBox(width: 6),
            Text(
              'Atualizado em $updated',
              style: TextStyle(fontSize: 11.5, color: c.ink3, fontWeight: FontWeight.w600),
            ),
          ]),
          const SizedBox(height: 18),
          for (final s in d.sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: ContentSectionView(section: s, onOpenDoc: openDoc, onOpenTerm: openTerm),
            ),
        ]),
      ),
    );
  }
}
