import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/auth_repository.dart';

/// FirebaseAuth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// GoogleSignIn instance provider
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  // Android için serverClientId (Web client ID) gerekli - idToken almak için
  // google-services.json'dan client_type: 3 olan Web client ID kullanılmalı
  // iOS için otomatik olarak GoogleService-Info.plist'ten alınır
  return GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web client ID (client_type: 3) - google-services.json'dan alındı
    serverClientId:
        '111770215758-gjlg8cjkd0fictaj3ri9upc9tvghp0cj.apps.googleusercontent.com',
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
    this.isEmailLoading = false,
    this.isGoogleLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
    this.currentUser,
  });

  final bool isLoading; // Genel loading (geriye dönük uyumluluk için)
  final bool isEmailLoading; // Email/Password giriş için
  final bool isGoogleLoading; // Google giriş için
  final bool isAuthenticated;
  final String? errorMessage;
  final AppUser? currentUser; // Mevcut kullanıcı bilgisi (isNewUser kontrolü için)

  AuthState copyWith({
    bool? isLoading,
    bool? isEmailLoading,
    bool? isGoogleLoading,
    bool? isAuthenticated,
    String? errorMessage,
    AppUser? currentUser,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isEmailLoading: isEmailLoading ?? this.isEmailLoading,
      isGoogleLoading: isGoogleLoading ?? this.isGoogleLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage,
      currentUser: currentUser,
    );
  }
}

/// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({required this.authRepository}) : super(const AuthState()) {
    // İlk kullanıcı durumunu kontrol et
    _checkInitialAuthState();
    
    // Auth state değişikliklerini dinle
    _authSubscription = authRepository.authStateChanges().listen((user) {
      state = state.copyWith(
        isAuthenticated: user != null,
        currentUser: user,
      );
    });
  }

  final AuthRepository authRepository;
  StreamSubscription<AppUser?>? _authSubscription;

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
          currentUser: user,
        );
      } else {
        state = state.copyWith(
          isEmailLoading: false,
          isLoading: false,
          isAuthenticated: false,
          errorMessage: 'Giriş yapılamadı. Lütfen bilgilerini kontrol et.',
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Giriş sırasında bir hata oluştu.';
      
      // Firebase hata kodlarına göre Türkçe mesajlar
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
          break;
        case 'wrong-password':
          errorMessage = 'Şifre yanlış. Lütfen tekrar deneyin.';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz e-posta adresi.';
          break;
        case 'invalid-credential':
          // Şifre çok kısa olabilir, önce form validasyonu kontrol edilmeli
          // Ama eğer buraya geldiyse, gerçekten yanlış bilgi girilmiş demektir
          errorMessage = 'E-posta veya şifre hatalı. Lütfen bilgilerinizi kontrol edin.';
          break;
        case 'user-disabled':
          errorMessage = 'Bu hesap devre dışı bırakılmış.';
          break;
        case 'too-many-requests':
          errorMessage = 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Bu giriş yöntemi şu anda kullanılamıyor.';
          break;
        case 'network-request-failed':
          errorMessage = 'İnternet bağlantınızı kontrol edin.';
          break;
        case 'weak-password':
          errorMessage = 'Şifre çok zayıf. Daha güçlü bir şifre seçin.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Bu e-posta adresi zaten kullanılıyor.';
          break;
        default:
          // Eğer bilinmeyen bir hata kodu varsa, mesajı Türkçe'ye çevirmeye çalış
          final englishMessage = e.message ?? '';
          if (englishMessage.contains('incorrect') || englishMessage.contains('wrong')) {
            errorMessage = 'E-posta veya şifre hatalı. Lütfen bilgilerinizi kontrol edin.';
          } else if (englishMessage.contains('expired')) {
            errorMessage = 'Oturum süresi dolmuş. Lütfen tekrar giriş yapın.';
          } else if (englishMessage.contains('malformed')) {
            errorMessage = 'Geçersiz giriş bilgileri. Lütfen bilgilerinizi kontrol edin.';
          } else {
            errorMessage = 'Giriş sırasında bir hata oluştu. Lütfen tekrar deneyin.';
          }
      }
      
      state = state.copyWith(
        isEmailLoading: false,
        isLoading: false,
        isAuthenticated: false,
        errorMessage: errorMessage,
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
      state = state.copyWith(
        isEmailLoading: false,
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.message ?? 'Kayıt sırasında bir hata oluştu.',
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
    );
    try {
      await authRepository.sendPasswordResetEmail(email: email);
      state = state.copyWith(
        isEmailLoading: false,
        isLoading: false,
        errorMessage: null,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isEmailLoading: false,
        isLoading: false,
        errorMessage: e.message ?? 'Şifre sıfırlama sırasında hata oluştu.',
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
          currentUser: user, // Kullanıcı bilgisini state'e kaydet (isNewUser kontrolü için)
        );
      } else {
        state = state.copyWith(
          isGoogleLoading: false,
          isLoading: false,
          isAuthenticated: false,
          errorMessage: 'Google ile giriş iptal edildi.',
          currentUser: null,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Google ile giriş sırasında hata oluştu.';
      
      // Daha anlamlı hata mesajları
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'Bu e-posta adresi farklı bir giriş yöntemiyle kayıtlı.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Google ile giriş bilgileri geçersiz. Lütfen tekrar deneyin.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Google ile giriş etkin değil. Lütfen Firebase Console\'dan etkinleştirin.';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      state = state.copyWith(
        isGoogleLoading: false,
        isLoading: false,
        isAuthenticated: false,
        errorMessage: errorMessage,
        currentUser: null,
      );
    } catch (e) {
      state = state.copyWith(
        isGoogleLoading: false,
        isLoading: false,
        isAuthenticated: false,
        errorMessage: 'Google ile giriş sırasında beklenmeyen bir hata oluştu: ${e.toString()}',
        currentUser: null,
      );
    }
  }

  /// Çıkış
  Future<void> signOut() async {
    await authRepository.signOut();
    state = const AuthState(
      isAuthenticated: false,
      currentUser: null,
    );
  }

  /// Şifre değiştir
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );
    try {
      await authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: null,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Şifre değiştirme sırasında hata oluştu.';
      if (e.code == 'weak-password') {
        errorMessage = 'Yeni şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
      } else if (e.code == 'requires-recent-login') {
        errorMessage = 'Güvenlik nedeniyle lütfen tekrar giriş yapın.';
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Hesabı sil
  Future<void> deleteAccount() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
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
}

