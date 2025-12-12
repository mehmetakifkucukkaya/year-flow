import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/extensions.dart';
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
import '../../features/onboarding/providers/onboarding_providers.dart';
import '../../features/reports/presentation/report_detail_page.dart';
import '../../features/reports/presentation/reports_page.dart';
import '../../features/settings/presentation/privacy_security_page.dart';
import '../../features/settings/presentation/profile_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../shared/models/yearly_report.dart';
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
  // Auth state'i daha güvenli bir şekilde hesapla:
  // - Yalnızca isAuthenticated true ise
  // - Ve herhangi bir loading durumu yoksa
  // - Ve errorMessage ve errorCode null ise kullanıcıyı authenticated kabul et.
  final authState = ref.watch(authStateProvider);
  final isAuthenticated = authState.isAuthenticated &&
      !authState.isLoading &&
      !authState.isEmailLoading &&
      !authState.isGoogleLoading &&
      authState.errorMessage == null &&
      authState.errorCode == null;

  // Onboarding tamamlandı mı kontrolü - try-catch ile güvenli okuma
  // İlk açılışta false olacak (henüz yüklenmemişse), sonra SharedPreferences'tan yüklenecek
  bool isOnboardingCompleted = false;
  try {
    isOnboardingCompleted = ref.watch(onboardingCompletedProvider);
  } catch (e) {
    // Hata durumunda varsayılan olarak false (onboarding göster)
    isOnboardingCompleted = false;
  }

  // Initial location belirleme
  // İlk açılışta: authenticated değilse ve onboarding tamamlanmamışsa onboarding'e git
  String getInitialLocation() {
    if (isAuthenticated) {
      return AppRoutes.home;
    }
    // Authenticated değilse - onboarding tamamlanmışsa login'e, değilse onboarding'e git
    // İlk açılışta isOnboardingCompleted false olacak, bu yüzden onboarding'e gidecek
    if (isOnboardingCompleted) {
      return AppRoutes.login;
    }
    // İlk açılış veya onboarding tamamlanmamış - onboarding göster
    return AppRoutes.onboarding;
  }

  return GoRouter(
    initialLocation: getInitialLocation(),
    debugLogDiagnostics: false,
    redirect: (context, state) {
      try {
        // Redirect içinde güncel state'leri oku
        final currentAuthState = ref.read(authStateProvider);
        final currentIsAuthenticated = currentAuthState.isAuthenticated &&
            !currentAuthState.isLoading &&
            !currentAuthState.isEmailLoading &&
            !currentAuthState.isGoogleLoading &&
            currentAuthState.errorMessage == null &&
            currentAuthState.errorCode == null;

        bool currentIsOnboardingCompleted = false;
        try {
          currentIsOnboardingCompleted =
              ref.read(onboardingCompletedProvider);
        } catch (e) {
          // Hata durumunda varsayılan olarak false
          currentIsOnboardingCompleted = false;
        }

        final currentPath = state.uri.path;
        final isAuthRoute = currentPath == AppRoutes.login ||
            currentPath == AppRoutes.register ||
            currentPath == AppRoutes.forgotPassword;
        final isHomeRoute = currentPath == AppRoutes.home ||
            currentPath == AppRoutes.goals ||
            currentPath == AppRoutes.reports ||
            currentPath == AppRoutes.settings;
        final isOnboardingRoute = currentPath == AppRoutes.onboarding;

        // Eğer authenticated ise:
        if (currentIsAuthenticated) {
          // Auth sayfalarına gitmeye çalışıyorsa home'a yönlendir
          if (isAuthRoute) {
            return AppRoutes.home;
          }
          // Onboarding'e gitmeye çalışıyorsa home'a yönlendir
          if (isOnboardingRoute) {
            return AppRoutes.home;
          }
        }

        // Eğer authenticated değilse:
        if (!currentIsAuthenticated) {
          // Home sayfalarına gitmeye çalışıyorsa login'e yönlendir
          if (isHomeRoute) {
            return AppRoutes.login;
          }
          // Onboarding tamamlanmadıysa ve auth sayfalarına gitmeye çalışıyorsa onboarding'e yönlendir
          // İlk açılışta onboarding tamamlanmamış olacak, bu yüzden onboarding'e yönlendirilecek
          if (!currentIsOnboardingCompleted && isAuthRoute) {
            return AppRoutes.onboarding;
          }
          // Onboarding tamamlandıysa ve auth sayfalarına erişmeye çalışıyorsa izin ver (null döndür)
          // Onboarding route'unda ise ve tamamlanmışsa login'e yönlendir
          if (isOnboardingRoute && currentIsOnboardingCompleted) {
            return AppRoutes.login;
          }
        }

        return null; // Yönlendirme yok
      } catch (e) {
        // Hata durumunda null döndür (navigation devam etsin)
        debugPrint('Router redirect error: $e');
        return null;
      }
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        redirect: (context, state) {
          try {
            final currentAuthState = ref.read(authStateProvider);
            final currentIsAuthenticated =
                currentAuthState.isAuthenticated &&
                    !currentAuthState.isLoading &&
                    !currentAuthState.isEmailLoading &&
                    !currentAuthState.isGoogleLoading &&
                    currentAuthState.errorMessage == null &&
                    currentAuthState.errorCode == null;

            bool currentIsOnboardingCompleted = false;
            try {
              currentIsOnboardingCompleted =
                  ref.read(onboardingCompletedProvider);
            } catch (e) {
              // Hata durumunda varsayılan olarak false
              currentIsOnboardingCompleted = false;
            }

            if (currentIsAuthenticated) {
              return AppRoutes.home;
            }
            if (currentIsOnboardingCompleted) {
              return AppRoutes.login;
            }
            return AppRoutes.onboarding;
          } catch (e) {
            // Hata durumunda onboarding'e yönlendir
            debugPrint('Splash redirect error: $e');
            return AppRoutes.onboarding;
          }
        },
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

      // Report Detail
      GoRoute(
        path: AppRoutes.reportDetail,
        name: 'reportDetail',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            return _slideTransition(
              context: context,
              state: state,
              child: const _PlaceholderScreen(title: 'Rapor Bulunamadı'),
            );
          }

          return _slideTransition(
            context: context,
            state: state,
            child: ReportDetailPage(
              reportType: extra['reportType'] as ReportType,
              content: extra['content'] as String,
              reportId: extra['reportId'] as String?,
              periodStart: extra['periodStart'] as DateTime?,
              periodEnd: extra['periodEnd'] as DateTime?,
            ),
          );
        },
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
        child: Text(context.l10n.pageNotFound(state.uri.path)),
      ),
    ),
  );
});

/// Main Shell - Bottom Navigation içeren ana wrapper
class _MainShell extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
        destinations: [
          NavigationDestination(
            icon:
                const Icon(Icons.home_outlined, size: 22), // Smaller icons
            selectedIcon: const Icon(Icons.home, size: 22),
            label: context.l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined, size: 22),
            selectedIcon: const Icon(Icons.flag, size: 22),
            label: context.l10n.goals,
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined, size: 22),
            selectedIcon: const Icon(Icons.analytics, size: 22),
            label: context.l10n.reports,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined, size: 22),
            selectedIcon: const Icon(Icons.settings, size: 22),
            label: context.l10n.settings,
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
