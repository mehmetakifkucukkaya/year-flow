import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Crashlytics yardımcı sınıfı
///
/// Uygulama genelinde crash raporlama ve hata takibi için kullanılır.
/// Debug modda hatalar sadece console'a yazdırılır.
class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics =
      FirebaseCrashlytics.instance;

  /// Crashlytics koleksiyonunu etkinleştir/devre dışı bırak
  static Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
    if (kDebugMode) {
      debugPrint(
          '🔥 Crashlytics: Collection ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  /// Kullanıcı tanımlayıcısı ayarla
  static Future<void> setUserIdentifier(String userId) async {
    if (kDebugMode) {
      debugPrint('🔥 Crashlytics: User ID set - $userId');
      return;
    }

    await _crashlytics.setUserIdentifier(userId);
  }

  /// Özel anahtar-değer çifti ayarla
  static Future<void> setCustomKey(String key, Object value) async {
    if (kDebugMode) {
      debugPrint('🔥 Crashlytics: Custom key - $key: $value');
      return;
    }

    await _crashlytics.setCustomKey(key, value);
  }

  /// Log mesajı ekle
  static void log(String message) {
    if (kDebugMode) {
      debugPrint('🔥 Crashlytics Log: $message');
      return;
    }

    _crashlytics.log(message);
  }

  /// Non-fatal hata kaydet
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
    Iterable<Object> information = const [],
  }) async {
    if (kDebugMode) {
      debugPrint('🔥 Crashlytics Error: $exception');
      debugPrint('🔥 Reason: $reason');
      debugPrint('🔥 Fatal: $fatal');
      if (stack != null) {
        debugPrint('🔥 Stack: $stack');
      }
      return;
    }

    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
      information: information,
    );
  }

  /// Flutter framework hatasını kaydet
  static void recordFlutterError(FlutterErrorDetails errorDetails) {
    if (kDebugMode) {
      debugPrint(
          '🔥 Crashlytics Flutter Error: ${errorDetails.exception}');
      return;
    }

    _crashlytics.recordFlutterError(errorDetails);
  }

  /// Fatal Flutter hatası kaydet
  static void recordFlutterFatalError(FlutterErrorDetails errorDetails) {
    if (kDebugMode) {
      debugPrint(
          '🔥 Crashlytics Fatal Flutter Error: ${errorDetails.exception}');
      return;
    }

    _crashlytics.recordFlutterFatalError(errorDetails);
  }

  /// Test için crash tetikle (SADECE DEBUG AMAÇLI)
  /// ÖNEMLİ: Bu metod uygulamayı kasıtlı olarak çökertir!
  static void testCrash() {
    if (kDebugMode) {
      debugPrint(
          '🔥 Crashlytics: Test crash triggered (debug mode - not crashing)');
      return;
    }

    _crashlytics.crash();
  }

  /// Kullanıcı oturumu bilgilerini temizle
  static Future<void> clearUserIdentifier() async {
    if (kDebugMode) {
      debugPrint('🔥 Crashlytics: User identifier cleared');
      return;
    }

    await _crashlytics.setUserIdentifier('');
  }

  /// Birden fazla özel anahtar ayarla
  static Future<void> setCustomKeys(Map<String, Object> keys) async {
    for (final entry in keys.entries) {
      await setCustomKey(entry.key, entry.value);
    }
  }

  /// Yaygın kullanıcı bilgilerini ayarla
  static Future<void> setUserInfo({
    required String userId,
    String? email,
    String? displayName,
    bool? isPremium,
  }) async {
    await setUserIdentifier(userId);

    final keys = <String, Object>{
      if (email != null) 'user_email': email,
      if (displayName != null) 'user_name': displayName,
      if (isPremium != null) 'is_premium': isPremium,
    };

    if (keys.isNotEmpty) {
      await setCustomKeys(keys);
    }
  }

  /// Crashlytics durumunu kontrol et
  static Future<bool> get isCrashlyticsCollectionEnabled async {
    return _crashlytics.isCrashlyticsCollectionEnabled;
  }

  /// Bekleyen tüm raporları gönder
  static Future<void> sendUnsentReports() async {
    if (kDebugMode) {
      debugPrint('🔥 Crashlytics: Sending unsent reports');
      return;
    }

    await _crashlytics.sendUnsentReports();
  }

  /// Gönderilmemiş raporları sil
  static Future<void> deleteUnsentReports() async {
    if (kDebugMode) {
      debugPrint('🔥 Crashlytics: Deleting unsent reports');
      return;
    }

    await _crashlytics.deleteUnsentReports();
  }

  /// Crashlytics'in yakaladığı son hatayı kontrol et
  static Future<bool> didCrashOnPreviousExecution() async {
    return await _crashlytics.didCrashOnPreviousExecution();
  }
}
