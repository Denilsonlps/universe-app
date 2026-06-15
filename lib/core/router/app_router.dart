import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../../data/models/app_user.dart';
import '../../data/models/course.dart';
import '../../shared/chrome/bottom_nav.dart';
import '../../shared/chrome/menu_drawer.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/faqs/screens/duvidas_screen.dart';
import '../../features/profile/screens/perfil_screen.dart';
import '../../features/profile/screens/cadastrar_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/courses/screens/courses_screen.dart';
import '../../features/courses/screens/course_detail_screen.dart';
import '../../features/campus/screens/ifsp_screen.dart';
import '../../features/campus/screens/ifsp_detail_screen.dart';
import '../../data/models/benefit.dart';
import '../../data/models/internship.dart';
import '../../data/models/contest.dart';
import '../../features/benefits/screens/benefits_screen.dart';
import '../../features/benefits/screens/benefit_detail_screen.dart';
import '../../features/internships/screens/estagio_screen.dart';
import '../../features/internships/screens/vaga_detail_screen.dart';
import '../../features/internships/screens/contest_detail_screen.dart';
import '../../features/internships/screens/depoimentos_screen.dart';

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
          GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
          GoRoute(path: '/cursos', builder: (c, s) => const CoursesScreen()),
          GoRoute(path: '/duvidas', builder: (c, s) => const DuvidasScreen()),
          GoRoute(path: '/perfil', builder: (c, s) => const PerfilScreen()),
        ],
      ),
      GoRoute(path: '/cadastrar', builder: (c, s) => const CadastrarScreen()),
      GoRoute(path: '/ifsp', builder: (c, s) => const IfspScreen()),
      GoRoute(path: '/ifsp/:key', builder: (c, s) => IfspDetailScreen(detailKey: s.pathParameters['key']!)),
      GoRoute(path: '/cursos/detail', builder: (c, s) => CourseDetailScreen(course: s.extra is Course ? s.extra as Course : null)),
      GoRoute(path: '/beneficios/gov', builder: (c, s) => const BenefitsScreen(kind: BenefitKind.gov)),
      GoRoute(path: '/beneficios/inst', builder: (c, s) => const BenefitsScreen(kind: BenefitKind.inst)),
      GoRoute(path: '/beneficios/detail', builder: (c, s) {
        final x = s.extra;
        if (x is ({Benefit benefit, bool isGov})) return BenefitDetailScreen(benefit: x.benefit, isGov: x.isGov);
        return const BenefitDetailScreen(benefit: null, isGov: true);
      }),
      GoRoute(path: '/estagio', builder: (c, s) => EstagioScreen(initialCourse: s.extra is String ? s.extra as String : 'Todos')),
      GoRoute(path: '/estagio/vaga', builder: (c, s) => VagaDetailScreen(vaga: s.extra is Internship ? s.extra as Internship : null)),
      GoRoute(path: '/estagio/concurso', builder: (c, s) => ConcursoDetailScreen(contest: s.extra is Contest ? s.extra as Contest : null)),
      GoRoute(path: '/estagio/depoimentos', builder: (c, s) => const DepoimentosScreen()),
    ],
  );
});

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
        onNavigate: (route) {
          Navigator.pop(context);
          if (navTabs.any((t) => '/${t.key}' == route)) {
            context.go(route);
          } else if (route == '/ifsp' || route == '/beneficios/gov' || route == '/beneficios/inst' || route == '/estagio') {
            context.push(route);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Em breve')));
          }
        },
        onLogout: () { Navigator.pop(context); ref.read(authRepositoryProvider).signOut(); },
      ),
      body: child,
    );
  }
}
