import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/checkin/presentation/check_in_page.dart';
import '../../features/goals/presentation/goal_create_page.dart';
import '../../features/goals/presentation/goal_detail_page.dart';
import '../../features/goals/presentation/goal_edit_page.dart';
import '../../features/goals/presentation/goals_archive_page.dart';
import '../../features/goals/presentation/goals_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/reports/presentation/reports_page.dart';
import '../../features/settings/presentation/privacy_security_page.dart';
import '../../features/settings/presentation/profile_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import 'app_routes.dart';

/// Smooth fade transition for bottom navigation pages
Page<T> _fadeTransition<T extends Object?>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}

/// Smooth slide transition for modal pages
Page<T> _slideTransition<T extends Object?>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.1);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

/// Custom transition page for GoRouter
class CustomTransitionPage<T> extends Page<T> {
  const CustomTransitionPage({
    required super.key,
    required this.child,
    required this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) transitionsBuilder;
  final Duration transitionDuration;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: transitionDuration,
      transitionsBuilder: transitionsBuilder,
    );
  }
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation:
        authState.isAuthenticated ? AppRoutes.home : AppRoutes.login,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = state.uri.path == AppRoutes.login ||
          state.uri.path == AppRoutes.register ||
          state.uri.path == AppRoutes.forgotPassword;
      final isHomeRoute = state.uri.path == AppRoutes.home ||
          state.uri.path == AppRoutes.goals ||
          state.uri.path == AppRoutes.reports ||
          state.uri.path == AppRoutes.settings;

      // Eğer authenticated ise ve auth sayfalarına gitmeye çalışıyorsa home'a yönlendir
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }

      // Eğer authenticated değilse ve home sayfalarına gitmeye çalışıyorsa login'e yönlendir
      if (!isAuthenticated && isHomeRoute) {
        return AppRoutes.login;
      }

      return null; // Yönlendirme yok
    },
    routes: [
      // Splash Screen (şimdilik login'e yönlendiriyor)
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        redirect: (context, state) => AppRoutes.login,
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _fadeTransition(
          context: context,
          state: state,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const ForgotPasswordPage(),
        ),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Main Shell (Bottom Navigation)
      ShellRoute(
        builder: (context, state, child) {
          return _MainShell(
            location: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => _fadeTransition(
              context: context,
              state: state,
              child: const HomePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.goals,
            name: 'goals',
            pageBuilder: (context, state) => _fadeTransition(
              context: context,
              state: state,
              child: const GoalsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.goalsArchive,
            name: 'goalsArchive',
            pageBuilder: (context, state) => _fadeTransition(
              context: context,
              state: state,
              child: const GoalsArchivePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.reports,
            name: 'reports',
            pageBuilder: (context, state) => _fadeTransition(
              context: context,
              state: state,
              child: const ReportsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => _fadeTransition(
              context: context,
              state: state,
              child: const SettingsPage(),
            ),
          ),
        ],
      ),

      // Goal Create (must be before goalDetail to avoid route conflict)
      GoRoute(
        path: AppRoutes.goalCreate,
        name: 'goalCreate',
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const GoalCreatePage(),
        ),
      ),

      // Goal Detail
      GoRoute(
        path: AppRoutes.goalDetail,
        name: 'goalDetail',
        pageBuilder: (context, state) {
          final goalId = state.pathParameters['id'] ?? '';
          return _slideTransition(
            context: context,
            state: state,
            child: GoalDetailPage(goalId: goalId),
          );
        },
      ),

      // Goal Edit
      GoRoute(
        path: AppRoutes.goalEdit,
        name: 'goalEdit',
        pageBuilder: (context, state) {
          final goalId = state.pathParameters['id'] ?? '';
          return _slideTransition(
            context: context,
            state: state,
            child: GoalEditPage(goalId: goalId),
          );
        },
      ),

      // Check-in
      GoRoute(
        path: AppRoutes.checkIn,
        name: 'checkIn',
        pageBuilder: (context, state) {
          final goalId = state.pathParameters['goalId'] ?? '';
          return _slideTransition(
            context: context,
            state: state,
            child: CheckInPage(goalId: goalId),
          );
        },
      ),

      // Yearly Report
      GoRoute(
        path: AppRoutes.yearlyReport,
        name: 'yearlyReport',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Yıllık Rapor'),
      ),

      // Premium
      GoRoute(
        path: AppRoutes.premium,
        name: 'premium',
        builder: (context, state) =>
            const _PlaceholderScreen(title: "Premium'a Geç"),
      ),

      // Profile
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const ProfilePage(),
        ),
      ),

      // Privacy & Security
      GoRoute(
        path: AppRoutes.privacySecurity,
        name: 'privacySecurity',
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const PrivacySecurityPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Sayfa bulunamadı: ${state.uri.path}'),
      ),
    ),
  );
});

/// Main Shell - Bottom Navigation içeren ana wrapper
class _MainShell extends StatelessWidget {
  const _MainShell({
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  /// Mevcut route'a göre seçili index'i belirle
  int _getSelectedIndex() {
    switch (location) {
      case AppRoutes.home:
        return 0;
      case AppRoutes.goals:
        return 1;
      case AppRoutes.reports:
        return 2;
      case AppRoutes.settings:
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        height: 72, // Slightly taller for better balance
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
              break;
            case 1:
              context.go(AppRoutes.goals);
              break;
            case 2:
              context.go(AppRoutes.reports);
              break;
            case 3:
              context.go(AppRoutes.settings);
              break;
          }
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 22), // Smaller icons
            selectedIcon: Icon(Icons.home, size: 22),
            label: 'Anasayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined, size: 22),
            selectedIcon: Icon(Icons.flag, size: 22),
            label: 'Hedefler',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined, size: 22),
            selectedIcon: Icon(Icons.analytics, size: 22),
            label: 'Raporlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, size: 22),
            selectedIcon: Icon(Icons.settings, size: 22),
            label: 'Ayarlar',
          ),
        ],
        indicatorColor: Theme.of(context)
            .colorScheme
            .primary
            .withOpacity(0.15), // Pastel background
      ),
    );
  }
}

/// Placeholder screen - Geliştirme sırasında kullanılacak
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Bu ekran henüz geliştirilmedi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
