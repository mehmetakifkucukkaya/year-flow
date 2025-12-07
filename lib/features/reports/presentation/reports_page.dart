import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/index.dart';
import '../../../shared/models/check_in.dart';
import '../../../shared/models/goal.dart';
import '../../../shared/models/yearly_report.dart';
import '../../../shared/providers/ai_providers.dart';
import '../../../shared/providers/goal_providers.dart';
import '../providers/reports_providers.dart';
import 'report_detail_page.dart';

/// Raporlar ana sayfası
///
/// Tasarım referansı: `designs/ai_yıllık_rapor_ekranı/screen.png`
class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  // Premium background color
  static const Color _premiumBackground = Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: _premiumBackground,
      child: const CustomScrollView(
        slivers: [
          // Status bar alanı için safe area
          SliverSafeArea(
            bottom: false,
            sliver: SliverToBoxAdapter(
              child: _ReportsTopAppBar(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeaderHero(),
                  SizedBox(height: AppSpacing.xl),
                  _OverviewSection(),
                  SizedBox(height: AppSpacing.xl),
                  _CategoryProgressSection(),
                  SizedBox(height: AppSpacing.xl),
                  _AchievementsSection(),
                  SizedBox(height: AppSpacing.xl),
                  _ChallengesSection(),
                  SizedBox(height: AppSpacing.xl),
                  _AiSuggestionsSection(),
                  SizedBox(height: AppSpacing.xl),
                  _ReportsHistorySection(),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xl),
          ),
        ],
      ),
    );
  }
}

/// Üst app bar – export butonu
class _ReportsTopAppBar extends ConsumerWidget {
  const _ReportsTopAppBar();

  void _showExportOptionsDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ReportsExportBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.reports,
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.yearlyPerformanceSummary,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                _showExportOptionsDialog(context, ref);
              },
              icon: const Icon(Icons.download_rounded),
              iconSize: 22,
              color: AppColors.gray700,
              padding: const EdgeInsets.all(12),
              tooltip: context.l10n.downloadReport,
            ),
          ),
        ],
      ),
    );
  }
}

/// Başlığın altında premium hero alanı
class _HeaderHero extends ConsumerWidget {
  const _HeaderHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final statsAsync = ref.watch(reportsStatsProvider);
    final reportsAsync = ref.watch(reportsHistoryProvider);

    final now = DateTime.now();
    Report? currentYearReport;

    reportsAsync.maybeWhen(
      data: (reports) {
        for (final report in reports) {
          if (report.reportType == ReportType.yearly &&
              report.periodStart.year == now.year) {
            currentYearReport = report;
            break;
          }
        }
      },
      orElse: () {},
    );

    final hasCurrentYearReport = currentYearReport != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderRadiusXl,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.12),
            const Color(0xFFEEF2FF),
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.yourYearlyReport(DateTime.now().year),
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontSize:
                  MediaQuery.of(context).size.width < 360 ? 24 : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.letsTakeOverview,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray700,
              fontSize:
                  MediaQuery.of(context).size.width < 360 ? 13 : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isSmallScreen = screenWidth < 380;
                final buttonText = hasCurrentYearReport
                    ? context.l10n.openReport
                    : context.l10n.createReport;

                // Küçük ekranlarda sadece icon butonu
                if (isSmallScreen && screenWidth < 340) {
                  return FilledButton(
                    onPressed: () {
                      final report = currentYearReport;
                      if (report != null) {
                        ReportDetailPage.navigate(
                          context,
                          reportType: report.reportType,
                          content: report.content,
                          reportId: report.id,
                          periodStart: report.periodStart,
                          periodEnd: report.periodEnd,
                        );
                      } else {
                        _showCreateReportDialog(context, ref);
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      minimumSize: const Size(48, 48),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusFull,
                      ),
                    ),
                    child: const Icon(Icons.add_rounded, size: 20),
                  );
                }

                // Küçük ekranlarda da tam metin göster
                if (isSmallScreen) {
                  return FilledButton.icon(
                    onPressed: () {
                      final report = currentYearReport;
                      if (report != null) {
                        ReportDetailPage.navigate(
                          context,
                          reportType: report.reportType,
                          content: report.content,
                          reportId: report.id,
                          periodStart: report.periodStart,
                          periodEnd: report.periodEnd,
                        );
                      } else {
                        _showCreateReportDialog(context, ref);
                      }
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(
                      buttonText,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusFull,
                      ),
                    ),
                  );
                }

                // Normal ekranlarda tam metin
                return FilledButton.icon(
                  onPressed: () {
                    final report = currentYearReport;
                    if (report != null) {
                      ReportDetailPage.navigate(
                        context,
                        reportType: report.reportType,
                        content: report.content,
                        reportId: report.id,
                        periodStart: report.periodStart,
                        periodEnd: report.periodEnd,
                      );
                    } else {
                      _showCreateReportDialog(context, ref);
                    }
                  },
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(
                    buttonText,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusFull,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          statsAsync.maybeWhen(
            orElse: () => const SizedBox.shrink(),
            data: (stats) {
              final completionRate = stats.totalGoals > 0
                  ? ((stats.completedGoals / stats.totalGoals) * 100)
                      .round()
                  : 0;
              final l10n = context.l10n;
              final message = completionRate >= 75
                  ? l10n.greatYear
                  : completionRate >= 50
                      ? l10n.goodProgress
                      : l10n.continueJourney;
              return Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray700,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Genel Bakış kartı
class _OverviewSection extends ConsumerWidget {
  const _OverviewSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final statsAsync = ref.watch(reportsStatsProvider);

    return statsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.borderRadiusXl,
        ),
        child: Text(context.l10n.errorLoadingData(error.toString())),
      ),
      data: (stats) {
        final completionRate = stats.totalGoals > 0
            ? ((stats.completedGoals / stats.totalGoals) * 100).round()
            : 0;

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF5F7FF),
                Color(0xFFEFFBFF),
              ],
            ),
            borderRadius: AppRadius.borderRadiusXl,
            border: Border.all(color: AppColors.gray200.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.overview,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: context.l10n.totalGoals,
                      value: '${stats.totalGoals}',
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      label: context.l10n.completionRate,
                      value: '$completionRate%',
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: context.l10n.checkIn,
                      value: '${stats.totalCheckIns}',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      label: context.l10n.averageProgress,
                      value: '${stats.averageProgress.round()}%',
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                context.l10n.yearlyProgress,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: AppRadius.borderRadiusFull,
                child: LinearProgressIndicator(
                  value: stats.averageProgress / 100,
                  backgroundColor: AppColors.gray200,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.98),
            const Color(0xFFF5F7FF),
          ],
        ),
        borderRadius: AppRadius.borderRadiusXl,
        border: Border.all(color: AppColors.gray200.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 4,
            offset: const Offset(-1, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kategori Bazlı Gelişim
class _CategoryProgressSection extends ConsumerWidget {
  const _CategoryProgressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(reportsStatsProvider);

    return statsAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.borderRadiusXl,
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.borderRadiusXl,
        ),
        child: Text(context.l10n.errorLoadingData(error.toString())),
      ),
      data: (stats) {
        final categories = stats.categoryProgress.entries.map((entry) {
          return _CategoryProgressData(
            label: entry.key.label,
            value: entry.value / 100,
          );
        }).toList();

        if (categories.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.borderRadiusXl,
            ),
            child: Text(
              context.l10n.noCategoryData,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.borderRadiusXl,
            border: Border.all(color: AppColors.gray200),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.categoryBasedDevelopment,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final item in categories) ...[
                _CategoryProgressRow(data: item),
                if (item != categories.last)
                  const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CategoryProgressData {
  const _CategoryProgressData({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}

class _CategoryProgressRow extends StatelessWidget {
  const _CategoryProgressRow({required this.data});

  final _CategoryProgressData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                data.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(data.value * 100).round()}%',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.gray200,
                borderRadius: AppRadius.borderRadiusFull,
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth * data.value;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 10,
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.borderRadiusFull,
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Başarılar
class _AchievementsSection extends ConsumerWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(reportsStatsProvider);

    return statsAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.borderRadiusXl,
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.borderRadiusXl,
        ),
        child: Text(context.l10n.errorLoadingData(error.toString())),
      ),
      data: (stats) {
        if (stats.totalGoals == 0) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.borderRadiusXl,
            ),
            child: Text(
              context.l10n.noAchievementData,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
          );
        }

        final completionRate = stats.totalGoals > 0
            ? ((stats.completedGoals / stats.totalGoals) * 100).round()
            : 0;

        // En yüksek ortalama ilerlemeye sahip 1–2 kategori
        final topCategories = stats.categoryProgress.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final leadingCategories = topCategories.take(2).toList();

        final achievements = <String>[];

        final l10n = context.l10n;
        achievements.add(
          l10n.thisYearWorkedOnGoals(
            stats.totalGoals,
            stats.completedGoals,
            completionRate,
          ),
        );

        achievements.add(
          l10n.averageProgressLevel(stats.averageProgress.round()),
        );

        if (leadingCategories.isNotEmpty) {
          final primary = leadingCategories.first;
          final primaryValue = primary.value.round();

          var text = l10n.strongestProgressInCategory(
            primary.key.label,
            primaryValue,
          );

          if (leadingCategories.length > 1) {
            final secondary = leadingCategories[1];
            final secondaryValue = secondary.value.round();
            text += l10n.reachedLevelInCategory(
              secondaryValue,
              secondary.key.label,
            );
          } else {
            text += '.';
          }

          achievements.add(text);
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.borderRadiusXl,
            border: Border.all(color: AppColors.gray200),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.achievements,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final item in achievements) ...[
                _AchievementCard(text: item),
                if (item != achievements.last)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderRadiusLg,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF7FBFF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Zorluklar & Çözümler
class _ChallengesSection extends ConsumerWidget {
  const _ChallengesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(reportsStatsProvider);

    return statsAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.borderRadiusXl,
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.borderRadiusXl,
        ),
        child: Text(context.l10n.errorLoadingData(error.toString())),
      ),
      data: (stats) {
        if (stats.totalGoals == 0) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.borderRadiusXl,
            ),
            child: Text(
              context.l10n.goalAndCheckInDataNeeded,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
          );
        }

        // En düşük ortalama ilerlemeye sahip 1–2 kategori
        final entries = stats.categoryProgress.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

        final lowCategories = entries.where((e) => e.value < 50).toList();

        final l10n = context.l10n;
        final items = <_ChallengeData>[];

        if (lowCategories.isNotEmpty) {
          final first = lowCategories.first;
          final value = first.value.round();
          items.add(
            _ChallengeData(
              title: l10n.challengeLowProgress(first.key.label, value),
              solution: l10n.solutionAddActions,
            ),
          );
        }

        if (lowCategories.length > 1) {
          final second = lowCategories[1];
          final value = second.value.round();
          items.add(
            _ChallengeData(
              title:
                  l10n.challengeFocusDifficulty(second.key.label, value),
              solution: l10n.solutionBreakDownGoals,
            ),
          );
        }

        if (items.isEmpty) {
          items.add(
            _ChallengeData(
              title: l10n.generalStatusHealthy,
              solution: l10n.solutionReviewPriorities,
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.borderRadiusXl,
            border: Border.all(color: AppColors.gray200),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.challengesAndSolutions,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final item in items) ...[
                _ChallengeCard(data: item),
                if (item != items.last)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ChallengeData {
  const _ChallengeData({
    required this.title,
    required this.solution,
  });

  final String title;
  final String solution;
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.data});

  final _ChallengeData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderRadiusLg,
        color: const Color(0xFFFEF9F3),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warning.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.report_problem_rounded,
                  color: AppColors.warning,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Divider(
                      height: 20,
                      thickness: 0.7,
                      color: Color(0xFFFFE0B2),
                    ),
                    Text(
                      data.solution,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.gray800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBulletRow extends StatelessWidget {
  const _IconBulletRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray800,
            ),
          ),
        ),
      ],
    );
  }
}

/// AI Önerileri kartı
class _AiSuggestionsSection extends StatelessWidget {
  const _AiSuggestionsSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderRadiusXl,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.12),
            const Color(0xFFF9F5FF),
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                context.l10n.aiSuggestions,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.aiSuggestionExample,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reports Export Bottom Sheet
class _ReportsExportBottomSheet extends ConsumerStatefulWidget {
  const _ReportsExportBottomSheet();

  @override
  ConsumerState<_ReportsExportBottomSheet> createState() =>
      _ReportsExportBottomSheetState();
}

class _ReportsExportBottomSheetState
    extends ConsumerState<_ReportsExportBottomSheet> {
  bool _isLoading = false;

  Future<void> _handleExport(String format) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      AppSnackbar.showError(context, message: context.l10n.loginRequired);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final exportService = ref.read(exportServiceProvider);

      if (format == 'json') {
        await exportService.exportGoalsAndReportsAsJson(userId);
      } else {
        await exportService.exportGoalsAndReportsAsCsv(userId);
      }

      if (mounted) {
        AppSnackbar.showSuccess(
          context,
          message: context.l10n.reportExportedSuccessfully,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.exportReport,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.selectFormat,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _isLoading ? null : () => _handleExport('json'),
                  icon: const Icon(Icons.code_rounded),
                  label: Text(context.l10n.json),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                      color: AppColors.gray300,
                      width: 1.5,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusLg,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _isLoading ? null : () => _handleExport('csv'),
                  icon: const Icon(Icons.table_chart_rounded),
                  label: Text(context.l10n.csv),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                      color: AppColors.gray300,
                      width: 1.5,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusLg,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading) ...[
            const SizedBox(height: AppSpacing.md),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Create Report Dialog - Allows user to create weekly, monthly, or yearly reports
void _showCreateReportDialog(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const _CreateReportBottomSheet(),
  );
}

class _CreateReportBottomSheet extends ConsumerStatefulWidget {
  const _CreateReportBottomSheet();

  @override
  ConsumerState<_CreateReportBottomSheet> createState() =>
      _CreateReportBottomSheetState();
}

class _CreateReportBottomSheetState
    extends ConsumerState<_CreateReportBottomSheet> {
  ReportType? _selectedType;
  bool _isGenerating = false;

  Report? _findExistingReport(
    List<Report> reports, {
    required ReportType type,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    for (final report in reports) {
      if (report.reportType != type) continue;

      final start = report.periodStart;
      final end = report.periodEnd;

      switch (type) {
        case ReportType.weekly:
          final sameStartDay = start.year == periodStart.year &&
              start.month == periodStart.month &&
              start.day == periodStart.day;
          final sameEndDay = end.year == periodEnd.year &&
              end.month == periodEnd.month &&
              end.day == periodEnd.day;
          if (sameStartDay && sameEndDay) {
            return report;
          }
          break;
        case ReportType.monthly:
          if (start.year == periodStart.year &&
              start.month == periodStart.month) {
            return report;
          }
          break;
        case ReportType.yearly:
          if (start.year == periodStart.year) {
            return report;
          }
          break;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _selectedType = ReportType.weekly;
  }

  Future<void> _generateReport() async {
    if (_selectedType == null) return;

    setState(() => _isGenerating = true);

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        AppSnackbar.showError(context,
            message: context.l10n.loginRequired);
        return;
      }

      final goalsAsync = ref.read(goalsStreamProvider);
      final goals = goalsAsync.when(
        data: (goals) => goals,
        loading: () => <Goal>[],
        error: (_, __) => <Goal>[],
      );

      if (goals.isEmpty) {
        AppSnackbar.showError(
          context,
          message: context.l10n.atLeastOneGoalRequired,
        );
        return;
      }

      // Get check-ins for the period
      final allCheckInsFutures = goals.map((goal) async {
        final checkInsAsync = ref.read(checkInsStreamProvider(goal.id));
        return checkInsAsync.when(
          data: (checkIns) => checkIns,
          loading: () => <CheckIn>[],
          error: (_, __) => <CheckIn>[],
        );
      }).toList();

      final allCheckInsResults = await Future.wait(allCheckInsFutures);
      final allCheckIns =
          allCheckInsResults.expand((checkIns) => checkIns).toList();

      // Var olan raporları oku (AI çağrısından önce)
      final repository = ref.read(goalRepositoryProvider);
      final existingReports =
          await repository.watchAllReports(userId).first;

      final aiService = ref.read(aiServiceProvider);
      String content;

      final now = DateTime.now();
      DateTime periodStart;
      DateTime periodEnd;

      switch (_selectedType!) {
        case ReportType.weekly:
          // This week (Monday to Sunday)
          final monday = now.subtract(Duration(days: now.weekday - 1));
          periodStart = DateTime(monday.year, monday.month, monday.day);
          periodEnd = periodStart
              .add(const Duration(days: 6, hours: 23, minutes: 59));

          final weekCheckIns = allCheckIns.where((ci) {
            return ci.createdAt.isAfter(
                    periodStart.subtract(const Duration(days: 1))) &&
                ci.createdAt
                    .isBefore(periodEnd.add(const Duration(days: 1)));
          }).toList();

          final existingWeekly = _findExistingReport(
            existingReports,
            type: ReportType.weekly,
            periodStart: periodStart,
            periodEnd: periodEnd,
          );

          if (existingWeekly != null) {
            Navigator.of(context).pop();
            ReportDetailPage.navigate(
              context,
              reportType: existingWeekly.reportType,
              content: existingWeekly.content,
              reportId: existingWeekly.id,
              periodStart: existingWeekly.periodStart,
              periodEnd: existingWeekly.periodEnd,
            );
            return;
          }

          content = await aiService.generateWeeklyReport(
            userId: userId,
            weekStart: periodStart,
            weekEnd: periodEnd,
            goals: goals,
            checkIns: weekCheckIns,
          );
          break;

        case ReportType.monthly:
          periodStart = DateTime(now.year, now.month, 1);
          periodEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

          final monthCheckIns = allCheckIns.where((ci) {
            return ci.createdAt.year == now.year &&
                ci.createdAt.month == now.month;
          }).toList();

          final existingMonthly = _findExistingReport(
            existingReports,
            type: ReportType.monthly,
            periodStart: periodStart,
            periodEnd: periodEnd,
          );

          if (existingMonthly != null) {
            Navigator.of(context).pop();
            ReportDetailPage.navigate(
              context,
              reportType: existingMonthly.reportType,
              content: existingMonthly.content,
              reportId: existingMonthly.id,
              periodStart: existingMonthly.periodStart,
              periodEnd: existingMonthly.periodEnd,
            );
            return;
          }

          content = await aiService.generateMonthlyReport(
            userId: userId,
            year: now.year,
            month: now.month,
            goals: goals,
            checkIns: monthCheckIns,
          );
          break;

        case ReportType.yearly:
          periodStart = DateTime(now.year, 1, 1);
          periodEnd = DateTime(now.year, 12, 31, 23, 59, 59);

          final yearCheckIns = allCheckIns.where((ci) {
            return ci.createdAt.year == now.year;
          }).toList();

          final existingYearly = _findExistingReport(
            existingReports,
            type: ReportType.yearly,
            periodStart: periodStart,
            periodEnd: periodEnd,
          );

          if (existingYearly != null) {
            Navigator.of(context).pop();
            ReportDetailPage.navigate(
              context,
              reportType: existingYearly.reportType,
              content: existingYearly.content,
              reportId: existingYearly.id,
              periodStart: existingYearly.periodStart,
              periodEnd: existingYearly.periodEnd,
            );
            return;
          }

          content = await aiService.generateYearlyReport(
            userId: userId,
            year: now.year,
            goals: goals,
            checkIns: yearCheckIns,
          );
          break;
      }

      // Save report to repository
      if (mounted && content.isNotEmpty) {
        final repository = ref.read(goalRepositoryProvider);
        final report = Report(
          id: '${_selectedType!.name}-${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          reportType: _selectedType!,
          periodStart: periodStart,
          periodEnd: periodEnd,
          generatedAt: DateTime.now(),
          content: content,
        );

        await repository.saveReport(report);

        Navigator.of(context).pop(); // Close bottom sheet
        ReportDetailPage.navigate(
          context,
          reportType: _selectedType!,
          content: content,
          reportId: report.id,
          periodStart: periodStart,
          periodEnd: periodEnd,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          message: context.l10n.errorCreatingReport(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Rapor Oluştur',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.selectReportType,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...ReportType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                borderRadius: AppRadius.borderRadiusLg,
                onTap: () {
                  setState(() => _selectedType = type);
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _selectedType == type
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.gray50,
                    borderRadius: AppRadius.borderRadiusLg,
                    border: Border.all(
                      color: _selectedType == type
                          ? AppColors.primary
                          : AppColors.gray200,
                      width: _selectedType == type ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        type == ReportType.weekly
                            ? Icons.calendar_view_week_rounded
                            : type == ReportType.monthly
                                ? Icons.calendar_month_rounded
                                : Icons.calendar_today_rounded,
                        color: _selectedType == type
                            ? AppColors.primary
                            : AppColors.gray700,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.getLocalizedLabel(context),
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _selectedType == type
                                    ? AppColors.primary
                                    : AppColors.gray900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              type == ReportType.weekly
                                  ? context.l10n.thisWeekSummary
                                  : type == ReportType.monthly
                                      ? context.l10n.thisMonthSummary
                                      : context.l10n.thisYearSummary,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedType == type)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isGenerating ? null : _generateReport,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusLg,
                ),
              ),
              child: _isGenerating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Rapor Oluştur',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Geçmiş Raporlar Bölümü
class _ReportsHistorySection extends ConsumerWidget {
  const _ReportsHistorySection();

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = context.l10n;
    final day = date.day;
    final month = date.month;
    final year = date.year;
    final monthNames = [
      l10n.january,
      l10n.february,
      l10n.march,
      l10n.april,
      l10n.may,
      l10n.june,
      l10n.july,
      l10n.august,
      l10n.september,
      l10n.october,
      l10n.november,
      l10n.december,
    ];
    return '$day ${monthNames[month - 1]} $year';
  }

  String _formatPeriod(BuildContext context, Report report) {
    final l10n = context.l10n;
    if (report.reportType == ReportType.weekly) {
      return '${report.periodStart.day}.${report.periodStart.month}.${report.periodStart.year} - ${report.periodEnd.day}.${report.periodEnd.month}.${report.periodEnd.year}';
    } else if (report.reportType == ReportType.monthly) {
      final monthNames = [
        l10n.january,
        l10n.february,
        l10n.march,
        l10n.april,
        l10n.may,
        l10n.june,
        l10n.july,
        l10n.august,
        l10n.september,
        l10n.october,
        l10n.november,
        l10n.december,
      ];
      return '${monthNames[report.periodStart.month - 1]} ${report.periodStart.year}';
    } else {
      return '${report.periodStart.year}';
    }
  }

  String _getReportTitle(BuildContext context, Report report) {
    final l10n = context.l10n;
    return l10n.reportTypeLabel(
      report.reportType.getLocalizedLabel(context),
      _formatPeriod(context, report),
    );
  }

  IconData _getReportIcon(ReportType type) {
    switch (type) {
      case ReportType.weekly:
        return Icons.calendar_view_week_rounded;
      case ReportType.monthly:
        return Icons.calendar_month_rounded;
      case ReportType.yearly:
        return Icons.calendar_today_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsHistoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return reportsAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.borderRadiusXl,
          border: Border.all(color: AppColors.gray200),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.borderRadiusXl,
          border: Border.all(color: AppColors.gray200),
        ),
        child: Text(
          context.l10n.reportsLoadingError(error.toString()),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.gray600,
          ),
        ),
      ),
      data: (reports) {
        if (reports.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.borderRadiusXl,
              border: Border.all(color: AppColors.gray200),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: 48,
                  color: AppColors.gray400,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Henüz rapor oluşturulmamış',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.createFirstReportInstruction,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.borderRadiusXl,
            border: Border.all(color: AppColors.gray200),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    context.l10n.pastReports,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...reports.map((report) {
                return _ReportHistoryItem(
                  report: report,
                  title: _getReportTitle(context, report),
                  date: _formatDate(context, report.generatedAt),
                  icon: _getReportIcon(report.reportType),
                  onTap: () {
                    ReportDetailPage.navigate(
                      context,
                      reportType: report.reportType,
                      content: report.content,
                      reportId: report.id,
                      periodStart: report.periodStart,
                      periodEnd: report.periodEnd,
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ReportHistoryItem extends StatelessWidget {
  const _ReportHistoryItem({
    required this.report,
    required this.title,
    required this.date,
    required this.icon,
    required this.onTap,
  });

  final Report report;
  final String title;
  final String date;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderRadiusLg,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: AppRadius.borderRadiusLg,
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: AppRadius.borderRadiusLg,
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    date,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}
