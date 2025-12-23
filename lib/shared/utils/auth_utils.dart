import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:year_flow/core/utils/extensions.dart';
import 'package:year_flow/features/auth/providers/auth_providers.dart';

/// Resolves Firebase authentication errors to localized user-friendly messages
///
/// This function handles:
/// - Google auth specific codes ([AuthNotifier.googleAuthFailedCode], [AuthNotifier.googleAuthCancelledCode])
/// - Firebase Auth error codes with localization via [AuthErrorHandler]
/// - Fallback to original message or generic error
///
/// Parameters:
/// - [context]: BuildContext for accessing localization
/// - [errorMessage]: The raw error message from auth result
/// - [errorCode]: Optional Firebase Auth error code
///
/// Returns localized error message string
String resolveAuthError(
    BuildContext context, String? errorMessage, String? errorCode) {
  final l10n = context.l10n;

  // Google auth specific codes
  if (errorMessage == AuthNotifier.googleAuthFailedCode) {
    return l10n.googleAuthFailed;
  }
  if (errorMessage == AuthNotifier.googleAuthCancelledCode) {
    return l10n.googleAuthCancelled;
  }

  // Firebase Auth error code - try to localize
  if (errorCode != null) {
    try {
      final exception =
          FirebaseAuthException(code: errorCode, message: errorMessage);
      return AuthErrorHandler.getLocalizedSignInMessage(
          context, exception);
    } catch (_) {
      // If error code can't be parsed, return raw message
      return errorMessage ?? l10n.errorUnexpectedAuth;
    }
  }

  // Fallback: return raw message or generic error
  return errorMessage ?? l10n.errorUnexpectedAuth;
}

/// Authentication error handler
///
/// Provides localized error messages for Firebase Auth exceptions
class AuthErrorHandler {
  /// Get localized sign-in error message from Firebase Auth exception
  static String getLocalizedSignInMessage(
      BuildContext context, FirebaseAuthException exception) {
    return _getLocalizedAuthMessage(context, exception, isSignIn: true);
  }

  /// Get localized sign-up error message from Firebase Auth exception
  static String getLocalizedSignUpMessage(
      BuildContext context, FirebaseAuthException exception) {
    return _getLocalizedAuthMessage(context, exception, isSignIn: false);
  }

  /// Internal method to get localized auth message
  static String _getLocalizedAuthMessage(
      BuildContext context, FirebaseAuthException exception,
      {required bool isSignIn}) {
    final l10n = context.l10n;

    switch (exception.code) {
      case 'user-not-found':
        return l10n.errorUserNotFound;
      case 'wrong-password':
        return l10n.errorWrongPassword;
      case 'invalid-credential':
        return isSignIn
            ? l10n.errorInvalidCredential
            : l10n.errorWrongPassword;
      case 'invalid-email':
        return l10n.errorInvalidEmail;
      case 'user-disabled':
        return l10n.errorUserDisabled;
      case 'too-many-requests':
        return l10n.errorTooManyRequests;
      case 'operation-not-allowed':
        return l10n.errorOperationNotAllowed;
      case 'network-request-failed':
        return l10n.errorNetworkRequestFailed;
      case 'requires-recent-login':
        return l10n.errorRequiresRecentLogin;
      case 'email-already-in-use':
        return l10n.errorEmailAlreadyInUse;
      case 'weak-password':
        return l10n.errorWeakPassword;
      case 'account-exists-with-different-credential':
        return l10n.errorEmailAlreadyInUse;
      default:
        return exception.message ?? l10n.errorUnexpectedAuth;
    }
  }
}
