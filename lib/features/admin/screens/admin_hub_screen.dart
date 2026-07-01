import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/icon_tile.dart';

class AdminHubScreen extends ConsumerWidget {
  const AdminHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final pendVagas = ref.watch(vagasSugeridasProvider).valueOrNull?.length ?? 0;
    final pendNoticias = ref.watch(noticiasSugeridasProvider).valueOrNull?.length ?? 0;
    final cards = <({String icon, String title, String sub, String route})>[
      (icon: 'briefcase', title: 'Vagas e concursos', sub: 'Estágios, jovem aprendiz e concursos', route: '/admin/vagas'),
      (icon: 'briefcase', title: 'Vagas sugeridas', sub: pendVagas == 0 ? 'Nenhuma pendente' : '$pendVagas aguardando revisão', route: '/admin/sugestoes'),
      (icon: 'bell', title: 'Notícias sugeridas', sub: pendNoticias == 0 ? 'Nenhuma pendente' : '$pendNoticias aguardando revisão', route: '/admin/noticias-sugeridas'),
      (icon: 'book', title: 'Páginas de conteúdo', sub: 'Edite os benefícios que os alunos veem', route: '/admin/conteudo'),
      (icon: 'bell', title: 'Notícias', sub: 'Avisos e novidades do campus', route: '/admin/noticias'),
    ];
    return PageShell(
      bodyPadding: const EdgeInsets.all(16),
      header: GreenHero(title: 'Painel de Administração', subtitle: 'Setor de Estágios e Comunicação', icon: 'shield', onBack: () => context.pop()),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('O que você publica aparece para os alunos na hora.', style: TextStyle(fontSize: 12.5, color: c.ink3)),
        const SizedBox(height: 14),
        for (final card in cards) Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: AppCard(
            onTap: () => context.push(card.route),
            child: Row(children: [
              IconTile(card.icon, size: 50),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(card.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.ink)),
                const SizedBox(height: 2),
                Text(card.sub, style: TextStyle(fontSize: 12, color: c.ink3)),
              ])),
              Icon(appIcon('chevR'), size: 18, color: c.ink3),
            ]),
          ),
        ),
      ]),
    );
  }
}
