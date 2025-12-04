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
    required String name,
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

  /// Profil bilgilerini güncelle (displayName ve/veya email)
  Future<AppUser> updateProfile({
    String? displayName,
    String? email,
  });
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
    final appUser = AppUser.fromFirebaseUser(user, isNewUser: false);
    // Users collection'ına kaydet/güncelle (bilgiler güncellenmiş olabilir)
    await _saveUserToFirestore(appUser);
    return appUser;
  }

  @override
  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) return null;
    
    // Kullanıcı adını güncelle
    await user.updateProfile(displayName: name);
    await user.reload();
    final updatedUser = _firebaseAuth.currentUser;
    
    // Email ile kayıt her zaman yeni kullanıcıdır
    final appUser = AppUser.fromFirebaseUser(updatedUser ?? user, isNewUser: true);
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

    // Firestore'dan tüm kullanıcı verilerini sil (yeni yapı: users/{userId}/subcollections)
    // ÖNEMLİ: Firestore silme işlemi başarısız olursa auth hesabını silme
    try {
      final userDocRef = _firestore.collection('users').doc(userId);

      // Tüm subcollection'ları sil
      // Batch işlemi 500 doküman limitine sahip, bu yüzden her subcollection için ayrı batch kullanıyoruz
      
      // Goals'ları sil (users/{userId}/goals)
      final goalsSnapshot = await userDocRef.collection('goals').get();
      if (goalsSnapshot.docs.isNotEmpty) {
        final goalsBatch = _firestore.batch();
        for (final goalDoc in goalsSnapshot.docs) {
          goalsBatch.delete(goalDoc.reference);
        }
        await goalsBatch.commit();
      }

      // Check-ins'leri sil (users/{userId}/checkIns)
      final checkInsSnapshot = await userDocRef.collection('checkIns').get();
      if (checkInsSnapshot.docs.isNotEmpty) {
        final checkInsBatch = _firestore.batch();
        for (final checkInDoc in checkInsSnapshot.docs) {
          checkInsBatch.delete(checkInDoc.reference);
        }
        await checkInsBatch.commit();
      }

      // Yearly reports'ları sil (users/{userId}/yearlyReports)
      final reportsSnapshot = await userDocRef.collection('yearlyReports').get();
      if (reportsSnapshot.docs.isNotEmpty) {
        final reportsBatch = _firestore.batch();
        for (final reportDoc in reportsSnapshot.docs) {
          reportsBatch.delete(reportDoc.reference);
        }
        await reportsBatch.commit();
      }

      // Notes'ları sil (users/{userId}/notes)
      final notesSnapshot = await userDocRef.collection('notes').get();
      if (notesSnapshot.docs.isNotEmpty) {
        final notesBatch = _firestore.batch();
        for (final noteDoc in notesSnapshot.docs) {
          notesBatch.delete(noteDoc.reference);
        }
        await notesBatch.commit();
      }

      // User document'ını sil
      await userDocRef.delete();
      
      print('User data successfully deleted from Firestore');
    } catch (e, stackTrace) {
      print('Error deleting user data from Firestore: $e');
      print('Stack trace: $stackTrace');
      // Firestore silme başarısız olursa auth hesabını silme - veri tutarlılığı için
      throw Exception('Firestore verileri silinirken hata oluştu. Hesap silinemedi: $e');
    }

    // Firebase Auth hesabını sil (sadece Firestore silme başarılı olduysa)
    try {
      await user.delete();
      print('User account successfully deleted from Firebase Auth');
    } catch (e) {
      print('Error deleting user from Firebase Auth: $e');
      // Auth silme başarısız olursa hata fırlat
      throw Exception('Firebase Auth hesabı silinirken hata oluştu: $e');
    }
  }

  @override
  Future<AppUser> updateProfile({
    String? displayName,
    String? email,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı giriş yapmamış');
    }

    bool hasChanges = false;

    // İsim güncelle
    if (displayName != null &&
        displayName.trim().isNotEmpty &&
        displayName.trim() != user.displayName) {
      await user.updateProfile(displayName: displayName.trim());
      hasChanges = true;
    }

    // E-posta güncelle
    if (email != null &&
        email.trim().isNotEmpty &&
        email.trim() != user.email) {
      await user.updateEmail(email.trim());
      hasChanges = true;
    }

    if (hasChanges) {
      await user.reload();
    }

    final updatedUser = _firebaseAuth.currentUser ?? user;
    final appUser = AppUser.fromFirebaseUser(updatedUser);

    // Firestore'daki user dokümanını da güncelle
    await _saveUserToFirestore(appUser);

    return appUser;
  }
}


