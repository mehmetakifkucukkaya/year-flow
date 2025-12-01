import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
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
final reportsStatsProvider = FutureProvider<ReportsStats>((ref) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) {
    return const ReportsStats(
      totalGoals: 0,
      completedGoals: 0,
      totalCheckIns: 0,
      averageProgress: 0,
      categoryProgress: {},
    );
  }

  final repository = ref.read(goalRepositoryProvider);
  final goals = await repository.fetchGoals(userId);

  // Calculate stats
  final totalGoals = goals.length;
  final completedGoals = goals.where((g) => g.progress >= 100).length;
  
  // Calculate total check-ins
  int totalCheckIns = 0;
  final categoryProgressMap = <GoalCategory, List<int>>{};
  
              for (final goal in goals) {
                // Get check-ins for this goal
                final checkIns = await repository.watchCheckIns(goal.id, userId).first;
    totalCheckIns += checkIns.length;
    
    // Track progress by category
    if (!categoryProgressMap.containsKey(goal.category)) {
      categoryProgressMap[goal.category] = [];
    }
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

