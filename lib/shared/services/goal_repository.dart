import '../models/check_in.dart';
import '../models/goal.dart';
import '../models/yearly_report.dart';

abstract class GoalRepository {
  Stream<List<Goal>> watchGoals(String userId);

  Future<List<Goal>> fetchGoals(String userId);

  Future<Goal?> fetchGoalById(String goalId);

  Future<Goal> createGoal(Goal goal);

  Future<Goal> updateGoal(Goal goal);

  Future<void> archiveGoal(String goalId);

  Future<void> deleteGoal(String goalId);

  // Check-ins
  Stream<List<CheckIn>> watchCheckIns(String goalId);

  Future<CheckIn> addCheckIn(CheckIn checkIn);

  // Yearly reports (per user)
  Stream<YearlyReport?> watchYearlyReport({
    required String userId,
    required int year,
  });

  Future<YearlyReport?> getYearlyReport({
    required String userId,
    required int year,
  });

  Future<YearlyReport> saveYearlyReport(YearlyReport report);
}


