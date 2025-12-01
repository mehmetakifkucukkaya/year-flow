import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/check_in.dart';
import '../models/goal.dart';
import '../models/yearly_report.dart';
import 'goal_repository.dart';

/// Export service - Goals, Check-ins ve Reports'ları JSON/CSV olarak export eder
class ExportService {
  ExportService({
    required GoalRepository goalRepository,
  }) : _goalRepository = goalRepository;

  final GoalRepository _goalRepository;

  /// Tüm verileri JSON olarak export et
  Future<void> exportAllDataAsJson(String userId) async {
    try {
      // Goals'ları al
      final goals = await _goalRepository.fetchGoals(userId);

      // Her goal için check-ins'leri al
      final allCheckIns = <CheckIn>[];
      for (final goal in goals) {
        final checkIns = await _goalRepository.watchCheckIns(goal.id, userId).first;
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
        'yearlyReport': yearlyReport != null ? _yearlyReportToJson(yearlyReport) : null,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Dosyayı kaydet ve paylaş
      await _shareJsonFile(jsonString, 'yearflow_backup_${DateTime.now().millisecondsSinceEpoch}.json');
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
        'yearlyReport': yearlyReport != null ? _yearlyReportToJson(yearlyReport) : null,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Dosyayı kaydet ve paylaş
      await _shareJsonFile(jsonString, 'yearflow_goals_reports_${DateTime.now().millisecondsSinceEpoch}.json');
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
        final checkIns = await _goalRepository.watchCheckIns(goal.id, userId).first;
        allCheckIns.addAll(checkIns);
      }

      // CSV oluştur
      final csvLines = <String>[];
      
      // Goals CSV
      csvLines.add('=== GOALS ===');
      csvLines.add('ID,Title,Category,Created At,Target Date,Progress,Is Archived');
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

      csvLines.add('');
      csvLines.add('=== CHECK-INS ===');
      csvLines.add('ID,Goal ID,Created At,Score,Progress Delta,Note');
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

      final csvString = csvLines.join('\n');

      // Dosyayı kaydet ve paylaş
      await _shareCsvFile(csvString, 'yearflow_backup_${DateTime.now().millisecondsSinceEpoch}.csv');
    } catch (e) {
      throw Exception('Veri export edilirken hata oluştu: $e');
    }
  }

  /// JSON dosyasını paylaş
  Future<void> _shareJsonFile(String content, String fileName) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'YearFlow Veri Yedekleme',
      );
    } catch (e) {
      throw Exception('Dosya paylaşılırken hata oluştu: $e');
    }
  }

  /// CSV dosyasını paylaş
  Future<void> _shareCsvFile(String content, String fileName) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content, encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'YearFlow Veri Yedekleme',
      );
    } catch (e) {
      throw Exception('Dosya paylaşılırken hata oluştu: $e');
    }
  }

  /// CSV için özel karakterleri escape et
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
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
      'motivation': goal.motivation,
      'progress': goal.progress,
      'isArchived': goal.isArchived,
      'subGoals': goal.subGoals.map((sg) => {
        'id': sg.id,
        'title': sg.title,
        'isCompleted': sg.isCompleted,
        'dueDate': sg.dueDate?.toIso8601String(),
      }).toList(),
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
}

