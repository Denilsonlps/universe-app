import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/chrome/bottom_nav.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/accordion.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/icon_tile.dart';

const _faqCats = ['Todas', 'Campus', 'Enem', 'Gerais'];

class DuvidasScreen extends ConsumerStatefulWidget {
  const DuvidasScreen({super.key});
  @override
  ConsumerState<DuvidasScreen> createState() => _DuvidasScreenState();
}

class _DuvidasScreenState extends ConsumerState<DuvidasScreen> {
  String _cat = 'Todas';
  String _q = '';
  int _openIdx = 0;
  String _msg = '';
  String _formCat = 'Dúvidas gerais';

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final all = ref.watch(universeRepositoryProvider).faqs();
    final list = all.where((f) =>
        (_cat == 'Todas' || f.category == _cat) &&
        f.question.toLowerCase().contains(_q.toLowerCase())).toList();

    return PageShell(
      bodyPadding: const EdgeInsets.all(16),
      bottomNav: AppBottomNav(current: 'duvidas', onTap: (k) => context.go('/$k')),
      header: Container(
        color: c.bg,
        padding: const EdgeInsets.fromLTRB(16, kStatusH, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Dúvidas', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: c.ink, letterSpacing: -0.4)),
          const SizedBox(height: 12),
          AppField(icon: 'search', hint: 'Pesquisar dúvidas…', value: _q, onChanged: (v) => setState(() => _q = v)),
        ]),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _faqCats.length,
            separatorBuilder: (context, i) => const SizedBox(width: 9),
            itemBuilder: (context, i) => AppChip(_faqCats[i], active: _cat == _faqCats[i], onTap: () => setState(() { _cat = _faqCats[i]; _openIdx = 0; })),
          ),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          const EmptyState(icon: 'question', title: 'Nenhuma dúvida encontrada', body: 'Não achamos resultados. Encaminhe sua pergunta abaixo.')
        else
          for (var i = 0; i < list.length; i++) Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Accordion(question: list[i].question, answer: list[i].answer, open: _openIdx == i, onToggle: () => setState(() => _openIdx = _openIdx == i ? -1 : i)),
          ),
        const SizedBox(height: 16),
        // Encaminhe sua dúvida
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              IconTile('send', size: 42, iconSize: 20, bg: c.green100),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Não achou sua dúvida?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.ink)),
                Text('Encaminhe direto para o campus', style: TextStyle(fontSize: 12, color: c.ink2)),
              ])),
            ]),
            const SizedBox(height: 14),
            Text('Categoria', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
            const SizedBox(height: 7),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final cat in const ['Dúvidas gerais', 'Campus', 'Enem'])
                AppChip(cat, active: _formCat == cat, onTap: () => setState(() => _formCat = cat)),
            ]),
            const SizedBox(height: 12),
            AppField(hint: 'Digite sua mensagem…', value: _msg, onChanged: (v) => setState(() => _msg = v)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${_msg.length}/500', style: TextStyle(fontSize: 11.5, color: c.ink3)),
              AppButton('Enviar', size: AppButtonSize.sm, icon: 'send',
                onTap: _msg.trim().length < 5 ? null : () { setState(() => _msg = ''); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dúvida enviada ao campus!'))); }),
            ]),
          ]),
        ),
      ]),
    );
  }
}
