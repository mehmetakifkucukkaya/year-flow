import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/index.dart';
import '../../../shared/models/goal.dart';
import '../../../shared/providers/goal_providers.dart';

class GoalsArchivePage extends ConsumerStatefulWidget {
  const GoalsArchivePage({super.key});

  @override
  ConsumerState<GoalsArchivePage> createState() =>
      _GoalsArchivePageState();
}

class _GoalsArchivePageState extends ConsumerState<GoalsArchivePage> {
  // Premium background color
  static const Color _premiumBackground = Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context) {
    final archivedGoalsAsync = ref.watch(archivedGoalsStreamProvider);

    return Container(
      color: _premiumBackground,
      child: archivedGoalsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Arşiv yüklenirken bir hata oluştu.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () {
                      ref.invalidate(archivedGoalsStreamProvider);
                    },
                    child: Text(context.l10n.tryAgain),
                  ),
                ],
              ),
            ),
          );
        },
        data: (archivedGoals) {
          // Tarihe göre sırala (en yeni önce)
          final sortedGoals = List<Goal>.from(archivedGoals)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return CustomScrollView(
            slivers: [
              // SafeArea for status bar
              SliverSafeArea(
                bottom: false,
                sliver: SliverToBoxAdapter(
                  child: _TopAppBar(),
                ),
              ),

              // Goals List
              if (sortedGoals.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final goal = sortedGoals[index];
                        return _ArchivedGoalCard(goal: goal);
                      },
                      childCount: sortedGoals.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TopAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
          Expanded(
            child: Text(
              'Tamamlanan Hedefler',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
            ),
            child: const Icon(
              Icons.archive_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Henüz tamamlanan hedef yok',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Hedeflerini tamamladıkça burada gözükecekler',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ArchivedGoalCard extends ConsumerWidget {
  const _ArchivedGoalCard({required this.goal});

  final Goal goal;

  Color _getCategoryColor(GoalCategory category) {
    switch (category) {
      case GoalCategory.health:
        return const Color(0xFF4CAF50);
      case GoalCategory.mentalHealth:
        return const Color(0xFF81C784);
      case GoalCategory.finance:
        return const Color(0xFF009688);
      case GoalCategory.career:
        return const Color(0xFF2196F3);
      case GoalCategory.relationships:
        return const Color(0xFFE91E63);
      case GoalCategory.learning:
        return const Color(0xFF9C27B0);
      case GoalCategory.creativity:
        return const Color(0xFFFF6B6B);
      case GoalCategory.hobby:
        return const Color(0xFFFF9800);
      case GoalCategory.personalGrowth:
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryColor = _getCategoryColor(goal.category);
    final completedDate =
        goal.completedAt ?? goal.targetDate ?? goal.createdAt;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat('d MMMM yyyy', locale);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 14,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push(AppRoutes.goalDetailPath(goal.id));
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Category badge and unarchive button
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            goal.category.emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            goal.category.getLocalizedLabel(context),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: categoryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Arşivden çıkarma butonu - daha güzel tasarım
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final shouldUnarchive = await showDialog<bool>(
                              context: context,
                              barrierColor: Colors.black.withOpacity(0.5),
                              builder: (context) =>
                                  _UnarchiveConfirmationDialog(
                                goalTitle: goal.title,
                              ),
                            );

                            if (shouldUnarchive == true &&
                                context.mounted) {
                              try {
                                final repository =
                                    ref.read(goalRepositoryProvider);
                                final updatedGoal = goal.copyWith(
                                  isArchived: false,
                                  isCompleted: false,
                                );
                                await repository.updateGoal(updatedGoal);

                                if (context.mounted) {
                                  ref.invalidate(
                                      archivedGoalsStreamProvider);
                                  ref.invalidate(goalsStreamProvider);
                                  AppSnackbar.showSuccess(
                                    context,
                                    message: 'Hedef arşivden çıkarıldı',
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  AppSnackbar.showError(
                                    context,
                                    message: 'Hata: $e',
                                  );
                                }
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.unarchive_outlined,
                              size: 18,
                              color: AppColors.gray700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Title
                Text(
                  goal.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                    height: 1.3,
                  ),
                ),
                // Description
                if (goal.description != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    goal.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                // Progress bar (100%)
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            categoryColor,
                            categoryColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Footer: Completed badge and date
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.15),
                            AppColors.primary.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tamamlandı',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Tamamlanma tarihi
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateFormat.format(completedDate),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.gray600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Unarchive Confirmation Dialog
class _UnarchiveConfirmationDialog extends StatelessWidget {
  const _UnarchiveConfirmationDialog({required this.goalTitle});

  final String goalTitle;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      content: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.unarchive_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Arşivden Çıkar',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '"$goalTitle" hedefini arşivden çıkarmak istediğinize emin misiniz?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(context.l10n.cancel),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(context.l10n.remove),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
