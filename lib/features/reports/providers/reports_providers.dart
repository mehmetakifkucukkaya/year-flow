import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/check_in.dart';
import '../../../shared/models/yearly_report.dart';
import '../../../shared/providers/goal_providers.dart';

/// Reports statistics model
class ReportsStats {
  const ReportsStats({
    required this.totalGoals,
    required this.completedGoals,
    required this.totalCheckIns,
    required this.averageProgress,
    required this.categoryProgress,
  });

  final int totalGoals;
  final int completedGoals;
  final int totalCheckIns;
  final double averageProgress;
  final Map<GoalCategory, double> categoryProgress;
}

/// Reports statistics provider
///
/// - `watchAllGoals` stream'i sayesinde hedeflerdeki her değişimde (ekleme,
///   güncelleme, tamamlama/arsivleme) yeniden hesaplanır.
/// - Check-in sayıları ve kategori ortalamaları da her emisyon için
///   güncellenir; böylece rapor sayfası açıldığında en güncel durumu gösterir.
final reportsStatsProvider = StreamProvider<ReportsStats>((ref) {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) {
    return Stream.value(
      const ReportsStats(
        totalGoals: 0,
        completedGoals: 0,
        totalCheckIns: 0,
        averageProgress: 0,
        categoryProgress: {},
      ),
    );
  }

  final repository = ref.read(goalRepositoryProvider);

  // Tüm hedefleri (aktif + tamamlanmış/arşivlenmiş) dinle
  return repository.watchAllGoals(userId).asyncMap((goals) async {
    // Calculate stats
    final totalGoals = goals.length;
    final completedGoals =
        goals.where((g) => g.isCompleted || g.progress >= 100).length;

    // Tüm check-in kayıtlarını tek sorguda al (N+1 sorgu problemini önlemek için)
    final allCheckIns = await repository.watchAllCheckIns(userId).first;

    // goalId -> checkIns eşlemesi
    final checkInsByGoal = <String, List<CheckIn>>{};
    for (final checkIn in allCheckIns) {
      checkInsByGoal.putIfAbsent(checkIn.goalId, () => []);
      checkInsByGoal[checkIn.goalId]!.add(checkIn);
    }

    // Calculate total check-ins & category progress (completed dahil)
    int totalCheckIns = 0;
    final categoryProgressMap = <GoalCategory, List<int>>{};

    for (final goal in goals) {
      final goalCheckIns = checkInsByGoal[goal.id] ?? const <CheckIn>[];
      totalCheckIns += goalCheckIns.length;

      categoryProgressMap.putIfAbsent(goal.category, () => []);
      categoryProgressMap[goal.category]!.add(goal.progress);
    }

    // Calculate average progress
    final averageProgress = goals.isEmpty
        ? 0.0
        : goals.map((g) => g.progress).reduce((a, b) => a + b) / goals.length;

    // Calculate category averages
    final categoryProgress = <GoalCategory, double>{};
    for (final entry in categoryProgressMap.entries) {
      final progresses = entry.value;
      categoryProgress[entry.key] = progresses.isEmpty
          ? 0.0
          : progresses.reduce((a, b) => a + b) / progresses.length;
    }

    return ReportsStats(
      totalGoals: totalGoals,
      completedGoals: completedGoals,
      totalCheckIns: totalCheckIns,
      averageProgress: averageProgress,
      categoryProgress: categoryProgress,
    );
  });
});

/// Reports history provider - Tüm geçmiş raporları getirir
final reportsHistoryProvider = StreamProvider<List<Report>>((ref) {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  final repository = ref.read(goalRepositoryProvider);
  return repository.watchAllReports(userId);
});

