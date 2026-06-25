import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/user_avatar.dart';

/// Carteirinha digital do estudante — gerada a partir do perfil, no padrão
/// visual da carteirinha institucional do IFSP (logo, foto, dados, código de barras).
class CarteirinhaScreen extends ConsumerWidget {
  const CarteirinhaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final user = ref.watch(authStateProvider).valueOrNull;
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final name = user?.name ?? 'Estudante';
    final curso = profile?.course ?? 'Curso não informado';
    final matricula = profile?.enrollment ?? '—';

    return PageShell(
      bodyPadding: const EdgeInsets.all(20),
      header: GreenHero(title: 'Carteirinha digital', subtitle: 'Identificação do estudante', icon: 'card', onBack: () => context.pop()),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _StudentCard(name: name, curso: curso, matricula: matricula),
        const SizedBox(height: 18),
        Text(
          'Documento gerado pelo app Universe a partir dos seus dados de perfil. '
          'Não substitui a carteirinha institucional oficial. Mantenha curso e '
          'matrícula atualizados em Editar perfil.',
          style: TextStyle(fontSize: 12, color: c.ink3, height: 1.5),
        ),
      ]),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String name, curso, matricula;
  const _StudentCard({required this.name, required this.curso, required this.matricula});

  // Cores fixas: a carteirinha é um "documento" e não acompanha o tema.
  static const _green = Color(0xFF0A7D3B);
  static const _ink = Color(0xFF1A1A1A);
  static const _ink2 = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.58, // proporção aproximada de um cartão
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E2E2)),
          boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 18, offset: Offset(0, 8))],
        ),
        child: Column(children: [
          // faixa superior verde/laranja
          Row(children: const [
            Expanded(flex: 7, child: ColoredBox(color: _green, child: SizedBox(height: 7))),
            Expanded(flex: 3, child: ColoredBox(color: Color(0xFFF08A1D), child: SizedBox(height: 7))),
          ]),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // logo + dados
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const _IfspMark(),
                      const SizedBox(width: 8),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: const [
                        Text('INSTITUTO FEDERAL', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _ink, letterSpacing: 0.2, height: 1.05)),
                        Text('São Paulo · Campus Pirituba', style: TextStyle(fontSize: 9, color: _ink2, height: 1.1)),
                      ]),
                    ]),
                    const SizedBox(height: 14),
                    const Text('NOME / NOME SOCIAL', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: _ink2, letterSpacing: 0.5)),
                    const SizedBox(height: 1),
                    Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink, height: 1.1)),
                    const SizedBox(height: 8),
                    _field('Curso', curso),
                    _field('Matrícula', matricula),
                  ])),
                  const SizedBox(width: 12),
                  // foto com moldura verde
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(8)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(color: const Color(0xFFF2F2F2), child: UserAvatar(name, size: 72)),
                    ),
                  ),
                ]),
                const Spacer(),
                const _Barcode(),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _field(String label, String value) => Padding(
        padding: const EdgeInsets.only(top: 3),
        child: RichText(
          maxLines: 1, overflow: TextOverflow.ellipsis,
          text: TextSpan(children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontSize: 11, color: _ink2)),
            TextSpan(text: value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _ink)),
          ]),
        ),
      );
}

/// Marca pixelada do IFSP (grade de quadradinhos verde/vermelho — estilizada).
class _IfspMark extends StatelessWidget {
  const _IfspMark();
  @override
  Widget build(BuildContext context) {
    const g = Color(0xFF0A7D3B), r = Color(0xFFD23B2E), e = Colors.transparent;
    const grid = [
      [g, g, e, g],
      [r, e, g, e],
      [g, g, e, g],
    ];
    return Column(mainAxisSize: MainAxisSize.min, children: [
      for (final row in grid)
        Row(mainAxisSize: MainAxisSize.min, children: [
          for (final cell in row)
            Container(width: 6, height: 6, margin: const EdgeInsets.all(0.7), color: cell),
        ]),
    ]);
  }
}

/// Código de barras decorativo (barras de larguras variadas).
class _Barcode extends StatelessWidget {
  const _Barcode();
  @override
  Widget build(BuildContext context) {
    // Padrão fixo de larguras (estético; não codifica dado real).
    const widths = [3.0, 1.0, 2.0, 1.0, 1.0, 3.0, 1.0, 2.0, 2.0, 1.0, 1.0, 2.0, 3.0, 1.0, 1.0, 2.0,
      1.0, 3.0, 1.0, 2.0, 1.0, 1.0, 2.0, 3.0, 1.0, 1.0, 2.0, 1.0, 3.0, 1.0, 2.0, 1.0, 1.0, 2.0, 3.0, 1.0];
    return SizedBox(
      height: 34,
      child: Row(children: [
        for (var i = 0; i < widths.length; i++)
          Container(width: widths[i], color: i.isEven ? Colors.black : Colors.transparent),
      ]),
    );
  }
}
