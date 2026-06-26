import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/ifsp_info.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/section_title.dart';
import '../widgets/campus_map.dart';

const _siteUrl = 'https://ptb.ifsp.edu.br';

/// Tela única do campus: História, Contatos, Horário, Localização (mapa) e Site.
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
        child: AsyncListView<IfspInfo>(
          value: infoAsync,
          onRetry: () => ref.invalidate(ifspInfoProvider),
          emptyTitle: 'Nenhuma informação disponível',
          data: (infos) {
            final byKey = {for (final i in infos) i.key: i.detail};
            return _Body(byKey: byKey);
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final Map<String, IfspDetail?> byKey;
  const _Body({required this.byKey});

  Future<void> _abrirSite() async {
    await launchUrl(Uri.parse(_siteUrl), mode: LaunchMode.externalApplication);
  }

  Future<void> _ligar(String numero) async {
    final tel = numero.replaceAll(RegExp(r'[^0-9+]'), '');
    await launchUrl(Uri.parse('tel:$tel'));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final historia = byKey['historia'];
    final contatos = byKey['contatos'];
    final horario = byKey['horario'];
    final endereco = byKey['endereco'];

    String? rowValue(IfspDetail? d, String labelContains) {
      if (d == null) return null;
      for (final r in d.rows) {
        if (r.$1.toLowerCase().contains(labelContains)) return r.$2;
      }
      return null;
    }

    final telefone = rowValue(contatos, 'telefone');

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // 1. História
      if (historia?.body != null) ...[
        const SectionTitle('História'),
        const SizedBox(height: 10),
        AppCard(child: Text(historia!.body!, style: TextStyle(fontSize: 13.5, height: 1.6, color: c.ink2))),
        const SizedBox(height: 20),
      ],
      // 2. Contatos
      if (telefone != null) ...[
        const SectionTitle('Contatos'),
        const SizedBox(height: 10),
        AppCard(
          onTap: () => _ligar(telefone),
          child: Row(children: [
            Icon(appIcon('phone'), size: 20, color: c.green700),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Telefone', style: TextStyle(fontSize: 11.5, color: c.ink3)),
              Text(telefone, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.ink)),
            ])),
            Icon(appIcon('chevR'), size: 18, color: c.ink3),
          ]),
        ),
        const SizedBox(height: 20),
      ],
      // 3. Horário
      if (horario != null) ...[
        const SectionTitle('Horário de funcionamento'),
        const SizedBox(height: 10),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            for (var i = 0; i < horario.rows.length; i++) ...[
              if (i > 0) Divider(height: 1, color: c.line),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(children: [
                  Expanded(flex: 2, child: Text(horario.rows[i].$1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink2))),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: Text(horario.rows[i].$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink))),
                ]),
              ),
            ],
          ]),
        ),
        if (horario.body != null) Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Text(horario.body!, style: TextStyle(fontSize: 12, color: c.ink3, height: 1.4)),
        ),
        const SizedBox(height: 20),
      ],
      // 4. Localização
      const SectionTitle('Localização'),
      const SizedBox(height: 10),
      if (endereco?.body != null) Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 2),
        child: Text(endereco!.body!, style: TextStyle(fontSize: 13.5, height: 1.5, color: c.ink2)),
      ),
      const CampusMap(),
      const SizedBox(height: 20),
      // 5. Site oficial
      const SectionTitle('Site oficial'),
      const SizedBox(height: 10),
      AppCard(
        onTap: _abrirSite,
        child: Row(children: [
          Icon(appIcon('globe'), size: 20, color: c.green700),
          const SizedBox(width: 12),
          Expanded(child: Text('ptb.ifsp.edu.br', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.ink))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(color: c.green800, borderRadius: BorderRadius.circular(10)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Abrir', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
              SizedBox(width: 5),
              Icon(Icons.open_in_new, size: 14, color: Colors.white),
            ]),
          ),
        ]),
      ),
    ]);
  }
}
