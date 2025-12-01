import 'package:meta/meta.dart';

@immutable
class CheckIn {
  const CheckIn({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.createdAt,
    required this.score,
    required this.progressDelta,
    this.note,
  });

  final String id;
  final String goalId;
  final String userId;
  final DateTime createdAt;
  final int score; // 1–10
  final int progressDelta; // change in progress in percentage points
  final String? note;
}


