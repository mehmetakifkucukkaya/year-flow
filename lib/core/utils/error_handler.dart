import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Base class for application errors
sealed class AppError {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  /// Returns user-friendly error message
  String get userMessage => message;
}

/// Network-related errors (API, connectivity)
class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage {
    if (originalError is DioException) {
      final dioError = originalError as DioException;
      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';
        case DioExceptionType.connectionError:
          return 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.';
        case DioExceptionType.badResponse:
          final statusCode = dioError.response?.statusCode;
          if (statusCode == 401)
            return 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.';
          if (statusCode == 403) return 'Bu işlem için yetkiniz yok.';
          if (statusCode == 404) return 'İstenen kaynak bulunamadı.';
          if (statusCode == 500)
            return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
          return 'Bir hata oluştu. Lütfen tekrar deneyin.';
        case DioExceptionType.cancel:
          return 'İşlem iptal edildi.';
        default:
          return message;
      }
    }
    return message;
  }
}

/// Authentication errors
class AuthError extends AppError {
  const AuthError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage {
    if (originalError is FirebaseAuthException) {
      final authError = originalError as FirebaseAuthException;
      switch (authError.code) {
        case 'user-not-found':
          return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
        case 'wrong-password':
          return 'Hatalı şifre. Lütfen tekrar deneyin.';
        case 'email-already-in-use':
          return 'Bu e-posta adresi zaten kullanımda.';
        case 'invalid-email':
          return 'Geçersiz e-posta adresi.';
        case 'weak-password':
          return 'Şifre çok zayıf. En az 6 karakter olmalıdır.';
        case 'user-disabled':
          return 'Bu hesap devre dışı bırakılmış.';
        case 'too-many-requests':
          return 'Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin.';
        case 'operation-not-allowed':
          return 'Bu işlem şu anda kullanılamıyor.';
        case 'requires-recent-login':
          return 'Bu işlem için yeniden giriş yapmanız gerekiyor.';
        default:
          return message;
      }
    }
    return message;
  }
}

/// Firestore/Database errors
class DatabaseError extends AppError {
  const DatabaseError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage {
    if (originalError is FirebaseException) {
      final firebaseError = originalError as FirebaseException;
      switch (firebaseError.code) {
        case 'permission-denied':
          return 'Bu işlem için yetkiniz yok.';
        case 'not-found':
          return 'İstenen veri bulunamadı.';
        case 'already-exists':
          return 'Bu veri zaten mevcut.';
        case 'unavailable':
          // Firestore offline durumunda, gRPC UNAVAILABLE hataları görülebilir.
          // Kullanıcıya daha açıklayıcı bir mesaj verelim.
          return 'İnternet bağlantısı yok veya geçici olarak kullanılamıyor. Değişiklikler bağlantı sağlanınca senkronize edilecek.';
        default:
          return 'Veri işlemi sırasında bir hata oluştu.';
      }
    }
    return message;
  }
}

/// Validation errors (user input, business logic)
class ValidationError extends AppError {
  const ValidationError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Unknown/unexpected errors
class UnknownError extends AppError {
  const UnknownError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String get userMessage =>
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
}

/// Error handler utility to convert exceptions to AppError
class ErrorHandler {
  const ErrorHandler._();

  /// Converts any error to AppError and reports to Crashlytics
  static AppError handle(dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌ Error: $error');
      if (stackTrace != null) {
        debugPrint('❌ StackTrace: $stackTrace');
      }
    }

    // Already an AppError
    if (error is AppError) {
      // Non-fatal hataları Crashlytics'e gönder
      _recordNonFatalError(error, error.stackTrace);
      return error;
    }

    AppError appError;

    // Network errors
    if (error is DioException) {
      appError = NetworkError(
        message: error.message ?? 'Network error occurred',
        code: error.type.name,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    // Firebase Auth errors
    else if (error is FirebaseAuthException) {
      appError = AuthError(
        message: error.message ?? 'Authentication error occurred',
        code: error.code,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    // Firebase/Firestore errors
    else if (error is FirebaseException) {
      appError = DatabaseError(
        message: error.message ?? 'Database error occurred',
        code: error.code,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    // Unknown error
    else {
      appError = UnknownError(
        message: error.toString(),
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Non-fatal hatayı Crashlytics'e gönder
    _recordNonFatalError(appError, stackTrace);

    return appError;
  }

  /// Non-fatal hataları Crashlytics'e gönderir
  static void _recordNonFatalError(
      AppError error, StackTrace? stackTrace) {
    // Debug modda Crashlytics'e gönderme
    if (kDebugMode) return;

    try {
      FirebaseCrashlytics.instance.recordError(
        error.originalError ?? error,
        stackTrace ?? StackTrace.current,
        reason: error.message,
        information: [
          'Error Type: ${error.runtimeType}',
          if (error.code != null) 'Error Code: ${error.code}',
        ],
        fatal: false,
      );
    } catch (e) {
      // Crashlytics hatası durumunda sessizce devam et
      debugPrint('Crashlytics error: $e');
    }
  }

  /// Crashlytics'e özel log ekler
  static void log(String message) {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.log(message);
    }
    debugPrint('📝 Log: $message');
  }

  /// Crashlytics'te kullanıcı tanımlayıcısı ayarlar
  static Future<void> setUserIdentifier(String userId) async {
    if (!kDebugMode) {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    }
  }

  /// Crashlytics'e özel anahtar-değer çifti ekler
  static Future<void> setCustomKey(String key, Object value) async {
    if (!kDebugMode) {
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
    }
  }

  /// Creates a validation error
  static ValidationError validation(String message, {String? code}) {
    return ValidationError(
      message: message,
      code: code,
    );
  }

  /// Creates a network error
  static NetworkError network(String message,
      {String? code, dynamic originalError}) {
    return NetworkError(
      message: message,
      code: code,
      originalError: originalError,
    );
  }

  /// Creates an auth error
  static AuthError auth(String message,
      {String? code, dynamic originalError}) {
    return AuthError(
      message: message,
      code: code,
      originalError: originalError,
    );
  }

  /// Creates a database error
  static DatabaseError database(String message,
      {String? code, dynamic originalError}) {
    return DatabaseError(
      message: message,
      code: code,
      originalError: originalError,
    );
  }
}
