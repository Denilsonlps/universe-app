import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/courses.dart';
import '../../../shared/chrome/app_headers.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/user_avatar.dart';

/// Carteirinha digital do estudante — gerada a partir do perfil (RF da R2).
class CarteirinhaScreen extends ConsumerWidget {
  const CarteirinhaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final user = ref.watch(authStateProvider).valueOrNull;
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final name = user?.name ?? 'Estudante';
    final curso = profile?.course == null ? 'Curso não informado' : courseShort(profile!.course!);
    final matricula = profile?.enrollment ?? '—';

    Widget field(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: Colors.white.withValues(alpha: 0.7))),
          const SizedBox(height: 2),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white)),
        ]);

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      header: GreenHero(title: 'Carteirinha digital', subtitle: 'Identificação do estudante', icon: 'card', onBack: () => context.pop()),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.green600, c.green900]),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('IFSP · PIRITUBA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: Colors.white.withValues(alpha: 0.85))),
                const Spacer(),
                Icon(appIcon('cap'), size: 20, color: Colors.white.withValues(alpha: 0.85)),
              ]),
              const SizedBox(height: 18),
              Row(children: [
                UserAvatar(name, size: 64),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('Estudante', style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.78))),
                ])),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: field('Curso', curso)),
                const SizedBox(width: 12),
                Expanded(child: field('Matrícula', matricula)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          Text(
            'Documento de uso interno gerado pelo app Universe a partir dos seus dados de perfil. '
            'Mantenha curso e matrícula atualizados em Editar perfil.',
            style: TextStyle(fontSize: 12, color: c.ink3, height: 1.5),
          ),
        ]),
      ),
    );
  }
}
