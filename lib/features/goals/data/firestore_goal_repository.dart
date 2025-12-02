import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/check_in.dart';
import '../../../shared/models/goal.dart';
import '../../../shared/models/note.dart';
import '../../../shared/models/yearly_report.dart';
import '../../../shared/services/goal_repository.dart';

/// Firestore koleksiyon isimleri
class _FirestoreCollections {
  static const String goals = 'goals';
  static const String checkIns = 'checkIns';
  static const String yearlyReports = 'yearlyReports';
  static const String notes = 'notes';
}

/// Firestore tabanlı GoalRepository implementasyonu
class FirestoreGoalRepository implements GoalRepository {
  FirestoreGoalRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  // ==================== Goals ====================

  @override
  Stream<List<Goal>> watchGoals(String userId) async* {
    try {
      yield* _firestore
          .collection(_FirestoreCollections.goals)
          .where('userId', isEqualTo: userId)
          .where('isArchived', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        try {
          return snapshot.docs
              .map((doc) {
                try {
                  return _goalFromFirestore(doc.id, doc.data());
                } catch (e) {
                  print('Error parsing goal ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<Goal>()
              .toList();
        } catch (e) {
          print('Error parsing goals from Firestore: $e');
          return <Goal>[];
        }
      });
    } catch (e, stackTrace) {
      // Hata detaylarını logla
      print('Firestore watchGoals error: $e');
      print('Stack trace: $stackTrace');
      // Hata durumunda boş liste döndür (stream'i kırmamak için)
      yield <Goal>[];
    }
  }

  @override
  Future<List<Goal>> fetchGoals(String userId) async {
    final snapshot = await _firestore
        .collection(_FirestoreCollections.goals)
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => _goalFromFirestore(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<Goal?> fetchGoalById(String goalId) async {
    final doc = await _firestore
        .collection(_FirestoreCollections.goals)
        .doc(goalId)
        .get();

    if (!doc.exists) return null;

    return _goalFromFirestore(doc.id, doc.data()!);
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    final docRef = _firestore.collection(_FirestoreCollections.goals).doc();
    final goalWithId = Goal(
      id: docRef.id,
      userId: goal.userId,
      title: goal.title,
      category: goal.category,
      createdAt: goal.createdAt,
      targetDate: goal.targetDate,
      description: goal.description,
      motivation: goal.motivation,
      subGoals: goal.subGoals,
      progress: goal.progress,
      isArchived: goal.isArchived,
    );

    await docRef.set(_goalToFirestore(goalWithId));
    return goalWithId;
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    await _firestore
        .collection(_FirestoreCollections.goals)
        .doc(goal.id)
        .update(_goalToFirestore(goal));

    return goal;
  }

  @override
  Future<void> archiveGoal(String goalId) async {
    await _firestore
        .collection(_FirestoreCollections.goals)
        .doc(goalId)
        .update({'isArchived': true});
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await _firestore
        .collection(_FirestoreCollections.goals)
        .doc(goalId)
        .delete();
  }

  // ==================== Check-ins ====================

  @override
  Stream<List<CheckIn>> watchCheckIns(String goalId, String userId) {
    return _firestore
        .collection(_FirestoreCollections.checkIns)
        .where('goalId', isEqualTo: goalId)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _checkInFromFirestore(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<CheckIn> addCheckIn(CheckIn checkIn) async {
    final docRef = _firestore.collection(_FirestoreCollections.checkIns).doc();
    final checkInWithId = CheckIn(
      id: docRef.id,
      goalId: checkIn.goalId,
      userId: checkIn.userId,
      createdAt: checkIn.createdAt,
      score: checkIn.score,
      progressDelta: checkIn.progressDelta,
      note: checkIn.note,
    );

    await docRef.set(_checkInToFirestore(checkInWithId));

    return checkInWithId;
  }

  // ==================== Yearly Reports ====================

  @override
  Stream<YearlyReport?> watchYearlyReport({
    required String userId,
    required int year,
  }) {
    return _firestore
        .collection(_FirestoreCollections.yearlyReports)
        .where('userId', isEqualTo: userId)
        .where('year', isEqualTo: year)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return _yearlyReportFromFirestore(doc.id, doc.data());
    });
  }

  @override
  Future<YearlyReport?> getYearlyReport({
    required String userId,
    required int year,
  }) async {
    final snapshot = await _firestore
        .collection(_FirestoreCollections.yearlyReports)
        .where('userId', isEqualTo: userId)
        .where('year', isEqualTo: year)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return _yearlyReportFromFirestore(doc.id, doc.data());
  }

  @override
  Future<YearlyReport> saveYearlyReport(YearlyReport report) async {
    final docRef = _firestore
        .collection(_FirestoreCollections.yearlyReports)
        .doc(report.id);

    await docRef.set(_yearlyReportToFirestore(report));
    return report;
  }

  // ==================== Firestore Conversion Helpers ====================

  Map<String, dynamic> _goalToFirestore(Goal goal) {
    return {
      'userId': goal.userId,
      'title': goal.title,
      'category': goal.category.name,
      'createdAt': Timestamp.fromDate(goal.createdAt),
      'targetDate': goal.targetDate != null
          ? Timestamp.fromDate(goal.targetDate!)
          : null,
      'description': goal.description,
      'motivation': goal.motivation,
      'subGoals': goal.subGoals.map((sg) => _subGoalToMap(sg)).toList(),
      'progress': goal.progress,
      'isArchived': goal.isArchived,
    };
  }

  Goal _goalFromFirestore(String id, Map<String, dynamic> data) {
    return Goal(
      id: id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      category: GoalCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => GoalCategory.personalGrowth,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      targetDate: data['targetDate'] != null
          ? (data['targetDate'] as Timestamp).toDate()
          : null,
      description: data['description'] as String? ?? data['motivation'] as String?,
      motivation: data['motivation'] as String?,
      subGoals: (data['subGoals'] as List<dynamic>?)
              ?.map((sg) => _subGoalFromMap(sg as Map<String, dynamic>))
              .toList() ??
          [],
      progress: (data['progress'] as int?) ?? 0,
      isArchived: (data['isArchived'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> _subGoalToMap(SubGoal subGoal) {
    return {
      'id': subGoal.id,
      'title': subGoal.title,
      'isCompleted': subGoal.isCompleted,
      'dueDate': subGoal.dueDate != null
          ? Timestamp.fromDate(subGoal.dueDate!)
          : null,
    };
  }

  SubGoal _subGoalFromMap(Map<String, dynamic> map) {
    return SubGoal(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> _checkInToFirestore(CheckIn checkIn) {
    return {
      'goalId': checkIn.goalId,
      'userId': checkIn.userId,
      'createdAt': Timestamp.fromDate(checkIn.createdAt),
      'score': checkIn.score,
      'progressDelta': checkIn.progressDelta,
      'note': checkIn.note,
    };
  }

  CheckIn _checkInFromFirestore(String id, Map<String, dynamic> data) {
    return CheckIn(
      id: id,
      goalId: data['goalId'] as String,
      userId: data['userId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      score: data['score'] as int,
      progressDelta: data['progressDelta'] as int,
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> _yearlyReportToFirestore(YearlyReport report) {
    return {
      'userId': report.userId,
      'year': report.year,
      'generatedAt': Timestamp.fromDate(report.generatedAt),
      'content': report.content,
    };
  }

  YearlyReport _yearlyReportFromFirestore(String id, Map<String, dynamic> data) {
    return YearlyReport(
      id: id,
      userId: data['userId'] as String,
      year: data['year'] as int,
      generatedAt: (data['generatedAt'] as Timestamp).toDate(),
      content: data['content'] as String,
    );
  }

  @override
  Stream<List<Note>> watchNotes(String goalId, String userId) {
    try {
      return _firestore
          .collection(_FirestoreCollections.notes)
          .where('goalId', isEqualTo: goalId)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Note(
            id: doc.id,
            goalId: data['goalId'] as String,
            userId: data['userId'] as String,
            createdAt: (data['createdAt'] as Timestamp).toDate(),
            content: data['content'] as String,
          );
        }).toList();
      });
    } catch (e) {
      print('Error watching notes: $e');
      return Stream.value([]);
    }
  }

  @override
  Future<void> addNote(Note note) async {
    try {
      await _firestore.collection(_FirestoreCollections.notes).doc(note.id).set({
        'goalId': note.goalId,
        'userId': note.userId,
        'createdAt': Timestamp.fromDate(note.createdAt),
        'content': note.content,
      });
    } catch (e) {
      print('Error adding note: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection(_FirestoreCollections.notes).doc(noteId).delete();
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }
}

