import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/goal.dart';
import '../../../shared/providers/goal_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // Premium background color
  static const Color _premiumBackground = Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Container(
      color: _premiumBackground,
      child: CustomScrollView(
        slivers: [
          // SafeArea for status bar
          SliverSafeArea(
            bottom: false,
            sliver: SliverToBoxAdapter(
              child: _TopAppBar(),
            ),
          ),

          // Hedeflerin Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.xl,
                bottom: AppSpacing.md,
              ),
              child: Text(
                'Hedeflerin',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Goal Cards
          goalsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hedefler yüklenirken bir hata oluştu',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      error.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (goals) {
              if (goals.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.lg,
                    ),
                    child: _EmptyGoalsCard(),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= goals.length) return null;
                    final goal = goals[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        bottom: AppSpacing.md,
                      ),
                      child: _GoalCard(goal: goal),
                    );
                  },
                  childCount: goals.length,
                ),
              );
            },
          ),

          // Yaklaşan Check-in Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.xl,
                bottom: AppSpacing.md,
              ),
              child: Text(
                'Yaklaşan Check-in\'lerin',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Yaklaşan Check-in + Günün Sorusu
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: _UpcomingCheckInsSection(),
            ),
          ),

          // Bottom padding for navigation bar
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xl),
          ),
        ],
      ),
    );
  }
}

/// Top App Bar - Logo, greeting, profile button
class _TopAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Logo icon - smaller and minimal
          Icon(
            Icons.waves,
            size: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: AppSpacing.sm),
          // Greeting - bolder and better aligned
          Expanded(
            child: Text(
              'Merhaba, Akif',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Goal Card Widget with premium styling
class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final Goal goal;

  Color get _categoryColor {
    final key = goal.category.name;
    return AppColors.categoryColors[key] ?? AppColors.primary;
  }

  Color get _categoryBackgroundColor {
    final key = goal.category.name;
    return AppColors.categoryBackgroundColors[key] ??
        AppColors.primary.withOpacity(0.08);
  }

  int get _clampedProgress => goal.progress.clamp(0, 100);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.borderRadiusMd,
        onTap: () {
          context.push(AppRoutes.goalDetailPath(goal.id));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.borderRadiusMd,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                offset: const Offset(0, 4),
                blurRadius: 14,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20), // Increased padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category chip - more rounded (22px radius)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _categoryBackgroundColor,
                              borderRadius:
                                  BorderRadius.circular(22), // 22px radius
                            ),
                            child: Text(
                              goal.category.label,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: _categoryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          // Goal title
                          Text(
                            goal.title,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Progress percentage
                    Text(
                      '$_clampedProgress%',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Progress bar - fully rounded
                ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Fully rounded
                  child: LinearProgressIndicator(
                    value: _clampedProgress / 100,
                    minHeight: 10,
                    backgroundColor: AppColors.gray200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty state when user has no goals yet
class _EmptyGoalsCard extends StatelessWidget {
  const _EmptyGoalsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Henüz hedef oluşturmadın',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'İlk hedefini oluştur ve yılını daha planlı, odaklı ve anlamlı hale getir.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.push(AppRoutes.goals);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Hedef Oluştur',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Upcoming check-ins + daily question section
class _UpcomingCheckInsSection extends ConsumerWidget {
  const _UpcomingCheckInsSection();

  List<Goal> _getUpcomingGoals(List<Goal> goals) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcoming = goals.where((goal) {
      final target = goal.targetDate;
      if (target == null) return false;

      final targetDay = DateTime(target.year, target.month, target.day);
      final diff = targetDay.difference(today).inDays;
      // Bugün–önümüzdeki 7 gün arası (0–7 gün kaldı)
      return diff >= 0 && diff <= 7;
    }).toList();

    upcoming.sort((a, b) => a.targetDate!.compareTo(b.targetDate!));
    return upcoming.take(3).toList();
  }

  String _formatRemaining(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final diff = targetDay.difference(today).inDays;

    if (diff < 0) {
      if (diff == -1) return '1 gün gecikti';
      return '${-diff} gün gecikti';
    }
    if (diff == 0) return 'Bugün';
    if (diff == 1) return '1 gün kaldı';
    return '$diff gün kaldı';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsStreamProvider);

    return goalsAsync.when(
      loading: () => const _DailyQuestionCard(),
      error: (_, __) => const _DailyQuestionCard(),
      data: (goals) {
        final upcomingGoals = _getUpcomingGoals(goals);

        if (upcomingGoals.isEmpty) {
          return const _DailyQuestionCard();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF4F7FF),
                    Color(0xFFFFFFFF),
                  ],
                ),
                borderRadius: AppRadius.borderRadiusLg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 6),
                    blurRadius: 16,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bu hafta odaklanman gereken hedefler',
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Önümüzdeki 7 gün içinde tamamlanması planlanan hedeflerin',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${upcomingGoals.length} hedef',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...upcomingGoals.map((goal) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            context.push(AppRoutes.checkInPath(goal.id));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        goal.title,
                                        style:
                                            AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatRemaining(goal.targetDate!),
                                        style:
                                            AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.gray600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Check-in Yap',
                                    style:
                                        AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const _DailyQuestionCard(),
          ],
        );
      },
    );
  }
}

/// Daily Question Card with premium styling
/// Uses real goals data for starting a check-in
class _DailyQuestionCard extends ConsumerWidget {
  const _DailyQuestionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 14,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GÜNÜN SORUSU',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bugün hedeflerine ulaşmak için seni motive eden en büyük şey neydi?',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Bigger button with more padding
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  final goalsAsync = ref.read(goalsStreamProvider);

                  goalsAsync.when(
                    loading: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hedefler yükleniyor...'),
                        ),
                      );
                    },
                    error: (error, _) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Hedefler alınırken bir hata oluştu: $error',
                          ),
                        ),
                      );
                    },
                    data: (goals) {
                      if (goals.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Henüz hiç hedefin yok. Önce bir hedef oluşturmalısın.',
                            ),
                          ),
                        );
                        context.push(AppRoutes.goals);
                        return;
                      }

                      showModalBottomSheet<void>(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (sheetContext) {
                          return SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hangi hedef için check-in yapmak istersin?',
                                    style:
                                        AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Aşağıdan bir hedef seç; seni doğrudan check-in ekranına götürelim.',
                                    style:
                                        AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.gray600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Flexible(
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: goals.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(
                                        height: AppSpacing.xs,
                                      ),
                                      itemBuilder: (context, index) {
                                        final goal = goals[index];
                                        return ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          title: Text(
                                            goal.title,
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            goal.category.label,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.gray600,
                                            ),
                                          ),
                                          trailing: const Icon(
                                            Icons.chevron_right,
                                            color: AppColors.gray500,
                                          ),
                                          onTap: () {
                                            Navigator.of(sheetContext).pop();
                                            context.push(
                                              AppRoutes.checkInPath(goal.id),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  minimumSize:
                      const Size(double.infinity, 52), // Bigger button
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12), // More rounded
                  ),
                ),
                child: Text(
                  'Yanıtını Yaz',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
