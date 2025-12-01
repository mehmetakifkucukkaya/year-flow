import 'package:meta/meta.dart';

@immutable
class YearlyReport {
  const YearlyReport({
    required this.id,
    required this.userId,
    required this.year,
    required this.generatedAt,
    required this.content,
  });

  final String id;
  final String userId;
  final int year;
  final DateTime generatedAt;
  final String content;
}


