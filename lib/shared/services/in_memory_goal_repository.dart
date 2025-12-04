import 'dart:async';

import '../models/check_in.dart';
import '../models/goal.dart';
import '../models/note.dart';
import '../models/yearly_report.dart';
import 'goal_repository.dart';

/// Simple in-memory implementation of [GoalRepository] for local development.
class InMemoryGoalRepository implements GoalRepository {
  InMemoryGoalRepository();

  final List<Goal> _goals = [];
  final List<CheckIn> _checkIns = [];
  final List<YearlyReport> _reports = [];
  final List<Report> _allReports = [];

  List<Goal> _goalsForUser(String userId) {
    return _goals
        .where((g) => g.userId == userId && !g.isArchived)
        .toList();
  }

  @override
  Stream<List<Goal>> watchGoals(String userId) async* {
    yield _goalsForUser(userId);
  }

  @override
  Stream<List<Goal>> watchAllGoals(String userId) async* {
    yield _goals.where((g) => g.userId == userId).toList();
  }

  @override
  Future<List<Goal>> fetchGoals(String userId) async {
    return _goalsForUser(userId);
  }

  @override
  Future<Goal?> fetchGoalById(String goalId) async {
    try {
      return _goals.firstWhere((g) => g.id == goalId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    _goals.add(goal);
    return goal;
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
    } else {
      _goals.add(goal);
    }
    return goal;
  }

  @override
  Future<void> archiveGoal(String goalId) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      _goals[index] = goal.copyWith(
        isArchived: true,
      );
    }
  }

  @override
  Future<void> completeGoal(String goalId) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      _goals[index] = goal.copyWith(
        progress: 100,
        isArchived: true,
        isCompleted: true,
        completedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
  }

  @override
  Future<void> deleteGoalForUser(String goalId, String userId) async {
    _goals.removeWhere((g) => g.id == goalId && g.userId == userId);
  }

  @override
  Stream<List<CheckIn>> watchCheckIns(
      String goalId, String userId) async* {
    yield _checkIns
        .where((c) => c.goalId == goalId && c.userId == userId)
        .toList();
  }

  @override
  Future<CheckIn> addCheckIn(CheckIn checkIn) async {
    _checkIns.add(checkIn);
    return checkIn;
  }

  @override
  Stream<List<CheckIn>> watchAllCheckIns(String userId) async* {
    yield _checkIns.where((c) => c.userId == userId).toList();
  }

  @override
  Stream<YearlyReport?> watchYearlyReport({
    required String userId,
    required int year,
  }) async* {
    yield _reports.firstWhere(
      (r) => r.userId == userId && r.year == year,
      orElse: () => YearlyReport(
        id: 'report-$year',
        userId: userId,
        year: year,
        generatedAt: DateTime.now(),
        content: '',
      ),
    );
  }

  @override
  Future<YearlyReport?> getYearlyReport({
    required String userId,
    required int year,
  }) async {
    try {
      return _reports.firstWhere(
        (r) => r.userId == userId && r.year == year,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<YearlyReport> saveYearlyReport(YearlyReport report) async {
    final index = _reports.indexWhere(
      (r) => r.userId == report.userId && r.year == report.year,
    );
    if (index != -1) {
      _reports[index] = report;
    } else {
      _reports.add(report);
    }
    return report;
  }

  @override
  Stream<List<Note>> watchNotes(String goalId, String userId) {
    return Stream.value([]);
  }

  @override
  Future<void> addNote(Note note) async {
    // In-memory implementation - no-op
  }

  @override
  Future<void> deleteNote(String noteId) async {
    // In-memory implementation - no-op
  }

  @override
  Stream<List<Report>> watchAllReports(String userId) async* {
    yield _allReports
        .where((r) => r.userId == userId)
        .toList()
      ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
  }

  @override
  Future<Report> saveReport(Report report) async {
    final index = _allReports.indexWhere((r) => r.id == report.id);
    if (index != -1) {
      _allReports[index] = report;
    } else {
      _allReports.add(report);
    }
    return report;
  }

  @override
  Future<void> deleteReport(String reportId, String userId) async {
    _allReports.removeWhere(
      (r) => r.id == reportId && r.userId == userId,
    );
  }
}
