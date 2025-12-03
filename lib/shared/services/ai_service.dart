import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/check_in.dart';
import '../models/goal.dart';

/// Conditional logger for debug mode only
class _Logger {
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  static void error(String message, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('ERROR: $message');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
    // In production, send to crashlytics or logging service
  }
}

/// AI Service for interacting with Firebase Cloud Functions
/// Handles goal optimization, AI suggestions, and yearly report generation
class AIService {
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  AIService({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _functions = functions ??
            FirebaseFunctions.instanceFor(
              region: 'europe-west1',
            ),
        _auth = auth ?? FirebaseAuth.instance;

  /// Optimize a goal using AI
  /// Converts user goal to SMART format and suggests sub-goals
  Future<OptimizeGoalResponse> optimizeGoal({
    required String goalTitle,
    required String category,
    String? motivation,
    DateTime? targetDate,
  }) async {
    try {
      final user = await _getAuthenticatedUser();
      final result = await _callOptimizeFunction(user, {
        'goalTitle': goalTitle,
        'category': category,
        if (motivation != null && motivation.isNotEmpty)
          'motivation': motivation,
        if (targetDate != null) 'targetDate': targetDate.toIso8601String(),
      });

      return _parseOptimizeResponse(result);
    } catch (e) {
      throw _handleOptimizeError(e, goalTitle);
    }
  }

  /// Parse AI-generated dueDate field safely.
  /// Accepts ISO string, "null", empty string or null and converts to DateTime?.
  DateTime? _parseAiDueDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is! String) return null;

    final value = raw.trim();
    if (value.isEmpty || value.toLowerCase() == 'null') {
      return null;
    }

    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  /// Suggest sub-goals for a given goal (lightweight AI call)
  Future<List<String>> suggestSubGoals({
    required String goalTitle,
    required String category,
    String? description,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated');
      }

      final callable = _functions.httpsCallable('suggestSubGoalsFunction');

      _Logger.debug('AI Service: Calling suggestSubGoalsFunction with:');
      _Logger.debug('  goalTitle: $goalTitle');
      _Logger.debug('  category: $category');
      _Logger.debug('  description: $description');

      final result = await callable.call({
        'goalTitle': goalTitle,
        'category': category,
        if (description != null && description.isNotEmpty)
          'description': description,
      });

      _Logger.debug(
          'AI Service: suggestSubGoalsFunction result: ${result.data}');

      if (result.data == null) {
        throw Exception('No data received from Cloud Function');
      }

      final data = result.data as Map<String, dynamic>;
      final list = (data['subGoals'] as List<dynamic>? ?? [])
          .map((e) => (e as Map<String, dynamic>)['title'] as String)
          .where((title) => title.trim().isNotEmpty)
          .toList();

      return list;
    } catch (e, stackTrace) {
      _Logger.error('AI Service suggestSubGoals Error: $e', stackTrace);
      if (_shouldFallbackToOptimizeGoal(e)) {
        _Logger.debug(
            'AI Service: Falling back to optimizeGoal for sub-goal suggestions');
        try {
          final optimized = await optimizeGoal(
            goalTitle: goalTitle,
            category: category,
            motivation: description,
          );

          final fallbackList = optimized.subGoals
              .map((subGoal) => subGoal.title.trim())
              .where((title) => title.isNotEmpty)
              .toList();

          if (fallbackList.isNotEmpty) {
            return fallbackList;
          }
        } catch (fallbackError, fallbackStackTrace) {
          _Logger.error(
              'AI Service fallback via optimizeGoal failed: $fallbackError',
              fallbackStackTrace);
          throw Exception(
            'Alt görev önerileri alınamadı: ${fallbackError.toString()}',
          );
        }
      }

      throw Exception('Alt görev önerileri alınamadı: ${e.toString()}');
    }
  }

  bool _shouldFallbackToOptimizeGoal(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('ai service initialization failed') ||
        message.contains('failed to suggest sub-goals') ||
        message.contains('gemini api key');
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

      final callable =
          _functions.httpsCallable('generateSuggestionsFunction');

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

      final callable =
          _functions.httpsCallable('generateYearlyReportFunction');

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
      if (goal.description != null) 'description': goal.description,
      if (goal.targetDate != null)
        'targetDate': goal.targetDate!.toIso8601String(),
      if (goal.motivation != null) 'motivation': goal.motivation,
      'progress': goal.progress,
      'isArchived': goal.isArchived,
      'isCompleted': goal.isCompleted,
      if (goal.completedAt != null)
        'completedAt': goal.completedAt!.toIso8601String(),
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

  /// Get authenticated user
  Future<User> _getAuthenticatedUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated');
    }
    return user;
  }

  /// Call optimize goal function
  Future<Map<String, dynamic>> _callOptimizeFunction(
    User user,
    Map<String, dynamic> data,
  ) async {
    final callable = _functions.httpsCallable('optimizeGoalFunction');

    _Logger.debug('AI Service: Calling optimizeGoalFunction with:');
    _Logger.debug('  goalTitle: ${data['goalTitle']}');
    _Logger.debug('  category: ${data['category']}');
    _Logger.debug('  motivation: ${data['motivation']}');

    final result = await callable.call(data);

    _Logger.debug('AI Service: Received result: ${result.data}');

    if (result.data == null) {
      throw Exception('No data received from Cloud Function');
    }

    return result.data as Map<String, dynamic>;
  }

  /// Parse optimize response
  OptimizeGoalResponse _parseOptimizeResponse(Map<String, dynamic> data) {
    _Logger.debug('AI Service: Parsing response data...');
    _Logger.debug('  optimizedTitle: ${data['optimizedTitle']}');
    _Logger.debug(
        '  subGoals count: ${(data['subGoals'] as List).length}');
    _Logger.debug('  explanation: ${data['explanation']}');

    final response = OptimizeGoalResponse(
      optimizedTitle: data['optimizedTitle'] as String,
      subGoals: (data['subGoals'] as List<dynamic>).map((sg) {
        return SubGoal(
          id: sg['id'] as String,
          title: sg['title'] as String,
          isCompleted: sg['isCompleted'] as bool? ?? false,
          dueDate: _parseAiDueDate(sg['dueDate']),
        );
      }).toList(),
      explanation: data['explanation'] as String,
    );

    _Logger.debug('AI Service: Successfully created OptimizeGoalResponse');
    _Logger.debug('  optimizedTitle: ${response.optimizedTitle}');
    _Logger.debug('  subGoals count: ${response.subGoals.length}');

    return response;
  }

  /// Handle optimize error
  Exception _handleOptimizeError(Object error, String goalTitle) {
    _Logger.error('AI Service Error: $error');

    // Provide more specific error messages
    if (error.toString().contains('NOT_FOUND')) {
      return Exception(
          'Cloud Function bulunamadı. Functions deploy edildi mi?');
    } else if (error.toString().contains('PERMISSION_DENIED')) {
      return Exception('Yetki hatası. Giriş yaptığınızdan emin olun.');
    } else if (error.toString().contains('UNAVAILABLE')) {
      return Exception(
          'Cloud Function şu anda kullanılamıyor. Lütfen tekrar deneyin.');
    } else if (error.toString().contains('DEADLINE_EXCEEDED')) {
      return Exception(
          'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.');
    }

    final message = error.toString();
    final normalized = message.toLowerCase();

    // Hedef çok kısa / anlamsız ise daha açıklayıcı bir mesaj göster
    if (_isGoalTooShort(goalTitle) || _isAiParsingError(normalized)) {
      return Exception(
        'AI bu hedefi anlamakta zorlandı. '
        'Hedef başlığını biraz daha açıklayıcı ve net yazmayı dene. '
        'Örneğin: "İngilizce seviyemi B1\'den B2\'ye çıkarmak" gibi.',
      );
    }

    // AI'den gelen beklenmeyen tarih formatları için kullanıcı dostu mesaj
    if (normalized.contains('invalid date format')) {
      return Exception(
        'AI tarafından üretilen tarihler işlenemedi. '
        'Lütfen daha sonra tekrar dene veya hedefi elle düzenle.',
      );
    }

    return Exception('Hedef optimizasyonu başarısız: $message');
  }

  /// Check if goal title is too short
  bool _isGoalTooShort(String goalTitle) {
    final trimmedTitle = goalTitle.trim();
    if (trimmedTitle.isEmpty) return true;
    final wordCount = trimmedTitle.split(RegExp(r'\s+')).length;
    return trimmedTitle.length < 4 || wordCount < 2;
  }

  /// Check if error is AI parsing related
  bool _isAiParsingError(String normalizedMessage) {
    return normalizedMessage.contains('invalid json response from ai') ||
        normalizedMessage.contains('invalid response structure from ai') ||
        normalizedMessage.contains('empty response from gemini api') ||
        normalizedMessage.contains('goal optimization failed');
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
