import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/index.dart';
import '../../../shared/models/yearly_report.dart';

/// Rapor detay sayfası
/// Oluşturulan raporun içeriğini gösterir
class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({
    super.key,
    required this.reportType,
    required this.content,
    this.periodStart,
    this.periodEnd,
  });

  final ReportType reportType;
  final String content;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  static void navigate(
    BuildContext context, {
    required ReportType reportType,
    required String content,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    context.push(
      '/reports/detail',
      extra: {
        'reportType': reportType,
        'content': content,
        'periodStart': periodStart,
        'periodEnd': periodEnd,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: Text(
          '${reportType.label} Rapor',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _shareReport(context),
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Paylaş',
          ),
          IconButton(
            onPressed: () => _copyReport(context),
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Kopyala',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period info card
              if (periodStart != null && periodEnd != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: AppRadius.borderRadiusLg,
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        reportType == ReportType.weekly
                            ? Icons.calendar_view_week_rounded
                            : reportType == ReportType.monthly
                                ? Icons.calendar_month_rounded
                                : Icons.calendar_today_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _formatPeriod(periodStart!, periodEnd!),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Report content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.borderRadiusXl,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildReportContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent(BuildContext context) {
    // Simple markdown-like rendering
    // Split by lines and render headers, paragraphs, etc.
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.isEmpty) {
        widgets.add(const SizedBox(height: AppSpacing.md));
        continue;
      }

      // Headers
      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xl,
              bottom: AppSpacing.md,
            ),
            child: Text(
              line.substring(2),
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.gray900,
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.lg,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              line.substring(3),
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.md,
              bottom: AppSpacing.xs,
            ),
            child: Text(
              line.substring(4),
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray800,
              ),
            ),
          ),
        );
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        // Bullet points
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              bottom: AppSpacing.xs,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.gray800,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Regular paragraph
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              line,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.gray800,
                height: 1.6,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  String _formatPeriod(DateTime start, DateTime end) {
    if (reportType == ReportType.weekly) {
      return '${start.day}.${start.month}.${start.year} - ${end.day}.${end.month}.${end.year}';
    } else if (reportType == ReportType.monthly) {
      final monthNames = [
        'Ocak',
        'Şubat',
        'Mart',
        'Nisan',
        'Mayıs',
        'Haziran',
        'Temmuz',
        'Ağustos',
        'Eylül',
        'Ekim',
        'Kasım',
        'Aralık',
      ];
      return '${monthNames[start.month - 1]} ${start.year}';
    } else {
      return '${start.year}';
    }
  }

  void _shareReport(BuildContext context) {
    // TODO: Implement share functionality
    AppSnackbar.showInfo(
      context,
      message: 'Paylaşım özelliği yakında eklenecek',
    );
  }

  void _copyReport(BuildContext context) {
    Clipboard.setData(ClipboardData(text: content));
    AppSnackbar.showSuccess(
      context,
      message: 'Rapor kopyalandı',
    );
  }
}

