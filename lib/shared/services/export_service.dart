import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../models/check_in.dart';
import '../models/goal.dart';
import '../models/yearly_report.dart';
import '../services/goal_repository.dart';

/// Export service - Goals, Check-ins ve Reports'ları JSON/CSV olarak export eder
class ExportService {
  ExportService({
    required GoalRepository goalRepository,
  }) : _goalRepository = goalRepository;

  final GoalRepository _goalRepository;

  /// JSON backup dosyasından verileri import et
  Future<void> importBackupFromJson({
    required String userId,
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Yedek dosyası bulunamadı');
      }

      final content = await file.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Geçersiz yedek formatı');
      }

      final goalsJson = decoded['goals'] as List<dynamic>? ?? [];
      final checkInsJson = decoded['checkIns'] as List<dynamic>? ?? [];
      final yearlyReportJson =
          decoded['yearlyReport'] as Map<String, dynamic>?;

      // 1) Mevcut verileri temizle (idempotent import için)
      // Goals (ve ilişkili check-in/notes'lar backend tarafında silinir)
      final existingGoals = await _goalRepository.fetchGoals(userId);
      for (final goal in existingGoals) {
        await _goalRepository.deleteGoalForUser(goal.id, userId);
      }

      // Raporlar (haftalık/aylık/yıllık hepsi)
      final existingReportsStream =
          _goalRepository.watchAllReports(userId).first;
      final existingReports = await existingReportsStream;
      for (final report in existingReports) {
        await _goalRepository.deleteReport(report.id, userId);
      }

      // 2) Yedekten Goals oluştur
      for (final raw in goalsJson) {
        if (raw is! Map<String, dynamic>) continue;
        final goal = _goalFromJson(raw, userId);
        await _goalRepository.createGoal(goal);
      }

      // 3) Yedekten Check-ins oluştur
      for (final raw in checkInsJson) {
        if (raw is! Map<String, dynamic>) continue;
        final checkIn = _checkInFromJson(raw, userId);
        await _goalRepository.addCheckIn(checkIn);
      }

      // 4) Yearly report (opsiyonel)
      if (yearlyReportJson != null) {
        final report = _yearlyReportFromJson(yearlyReportJson, userId);
        await _goalRepository.saveYearlyReport(report);
      }
    } catch (e) {
      throw Exception('Yedek içe aktarılırken hata oluştu: $e');
    }
  }

  /// Tüm verileri JSON olarak export et
  Future<void> exportAllDataAsJson(String userId) async {
    try {
      // Goals'ları al
      final goals = await _goalRepository.fetchGoals(userId);

      // Her goal için check-ins'leri al
      final allCheckIns = <CheckIn>[];
      for (final goal in goals) {
        final checkIns =
            await _goalRepository.watchCheckIns(goal.id, userId).first;
        allCheckIns.addAll(checkIns);
      }

      // Yearly reports'ları al
      final currentYear = DateTime.now().year;
      final yearlyReport = await _goalRepository.getYearlyReport(
        userId: userId,
        year: currentYear,
      );

      // JSON oluştur
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'userId': userId,
        'goals': goals.map((g) => _goalToJson(g)).toList(),
        'checkIns': allCheckIns.map((c) => _checkInToJson(c)).toList(),
        'yearlyReport': yearlyReport != null
            ? _yearlyReportToJson(yearlyReport)
            : null,
      };

      final jsonString =
          const JsonEncoder.withIndent('  ').convert(exportData);

      // Dosyayı kaydet ve paylaş
      await _shareJsonFile(
        jsonString,
        _buildBackupFileName(prefix: 'YearFlow', extension: 'json'),
      );
    } catch (e) {
      throw Exception('Veri export edilirken hata oluştu: $e');
    }
  }

  /// Goals ve Reports'ları JSON olarak export et
  Future<void> exportGoalsAndReportsAsJson(String userId) async {
    try {
      // Goals'ları al
      final goals = await _goalRepository.fetchGoals(userId);

      // Yearly reports'ları al
      final currentYear = DateTime.now().year;
      final yearlyReport = await _goalRepository.getYearlyReport(
        userId: userId,
        year: currentYear,
      );

      // JSON oluştur
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'userId': userId,
        'goals': goals.map((g) => _goalToJson(g)).toList(),
        'yearlyReport': yearlyReport != null
            ? _yearlyReportToJson(yearlyReport)
            : null,
      };

      final jsonString =
          const JsonEncoder.withIndent('  ').convert(exportData);

      // Dosyayı kaydet ve paylaş
      await _shareJsonFile(
        jsonString,
        _buildBackupFileName(
            prefix: 'YearFlow_GoalsReports', extension: 'json'),
      );
    } catch (e) {
      throw Exception('Veri export edilirken hata oluştu: $e');
    }
  }

  /// Goals ve Reports'ları CSV olarak export et
  Future<void> exportGoalsAndReportsAsCsv(String userId) async {
    try {
      // Goals'ları al
      final goals = await _goalRepository.fetchGoals(userId);

      // CSV oluştur
      final csvLines = <String>[];

      // Goals CSV (tek tablo, kullanıcı dostu kolon başlıkları)
      csvLines.add(
        'ID,Başlık,Kategori,Oluşturulma Tarihi,Hedef Tarihi,İlerleme,Arşivlendi Mi,Açıklama',
      );
      for (final goal in goals) {
        csvLines.add([
          goal.id,
          _escapeCsv(goal.title),
          goal.category.name,
          goal.createdAt.toIso8601String(),
          goal.targetDate?.toIso8601String() ?? '',
          goal.progress.toString(),
          goal.isArchived.toString(),
          _escapeCsv(goal.description ?? ''),
        ].join(','));
      }

      final csvString = csvLines.join('\n');

      // Dosyayı kaydet ve paylaş
      await _shareCsvFile(
        csvString,
        _buildBackupFileName(
            prefix: 'YearFlow_GoalsReports', extension: 'csv'),
      );
    } catch (e) {
      throw Exception('Veri export edilirken hata oluştu: $e');
    }
  }

  /// Tüm verileri CSV olarak export et
  Future<void> exportAllDataAsCsv(String userId) async {
    try {
      // Goals'ları al
      final goals = await _goalRepository.fetchGoals(userId);

      // Her goal için check-ins'leri al
      final allCheckIns = <CheckIn>[];
      for (final goal in goals) {
        final checkIns =
            await _goalRepository.watchCheckIns(goal.id, userId).first;
        allCheckIns.addAll(checkIns);
      }

      // CSV oluştur
      final csvLines = <String>[];

      // Goals CSV
      csvLines.add(
        'ID,Başlık,Kategori,Oluşturulma Tarihi,Hedef Tarihi,İlerleme,Arşivlendi Mi',
      );
      for (final goal in goals) {
        csvLines.add([
          goal.id,
          _escapeCsv(goal.title),
          goal.category.name,
          goal.createdAt.toIso8601String(),
          goal.targetDate?.toIso8601String() ?? '',
          goal.progress.toString(),
          goal.isArchived.toString(),
        ].join(','));
      }

      if (allCheckIns.isNotEmpty) {
        csvLines.add('');
        csvLines.add(
          'CheckIn ID,Goal ID,Oluşturulma Tarihi,Skor,İlerleme Değişimi,Not',
        );
        for (final checkIn in allCheckIns) {
          csvLines.add([
            checkIn.id,
            checkIn.goalId,
            checkIn.createdAt.toIso8601String(),
            checkIn.score.toString(),
            checkIn.progressDelta.toString(),
            _escapeCsv(checkIn.note ?? ''),
          ].join(','));
        }
      }

      final csvString = csvLines.join('\n');

      // Dosyayı kaydet ve paylaş
      await _shareCsvFile(
        csvString,
        _buildBackupFileName(prefix: 'YearFlow', extension: 'csv'),
      );
    } catch (e) {
      throw Exception('Veri export edilirken hata oluştu: $e');
    }
  }

  /// JSON dosyasını paylaş ve kaydet
  Future<void> _shareJsonFile(String content, String fileName) async {
    try {
      final yearFlowDir = await _getYearFlowDirectory();

      // Dosyayı kaydet
      final savedFile = File('${yearFlowDir.path}/$fileName');
      await savedFile.writeAsString(content);

      // Paylaşım menüsünü göster
      try {
        await Share.shareXFiles(
          [XFile(savedFile.path)],
          text: 'YearFlow Veri Yedekleme',
        );
      } catch (pluginError) {
        // Plugin yüklenmemişse, dosya yolunu text olarak paylaş
        if (pluginError.toString().contains('MissingPluginException')) {
          await Share.share(
            'YearFlow Veri Yedekleme',
          );
        } else {
          rethrow;
        }
      }
    } catch (e) {
      throw Exception('Dosya kaydedilirken/paylaşılırken hata oluştu: $e');
    }
  }

  /// CSV dosyasını paylaş ve kaydet
  Future<void> _shareCsvFile(String content, String fileName) async {
    try {
      final yearFlowDir = await _getYearFlowDirectory();

      // Dosyayı kaydet
      final savedFile = File('${yearFlowDir.path}/$fileName');
      await savedFile.writeAsString(content, encoding: utf8);

      // Paylaşım menüsünü göster
      try {
        await Share.shareXFiles(
          [XFile(savedFile.path)],
          text: 'YearFlow Veri Yedekleme',
        );
      } catch (pluginError) {
        // Plugin yüklenmemişse, dosya yolunu text olarak paylaş
        if (pluginError.toString().contains('MissingPluginException')) {
          await Share.share(
            'YearFlow Veri Yedekleme',
          );
        } else {
          rethrow;
        }
      }
    } catch (e) {
      throw Exception('Dosya kaydedilirken/paylaşılırken hata oluştu: $e');
    }
  }

  /// Platforma göre kullanıcıya görünür bir YearFlow klasörü döndür
  Future<Directory> _getYearFlowDirectory() async {
    Directory baseDir;

    if (Platform.isAndroid) {
      // Android'de doğrudan ortak Downloads klasörünü hedefle
      // /storage/emulated/0/Download
      baseDir = Directory('/storage/emulated/0/Download');
    } else {
      // iOS ve diğer platformlar için uygulama döküman dizini
      baseDir = await getApplicationDocumentsDirectory();
    }

    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    return baseDir;
  }

  /// Yedekleme dosya adını oluştur (örn: YearFlow_4Aralik_2025.csv)
  String _buildBackupFileName({
    required String prefix,
    required String extension,
  }) {
    final now = DateTime.now();
    const monthNames = [
      'Ocak',
      'Subat',
      'Mart',
      'Nisan',
      'Mayis',
      'Haziran',
      'Temmuz',
      'Agustos',
      'Eylul',
      'Ekim',
      'Kasim',
      'Aralik',
    ];
    final day = now.day;
    final monthName = monthNames[now.month - 1];
    final year = now.year;

    return '${prefix}_$day${monthName}_$year.$extension';
  }

  /// CSV için özel karakterleri escape et
  String _escapeCsv(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Goal'u JSON'a çevir
  Map<String, dynamic> _goalToJson(Goal goal) {
    return {
      'id': goal.id,
      'title': goal.title,
      'category': goal.category.name,
      'createdAt': goal.createdAt.toIso8601String(),
      'targetDate': goal.targetDate?.toIso8601String(),
      'description': goal.description,
      'progress': goal.progress,
      'isArchived': goal.isArchived,
      'subGoals': goal.subGoals
          .map((sg) => {
                'id': sg.id,
                'title': sg.title,
                'isCompleted': sg.isCompleted,
                'dueDate': sg.dueDate?.toIso8601String(),
              })
          .toList(),
    };
  }

  /// CheckIn'i JSON'a çevir
  Map<String, dynamic> _checkInToJson(CheckIn checkIn) {
    return {
      'id': checkIn.id,
      'goalId': checkIn.goalId,
      'createdAt': checkIn.createdAt.toIso8601String(),
      'score': checkIn.score,
      'progressDelta': checkIn.progressDelta,
      'note': checkIn.note,
    };
  }

  /// YearlyReport'u JSON'a çevir
  Map<String, dynamic> _yearlyReportToJson(YearlyReport report) {
    return {
      'id': report.id,
      'userId': report.userId,
      'year': report.year,
      'generatedAt': report.generatedAt.toIso8601String(),
      'content': report.content,
    };
  }

  /// JSON'dan Goal oluştur (exportAllDataAsJson formatı)
  Goal _goalFromJson(Map<String, dynamic> json, String userId) {
    final categoryName = json['category'] as String?;
    final category = GoalCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => GoalCategory.personalGrowth,
    );

    final subGoalsJson = json['subGoals'] as List<dynamic>? ?? [];
    final subGoals = subGoalsJson
        .whereType<Map<String, dynamic>>()
        .map(
          (sg) => SubGoal(
            id: sg['id'] as String? ?? '',
            title: sg['title'] as String? ?? '',
            isCompleted: sg['isCompleted'] as bool? ?? false,
            dueDate: sg['dueDate'] != null &&
                    (sg['dueDate'] as String).isNotEmpty
                ? DateTime.tryParse(sg['dueDate'] as String)
                : null,
          ),
        )
        .toList();

    return Goal(
      id: json['id'] as String? ?? '',
      userId: userId,
      title: json['title'] as String? ?? '',
      category: category,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      targetDate: json['targetDate'] != null &&
              (json['targetDate'] as String).isNotEmpty
          ? DateTime.tryParse(json['targetDate'] as String)
          : null,
      description: json['description'] as String?,
      motivation: json['motivation'] as String?,
      subGoals: subGoals,
      progress: json['progress'] as int? ?? 0,
      isArchived: json['isArchived'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null &&
              (json['completedAt'] as String).isNotEmpty
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }

  /// JSON'dan CheckIn oluştur (exportAllDataAsJson formatı)
  CheckIn _checkInFromJson(Map<String, dynamic> json, String userId) {
    return CheckIn(
      id: json['id'] as String? ?? '',
      goalId: json['goalId'] as String? ?? '',
      userId: userId,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      score: json['score'] as int? ?? 0,
      progressDelta: json['progressDelta'] as int? ?? 0,
      note: json['note'] as String?,
    );
  }

  /// JSON'dan YearlyReport oluştur (exportAllDataAsJson formatı)
  YearlyReport _yearlyReportFromJson(
    Map<String, dynamic> json,
    String userId,
  ) {
    return YearlyReport(
      id: json['id'] as String? ?? '',
      userId: userId,
      year: json['year'] as int? ?? DateTime.now().year,
      generatedAt:
          DateTime.tryParse(json['generatedAt'] as String? ?? '') ??
              DateTime.now(),
      content: json['content'] as String? ?? '',
    );
  }
}
