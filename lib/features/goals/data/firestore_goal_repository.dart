import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/models/check_in.dart';
import '../../../shared/models/goal.dart';
import '../../../shared/models/note.dart';
import '../../../shared/models/yearly_report.dart';
import '../../../shared/services/goal_repository.dart';

/// Firestore koleksiyon isimleri
class _FirestoreCollections {
  static const String users = 'users';
  static const String goals = 'goals';
  static const String checkIns = 'checkIns';
  static const String yearlyReports = 'yearlyReports';
  static const String notes = 'notes';

  /// Kullanıcıya özel koleksiyon referansı al
  static CollectionReference _userGoalsCollection(
      FirebaseFirestore firestore, String userId) {
    return firestore.collection(users).doc(userId).collection(goals);
  }

  static CollectionReference _userCheckInsCollection(
      FirebaseFirestore firestore, String userId) {
    return firestore.collection(users).doc(userId).collection(checkIns);
  }

  static CollectionReference _userYearlyReportsCollection(
      FirebaseFirestore firestore, String userId) {
    return firestore
        .collection(users)
        .doc(userId)
        .collection(yearlyReports);
  }

  static CollectionReference _userReportsCollection(
      FirebaseFirestore firestore, String userId) {
    return firestore.collection(users).doc(userId).collection('reports');
  }

  static CollectionReference _userNotesCollection(
      FirebaseFirestore firestore, String userId) {
    return firestore.collection(users).doc(userId).collection(notes);
  }
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
      // Önce tüm goal'ları al (isArchived filtresi olmadan)
      // Sonra memory'de filtrele (index gerektirmemek için)
      yield* _FirestoreCollections._userGoalsCollection(_firestore, userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        try {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  if (data == null) return null;
                  final goal = _goalFromFirestore(
                      doc.id, data as Map<String, dynamic>);
                  // isArchived filtresini memory'de yap
                  if (goal.isArchived) return null;
                  return goal;
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
  Stream<List<Goal>> watchAllGoals(String userId) async* {
    try {
      // Tüm goal'ları al (isArchived filtresi olmadan)
      yield* _FirestoreCollections._userGoalsCollection(_firestore, userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        try {
          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  if (data == null) return null;
                  return _goalFromFirestore(
                      doc.id, data as Map<String, dynamic>);
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
      print('Firestore watchAllGoals error: $e');
      print('Stack trace: $stackTrace');
      yield <Goal>[];
    }
  }

  @override
  Future<List<Goal>> fetchGoals(String userId) async {
    final snapshot = await _FirestoreCollections._userGoalsCollection(
            _firestore, userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          if (data == null) return null;
          final goal =
              _goalFromFirestore(doc.id, data as Map<String, dynamic>);
          // isArchived filtresini memory'de yap
          if (goal.isArchived) return null;
          return goal;
        })
        .whereType<Goal>()
        .toList();
  }

  @override
  Future<Goal?> fetchGoalById(String goalId) async {
    // GoalId ile direkt erişim için tüm kullanıcıların goals koleksiyonlarında arama yapmalıyız
    // Ancak bu verimsiz olabilir. Alternatif: goalId'yi userId ile birlikte saklamak
    // Şimdilik eski yapıyı koruyoruz ama userId'yi de parametre olarak almalıyız
    // Ancak interface'de userId yok, bu yüzden tüm kullanıcılarda arama yapacağız
    // Bu geçici bir çözüm - ideal olarak goalId userId içermeli veya interface güncellenmeli

    // Önce mevcut kullanıcının goals'ında ara
    // Not: Bu metodun çağrıldığı yerlerde userId bilgisi olmalı
    // Şimdilik tüm users collection'ında arama yapacağız (verimsiz ama çalışır)
    final usersSnapshot =
        await _firestore.collection(_FirestoreCollections.users).get();

    for (final userDoc in usersSnapshot.docs) {
      final goalDoc = await userDoc.reference
          .collection(_FirestoreCollections.goals)
          .doc(goalId)
          .get();

      if (goalDoc.exists) {
        final data = goalDoc.data();
        if (data != null) {
          return _goalFromFirestore(goalDoc.id, data);
        }
      }
    }

    return null;
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    final docRef =
        _FirestoreCollections._userGoalsCollection(_firestore, goal.userId)
            .doc();
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
    await _FirestoreCollections._userGoalsCollection(
            _firestore, goal.userId)
        .doc(goal.id)
        .update(_goalToFirestore(goal));

    return goal;
  }

  @override
  Future<void> archiveGoal(String goalId) async {
    // archiveGoal için userId gerekli, ama interface'de yok
    // Tüm kullanıcılarda arama yapmak yerine, mevcut kullanıcının goals'ında ara
    // Not: Bu metodun çağrıldığı yerlerde userId bilgisi olmalı
    // Şimdilik tüm users collection'ında arama yapacağız ama sadece kendi verilerine erişebiliriz
    final usersSnapshot =
        await _firestore.collection(_FirestoreCollections.users).get();

    for (final userDoc in usersSnapshot.docs) {
      final goalDoc = await userDoc.reference
          .collection(_FirestoreCollections.goals)
          .doc(goalId)
          .get();

      if (goalDoc.exists) {
        await goalDoc.reference.update({'isArchived': true});
        return;
      }
    }
  }

  @override
  Future<void> completeGoal(String goalId) async {
    // completeGoal için userId gerekli, ama interface'de yok
    // Tüm kullanıcılarda arama yapmak yerine, mevcut kullanıcının goals'ında ara
    // Not: Bu metodun çağrıldığı yerlerde userId bilgisi olmalı
    // Şimdilik tüm users collection'ında arama yapacağız ama sadece kendi verilerine erişebiliriz
    final usersSnapshot =
        await _firestore.collection(_FirestoreCollections.users).get();

    for (final userDoc in usersSnapshot.docs) {
      final goalDoc = await userDoc.reference
          .collection(_FirestoreCollections.goals)
          .doc(goalId)
          .get();

      if (goalDoc.exists) {
        // Hedefi tamamla ve otomatik olarak arşive taşı
        await goalDoc.reference.update({
          'isCompleted': true,
          'isArchived': true,
          'progress': 100,
        });
        return;
      }
    }

    throw Exception('Hedef bulunamadı');
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    // deleteGoal için userId gerekli, ama interface'de yok
    // Tüm kullanıcılarda arama yapmak yerine, mevcut kullanıcının goals'ında ara
    // Not: Bu metodun çağrıldığı yerlerde userId bilgisi olmalı
    // Şimdilik tüm users collection'ında arama yapacağız ama sadece kendi verilerine erişebiliriz
    final usersSnapshot =
        await _firestore.collection(_FirestoreCollections.users).get();

    for (final userDoc in usersSnapshot.docs) {
      final goalDoc = await userDoc.reference
          .collection(_FirestoreCollections.goals)
          .doc(goalId)
          .get();

      if (goalDoc.exists) {
        await goalDoc.reference.delete();
        return;
      }
    }
  }

  // ==================== Check-ins ====================

  @override
  Stream<List<CheckIn>> watchCheckIns(String goalId, String userId) {
    return _FirestoreCollections._userCheckInsCollection(
            _firestore, userId)
        .where('goalId', isEqualTo: goalId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              if (data == null) return null;
              return _checkInFromFirestore(
                  doc.id, data as Map<String, dynamic>);
            })
            .whereType<CheckIn>()
            .toList());
  }

  @override
  Future<CheckIn> addCheckIn(CheckIn checkIn) async {
    final docRef = _FirestoreCollections._userCheckInsCollection(
            _firestore, checkIn.userId)
        .doc();
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

  @override
  Stream<List<CheckIn>> watchAllCheckIns(String userId) {
    try {
      return _FirestoreCollections._userCheckInsCollection(
              _firestore, userId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) {
                final data = doc.data();
                if (data == null) return null;
                return _checkInFromFirestore(
                    doc.id, data as Map<String, dynamic>);
              })
              .whereType<CheckIn>()
              .toList());
    } catch (e, stackTrace) {
      print('Firestore watchAllCheckIns error: $e');
      print(stackTrace);
      return Stream.value(<CheckIn>[]);
    }
  }

  // ==================== Yearly Reports ====================

  @override
  Stream<YearlyReport?> watchYearlyReport({
    required String userId,
    required int year,
  }) {
    return _FirestoreCollections._userYearlyReportsCollection(
            _firestore, userId)
        .where('year', isEqualTo: year)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = doc.data();
      if (data == null) return null;
      return _yearlyReportFromFirestore(
          doc.id, data as Map<String, dynamic>);
    });
  }

  @override
  Future<YearlyReport?> getYearlyReport({
    required String userId,
    required int year,
  }) async {
    final snapshot =
        await _FirestoreCollections._userYearlyReportsCollection(
                _firestore, userId)
            .where('year', isEqualTo: year)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final data = doc.data();
    if (data == null) return null;
    return _yearlyReportFromFirestore(
        doc.id, data as Map<String, dynamic>);
  }

  @override
  Future<YearlyReport> saveYearlyReport(YearlyReport report) async {
    final docRef = _FirestoreCollections._userYearlyReportsCollection(
            _firestore, report.userId)
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
      'isCompleted': goal.isCompleted,
      'completedAt': goal.completedAt != null
          ? Timestamp.fromDate(goal.completedAt!)
          : null,
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
      description:
          data['description'] as String? ?? data['motivation'] as String?,
      motivation: data['motivation'] as String?,
      subGoals: (data['subGoals'] as List<dynamic>?)
              ?.map((sg) => _subGoalFromMap(sg as Map<String, dynamic>))
              .toList() ??
          [],
      progress: (data['progress'] as int?) ?? 0,
      isArchived: (data['isArchived'] as bool?) ?? false,
      isCompleted: (data['isCompleted'] as bool?) ?? false,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
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

  YearlyReport _yearlyReportFromFirestore(
      String id, Map<String, dynamic> data) {
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
      return _FirestoreCollections._userNotesCollection(_firestore, userId)
          .where('goalId', isEqualTo: goalId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) {
              final data = doc.data();
              if (data == null) return null;
              final dataMap = data as Map<String, dynamic>;
              return Note(
                id: doc.id,
                goalId: dataMap['goalId'] as String? ?? '',
                userId: dataMap['userId'] as String? ?? '',
                createdAt:
                    (dataMap['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                content: dataMap['content'] as String? ?? '',
              );
            })
            .whereType<Note>()
            .toList();
      });
    } catch (e) {
      print('Error watching notes: $e');
      return Stream.value([]);
    }
  }

  @override
  Future<void> addNote(Note note) async {
    try {
      await _FirestoreCollections._userNotesCollection(
              _firestore, note.userId)
          .doc(note.id)
          .set({
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
    // deleteNote için userId gerekli, ama interface'de yok
    // Not: Bu metodun çağrıldığı yerlerde userId bilgisi olmalı
    // Şimdilik tüm kullanıcılarda arama yapacağız
    try {
      final usersSnapshot =
          await _firestore.collection(_FirestoreCollections.users).get();

      for (final userDoc in usersSnapshot.docs) {
        final noteDoc = await userDoc.reference
            .collection(_FirestoreCollections.notes)
            .doc(noteId)
            .get();

        if (noteDoc.exists) {
          await noteDoc.reference.delete();
          return;
        }
      }
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Report>> watchAllReports(String userId) {
    return _FirestoreCollections._userReportsCollection(_firestore, userId)
        .orderBy('generatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) return null;
            return _reportFromFirestore(doc.id, data);
          })
          .whereType<Report>()
          .toList();
    });
  }

  @override
  Future<Report> saveReport(Report report) async {
    final docRef = _FirestoreCollections._userReportsCollection(
            _firestore, report.userId)
        .doc(report.id);

    await docRef.set(_reportToFirestore(report));
    return report;
  }

  @override
  Future<void> deleteReport(String reportId, String userId) async {
    await _FirestoreCollections._userReportsCollection(_firestore, userId)
        .doc(reportId)
        .delete();
  }

  // ==================== Report Firestore Conversion ====================

  Map<String, dynamic> _reportToFirestore(Report report) {
    return {
      'userId': report.userId,
      'reportType': report.reportType.name,
      'periodStart': Timestamp.fromDate(report.periodStart),
      'periodEnd': Timestamp.fromDate(report.periodEnd),
      'generatedAt': Timestamp.fromDate(report.generatedAt),
      'content': report.content,
    };
  }

  Report _reportFromFirestore(String id, Map<String, dynamic> data) {
    return Report(
      id: id,
      userId: data['userId'] as String,
      reportType: ReportType.values.firstWhere(
        (t) => t.name == data['reportType'],
        orElse: () => ReportType.yearly,
      ),
      periodStart: (data['periodStart'] as Timestamp).toDate(),
      periodEnd: (data['periodEnd'] as Timestamp).toDate(),
      generatedAt: (data['generatedAt'] as Timestamp).toDate(),
      content: data['content'] as String,
    );
  }
}
