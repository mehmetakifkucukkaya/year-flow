import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/auth_repository.dart';

/// FirebaseAuth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// GoogleSignIn instance provider
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  // Android için serverClientId (Web client ID) gerekli - idToken almak için.
  // Güvenlik için bu değer derleme zamanı ortam değişkeninden okunur.
  // Tanımlama örneği:
  // flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com
  const serverClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID', defaultValue: '');
  return GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web client ID (client_type: 3) - ortam değişkeninden alınır
    serverClientId: serverClientId.isEmpty ? null : serverClientId,
  );
});

/// FirebaseFirestore provider (auth için)
final firestoreForAuthProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final googleSignIn = ref.watch(googleSignInProvider);
  final firestore = ref.watch(firestoreForAuthProvider);
  return FirebaseAuthRepository(
    firebaseAuth: firebaseAuth,
    googleSignIn: googleSignIn,
    firestore: firestore,
  );
});

/// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    final repository = ref.watch(authRepositoryProvider);
    return AuthNotifier(authRepository: repository);
  },
);

/// Auth state
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isPasswordChanging = false,
    this.isProfileUpdating = false,
    this.isEmailLoading = false,
    this.isGoogleLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
    this.errorCode,
    this.currentUser,
  });

  final bool isLoading; // Genel loading (geriye dönük uyumluluk için)
  final bool isPasswordChanging; // Şifre değiştirme için özel loading
  final bool isProfileUpdating; // Profil güncelleme için özel loading
  final bool isEmailLoading; // Email/Password giriş için
  final bool isGoogleLoading; // Google giriş için
  final bool isAuthenticated;
  final String? errorMessage; // Ham hata mesajı (geriye dönük uyumluluk için)
  final String? errorCode; // Firebase Auth hata kodu (lokalizasyon için)
  final AppUser? currentUser; // Mevcut kullanıcı bilgisi (isNewUser kontrolü için)

  AuthState copyWith({
    bool? isLoading,
    bool? isPasswordChanging,
    bool? isProfileUpdating,
    bool? isEmailLoading,
    bool? isGoogleLoading,
    bool? isAuthenticated,
    String? errorMessage,
    String? errorCode,
    AppUser? currentUser,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isPasswordChanging: isPasswordChanging ?? this.isPasswordChanging,
      isProfileUpdating: isProfileUpdating ?? this.isProfileUpdating,
      isEmailLoading: isEmailLoading ?? this.isEmailLoading,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage,
      errorCode: errorCode,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

/// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  static const String googleAuthFailedCode = 'google_auth_failed';
  static const String googleAuthCancelledCode = 'google_auth_cancelled';

  AuthNotifier({required this.authRepository}) : super(const AuthState()) {
    // İlk kullanıcı durumunu kontrol et
    _checkInitialAuthState();
    
    // Auth state değişikliklerini dinle
    _authSubscription = authRepository.authStateChanges().listen((user) {
      // Şifre değişimi sırasında tüm auth event'lerini yoksay
      if (_isChangePasswordInProgress) {
        return;
      }
      
      // Şifre değişimi veya ardıl null event sırasında logout tetikleme
      if ((state.isPasswordChanging || _suppressAuthNull) && user == null) {
        return;
      }

      // Kullanıcı geri geldiğinde artık null eventleri bastırma
      if (user != null && _suppressAuthNull) {
        _suppressAuthNull = false;
      }

      state = state.copyWith(
        isAuthenticated: user != null,
        currentUser: user,
      );
    });
  }

  final AuthRepository authRepository;
  StreamSubscription<AppUser?>? _authSubscription;
  bool _suppressAuthNull = false; // Şifre değişimi sonrası kısa süreli null'u yoksay
  bool _isChangePasswordInProgress = false; // Şifre değişimi sırasında auth listener'ı yoksay
  
  /// Şifre değiştirme işlemi başlatıldığında çağır (auth listener'ı pause eder)
  void startPasswordChange() {
    _isChangePasswordInProgress = true;
  }
  
  /// Şifre değiştirme işlemi bittiğinde çağır (auth listener'ı resume eder)
  void endPasswordChange() {
    _isChangePasswordInProgress = false;
  }

  /// İlk auth state'i kontrol et
  Future<void> _checkInitialAuthState() async {
    // FirebaseAuth'tan direkt kontrol et
    final firebaseAuth = FirebaseAuth.instance;
    final currentUser = firebaseAuth.currentUser;
    if (currentUser != null) {
      state = state.copyWith(
        isAuthenticated: true,
        currentUser: AppUser.fromFirebaseUser(currentUser),
      );
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Email/Password ile giriş
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isEmailLoading: true,
      isLoading: true,
      errorMessage: null,
      errorCode: null,
    );
    try {
      final user = await authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      if (user != null) {
        state = state.copyWith(
          isEmailLoading: false,
          isLoading: false,
          isAuthenticated: true,
          errorMessage: null,
          errorCode: null,
          currentUser: user,
        );
      } else {
        state = state.copyWith(
          isEmailLoading: false,
          isLoading: false,
          isAuthenticated: false,
          errorMessage: 'Giriş yapılamadı. Lütfen bilgilerini kontrol et.',
          errorCode: null,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Hata kodunu state'e kaydet (UI tarafında lokalize edilecek)
      state = state.copyWith(
        isEmailLoading: false,
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.message, // Ham mesaj (geriye dönük uyumluluk için)
        errorCode: e.code, // Firebase Auth hata kodu
      );
    } catch (e) {
      state = state.copyWith(
        isEmailLoading: false,
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'Giriş sırasında beklenmeyen bir hata oluştu: ${e.toString()}',
      );
    }
  }

  /// Email/Password ile kayıt
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(
      isEmailLoading: true,
      isLoading: true,
      errorMessage: null,
      errorCode: null,
    );

    try {
      final user = await authRepository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      if (user != null) {
        state = state.copyWith(
          isEmailLoading: false,
          isLoading: false,
          isAuthenticated: true,
          errorMessage: null,
          currentUser: user,
        );
      } else {
        state = state.copyWith(
          isEmailLoading: false,
          isLoading: false,
          isAuthenticated: false,
          errorMessage:
              'Kayıt işlemi tamamlanamadı. Lütfen bilgilerini kontrol et.',
        );
      }
    } on FirebaseAuthException catch (e) {
      // Hata kodunu state'e kaydet (UI tarafında lokalize edilecek)
      state = state.copyWith(
        isEmailLoading: false,
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.message, // Ham mesaj (geriye dönük uyumluluk için)
        errorCode: e.code, // Firebase Auth hata kodu
      );
    } catch (_) {
      state = state.copyWith(
        isEmailLoading: false,
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'Kayıt sırasında beklenmeyen bir hata oluştu.',
      );
    }
  }

  /// Şifre sıfırlama
  Future<void> resetPassword({required String email}) async {
    state = state.copyWith(
      isEmailLoading: true,
      isLoading: true,
      errorMessage: null,
      errorCode: null,
    );
    try {
      await authRepository.sendPasswordResetEmail(email: email);
      state = state.copyWith(
        isEmailLoading: false,
        isLoading: false,
        errorMessage: null,
        errorCode: null,
      );
    } on FirebaseAuthException catch (e) {
      // Hata kodunu state'e kaydet (UI tarafında lokalize edilecek)
      state = state.copyWith(
        isEmailLoading: false,
        isLoading: false,
        errorMessage: e.message, // Ham mesaj (geriye dönük uyumluluk için)
        errorCode: e.code, // Firebase Auth hata kodu
      );
    } catch (_) {
      state = state.copyWith(
        isEmailLoading: false,
        isLoading: false,
        errorMessage:
            'Şifre sıfırlama sırasında beklenmeyen bir hata oluştu.',
      );
    }
  }

  /// Google ile giriş
  Future<void> signInWithGoogle() async {
    state = state.copyWith(
      isGoogleLoading: true,
      isLoading: true,
      errorMessage: null,
      errorCode: null,
      currentUser: null,
    );
    try {
      final user = await authRepository.signInWithGoogle();
      if (user != null) {
        state = state.copyWith(
          isGoogleLoading: false,
          isLoading: false,
          isAuthenticated: true,
          errorMessage: null,
          errorCode: null,
          currentUser: user, // Kullanıcı bilgisini state'e kaydet (isNewUser kontrolü için)
        );
      } else {
        state = state.copyWith(
          isGoogleLoading: false,
          isLoading: false,
          isAuthenticated: false,
          errorMessage: googleAuthCancelledCode,
          currentUser: null,
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Google sign-in failed (FirebaseAuthException): code=${e.code}, message=${e.message}',
      );
      
      state = state.copyWith(
        isGoogleLoading: false,
        isLoading: false,
        isAuthenticated: false,
        errorMessage: googleAuthFailedCode,
        currentUser: null,
      );
    } catch (e) {
      debugPrint('Google sign-in failed (unexpected): $e');
      state = state.copyWith(
        isGoogleLoading: false,
        isLoading: false,
        isAuthenticated: false,
        errorMessage: googleAuthFailedCode,
        currentUser: null,
      );
    }
  }

  /// Çıkış
  Future<void> signOut() async {
    _suppressAuthNull = false; // Auth null event'lerini artık yoksayma
    _isChangePasswordInProgress = false; // Şifre değiştirme flag'ini sıfırla
    await authRepository.signOut();
    state = const AuthState(
      isAuthenticated: false,
      isPasswordChanging: false,
      currentUser: null,
    );
  }

  /// Şifre değiştir
  /// NOT: Başarılı olduğunda isPasswordChanging TRUE kalır (logout yapılana kadar)
  /// Bu sayede router redirect tetiklenmez
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(
      isPasswordChanging: true,
      errorMessage: null,
      errorCode: null,
    );
    _suppressAuthNull = true;
    try {
      final updatedUser = await authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      // BAŞARILI: isPasswordChanging TRUE KALSIN (logout yapılana kadar)
      // Bu sayede router redirect tetiklenmez ve snackbar gösterilebilir
      state = state.copyWith(
        isPasswordChanging: true, // TRUE KALMALI!
        isAuthenticated: true,
        currentUser: updatedUser,
        errorMessage: null,
        errorCode: null,
      );
      // _suppressAuthNull TRUE KALSIN (logout yapılana kadar)
    } on FirebaseAuthException catch (e) {
      // HATA: isPasswordChanging FALSE olsun
      state = state.copyWith(
        isPasswordChanging: false,
        errorMessage: e.message,
        errorCode: e.code,
      );
      _suppressAuthNull = false;
      rethrow;
    } catch (e) {
      // HATA: isPasswordChanging FALSE olsun
      state = state.copyWith(
        isPasswordChanging: false,
        errorMessage: e.toString(),
        errorCode: null,
      );
      _suppressAuthNull = false;
      rethrow;
    }
  }

  /// Hesabı sil
  Future<void> deleteAccount() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      errorCode: null,
    );
    try {
      await authRepository.deleteAccount();
      state = const AuthState(
        isAuthenticated: false,
        currentUser: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Profil bilgilerini güncelle (isim ve/veya e-posta)
  /// NOT: State değişikliği minimize edildi - router rebuild'i önlemek için
  /// Sadece sonuçta currentUser güncellenir, loading state kullanılmaz
  Future<void> updateProfile({
    String? displayName,
    String? email,
  }) async {
    try {
      final updatedUser = await authRepository.updateProfile(
        displayName: displayName,
        email: email,
      );

      // Sadece currentUser'ı güncelle - router rebuild tetiklenmez
      state = state.copyWith(
        currentUser: updatedUser,
      );
    } on FirebaseAuthException {
      // Hata durumunda state'i değiştirme, sadece exception fırlat
      // UI tarafında catch ile yakalanacak
      rethrow;
    }
  }
}

