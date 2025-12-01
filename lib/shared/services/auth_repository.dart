import '../models/user.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();

  Future<User?> getCurrentUser();

  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  Future<User> registerWithEmail({
    required String email,
    required String password,
  });

  Future<void> resetPassword({required String email});

  Future<void> signOut();
}


