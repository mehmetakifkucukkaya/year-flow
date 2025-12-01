import 'dart:async';

import '../../core/constants/app_constants.dart';
import '../models/check_in.dart';
import '../models/goal.dart';
import '../models/note.dart';
import '../models/yearly_report.dart';
import 'goal_repository.dart';

const String _demoUserId = 'demo-user';

/// Simple in-memory implementation of [GoalRepository] for local development.
class InMemoryGoalRepository implements GoalRepository {
  InMemoryGoalRepository() {
    _seedData();
  }

  final List<Goal> _goals = [];
  final List<CheckIn> _checkIns = [];
  final List<YearlyReport> _reports = [];

  void _seedData() {
    if (_goals.isNotEmpty) return;

    final now = DateTime.now();

    _goals.addAll([
      Goal(
        id: 'goal-1',
        userId: _demoUserId,
        title: 'Haftada 3 Gün Spor Yap',
        category: GoalCategory.health,
        createdAt: now.subtract(const Duration(days: 40)),
        targetDate: now.add(const Duration(days: 200)),
        motivation: 'Daha enerjik hissetmek ve sağlıklı bir rutin oluşturmak.',
        subGoals: const [
          SubGoal(
            id: 'sub-1',
            title: 'Haftalık program oluştur',
            isCompleted: true,
          ),
          SubGoal(
            id: 'sub-2',
            title: 'Bir spor salonuna kayıt ol',
            isCompleted: false,
          ),
        ],
        progress: 75,
      ),
      Goal(
        id: 'goal-2',
        userId: _demoUserId,
        title: 'Aylık 1 Kitap Oku',
        category: GoalCategory.personalGrowth,
        createdAt: now.subtract(const Duration(days: 60)),
        targetDate: now.add(const Duration(days: 300)),
        motivation: 'Kendimi geliştirmek ve yeni bakış açıları kazanmak.',
        subGoals: const [
          SubGoal(
            id: 'sub-3',
            title: 'Okuma listesi hazırla',
            isCompleted: true,
          ),
        ],
        progress: 50,
      ),
      Goal(
        id: 'goal-3',
        userId: _demoUserId,
        title: 'Yeni Bir Programlama Dili Öğren',
        category: GoalCategory.career,
        createdAt: now.subtract(const Duration(days: 20)),
        targetDate: now.add(const Duration(days: 180)),
        motivation: 'Kariyerimde yeni fırsatlar yaratmak.',
        subGoals: const [
          SubGoal(
            id: 'sub-4',
            title: 'Temel kursu tamamla',
            isCompleted: false,
          ),
        ],
        progress: 20,
      ),
    ]);

    _checkIns.addAll([
      CheckIn(
        id: 'checkin-1',
        goalId: 'goal-1',
        userId: _demoUserId,
        createdAt: now.subtract(const Duration(days: 3)),
        score: 8,
        progressDelta: 15,
        note: 'Bu hafta 2 kez spor yaptım, enerji düzeyim arttı.',
      ),
      CheckIn(
        id: 'checkin-2',
        goalId: 'goal-2',
        userId: _demoUserId,
        createdAt: now.subtract(const Duration(days: 7)),
        score: 6,
        progressDelta: 10,
        note: 'Bir kitabı bitirdim, ikinciye başladım.',
      ),
    ]);
  }

  List<Goal> _goalsForUser(String userId) {
    return _goals.where((g) => g.userId == userId && !g.isArchived).toList();
  }

  @override
  Stream<List<Goal>> watchGoals(String userId) async* {
    yield _goalsForUser(userId);
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
      _goals[index] = Goal(
        id: goal.id,
        userId: goal.userId,
        title: goal.title,
        category: goal.category,
        createdAt: goal.createdAt,
        targetDate: goal.targetDate,
        motivation: goal.motivation,
        subGoals: goal.subGoals,
        progress: goal.progress,
        isArchived: true,
      );
    }
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
  }

  @override
  Stream<List<CheckIn>> watchCheckIns(String goalId, String userId) async* {
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
    // In-memory implementation - mock data
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
}


