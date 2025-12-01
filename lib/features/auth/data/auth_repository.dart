import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Domain user model (şimdilik sadece temel alanlar)
class AppUser {
  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isNewUser = false,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isNewUser; // Google ile giriş/kayıt sonrası yeni kullanıcı mı?

  factory AppUser.fromFirebaseUser(User user, {bool isNewUser = false}) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isNewUser: isNewUser,
    );
  }
}

/// Auth repository arayüzü
abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({required String email});

  Future<AppUser?> signInWithGoogle();

  Future<void> signOut();
}

/// FirebaseAuth tabanlı repository implementasyonu
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<AppUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return AppUser.fromFirebaseUser(user);
    });
  }

  @override
  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) return null;
    // Email ile giriş her zaman mevcut kullanıcıdır (yeni kullanıcı değil)
    return AppUser.fromFirebaseUser(user, isNewUser: false);
  }

  @override
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) return null;
    // Email ile kayıt her zaman yeni kullanıcıdır
    return AppUser.fromFirebaseUser(user, isNewUser: true);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      // Her zaman hesap seçim ekranını göster (kullanıcı her seferinde hesap seçebilsin)
      // signOut yapmadan da signIn() çağrısı hesap seçim ekranını gösterir
      // ama emin olmak için önce signOut yapıyoruz
      await _googleSignIn.signOut();

      // Google sign-in sadece mobil için; web desteği gerekirse ayrıca ele alınmalı.
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Kullanıcı iptal etti
        return null;
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Google authentication failed: idToken is null');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      // additionalUserInfo.isNewUser ile yeni kullanıcı mı kontrol et
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      return AppUser.fromFirebaseUser(user, isNewUser: isNewUser);
    } catch (e) {
      // Hata durumunda Google oturumunu temizle
      await _googleSignIn.signOut();
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}


