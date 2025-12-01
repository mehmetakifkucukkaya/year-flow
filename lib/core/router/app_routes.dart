/// Uygulama route path'leri
class AppRoutes {
  AppRoutes._();

  // Başlangıç
  static const String splash = '/';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Onboarding
  static const String onboarding = '/onboarding';

  // Main Tabs
  static const String home = '/home';
  static const String goals = '/goals';
  static const String reports = '/reports';
  static const String settings = '/settings';

  // Goals
  static const String goalDetail = '/goal/:id';
  static const String goalCreate = '/goal/create';
  static const String goalEdit = '/goal/:id/edit';

  // Check-in
  static const String checkIn = '/goal/:goalId/check-in';

  // Reports
  static const String yearlyReport = '/reports/yearly';
  static const String timeline = '/goal/:goalId/timeline';

  // Premium
  static const String premium = '/premium';

  /// Goal detail path oluştur
  static String goalDetailPath(String goalId) => '/goal/$goalId';

  /// Goal edit path oluştur
  static String goalEditPath(String goalId) => '/goal/$goalId/edit';

  /// Check-in path oluştur
  static String checkInPath(String goalId) => '/goal/$goalId/check-in';

  /// Timeline path oluştur
  static String timelinePath(String goalId) => '/goal/$goalId/timeline';
}

