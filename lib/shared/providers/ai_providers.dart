import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/check_in.dart';
import '../services/ai_service.dart';
import 'goal_providers.dart';

/// AI Service provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

/// Optimized goal provider (family) - for goal optimization
final optimizedGoalProvider =
    FutureProvider.family<OptimizeGoalResponse?, OptimizeGoalParams>(
        (ref, params) async {
  final aiService = ref.watch(aiServiceProvider);

  try {
    debugPrint('AI Provider: Starting optimization...');
    debugPrint('  goalTitle: ${params.goalTitle}');
    debugPrint('  category: ${params.category}');

    final result = await aiService.optimizeGoal(
      goalTitle: params.goalTitle,
      category: params.category,
      motivation: params.motivation,
    );

    debugPrint('AI Provider: Optimization completed successfully');
    debugPrint('  optimizedTitle: ${result.optimizedTitle}');
    debugPrint('  subGoals count: ${result.subGoals.length}');

    return result;
  } catch (e, stackTrace) {
    // Log the error for debugging
    debugPrint('AI Provider Error: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
});

/// AI Suggestions provider - generates personalized recommendations
final aiSuggestionsProvider = FutureProvider<String?>((ref) async {
  final aiService = ref.watch(aiServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  final goalsAsync = ref.watch(goalsStreamProvider);

  if (userId == null) {
    return null;
  }

  return goalsAsync.when(
    data: (goals) async {
      // Fetch all check-ins for all goals
      final allCheckIns = <CheckIn>[];
      for (final goal in goals) {
        final checkInsAsync = ref.read(checkInsStreamProvider(goal.id));
        checkInsAsync.when(
          data: (checkIns) {
            allCheckIns.addAll(checkIns);
          },
          loading: () => null,
          error: (_, __) => null,
        );
      }

      try {
        final suggestions = await aiService.generateSuggestions(
          userId: userId,
          goals: goals,
          checkIns: allCheckIns,
        );
        return suggestions;
      } catch (e) {
        throw Exception('Failed to generate suggestions: ${e.toString()}');
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Yearly report provider (family) - generates comprehensive yearly analysis
final yearlyReportProvider =
    FutureProvider.family<String?, YearlyReportParams>(
        (ref, params) async {
  final aiService = ref.watch(aiServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  final goalsAsync = ref.watch(goalsStreamProvider);

  if (userId == null) {
    return null;
  }

  return goalsAsync.when(
    data: (goals) async {
      // Filter goals by year
      final yearGoals = goals.where((g) {
        return g.createdAt.year == params.year ||
            (g.targetDate != null && g.targetDate!.year == params.year);
      }).toList();

      // Fetch all check-ins for year goals
      final allCheckIns = <CheckIn>[];
      for (final goal in yearGoals) {
        final checkInsAsync = ref.read(checkInsStreamProvider(goal.id));
        checkInsAsync.when(
          data: (checkIns) {
            // Filter check-ins by year
            allCheckIns.addAll(
              checkIns.where((ci) => ci.createdAt.year == params.year),
            );
          },
          loading: () => null,
          error: (_, __) => null,
        );
      }

      try {
        final report = await aiService.generateYearlyReport(
          userId: userId,
          year: params.year,
          goals: yearGoals,
          checkIns: allCheckIns,
        );
        return report;
      } catch (e) {
        throw Exception(
            'Failed to generate yearly report: ${e.toString()}');
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Parameters for goal optimization
class OptimizeGoalParams {
  final String goalTitle;
  final String category;
  final String? motivation;

  OptimizeGoalParams({
    required this.goalTitle,
    required this.category,
    this.motivation,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OptimizeGoalParams &&
        other.goalTitle == goalTitle &&
        other.category == category &&
        other.motivation == motivation;
  }

  @override
  int get hashCode => Object.hash(goalTitle, category, motivation);
}

/// Parameters for yearly report generation
class YearlyReportParams {
  final int year;

  YearlyReportParams({required this.year});
}
