import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/goals/presentation/goal_create_page.dart';
import '../../features/goals/presentation/goal_edit_page.dart';
import '../../features/goals/presentation/goal_detail_page.dart';
import '../../features/goals/presentation/goals_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/reports/presentation/reports_page.dart';
import 'app_routes.dart';

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
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
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
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
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.goals,
            name: 'goals',
            builder: (context, state) => const GoalsPage(),
          ),
          GoRoute(
            path: AppRoutes.reports,
            name: 'reports',
            builder: (context, state) => const ReportsPage(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Ayarlar'),
          ),
        ],
      ),

      // Goal Create (must be before goalDetail to avoid route conflict)
      GoRoute(
        path: AppRoutes.goalCreate,
        name: 'goalCreate',
        builder: (context, state) => const GoalCreatePage(),
      ),

      // Goal Detail
      GoRoute(
        path: AppRoutes.goalDetail,
        name: 'goalDetail',
        builder: (context, state) {
          final goalId = state.pathParameters['id'] ?? '';
          return GoalDetailPage(goalId: goalId);
        },
      ),

      // Goal Edit
      GoRoute(
        path: AppRoutes.goalEdit,
        name: 'goalEdit',
        builder: (context, state) {
          final goalId = state.pathParameters['id'] ?? '';
          return GoalEditPage(goalId: goalId);
        },
      ),

      // Check-in
      GoRoute(
        path: AppRoutes.checkIn,
        name: 'checkIn',
        builder: (context, state) {
          final goalId = state.pathParameters['goalId'] ?? '';
          return _PlaceholderScreen(title: 'Check-in: $goalId');
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
