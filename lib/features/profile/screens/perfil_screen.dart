import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/repositories/seed.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/courses.dart';
import '../../../shared/chrome/bottom_nav.dart';
import '../../../shared/chrome/page_shell.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_toggle.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/user_avatar.dart';

class PerfilScreen extends ConsumerStatefulWidget {
  const PerfilScreen({super.key});
  @override
  ConsumerState<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends ConsumerState<PerfilScreen> {
  bool _notif = true;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final user = ref.watch(authStateProvider).valueOrNull;
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final name = user?.name ?? 'Estudante';
    final stats = [
      ('Curso', profile?.course == null ? '—' : courseShort(profile!.course!)),
      ('Matrícula', profile?.enrollment ?? '—'),
    ];

    Widget rowItem(String icon, String label, VoidCallback onTap, {bool last = false}) => InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: c.line))),
        child: Row(children: [
          Icon(appIcon(icon), size: 21, color: c.green700),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: c.ink))),
          Icon(appIcon('chevR'), size: 17, color: c.ink3),
        ]),
      ),
    );

    return PageShell(
      bodyPadding: EdgeInsets.zero,
      bottomNav: AppBottomNav(current: 'perfil', onTap: (k) => context.go('/$k')),
      header: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.heroFrom, c.heroTo]),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, kStatusH, 20, 24),
        child: Column(children: [
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => ref.read(themeModeProvider.notifier).toggle(),
              child: Padding(padding: const EdgeInsets.all(6), child: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 22, color: Colors.white)),
            ),
          ),
          UserAvatar(name, size: 84),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          if (user?.email != null) Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(user!.email, style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.78))),
          ),
          const SizedBox(height: 18),
          Row(children: [
            for (final (k, v) in stats) Expanded(child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
              child: Column(children: [
                Text(v, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 3),
                Text(k, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.72))),
              ]),
            )),
          ]),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          AppCard(padding: EdgeInsets.zero, child: Column(children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
              child: Row(children: [
                Icon(appIcon('bell'), size: 21, color: c.green700),
                const SizedBox(width: 14),
                Expanded(child: Text('Notificações', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: c.ink))),
                AppToggle(on: _notif, onChanged: (v) => setState(() => _notif = v)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
              child: Row(children: [
                Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, size: 21, color: c.green700),
                const SizedBox(width: 14),
                Expanded(child: Text('Modo escuro', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: c.ink))),
                AppToggle(on: isDark, onChanged: (_) => ref.read(themeModeProvider.notifier).toggle()),
              ]),
            ),
          ])),
          const SizedBox(height: 14),
          AppCard(padding: EdgeInsets.zero, child: Column(children: [
            rowItem('edit', 'Editar perfil', () => context.push('/cadastrar')),
            rowItem('card', 'Carteirinha digital', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve')))),
            rowItem('shield', 'Alterar senha', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve'))), last: true),
          ])),
          const SizedBox(height: 14),
          AppCard(padding: EdgeInsets.zero, child: Column(children: [
            rowItem('question', 'Central de dúvidas', () => context.go('/duvidas')),
            rowItem('institution', 'Sobre o IFSP Pirituba', () => context.push('/ifsp')),
            rowItem('doc', 'Termos e privacidade', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve'))), last: true),
          ])),
          if (kDebugMode) ...[
            const SizedBox(height: 14),
            AppCard(padding: EdgeInsets.zero, child: Column(children: [
              rowItem('settings', 'Popular dados de exemplo (dev)', () async {
                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(const SnackBar(content: Text('Populando Firestore…')));
                try {
                  await seedFirestore();
                  messenger.showSnackBar(const SnackBar(content: Text('Dados populados!')));
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('Falha ao popular: $e')));
                }
              }, last: true),
            ])),
          ],
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => ref.read(authRepositoryProvider).signOut(),
            child: AppCard(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(appIcon('logout'), size: 20, color: c.error),
              const SizedBox(width: 9),
              Text('Sair da conta', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.error)),
            ])),
          ),
          const SizedBox(height: 18),
          Text('UNIVERSE · v1.0 · IFSP Pirituba', style: TextStyle(fontSize: 11, color: c.ink3)),
        ]),
      ),
    );
  }
}
