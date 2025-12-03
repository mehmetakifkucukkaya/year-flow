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
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return null;
  }
  
  // Sadece mevcut kullanıcının goals'ında ara
  final goals = await repo.fetchGoals(userId);
  try {
    return goals.firstWhere((goal) => goal.id == goalId);
  } catch (_) {
    return null;
  }
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

class WeeklyCheckInSummary {
  const WeeklyCheckInSummary({
    required this.checkInCount,
    required this.goalsWithProgress,
    required this.emptyDayStreak,
  });

  final int checkInCount;
  final int goalsWithProgress;
  final int emptyDayStreak;

  static const empty = WeeklyCheckInSummary(
    checkInCount: 0,
    goalsWithProgress: 0,
    emptyDayStreak: 0,
  );
}

/// Kullanıcının bu haftaki check-in özetini verir
final weeklyCheckInSummaryProvider =
    StreamProvider<WeeklyCheckInSummary>((ref) {
  final repo = ref.watch(goalRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return Stream.value(WeeklyCheckInSummary.empty);
  }

  return repo.watchAllCheckIns(userId).map((checkIns) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));

    final thisWeekCheckIns = checkIns.where((c) {
      final d = DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day);
      return !d.isBefore(startOfWeek) && !d.isAfter(today);
    }).toList();

    final checkInCount = thisWeekCheckIns.length;
    final goalsWithProgress =
        thisWeekCheckIns.map((c) => c.goalId).toSet().length;

    // Haftanın sonundan geriye doğru, üst üste check-in yapılmayan gün sayısı
    int emptyStreak = 0;
    for (int i = 0; i < 7; i++) {
      final day = today.subtract(Duration(days: i));
      if (day.isBefore(startOfWeek)) break;
      final hasCheckIn = thisWeekCheckIns.any((c) {
        final cd =
            DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day);
        return cd == day;
      });
      if (hasCheckIn) {
        break;
      } else {
        emptyStreak++;
      }
    }

    return WeeklyCheckInSummary(
      checkInCount: checkInCount,
      goalsWithProgress: goalsWithProgress,
      emptyDayStreak: emptyStreak,
    );
  });
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


