import '../models/check_in.dart';
import '../models/goal.dart';
import '../models/note.dart';
import '../models/yearly_report.dart';

abstract class GoalRepository {
  Stream<List<Goal>> watchGoals(String userId);

  Stream<List<Goal>> watchAllGoals(String userId);

  Future<List<Goal>> fetchGoals(String userId);

  Future<Goal?> fetchGoalById(String goalId);

  Future<Goal> createGoal(Goal goal);

  Future<Goal> updateGoal(Goal goal);

  Future<void> archiveGoal(String goalId);

  Future<void> completeGoal(String goalId);

  Future<void> deleteGoal(String goalId);

  /// Belirli bir kullanıcıya ait hedefi sil (security rules ile uyumlu)
  Future<void> deleteGoalForUser(String goalId, String userId);

  // Check-ins
  Stream<List<CheckIn>> watchCheckIns(String goalId, String userId);

  Future<CheckIn> addCheckIn(CheckIn checkIn);

  /// Kullanıcının tüm check-in kayıtlarını izler (hedeften bağımsız).
  Stream<List<CheckIn>> watchAllCheckIns(String userId);

  // Yearly reports (per user) - Legacy
  Stream<YearlyReport?> watchYearlyReport({
    required String userId,
    required int year,
  });

  Future<YearlyReport?> getYearlyReport({
    required String userId,
    required int year,
  });

  Future<YearlyReport> saveYearlyReport(YearlyReport report);

  // Reports (all types)
  /// Kullanıcının tüm raporlarını izler (haftalık, aylık, yıllık)
  Stream<List<Report>> watchAllReports(String userId);

  /// Rapor kaydet (tüm türler için)
  Future<Report> saveReport(Report report);

  /// Rapor sil
  Future<void> deleteReport(String reportId, String userId);

  /// Notes
  Stream<List<Note>> watchNotes(String goalId, String userId);

  Future<void> addNote(Note note);

  Future<void> deleteNote(String noteId);
}
