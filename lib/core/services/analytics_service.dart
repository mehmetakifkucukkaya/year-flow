import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics yardımcı sınıfı
///
/// Uygulama genelinde analytics olaylarını takip etmek için kullanılır.
/// Debug modda olaylar sadece console'a yazdırılır.
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Firebase Analytics Observer - GoRouter ile kullanım için
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Ekran görüntüleme olayı
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Screen View - $screenName');
      return;
    }

    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// Kullanıcı girişi olayı
  static Future<void> logLogin({String? method}) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Login - $method');
      return;
    }

    await _analytics.logLogin(loginMethod: method);
  }

  /// Kullanıcı kaydı olayı
  static Future<void> logSignUp({String? method}) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Sign Up - $method');
      return;
    }

    await _analytics.logSignUp(signUpMethod: method ?? 'email');
  }

  /// Hedef oluşturma olayı
  static Future<void> logGoalCreated({
    required String goalId,
    required String goalCategory,
    String? goalTitle,
  }) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Goal Created - $goalCategory');
      return;
    }

    await _analytics.logEvent(
      name: 'goal_created',
      parameters: {
        'goal_id': goalId,
        'goal_category': goalCategory,
        if (goalTitle != null) 'goal_title': goalTitle,
      },
    );
  }

  /// Hedef tamamlama olayı
  static Future<void> logGoalCompleted({
    required String goalId,
    required String goalCategory,
  }) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Goal Completed - $goalCategory');
      return;
    }

    await _analytics.logEvent(
      name: 'goal_completed',
      parameters: {
        'goal_id': goalId,
        'goal_category': goalCategory,
      },
    );
  }

  /// İlerleme güncelleme olayı
  static Future<void> logProgressUpdated({
    required String goalId,
    required int progressPercentage,
  }) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Progress Updated - $progressPercentage%');
      return;
    }

    await _analytics.logEvent(
      name: 'progress_updated',
      parameters: {
        'goal_id': goalId,
        'progress_percentage': progressPercentage,
      },
    );
  }

  /// Check-in olayı
  static Future<void> logCheckIn({
    required String checkInType,
    String? mood,
  }) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Check-in - $checkInType');
      return;
    }

    await _analytics.logEvent(
      name: 'check_in',
      parameters: {
        'check_in_type': checkInType,
        if (mood != null) 'mood': mood,
      },
    );
  }

  /// Paylaşım olayı
  static Future<void> logShare({
    required String contentType,
    required String itemId,
    String? method,
  }) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Share - $contentType');
      return;
    }

    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method ?? 'unknown',
    );
  }

  /// Premium satın alma başlangıcı
  static Future<void> logBeginCheckout({
    required String itemId,
    required String itemName,
    double? price,
    String? currency,
  }) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Begin Checkout - $itemName');
      return;
    }

    await _analytics.logBeginCheckout(
      value: price,
      currency: currency ?? 'TRY',
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          price: price,
        ),
      ],
    );
  }

  /// Premium satın alma tamamlandı
  static Future<void> logPurchase({
    required String itemId,
    required String itemName,
    required double price,
    String? currency,
    String? transactionId,
  }) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Purchase - $itemName');
      return;
    }

    await _analytics.logPurchase(
      transactionId: transactionId,
      value: price,
      currency: currency ?? 'TRY',
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          price: price,
        ),
      ],
    );
  }

  /// Özel olay
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Custom Event - $name');
      return;
    }

    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  /// Kullanıcı özelliği ayarla
  static Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Set User Property - $name: $value');
      return;
    }

    await _analytics.setUserProperty(name: name, value: value);
  }

  /// Kullanıcı ID'si ayarla
  static Future<void> setUserId(String? userId) async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Set User ID - $userId');
      return;
    }

    await _analytics.setUserId(id: userId);
  }

  /// Analytics koleksiyonunu etkinleştir/devre dışı bırak (GDPR/KVKK uyumluluğu için)
  static Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
    if (kDebugMode) {
      debugPrint(
          '📊 Analytics: Collection ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  /// Mevcut oturumu sonlandır
  static Future<void> resetAnalyticsData() async {
    if (kDebugMode) {
      debugPrint('📊 Analytics: Data Reset');
      return;
    }

    await _analytics.resetAnalyticsData();
  }
}
