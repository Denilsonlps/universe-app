import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../../data/models/app_user.dart';
import '../../shared/chrome/bottom_nav.dart';
import '../../shared/chrome/menu_drawer.dart';
import '../../features/_placeholder/placeholder_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';

const _authRoutes = {'/onboarding', '/login', '/register'};

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ValueNotifier<AsyncValue<AppUser?>>(const AsyncValue.loading());
  ref.onDispose(authListenable.dispose);
  ref.listen(authStateProvider, (_, next) => authListenable.value = next, fireImmediately: true);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final auth = authListenable.value;
      if (auth.isLoading) return '/splash';
      final loggedIn = auth.valueOrNull != null;
      final loc = state.matchedLocation;
      if (!loggedIn) return _authRoutes.contains(loc) ? null : '/onboarding';
      if (loc == '/splash' || _authRoutes.contains(loc)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
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
});

class _Tab extends ConsumerWidget {
  final String title, tab;
  const _Tab(this.title, this.tab);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlaceholderScreen(
      title: title, tab: tab,
      onMenu: () => Scaffold.of(context).openDrawer(),
      onBell: () {},
      onTab: (k) => context.go('/$k'),
    );
  }
}

class _Shell extends ConsumerWidget {
  final Widget child;
  const _Shell({required this.child});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    return Scaffold(
      backgroundColor: context.c.bg,
      drawer: MenuDrawer(
        userName: user?.name ?? 'Estudante',
        userEmail: user?.email ?? '',
        onNavigate: (route) { Navigator.pop(context); if (navTabs.any((t) => '/${t.key}' == route)) context.go(route); },
        onLogout: () { Navigator.pop(context); ref.read(authRepositoryProvider).signOut(); },
      ),
      body: child,
    );
  }
}
