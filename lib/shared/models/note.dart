import 'package:meta/meta.dart';

@immutable
class Note {
  const Note({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.createdAt,
    required this.content,
  });

  final String id;
  final String goalId;
  final String userId;
  final DateTime createdAt;
  final String content;
}
