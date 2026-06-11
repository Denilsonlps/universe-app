import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/campus/screens/campus_screen.dart';
import '../../features/campus/screens/campus_detail_screen.dart';
import '../../features/courses/screens/courses_screen.dart';
import '../../features/courses/screens/course_detail_screen.dart';
import '../../features/benefits/screens/benefits_gov_screen.dart';
import '../../features/benefits/screens/benefits_inst_screen.dart';
import '../../features/benefits/screens/benefit_detail_screen.dart';
import '../../features/internships/screens/internships_screen.dart';
import '../../features/internships/screens/internship_detail_screen.dart';
import '../../features/internships/screens/testimonials_screen.dart';
import '../../features/internships/screens/contest_detail_screen.dart';
import '../../features/admin/screens/admin_login_screen.dart';
import '../../features/admin/screens/admin_panel_screen.dart';
import '../../features/home/screens/housing_screen.dart';
import '../../features/home/screens/republicas_screen.dart';
import '../../features/home/screens/faqs_screen.dart';
import '../../features/home/screens/notifications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/profile_card_screen.dart';
import '../../features/profile/screens/profile_edit_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Auth / Splash ───────────────────────────────────────────────────────
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // ── Shell (bottom nav: Home / Cursos / Dúvidas / Perfil) ────────────────
    ShellRoute(
      builder: (context, state, child) => _AppShell(
        location: state.uri.toString(),
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/courses',
          builder: (context, state) => const CoursesScreen(),
        ),
        GoRoute(
          path: '/faqs',
          builder: (context, state) => const FAQsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    // ── Full-screen routes (no bottom nav) ──────────────────────────────────
    GoRoute(
      path: '/campus',
      builder: (context, state) => const CampusScreen(),
    ),
    GoRoute(
      path: '/internships',
      builder: (context, state) => const InternshipsScreen(),
    ),

    // ── Detail screens (outside shell = no bottom nav) ─────────────────────
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/campus/detail/:key',
      builder: (context, state) => CampusDetailScreen(
        detailKey: state.pathParameters['key']!,
      ),
    ),
    GoRoute(
      path: '/courses/:id',
      builder: (context, state) => CourseDetailScreen(
        courseId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/benefits/gov',
      builder: (context, state) => const BenefitsGovScreen(),
    ),
    GoRoute(
      path: '/benefits/inst',
      builder: (context, state) => const BenefitsInstScreen(),
    ),
    GoRoute(
      path: '/benefits/:kind/:id',
      builder: (context, state) => BenefitDetailScreen(
        kind: state.pathParameters['kind']!,
        benefitId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/internships/testimonials',
      builder: (context, state) => const TestimonialsScreen(),
    ),
    GoRoute(
      path: '/internships/:id',
      builder: (context, state) => InternshipDetailScreen(
        internshipId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/contests/:id',
      builder: (context, state) => ContestDetailScreen(
        contestId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/admin/login',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin/panel',
      builder: (context, state) => const AdminPanelScreen(),
    ),
    GoRoute(
      path: '/housing',
      builder: (context, state) => const HousingScreen(),
    ),
    GoRoute(
      path: '/republicas',
      builder: (context, state) => const RepublicasScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/profile/card',
      builder: (context, state) => const ProfileCardScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const ProfileEditScreen(),
    ),
  ],
);

// ── Bottom-nav tab index mapping ────────────────────────────────────────────

int _locationToIndex(String location) {
  if (location.startsWith('/courses')) return 1;
  if (location.startsWith('/faqs')) return 2;
  if (location.startsWith('/profile')) return 3;
  return 0; // home, campus, internships all stay on tab 0
}

const _tabRoutes = ['/home', '/courses', '/faqs', '/profile'];

// ── Shell scaffold ───────────────────────────────────────────────────────────

class _AppShell extends StatelessWidget {
  final String location;
  final Widget child;

  const _AppShell({required this.location, required this.child});

  @override
  Widget build(BuildContext context) {
    final index = _locationToIndex(location);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: child,
      bottomNavigationBar: _AppBottomNav(
        currentIndex: index,
        onTap: (i) => context.go(_tabRoutes[i]),
      ),
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _AppBottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Início'),
    (icon: Icons.school_outlined, activeIcon: Icons.school_rounded, label: 'Cursos'),
    (icon: Icons.help_outline_rounded, activeIcon: Icons.help_rounded, label: 'Dúvidas'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.86),
        border: const Border(top: BorderSide(color: AppColors.line, width: 1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D281C).withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Icon(
                        active ? item.activeIcon : item.icon,
                        size: 23,
                        color: active ? AppColors.green700 : AppColors.ink3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                          color: active ? AppColors.green700 : AppColors.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
