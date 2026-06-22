import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../../data/models/app_user.dart';
import '../../data/models/course.dart';
import '../../data/models/content_doc.dart';
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
import '../../data/models/internship.dart';
import '../../data/models/contest.dart';
import '../../features/benefits/screens/benefits_screen.dart';
import '../../features/content/screens/content_doc_screen.dart';
import '../../features/internships/screens/estagio_screen.dart';
import '../../features/internships/screens/vaga_detail_screen.dart';
import '../../features/internships/screens/contest_detail_screen.dart';
import '../../features/internships/screens/depoimentos_screen.dart';
import '../../features/admin/screens/admin_panel_screen.dart';
import '../../features/admin/screens/admin_hub_screen.dart';
import '../../features/admin/screens/admin_content_list_screen.dart';
import '../../features/admin/screens/admin_content_edit_screen.dart';
import '../../features/admin/screens/vaga_form_screen.dart';
import '../../features/admin/screens/concurso_form_screen.dart';
import '../../data/models/news.dart';
import '../../features/news/screens/news_list_screen.dart';
import '../../features/news/screens/news_detail_screen.dart';
import '../../features/admin/screens/admin_news_list_screen.dart';
import '../../features/admin/screens/admin_news_edit_screen.dart';
import '../../features/admin/screens/admin_sugestoes_screen.dart';
import '../providers/profile_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/repository_provider.dart';
import 'transitions.dart';

const _authRoutes = {'/onboarding', '/login', '/register'};

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ValueNotifier<AsyncValue<AppUser?>>(const AsyncValue.loading());
  ref.onDispose(authListenable.dispose);
  ref.listen(authStateProvider, (_, next) => authListenable.value = next, fireImmediately: true);

  final onbListenable = ValueNotifier<bool>(false);
  ref.onDispose(onbListenable.dispose);
  ref.listen(onboardingSeenProvider, (_, next) => onbListenable.value = next, fireImmediately: true);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: Listenable.merge([authListenable, onbListenable]),
    redirect: (context, state) {
      final auth = authListenable.value;
      if (auth.isLoading) return '/splash';
      final loggedIn = auth.valueOrNull != null;
      final loc = state.matchedLocation;
      if (!loggedIn) {
        if (_authRoutes.contains(loc)) return null;
        return onbListenable.value ? '/login' : '/onboarding';
      }
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
      GoRoute(path: '/cadastrar', pageBuilder: (c, s) => fadeSlide(s, const CadastrarScreen())),
      GoRoute(path: '/ifsp', pageBuilder: (c, s) => fadeSlide(s, const IfspScreen())),
      GoRoute(path: '/ifsp/:key', pageBuilder: (c, s) => fadeSlide(s, IfspDetailScreen(detailKey: s.pathParameters['key']!))),
      GoRoute(path: '/cursos/detail', pageBuilder: (c, s) => fadeSlide(s, CourseDetailScreen(course: s.extra is Course ? s.extra as Course : null))),
      GoRoute(path: '/beneficios/gov', pageBuilder: (c, s) => fadeSlide(s, const BenefitsScreen(kind: ContentKind.gov))),
      GoRoute(path: '/beneficios/inst', pageBuilder: (c, s) => fadeSlide(s, const BenefitsScreen(kind: ContentKind.inst))),
      GoRoute(path: '/conteudo/:id', pageBuilder: (c, s) {
        final extra = s.extra;
        if (extra is ContentDoc) return fadeSlide(s, ContentDocScreen(doc: extra));
        return fadeSlide(s, _ContentDocById(id: s.pathParameters['id']!));
      }),
      GoRoute(path: '/estagio', pageBuilder: (c, s) => fadeSlide(s, EstagioScreen(initialCourse: s.extra is String ? s.extra as String : 'Todos'))),
      GoRoute(path: '/estagio/vaga', pageBuilder: (c, s) => fadeSlide(s, VagaDetailScreen(vaga: s.extra is Internship ? s.extra as Internship : null))),
      GoRoute(path: '/estagio/concurso', pageBuilder: (c, s) => fadeSlide(s, ConcursoDetailScreen(contest: s.extra is Contest ? s.extra as Contest : null))),
      GoRoute(path: '/estagio/depoimentos', pageBuilder: (c, s) => fadeSlide(s, const DepoimentosScreen())),
      GoRoute(path: '/noticias', pageBuilder: (c, s) => fadeSlide(s, const NewsListScreen())),
      GoRoute(path: '/noticias/:id', pageBuilder: (c, s) {
        final extra = s.extra;
        if (extra is News) return fadeSlide(s, NewsDetailScreen(news: extra));
        return fadeSlide(s, NewsById(id: s.pathParameters['id']!));
      }),
      GoRoute(path: '/admin', pageBuilder: (c, s) => fadeSlide(s, const AdminHubScreen())),
      GoRoute(path: '/admin/vagas', pageBuilder: (c, s) => fadeSlide(s, const AdminPanelScreen())),
      GoRoute(path: '/admin/conteudo', pageBuilder: (c, s) => fadeSlide(s, const AdminContentListScreen())),
      GoRoute(path: '/admin/conteudo/editar', pageBuilder: (c, s) => fadeSlide(s, AdminContentEditScreen(doc: s.extra is ContentDoc ? s.extra as ContentDoc : null))),
      GoRoute(path: '/admin/sugestoes', pageBuilder: (c, s) => fadeSlide(s, const AdminSugestoesScreen())),
      GoRoute(path: '/admin/vaga', pageBuilder: (c, s) {
        final x = s.extra;
        if (x is ({Internship vaga, String suggestionId})) return fadeSlide(s, VagaFormScreen(vaga: x.vaga, fromSuggestionId: x.suggestionId));
        return fadeSlide(s, VagaFormScreen(vaga: x is Internship ? x : null));
      }),
      GoRoute(path: '/admin/concurso', pageBuilder: (c, s) => fadeSlide(s, ConcursoFormScreen(contest: s.extra is Contest ? s.extra as Contest : null))),
      GoRoute(path: '/admin/noticias', pageBuilder: (c, s) => fadeSlide(s, const AdminNewsListScreen())),
      GoRoute(path: '/admin/noticias/editar', pageBuilder: (c, s) => fadeSlide(s, AdminNewsEditScreen(news: s.extra is News ? s.extra as News : null))),
    ],
  );
});

class _Shell extends ConsumerWidget {
  final Widget child;
  const _Shell({required this.child});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final isAdmin = ref.watch(isAdminProvider);
    return Scaffold(
      backgroundColor: context.c.bg,
      drawer: MenuDrawer(
        userName: user?.name ?? 'Estudante',
        userEmail: user?.email ?? '',
        isAdmin: isAdmin,
        onNavigate: (route) {
          Navigator.pop(context);
          if (navTabs.any((t) => '/${t.key}' == route)) {
            context.go(route);
          } else if (route == '/ifsp' || route == '/beneficios/gov' || route == '/beneficios/inst' || route == '/estagio' || route == '/admin') {
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

class _ContentDocById extends ConsumerWidget {
  final String id;
  const _ContentDocById({required this.id});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(contentDocProvider(id)).when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => const ContentDocScreen(doc: null),
      data: (d) => ContentDocScreen(doc: d),
    );
  }
}
