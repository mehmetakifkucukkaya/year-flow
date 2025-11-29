import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth state provider (mock - sonra Firebase ile değiştirilecek)
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

/// Auth state
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage,
    );
  }
}

/// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Email/Password ile giriş
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Mock login - sonra Firebase ile değiştirilecek
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.isNotEmpty) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'E-posta ve şifre gereklidir',
      );
    }
  }

  /// Email/Password ile kayıt
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Mock register - sonra Firebase ile değiştirilecek
    await Future.delayed(const Duration(seconds: 1));

    if (password != confirmPassword) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Şifreler eşleşmiyor',
      );
      return;
    }

    if (email.isNotEmpty && password.length >= 6) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Geçerli bir e-posta ve en az 6 karakter şifre gereklidir',
      );
    }
  }

  /// Şifre sıfırlama
  Future<void> resetPassword({required String email}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Mock password reset - sonra Firebase ile değiştirilecek
    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'E-posta adresi gereklidir',
      );
    }
  }

  /// Çıkış
  void signOut() {
    state = const AuthState();
  }
}

