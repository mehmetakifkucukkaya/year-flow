import 'package:meta/meta.dart';

import '../../core/constants/app_constants.dart';

@immutable
class Goal {
  const Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.createdAt,
    this.targetDate,
    this.motivation,
    this.subGoals = const [],
    this.progress = 0,
    this.isArchived = false,
  });

  final String id;
  final String userId;
  final String title;
  final GoalCategory category;
  final DateTime createdAt;
  final DateTime? targetDate;
  final String? motivation;
  final List<SubGoal> subGoals;
  final int progress; // 0–100
  final bool isArchived;

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    GoalCategory? category,
    DateTime? createdAt,
    DateTime? targetDate,
    String? motivation,
    List<SubGoal>? subGoals,
    int? progress,
    bool? isArchived,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      motivation: motivation ?? this.motivation,
      subGoals: subGoals ?? this.subGoals,
      progress: progress ?? this.progress,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

@immutable
class SubGoal {
  const SubGoal({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
}


