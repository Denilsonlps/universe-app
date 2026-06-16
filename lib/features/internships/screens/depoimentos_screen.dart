import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/repository_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/testimonial.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_field.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/stars.dart';
import '../../../shared/widgets/user_avatar.dart';

class DepoimentosScreen extends ConsumerStatefulWidget {
  const DepoimentosScreen({super.key});
  @override
  ConsumerState<DepoimentosScreen> createState() => _DepoimentosScreenState();
}

class _DepoimentosScreenState extends ConsumerState<DepoimentosScreen> {
  bool _adding = false;
  String _org = '', _text = '';
  int _stars = 5;

  Future<void> _submit() async {
    final user = ref.read(authStateProvider).valueOrNull;
    final t = Testimonial(name: user?.name ?? 'Estudante', course: 'IFSP', org: _org, stars: _stars, text: _text, authorUid: user?.id);
    await ref.read(universeRepositoryProvider).addTestimonial(t);
    if (!mounted) return;
    setState(() { _adding = false; _org = ''; _text = ''; _stars = 5; });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Depoimento publicado!')));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final allAsync = ref.watch(testimonialsProvider);
    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: 'Depoimentos', subtitle: 'Quem já estagiou conta como foi', icon: 'star', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!_adding)
            AppButton('Adicionar meu depoimento', full: true, icon: 'edit', onTap: () => setState(() => _adding = true))
          else
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Seu depoimento', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: c.ink)),
              const SizedBox(height: 12),
              AppField(label: 'Onde você estagiou?', icon: 'institution', value: _org, onChanged: (v) => setState(() => _org = v), hint: 'Empresa / órgão'),
              const SizedBox(height: 12),
              Text('Sua nota', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.ink2)),
              const SizedBox(height: 7),
              Row(children: [
                for (var s = 1; s <= 5; s++) GestureDetector(
                  onTap: () => setState(() => _stars = s),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(s <= _stars ? Icons.star : Icons.star_border, size: 28, color: s <= _stars ? c.star : c.line),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              AppField(label: 'Como foi a experiência?', value: _text, onChanged: (v) => setState(() => _text = v), hint: 'Conte para os colegas…'),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: AppButton('Cancelar', full: true, variant: AppButtonVariant.ghost, onTap: () => setState(() => _adding = false))),
                const SizedBox(width: 10),
                Expanded(child: AppButton('Publicar', full: true, icon: 'check',
                  onTap: (_org.trim().length >= 2 && _text.trim().length >= 10) ? _submit : null)),
              ]),
            ])),
          const SizedBox(height: 16),
          AsyncListView<Testimonial>(
            value: allAsync,
            onRetry: () => ref.invalidate(testimonialsProvider),
            emptyTitle: 'Nenhum depoimento ainda',
            emptyBody: 'Seja o primeiro a compartilhar sua experiência.',
            data: (all) => Column(children: [
              for (final t in all) Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    UserAvatar(t.name, size: 40),
                    const SizedBox(width: 11),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(t.name, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink)),
                      Text('${t.course} · ${t.org}', style: TextStyle(fontSize: 11, color: c.ink3)),
                    ])),
                  ]),
                  const SizedBox(height: 9),
                  Stars(t.stars),
                  const SizedBox(height: 9),
                  Text('"${t.text}"', style: TextStyle(fontSize: 12.5, height: 1.5, color: c.ink2)),
                ])),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
