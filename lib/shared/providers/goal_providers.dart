import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../features/goals/data/firestore_goal_repository.dart';
import '../models/check_in.dart';
import '../models/goal.dart';
import '../models/note.dart';
import '../services/export_service.dart';
import '../services/goal_repository.dart';

/// FirebaseFirestore provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// GoalRepository provider - Firestore kullanıyor
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreGoalRepository(firestore: firestore);
});

/// Current user ID provider
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.currentUser?.uid;
});

/// Goals stream provider - authenticated user için
final goalsStreamProvider = StreamProvider<List<Goal>>((ref) {
  final repo = ref.watch(goalRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    // Kullanıcı giriş yapmamışsa boş liste döndür
    return Stream.value([]);
  }

  return repo.watchGoals(userId);
});

/// Goal detail provider
final goalDetailProvider =
    FutureProvider.family<Goal?, String>((ref, goalId) async {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.fetchGoalById(goalId);
});

/// Check-ins stream provider for a specific goal
final checkInsStreamProvider =
    StreamProvider.family<List<CheckIn>, String>((ref, goalId) {
  final repo = ref.watch(goalRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    // Kullanıcı giriş yapmamışsa boş liste döndür
    return Stream.value([]);
  }
  
  return repo.watchCheckIns(goalId, userId);
});

/// Export service provider
final exportServiceProvider = Provider<ExportService>((ref) {
  final repo = ref.watch(goalRepositoryProvider);
  return ExportService(
    goalRepository: repo,
  );
});

/// Notes stream provider for a specific goal
final notesStreamProvider =
    StreamProvider.family<List<Note>, String>((ref, goalId) {
  final repo = ref.watch(goalRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return Stream.value([]);
  }
  
  return repo.watchNotes(goalId, userId);
});


