import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/goal.dart';
import '../models/check_in.dart';

/// AI Service for interacting with Firebase Cloud Functions
/// Handles goal optimization, AI suggestions, and yearly report generation
class AIService {
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  AIService({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _functions = functions ?? FirebaseFunctions.instanceFor(
          region: 'europe-west1',
        ),
        _auth = auth ?? FirebaseAuth.instance;

  /// Optimize a goal using AI
  /// Converts user goal to SMART format and suggests sub-goals
  Future<OptimizeGoalResponse> optimizeGoal({
    required String goalTitle,
    required String category,
    String? motivation,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated');
      }

      final callable = _functions.httpsCallable('optimizeGoalFunction');

      debugPrint('AI Service: Calling optimizeGoalFunction with:');
      debugPrint('  goalTitle: $goalTitle');
      debugPrint('  category: $category');
      debugPrint('  motivation: $motivation');

      final result = await callable.call({
        'goalTitle': goalTitle,
        'category': category,
        if (motivation != null && motivation.isNotEmpty) 'motivation': motivation,
      });

      debugPrint('AI Service: Received result: ${result.data}');

      if (result.data == null) {
        throw Exception('No data received from Cloud Function');
      }

      final data = result.data as Map<String, dynamic>;

      debugPrint('AI Service: Parsing response data...');
      debugPrint('  optimizedTitle: ${data['optimizedTitle']}');
      debugPrint('  subGoals count: ${(data['subGoals'] as List).length}');
      debugPrint('  explanation: ${data['explanation']}');

      final response = OptimizeGoalResponse(
        optimizedTitle: data['optimizedTitle'] as String,
        subGoals: (data['subGoals'] as List<dynamic>).map((sg) {
          return SubGoal(
            id: sg['id'] as String,
            title: sg['title'] as String,
            isCompleted: sg['isCompleted'] as bool? ?? false,
            dueDate: sg['dueDate'] != null
                ? DateTime.parse(sg['dueDate'] as String)
                : null,
          );
        }).toList(),
        explanation: data['explanation'] as String,
      );

      debugPrint('AI Service: Successfully created OptimizeGoalResponse');
      debugPrint('  optimizedTitle: ${response.optimizedTitle}');
      debugPrint('  subGoals count: ${response.subGoals.length}');

      return response;
    } catch (e, stackTrace) {
      debugPrint('AI Service Error: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Provide more specific error messages
      if (e.toString().contains('NOT_FOUND')) {
        throw Exception('Cloud Function bulunamadı. Functions deploy edildi mi?');
      } else if (e.toString().contains('PERMISSION_DENIED')) {
        throw Exception('Yetki hatası. Giriş yaptığınızdan emin olun.');
      } else if (e.toString().contains('UNAVAILABLE')) {
        throw Exception('Cloud Function şu anda kullanılamıyor. Lütfen tekrar deneyin.');
      } else if (e.toString().contains('DEADLINE_EXCEEDED')) {
        throw Exception('İstek zaman aşımına uğradı. Lütfen tekrar deneyin.');
      }
      
      throw Exception('Hedef optimizasyonu başarısız: ${e.toString()}');
    }
  }

  /// Generate AI suggestions based on user goals and progress
  Future<String> generateSuggestions({
    required String userId,
    required List<Goal> goals,
    required List<CheckIn> checkIns,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated');
      }

      if (user.uid != userId) {
        throw Exception('User can only access own data');
      }

      final callable = _functions.httpsCallable('generateSuggestionsFunction');

      final result = await callable.call({
        'userId': userId,
        'goals': goals.map((g) => _goalToMap(g)).toList(),
        'checkIns': checkIns.map((ci) => _checkInToMap(ci)).toList(),
      });

      final data = result.data as Map<String, dynamic>;
      return data['suggestions'] as String;
    } catch (e) {
      throw Exception('Failed to generate suggestions: ${e.toString()}');
    }
  }

  /// Generate yearly report using AI
  Future<String> generateYearlyReport({
    required String userId,
    required int year,
    required List<Goal> goals,
    required List<CheckIn> checkIns,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated');
      }

      if (user.uid != userId) {
        throw Exception('User can only access own data');
      }

      final callable = _functions.httpsCallable('generateYearlyReportFunction');

      final result = await callable.call({
        'userId': userId,
        'year': year,
        'goals': goals.map((g) => _goalToMap(g)).toList(),
        'checkIns': checkIns.map((ci) => _checkInToMap(ci)).toList(),
      });

      final data = result.data as Map<String, dynamic>;
      return data['content'] as String;
    } catch (e) {
      throw Exception('Failed to generate yearly report: ${e.toString()}');
    }
  }

  /// Convert Goal to Map for Cloud Functions
  Map<String, dynamic> _goalToMap(Goal goal) {
    return {
      'id': goal.id,
      'userId': goal.userId,
      'title': goal.title,
      'category': goal.category.name,
      'createdAt': goal.createdAt.toIso8601String(),
      if (goal.targetDate != null)
        'targetDate': goal.targetDate!.toIso8601String(),
      if (goal.motivation != null) 'motivation': goal.motivation,
      'progress': goal.progress,
      'isArchived': goal.isArchived,
    };
  }

  /// Convert CheckIn to Map for Cloud Functions
  Map<String, dynamic> _checkInToMap(CheckIn checkIn) {
    return {
      'id': checkIn.id,
      'goalId': checkIn.goalId,
      'userId': checkIn.userId,
      'createdAt': checkIn.createdAt.toIso8601String(),
      'score': checkIn.score,
      'progressDelta': checkIn.progressDelta,
      if (checkIn.note != null) 'note': checkIn.note,
    };
  }
}

/// Response model for goal optimization
class OptimizeGoalResponse {
  final String optimizedTitle;
  final List<SubGoal> subGoals;
  final String explanation;

  OptimizeGoalResponse({
    required this.optimizedTitle,
    required this.subGoals,
    required this.explanation,
  });
}

