import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/locale_provider.dart';
import '../models/check_in.dart';
import '../models/goal.dart';
import '../services/ai_service.dart';
import 'goal_providers.dart';

/// Fetch all check-ins for multiple goals in parallel
Future<List<CheckIn>> _fetchAllCheckIns(
  Ref ref,
  List<Goal> goals,
) async {
  final futures = goals.map((goal) async {
    final checkInsAsync = ref.read(checkInsStreamProvider(goal.id));
    return checkInsAsync.when(
      data: (checkIns) => checkIns,
      loading: () => <CheckIn>[],
      error: (_, __) => <CheckIn>[],
    );
  }).toList();

  final results = await Future.wait(futures);
  return results.expand((checkIns) => checkIns).toList();
}

/// AI Service provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

/// Optimized goal provider (family) - for goal optimization
/// Uses autoDispose to automatically clean up when no longer needed
final optimizedGoalProvider =
    FutureProvider.autoDispose.family<OptimizeGoalResponse?, OptimizeGoalParams>(
        (ref, params) async {
  final aiService = ref.watch(aiServiceProvider);
  final locale = ref.watch(localeProvider).languageCode;

  try {
    debugPrint('AI Provider: Starting optimization...');
    debugPrint('  goalTitle: ${params.goalTitle}');
    debugPrint('  category: ${params.category}');
    debugPrint('  locale: $locale');

    final result = await aiService.optimizeGoal(
      goalTitle: params.goalTitle,
      category: params.category,
      motivation: params.motivation,
      targetDate: params.targetDate,
      locale: locale,
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
/// Uses autoDispose to automatically clean up when no longer needed
final aiSuggestionsProvider = FutureProvider.autoDispose<String?>((ref) async {
  final aiService = ref.watch(aiServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  final goalsAsync = ref.watch(goalsStreamProvider);
  final locale = ref.watch(localeProvider).languageCode;

  if (userId == null) {
    return null;
  }

  return goalsAsync.when(
    data: (goals) async {
      if (goals.isEmpty) return null;

      // Fetch all check-ins for all goals in parallel
      final allCheckIns = await _fetchAllCheckIns(ref, goals);

      try {
        final suggestions = await aiService.generateSuggestions(
          userId: userId,
          goals: goals,
          checkIns: allCheckIns,
          locale: locale,
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
/// Uses autoDispose to automatically clean up when no longer needed
final yearlyReportProvider =
    FutureProvider.autoDispose.family<String?, YearlyReportParams>(
        (ref, params) async {
  final aiService = ref.watch(aiServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  final goalsAsync = ref.watch(goalsStreamProvider);
  final locale = ref.watch(localeProvider).languageCode;

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

      if (yearGoals.isEmpty) return null;

      // Fetch all check-ins for year goals in parallel
      final allCheckInsFutures = yearGoals.map((goal) async {
        final checkInsAsync = ref.read(checkInsStreamProvider(goal.id));
        return checkInsAsync.when(
          data: (checkIns) => checkIns
              .where((ci) => ci.createdAt.year == params.year)
              .toList(),
          loading: () => <CheckIn>[],
          error: (_, __) => <CheckIn>[],
        );
      }).toList();

      final allCheckInsResults = await Future.wait(allCheckInsFutures);
      final allCheckIns = allCheckInsResults.expand((checkIns) => checkIns).toList();

      try {
        final report = await aiService.generateYearlyReport(
          userId: userId,
          year: params.year,
          goals: yearGoals,
          checkIns: allCheckIns,
          locale: locale,
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
  final DateTime? targetDate;

  OptimizeGoalParams({
    required this.goalTitle,
    required this.category,
    this.motivation,
    this.targetDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OptimizeGoalParams &&
        other.goalTitle == goalTitle &&
        other.category == category &&
        other.motivation == motivation &&
        other.targetDate == targetDate;
  }

  @override
  int get hashCode =>
      Object.hash(goalTitle, category, motivation, targetDate);
}

/// Parameters for yearly report generation
class YearlyReportParams {
  final int year;

  YearlyReportParams({required this.year});
}
