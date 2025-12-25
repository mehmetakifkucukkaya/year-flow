import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/index.dart';
import '../../../shared/models/yearly_report.dart';
import '../../../shared/providers/goal_providers.dart';

/// Rapor detay sayfası
/// Oluşturulan raporun içeriğini gösterir
class ReportDetailPage extends ConsumerWidget {
  const ReportDetailPage({
    super.key,
    required this.reportType,
    required this.content,
    this.reportId,
    this.periodStart,
    this.periodEnd,
  });

  final ReportType reportType;
  final String content;
  final String? reportId;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  static void navigate(
    BuildContext context, {
    required ReportType reportType,
    required String content,
    String? reportId,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    context.push(
      '/reports/detail',
      extra: {
        'reportType': reportType,
        'content': content,
        'reportId': reportId,
        'periodStart': periodStart,
        'periodEnd': periodEnd,
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = isDark ? AppColors.gray900 : AppColors.gray50;

    String buildTitle() {
      final l10n = context.l10n;
      switch (reportType) {
        case ReportType.weekly:
          return l10n.weeklyReportTitle;
        case ReportType.monthly:
          return l10n.monthlyReportTitle;
        case ReportType.yearly:
          return l10n.yearlyReportTitle;
      }
    }

    Future<void> handleDelete() async {
      final id = reportId;
      if (id == null) {
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusLg,
            ),
            title: Text(context.l10n.deleteReport),
            content: const Text(
              'Bu raporu silmek istediğinden emin misin? Bu işlem geri alınamaz.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(context.l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: Text(context.l10n.delete),
              ),
            ],
          );
        },
      );

      if (confirm != true) {
        return;
      }

      try {
        final userId = ref.read(currentUserIdProvider);
        if (userId == null) {
          AppSnackbar.showError(
            context,
            message: context.l10n.errorUnexpectedAuth,
          );
          return;
        }

        final repository = ref.read(goalRepositoryProvider);
        await repository.deleteReport(id, userId);

        AppSnackbar.showSuccess(
          context,
          message: context.l10n.reportDeleted,
        );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        AppSnackbar.showError(
          context,
          message: context.l10n.reportDeleteError(e.toString()),
        );
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReportHeader(
                  title: buildTitle(),
                  onBackPressed: () => context.pop(),
                  onSharePressed: () => _shareReport(context),
                  onCopyPressed: () => _copyReport(context),
                  onDeletePressed: reportId != null ? handleDelete : null,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Date range card (premium calendar card)
                if (periodStart != null && periodEnd != null)
                  _DateRangeCard(
                    label: _formatPeriod(periodStart!, periodEnd!),
                    reportType: reportType,
                  ),

                const SizedBox(height: AppSpacing.xl),

                // Structured weekly layout when possible, otherwise fallback
                if (reportType == ReportType.weekly)
                  _WeeklyStructuredContent(
                    rawContent: content,
                  )
                else
                  _PlainReportCard(
                    child: _buildReportContent(context),
                  ),
              ],
            ),
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

      // **Heading** style - ana başlıklar
      if (line.startsWith('**') &&
          line.endsWith('**') &&
          line.length > 4) {
        final title = line.substring(2, line.length - 2).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xl,
              bottom: AppSpacing.md,
            ),
            child: Text(
              title,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.gray900,
              ),
            ),
          ),
        );
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
                  child: _buildFormattedText(
                    line.substring(2),
                    baseStyle: AppTextStyles.bodyLarge.copyWith(
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
            child: _buildFormattedText(
              line,
              baseStyle: AppTextStyles.bodyLarge.copyWith(
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

/// Basit inline markdown biçimlendirme:
/// Metin içindeki **kalın** bölümleri tespit eder.
Widget _buildFormattedText(
  String text, {
  required TextStyle baseStyle,
  TextStyle? boldStyle,
}) {
  if (!text.contains('**')) {
    return Text(
      text,
      style: baseStyle,
    );
  }

  final effectiveBoldStyle = boldStyle ??
      baseStyle.copyWith(
        fontWeight: FontWeight.w600,
      );

  final segments = text.split('**');
  final spans = <InlineSpan>[];

  for (var i = 0; i < segments.length; i++) {
    final segment = segments[i];
    if (segment.isEmpty) continue;

    final isBold = i.isOdd;
    spans.add(
      TextSpan(
        text: segment,
        style: isBold ? effectiveBoldStyle : baseStyle,
      ),
    );
  }

  return Text.rich(
    TextSpan(children: spans),
  );
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({
    required this.title,
    required this.onBackPressed,
    required this.onSharePressed,
    required this.onCopyPressed,
    this.onDeletePressed,
  });

  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onCopyPressed;
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onBackPressed,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Geri',
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onSharePressed,
              icon: const Icon(Icons.ios_share_rounded),
              tooltip: 'Paylaş',
            ),
            IconButton(
              onPressed: onCopyPressed,
              icon: const Icon(Icons.copy_all_rounded),
              tooltip: 'Kopyala',
            ),
            if (onDeletePressed != null)
              IconButton(
                onPressed: onDeletePressed,
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: context.l10n.delete,
              ),
          ],
        ),
      ],
    );
  }
}

class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard({
    required this.label,
    required this.reportType,
  });

  final String label;
  final ReportType reportType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor =
        isDark ? theme.colorScheme.primary : const Color(0xFF4E89FF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderRadiusXl,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor.withOpacity(isDark ? 0.24 : 0.14),
            baseColor.withOpacity(isDark ? 0.32 : 0.24),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.32 : 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? 0.08 : 0.9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              reportType == ReportType.weekly
                  ? Icons.calendar_view_week_rounded
                  : reportType == ReportType.monthly
                      ? Icons.calendar_month_rounded
                      : Icons.calendar_today_rounded,
              size: 22,
              color: isDark ? Colors.white : baseColor,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.gray900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlainReportCard extends StatelessWidget {
  const _PlainReportCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: AppRadius.borderRadiusXl,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : const Color(0xFFF2F2F5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _WeeklyStructuredContent extends StatelessWidget {
  const _WeeklyStructuredContent({
    required this.rawContent,
  });

  final String rawContent;

  @override
  Widget build(BuildContext context) {
    final sections = _parseSections(rawContent);

    // Eğer başlıkları parse edemezsek, eski render'a geri dön
    if (sections.isEmpty) {
      return _PlainReportCard(
        child: ReportDetailPage(
          reportType: ReportType.weekly,
          content: rawContent,
        )._buildReportContent(context),
      );
    }

    final generalSummary = sections['1. Haftanın Genel Özeti'];
    final goalsProgress = sections['2. Hedeflerdeki İlerleme'];
    final challenges = sections['3. Karşılaşılan Zorluklar & Çözümler'];
    final aiSuggestions = sections['4. AI Önerileri'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (generalSummary != null)
          _SectionCard(
            title: '1. Haftanın Genel Özeti',
            body: generalSummary,
          ),
        if (goalsProgress != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            title: '2. Hedeflerdeki İlerleme',
            body: goalsProgress,
          ),
        ],
        if (challenges != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            title: '3. Karşılaşılan Zorluklar & Çözümler',
            body: challenges,
          ),
        ],
        if (aiSuggestions != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _AiInsightsCard(body: aiSuggestions),
        ],
      ],
    );
  }

  /// Basit section parser:
  /// Beklenen format:
  /// "1. Haftanın Genel Özeti\n...metin...\n\n2. Hedeflerdeki İlerleme\n..."
  Map<String, String> _parseSections(String content) {
    final lines = content.split('\n');
    final buffer = StringBuffer();
    String? currentTitle;
    final Map<String, String> result = {};

    bool isSectionTitle(String line) {
      final normalized = line.trim();
      return normalized.startsWith('1. Haftanın Genel Özeti') ||
          normalized.startsWith('2. Hedeflerdeki İlerleme') ||
          normalized.startsWith('3. Karşılaşılan Zorluklar & Çözümler') ||
          normalized.startsWith('4. AI Önerileri');
    }

    void commitSection() {
      final title = currentTitle;
      if (title != null && buffer.isNotEmpty) {
        result[title] = buffer.toString().trim();
        buffer.clear();
      }
    }

    for (final rawLine in lines) {
      final line = rawLine.trimRight();

      if (line.trim().isEmpty) {
        buffer.writeln();
        continue;
      }

      if (isSectionTitle(line)) {
        commitSection();
        currentTitle = line.trim();
      } else {
        buffer.writeln(line);
      }
    }

    commitSection();

    return result;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: AppRadius.borderRadiusXl,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFFF2F2F5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.45 : 0.08),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 21,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFormattedText(
            body,
            baseStyle: AppTextStyles.bodyLarge.copyWith(
              fontSize: 16.5,
              height: 1.6,
              color: isDark ? AppColors.gray100 : AppColors.gray800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiInsightsCard extends StatelessWidget {
  const _AiInsightsCard({
    required this.body,
  });

  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderRadiusXl,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withOpacity(isDark ? 0.32 : 0.16),
            primary.withOpacity(isDark ? 0.44 : 0.24),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(isDark ? 0.6 : 0.35),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 14),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(isDark ? 0.18 : 0.9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(isDark ? 0.16 : 0.9),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AI Önerileri',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFormattedText(
            body,
            baseStyle: AppTextStyles.bodyLarge.copyWith(
              fontSize: 16.5,
              height: 1.6,
              color: isDark ? AppColors.gray50 : AppColors.gray800,
            ),
          ),
        ],
      ),
    );
  }
}
