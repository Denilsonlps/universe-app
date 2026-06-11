import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../../shared/chrome/bottom_nav.dart';
import '../../shared/chrome/menu_drawer.dart';
import '../../features/_placeholder/placeholder_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _Shell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (c, s) => const _Tab('Início', 'home')),
        GoRoute(path: '/cursos', builder: (c, s) => const _Tab('Cursos', 'cursos')),
        GoRoute(path: '/duvidas', builder: (c, s) => const _Tab('Dúvidas', 'duvidas')),
        GoRoute(path: '/perfil', builder: (c, s) => const _Tab('Perfil', 'perfil')),
      ],
    ),
  ],
);

class _Tab extends StatelessWidget {
  final String title, tab;
  const _Tab(this.title, this.tab);
  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: title, tab: tab,
      onMenu: () => Scaffold.of(context).openDrawer(),
      onBell: () {},
      onTab: (k) => context.go('/$k'),
    );
  }
}

class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.c.bg,
      drawer: MenuDrawer(
        userName: 'Ana Beatriz',
        userEmail: 'ana.silva@aluno.ifsp.edu.br',
        onNavigate: (route) { Navigator.pop(context); if (navTabs.any((t) => '/${t.key}' == route)) context.go(route); },
        onLogout: () => Navigator.pop(context),
      ),
      body: child,
    );
  }
}
