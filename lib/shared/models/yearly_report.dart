import 'package:meta/meta.dart';

/// Report type enum
enum ReportType {
  weekly('Haftalık'),
  monthly('Aylık'),
  yearly('Yıllık');

  const ReportType(this.label);
  final String label;
}

@immutable
class Report {
  const Report({
    required this.id,
    required this.userId,
    required this.reportType,
    required this.periodStart,
    required this.periodEnd,
    required this.generatedAt,
    required this.content,
  });

  final String id;
  final String userId;
  final ReportType reportType;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime generatedAt;
  final String content;

  /// Year for yearly reports (backward compatibility)
  int? get year {
    if (reportType == ReportType.yearly) {
      return periodStart.year;
    }
    return null;
  }
}

/// YearlyReport - kept for backward compatibility
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

  /// Convert to new Report model
  Report toReport() {
    return Report(
      id: id,
      userId: userId,
      reportType: ReportType.yearly,
      periodStart: DateTime(year, 1, 1),
      periodEnd: DateTime(year, 12, 31, 23, 59, 59),
      generatedAt: generatedAt,
      content: content,
    );
  }
}
