import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Şifre değiştir (mevcut şifre ile)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Hesabı sil (Firebase Auth + Firestore cleanup)
  Future<void> deleteAccount();
}

/// FirebaseAuth tabanlı repository implementasyonu
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _firestore = firestore;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  /// Users collection'ına kullanıcı kaydet/güncelle
  Future<void> _saveUserToFirestore(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // merge: true ile mevcut verileri koru
    } catch (e) {
      // Firestore hatası auth işlemini engellememeli
      print('Error saving user to Firestore: $e');
    }
  }

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
    final appUser = AppUser.fromFirebaseUser(user, isNewUser: true);
    // Users collection'ına kaydet
    await _saveUserToFirestore(appUser);
    return appUser;
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

      final appUser = AppUser.fromFirebaseUser(user, isNewUser: isNewUser);
      
      // Yeni kullanıcı ise veya mevcut kullanıcı bilgileri güncellenmişse Firestore'a kaydet
      if (isNewUser || user.displayName != null || user.photoURL != null) {
        await _saveUserToFirestore(appUser);
      }

      return appUser;
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

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı giriş yapmamış');
    }

    if (user.email == null) {
      throw Exception('E-posta adresi bulunamadı');
    }

    // Email/Password ile giriş yapmış kullanıcılar için şifre değiştirme
    // Google ile giriş yapmış kullanıcılar için şifre yok, bu durumda hata ver
    if (user.providerData.isEmpty ||
        !user.providerData.any((info) => info.providerId == 'password')) {
      throw Exception('Google ile giriş yapmış kullanıcılar şifre değiştiremez');
    }

    // Mevcut şifreyi doğrula
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      throw Exception('Mevcut şifre yanlış');
    }

    // Yeni şifreyi güncelle
    await user.updatePassword(newPassword);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı giriş yapmamış');
    }

    final userId = user.uid;

    // Firestore'dan tüm kullanıcı verilerini sil
    try {
      final batch = _firestore.batch();

      // Goals'ları sil
      final goalsSnapshot = await _firestore
          .collection('goals')
          .where('userId', isEqualTo: userId)
          .get();
      for (final goalDoc in goalsSnapshot.docs) {
        batch.delete(goalDoc.reference);
      }

      // Check-ins'leri sil (ayrı collection olarak)
      final checkInsSnapshot = await _firestore
          .collection('checkIns')
          .where('userId', isEqualTo: userId)
          .get();
      for (final checkInDoc in checkInsSnapshot.docs) {
        batch.delete(checkInDoc.reference);
      }

      // Yearly reports'ları sil
      final reportsSnapshot = await _firestore
          .collection('yearlyReports')
          .where('userId', isEqualTo: userId)
          .get();
      for (final reportDoc in reportsSnapshot.docs) {
        batch.delete(reportDoc.reference);
      }

      // User document'ını sil
      final userDocRef = _firestore.collection('users').doc(userId);
      batch.delete(userDocRef);

      await batch.commit();
    } catch (e) {
      print('Error deleting user data from Firestore: $e');
      // Firestore hatası olsa bile auth hesabını silmeye devam et
    }

    // Firebase Auth hesabını sil
    await user.delete();
  }
}


