import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Firebase Auth hatalarını lokalize edilmiş mesajlara çeviren utility sınıfı
class AuthErrorHandler {
  AuthErrorHandler._();

  /// FirebaseAuthException'ı lokalize edilmiş mesaja çevir
  /// 
  /// [context] lokalizasyon için gerekli BuildContext
  /// [exception] yakalanan FirebaseAuthException
  /// 
  /// Returns lokalize edilmiş hata mesajı
  static String getLocalizedMessage(
    BuildContext context,
    FirebaseAuthException exception,
  ) {
    final l10n = AppLocalizations.of(context)!;

    switch (exception.code) {
      // Kayıt hataları
      case 'email-already-in-use':
        return l10n.errorEmailAlreadyInUse;
      case 'weak-password':
        return l10n.errorWeakPassword;
      case 'invalid-email':
        return l10n.errorInvalidEmail;

      // Giriş hataları
      case 'user-not-found':
        return l10n.errorUserNotFound;
      case 'wrong-password':
        return l10n.errorWrongPassword;
      case 'invalid-credential':
        return l10n.errorInvalidCredential;

      // Hesap durumu hataları
      case 'user-disabled':
        return l10n.errorUserDisabled;
      case 'too-many-requests':
        return l10n.errorTooManyRequests;
      case 'operation-not-allowed':
        return l10n.errorOperationNotAllowed;

      // Ağ hataları
      case 'network-request-failed':
        return l10n.errorNetworkRequestFailed;

      // Şifre değiştirme hataları
      case 'requires-recent-login':
        return l10n.errorRequiresRecentLogin;

      // Bilinmeyen hatalar için varsayılan mesajlar
      default:
        // Eğer exception'ın kendi mesajı varsa ve İngilizce ise,
        // genel bir mesaj döndür (güvenlik ve tutarlılık için)
        return l10n.errorUnexpectedAuth;
    }
  }

  /// Sign-in hataları için özel lokalize mesaj
  /// 
  /// Account enumeration riskini azaltmak için user-not-found ve wrong-password
  /// hatalarını tek bir genel mesaja çevirir.
  static String getLocalizedSignInMessage(
    BuildContext context,
    FirebaseAuthException exception,
  ) {
    final l10n = AppLocalizations.of(context)!;

    switch (exception.code) {
      case 'email-already-in-use':
        return l10n.errorEmailAlreadyInUse;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-email':
      case 'invalid-credential':
        // Account enumeration riskini azaltmak için tek bir genel mesaj
        return l10n.errorSignInFailed;
      case 'user-disabled':
        return l10n.errorUserDisabled;
      case 'too-many-requests':
        return l10n.errorTooManyRequests;
      case 'operation-not-allowed':
        return l10n.errorOperationNotAllowed;
      case 'network-request-failed':
        return l10n.errorNetworkRequestFailed;
      default:
        return l10n.errorSignInFailed;
    }
  }

  /// Sign-up hataları için özel lokalize mesaj
  static String getLocalizedSignUpMessage(
    BuildContext context,
    FirebaseAuthException exception,
  ) {
    final l10n = AppLocalizations.of(context)!;

    switch (exception.code) {
      case 'email-already-in-use':
        return l10n.errorEmailAlreadyInUse;
      case 'weak-password':
        return l10n.errorWeakPassword;
      case 'invalid-email':
        return l10n.errorInvalidEmail;
      case 'operation-not-allowed':
        return l10n.errorOperationNotAllowed;
      case 'network-request-failed':
        return l10n.errorNetworkRequestFailed;
      default:
        return l10n.errorSignUpFailed;
    }
  }

  /// Password reset hataları için özel lokalize mesaj
  static String getLocalizedPasswordResetMessage(
    BuildContext context,
    FirebaseAuthException exception,
  ) {
    final l10n = AppLocalizations.of(context)!;

    switch (exception.code) {
      case 'user-not-found':
        return l10n.errorUserNotFound;
      case 'invalid-email':
        return l10n.errorInvalidEmail;
      case 'network-request-failed':
        return l10n.errorNetworkRequestFailed;
      default:
        return l10n.errorPasswordResetFailed;
    }
  }

  /// Password change hataları için özel lokalize mesaj
  static String getLocalizedPasswordChangeMessage(
    BuildContext context,
    FirebaseAuthException exception,
  ) {
    final l10n = AppLocalizations.of(context)!;

    switch (exception.code) {
      case 'weak-password':
        return l10n.errorWeakPassword;
      case 'requires-recent-login':
        return l10n.errorRequiresRecentLogin;
      case 'wrong-password':
        return l10n.errorWrongPassword;
      case 'network-request-failed':
        return l10n.errorNetworkRequestFailed;
      default:
        return l10n.errorPasswordResetFailed;
    }
  }
}


