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
    this.description,
    this.motivation,
    this.subGoals = const [],
    this.progress = 0,
    this.isArchived = false,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final String userId;
  final String title;
  final GoalCategory category;
  final DateTime createdAt;
  final DateTime? targetDate;
  final String? description;
  final String? motivation;
  final List<SubGoal> subGoals;
  final int progress; // 0–100
  final bool isArchived;
  final bool isCompleted;
  final DateTime? completedAt;

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    GoalCategory? category,
    DateTime? createdAt,
    DateTime? targetDate,
    String? description,
    String? motivation,
    List<SubGoal>? subGoals,
    int? progress,
    bool? isArchived,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      motivation: motivation ?? this.motivation,
      subGoals: subGoals ?? this.subGoals,
      progress: progress ?? this.progress,
      isArchived: isArchived ?? this.isArchived,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
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
