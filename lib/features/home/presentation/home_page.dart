import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/index.dart';
import '../../../shared/models/goal.dart';
import '../../../shared/providers/goal_providers.dart';
import '../../auth/providers/auth_providers.dart';

final _namePromptShownProvider = StateProvider<bool>((ref) => false);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // Premium background color
  static const Color _premiumBackground = Color(0xFFF9FAFB);

  void _maybeShowNamePrompt(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authStateProvider);
    final user = authState.currentUser;
    final hasName = (user?.displayName?.trim().isNotEmpty ?? false);
    final alreadyShown = ref.read(_namePromptShownProvider);

    if (hasName || alreadyShown) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(_namePromptShownProvider.notifier).state = true;

      final controller = TextEditingController(
        text: user?.displayName?.trim() ?? '',
      );

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusTopXl,
        ),
        builder: (sheetContext) {
          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom +
                  AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'İsmini belirleyelim',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sana ekranda adınla hitap edelim. İstemezsen bu adımı her zaman profilinden değiştirebilirsin.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: controller,
                  label: 'İsim',
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Daha sonra'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          final newName = controller.text.trim();
                          try {
                            await ref
                                .read(authStateProvider.notifier)
                                .updateProfile(
                                  displayName:
                                      newName.isEmpty ? null : newName,
                                  email: null,
                                );
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                              AppSnackbar.showSuccess(
                                context,
                                message: 'İsmin kaydedildi',
                              );
                            }
                          } catch (e) {
                            if (sheetContext.mounted) {
                              AppSnackbar.showError(
                                context,
                                message: e
                                    .toString()
                                    .replaceFirst('Exception: ', ''),
                              );
                            }
                          }
                        },
                        child: const Text('Kaydet'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsStreamProvider);
    final weeklySummaryAsync = ref.watch(weeklyCheckInSummaryProvider);

    _maybeShowNamePrompt(context, ref);

    return Container(
      color: _premiumBackground,
      child: CustomScrollView(
        slivers: [
          // SafeArea for status bar
          const SliverSafeArea(
            bottom: false,
            sliver: SliverToBoxAdapter(
              child: _TopAppBar(),
            ),
          ),

          // Haftalık Özet Kartı
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.lg,
              ),
              child: weeklySummaryAsync.when(
                loading: () => const _WeeklySummarySkeletonCard(),
                error: (_, __) => const _WeeklySummaryErrorCard(),
                data: (summary) => _WeeklySummaryCard(summary: summary),
              ),
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

              // Ana sayfada sadece son eklenen birkaç hedefi göster
              final displayGoals = goals.take(3).toList();

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= displayGoals.length) return null;
                    final goal = displayGoals[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        bottom: AppSpacing.md,
                      ),
                      child: _GoalCard(goal: goal),
                    );
                  },
                  childCount: displayGoals.length,
                ),
              );
            },
          ),

          // Yaklaşan Check-in Section (sadece yaklaşan hedef varsa göster)
          const SliverToBoxAdapter(
            child: _UpcomingCheckInsSection(),
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

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.summary});

  final WeeklyCheckInSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.6),
                ],
              ),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Haftalık özet',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bu hafta toplam ${summary.checkInCount} check-in ile '
                  '${summary.goalsWithProgress} farklı hedefte ilerleme kaydettin.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklySummarySkeletonCard extends StatelessWidget {
  const _WeeklySummarySkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusLg,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: 70,
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklySummaryErrorCard extends StatelessWidget {
  const _WeeklySummaryErrorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: AppColors.gray500,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Bu haftanın özeti şu an yüklenemedi. Birazdan tekrar dene.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Top App Bar - Logo, greeting, profile button
class _TopAppBar extends ConsumerWidget {
  const _TopAppBar();

  String _buildGreeting(String? displayName) {
    final now = DateTime.now();
    final hour = now.hour;

    String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Günaydın';
    } else if (hour < 18) {
      timeGreeting = 'Merhaba';
    } else {
      timeGreeting = 'İyi akşamlar';
    }

    final name = (displayName?.trim().isNotEmpty ?? false)
        ? displayName!.trim()
        : 'KUllanıcı';

    return '$timeGreeting, $name';
  }

  String _buildInitials(String? displayName) {
    if (displayName == null || displayName.trim().isEmpty) {
      return 'YF';
    }

    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }

    final first = parts.first.characters.first.toString();
    final last = parts.last.characters.first.toString();
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.currentUser;
    final greeting = _buildGreeting(user?.displayName);

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
                greeting,
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Bugün nasıl geçiyor?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Goal Card Widget with premium styling and detailed information
class _GoalCard extends ConsumerWidget {
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

  String _formatTargetDate(DateTime? targetDate) {
    if (targetDate == null) return 'Hedef tarihi belirtilmemiş';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    final diff = targetDay.difference(today).inDays;

    if (diff < 0) {
      if (diff == -1) return '1 gün gecikti';
      return '${-diff} gün gecikti';
    }
    if (diff == 0) return 'Bugün';
    if (diff == 1) return '1 gün kaldı';
    if (diff < 7) return '$diff gün kaldı';

    // Tarih formatı
    final months = [
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
      'Aralık'
    ];
    return '${targetDate.day} ${months[targetDate.month - 1]} ${targetDate.year}';
  }

  int _getRemainingTasksCount() {
    if (goal.subGoals.isEmpty) return 0;
    final completed = goal.subGoals.where((sg) => sg.isCompleted).length;
    return goal.subGoals.length - completed;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInsAsync = ref.watch(checkInsStreamProvider(goal.id));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.borderRadiusLg,
        onTap: () {
          context.push(AppRoutes.goalDetailPath(goal.id));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.borderRadiusLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 4),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Category and Progress
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _categoryBackgroundColor,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  goal.category.emoji,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  goal.category.label,
                                  style:
                                      AppTextStyles.labelMedium.copyWith(
                                    color: _categoryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          // Goal title
                          Text(
                            goal.title,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Progress percentage
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_clampedProgress%',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _categoryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                // Description (if available)
                if (goal.description != null &&
                    goal.description!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    goal.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: AppSpacing.sm),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _clampedProgress / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.gray200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_categoryColor),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Details row: Remaining tasks, Check-ins, Target date
                Row(
                  children: [
                    // Remaining tasks (only if there are remaining tasks)
                    if (_getRemainingTasksCount() > 0) ...[
                      Expanded(
                        child: _DetailItem(
                          icon: Icons.checklist_rounded,
                          text: '${_getRemainingTasksCount()} görev kaldı',
                          color: AppColors.gray700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    // Check-ins count
                    checkInsAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (checkIns) => Expanded(
                        child: _DetailItem(
                          icon: Icons.track_changes_rounded,
                          text: '${checkIns.length} check-in',
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                  ],
                ),

                // Target date
                if (goal.targetDate != null)
                  _DetailItem(
                    icon: Icons.calendar_today_rounded,
                    text: _formatTargetDate(goal.targetDate),
                    color: goal.targetDate!.isBefore(DateTime.now())
                        ? AppColors.error
                        : AppColors.gray700,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Detail item widget for goal card
class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

      // targetDate yoksa gösterilmez
      if (target == null) return false;

      final targetDay = DateTime(target.year, target.month, target.day);
      final diff = targetDay.difference(today).inDays;
      // 7 günden az kalmış hedefler (geçmişte kalanlar dahil, bugün ve önümüzdeki 7 gün)
      // -7 gün (1 hafta önce) ile +7 gün (1 hafta sonra) arası
      return diff >= -7 && diff <= 7;
    }).toList();

    // Sıralama: önce geçmişte kalanlar (en yakın olanlar önce), sonra gelecekteki hedefler
    upcoming.sort((a, b) {
      final diffA = DateTime(
              a.targetDate!.year, a.targetDate!.month, a.targetDate!.day)
          .difference(today)
          .inDays;
      final diffB = DateTime(
              b.targetDate!.year, b.targetDate!.month, b.targetDate!.day)
          .difference(today)
          .inDays;

      // Geçmişte kalanlar önce (negatif değerler), sonra gelecekteki hedefler
      if (diffA < 0 && diffB >= 0) return -1;
      if (diffA >= 0 && diffB < 0) return 1;
      // Aynı kategorideyse (ikisi de geçmişte veya ikisi de gelecekte), yakın olan önce
      return diffA.abs().compareTo(diffB.abs());
    });

    return upcoming.take(3).toList();
  }

  String _formatRemaining(DateTime? targetDate) {
    if (targetDate == null) {
      return 'Check-in yap';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
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
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (goals) {
        final upcomingGoals = _getUpcomingGoals(goals);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Padding(
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
            // İçerik
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Eğer yaklaşan hedef yoksa bilgilendirici mesaj göster
                  if (upcomingGoals.isEmpty)
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
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Hedeflerinin bitmesine 7 gün kalınca burada gözükecekler',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.gray700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
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
                                      color: AppColors.primary
                                          .withOpacity(0.12),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Yaklaşan check-in\'lerin',
                                          style: AppTextStyles.titleSmall
                                              .copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '7 günden az kalmış hedeflerin check-in\'lerini yap',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
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
                                      color: AppColors.primary
                                          .withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${upcomingGoals.length} hedef',
                                      style: AppTextStyles.labelSmall
                                          .copyWith(
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
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.xs),
                                  child: Material(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    child: InkWell(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      onTap: () {
                                        context.push(AppRoutes.checkInPath(
                                            goal.id));
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    goal.title,
                                                    style: AppTextStyles
                                                        .bodyMedium
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                  ),
                                                  const SizedBox(
                                                      height: 2),
                                                  Text(
                                                    _formatRemaining(
                                                        goal.targetDate),
                                                    style: AppTextStyles
                                                        .bodySmall
                                                        .copyWith(
                                                      color: AppColors
                                                          .gray600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                                width: AppSpacing.sm),
                                            Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withOpacity(0.08),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        999),
                                              ),
                                              child: Text(
                                                'Check-in Yap',
                                                style: AppTextStyles
                                                    .labelSmall
                                                    .copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight:
                                                      FontWeight.w600,
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
                    ),
                ],
              ),
            ),
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
    final now = DateTime.now();
    // Haftada sadece 1 kez, Pazar günleri göster
    if (now.weekday != DateTime.sunday) {
      return const SizedBox.shrink();
    }

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
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
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
                                            Navigator.of(sheetContext)
                                                .pop();
                                            context.push(
                                              AppRoutes.checkInPath(
                                                  goal.id),
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
