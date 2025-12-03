/// Uygulama genelinde kullanılan sabitler
class AppConstants {
  AppConstants._();

  /// Uygulama adı
  static const String appName = 'YearFlow';

  /// Ücretsiz kullanıcı hedef limiti
  static const int freeGoalLimit = 5;

  /// Check-in puanlama aralığı
  static const int minScore = 1;
  static const int maxScore = 10;

  /// Animasyon süreleri
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);

  /// Sayfalama
  static const int pageSize = 20;
}

/// Hedef kategorileri
enum GoalCategory {
  health('Sağlık', '💪'),
  mentalHealth('Ruh Sağlığı', '🧘'),
  finance('Finans', '💰'),
  career('Kariyer', '💼'),
  relationships('İlişkiler', '❤️'),
  learning('Öğrenme', '📚'),
  creativity('Yaratıcılık', '🎨'),
  hobby('Hobi', '🎮'),
  personalGrowth('Kişisel Gelişim', '🌱');

  const GoalCategory(this.label, this.emoji);

  final String label;
  final String emoji;
}

