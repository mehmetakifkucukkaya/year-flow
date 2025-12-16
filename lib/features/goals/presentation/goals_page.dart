import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/models/goal.dart';
import '../../../shared/providers/goal_providers.dart';

enum _SortOption {
  newest,
  oldest,
  progressHigh,
  progressLow,
  titleAsc,
  titleDesc,
}

enum _FilterOption {
  all,
  health,
  mentalHealth,
  finance,
  career,
  relationships,
  learning,
  creativity,
  hobby,
  personalGrowth,
}

class GoalsPage extends ConsumerStatefulWidget {
  const GoalsPage({super.key});

  @override
  ConsumerState<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage>
    with SingleTickerProviderStateMixin {
  // Premium background color
  static const Color _premiumBackground = Color(0xFFF9FAFB);

  _SortOption _sortOption = _SortOption.newest;
  _FilterOption _filterOption = _FilterOption.all;
  late TabController _tabController;
  int _selectedTabIndex = 0; // 0: Aktif, 1: Tamamlanan

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Goal> _filterAndSortGoals(List<Goal> goals) {
    // Filtrele
    var filtered = goals;
    if (_filterOption != _FilterOption.all) {
      final category = _filterOptionToCategory(_filterOption);
      filtered = goals.where((g) => g.category == category).toList();
    }

    // Sırala
    switch (_sortOption) {
      case _SortOption.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _SortOption.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case _SortOption.progressHigh:
        filtered.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case _SortOption.progressLow:
        filtered.sort((a, b) => a.progress.compareTo(b.progress));
        break;
      case _SortOption.titleAsc:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case _SortOption.titleDesc:
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
    }

    return filtered;
  }

  GoalCategory? _filterOptionToCategory(_FilterOption option) {
    switch (option) {
      case _FilterOption.all:
        return null;
      case _FilterOption.health:
        return GoalCategory.health;
      case _FilterOption.mentalHealth:
        return GoalCategory.mentalHealth;
      case _FilterOption.finance:
        return GoalCategory.finance;
      case _FilterOption.career:
        return GoalCategory.career;
      case _FilterOption.relationships:
        return GoalCategory.relationships;
      case _FilterOption.learning:
        return GoalCategory.learning;
      case _FilterOption.creativity:
        return GoalCategory.creativity;
      case _FilterOption.hobby:
        return GoalCategory.hobby;
      case _FilterOption.personalGrowth:
        return GoalCategory.personalGrowth;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tüm hedefleri al (aktif ve tamamlanan)
    final allGoalsAsync = ref.watch(allGoalsStreamProvider);

    return Container(
      color: _premiumBackground,
      child: allGoalsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) {
          // Hata detaylarını logla
          debugPrint('GoalsPage error: $error');
          debugPrint('Stack trace: $stackTrace');

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
                    context.l10n.goalsLoadingError,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () {
                      // Stream'i yeniden başlat
                      ref.invalidate(goalsStreamProvider);
                    },
                    child: Text(context.l10n.tryAgain),
                  ),
                ],
              ),
            ),
          );
        },
        data: (allGoals) {
          // Aktif ve tamamlanan hedefleri ayır
          final activeGoals = allGoals
              .where((g) => !g.isArchived && !g.isCompleted)
              .toList();
          final completedGoals = allGoals
              .where((g) => g.isArchived && g.isCompleted)
              .toList();

          // Seçili tab'a göre hedefleri filtrele ve sırala
          final currentGoals = _selectedTabIndex == 0
              ? _filterAndSortGoals(activeGoals)
              : _filterAndSortGoals(completedGoals);

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // SafeArea for status bar
                  SliverSafeArea(
                    bottom: false,
                    sliver: SliverToBoxAdapter(
                      child: _TopAppBar(),
                    ),
                  ),

                  // Tab Bar - Modern Design
                  SliverToBoxAdapter(
                    child: Builder(
                      builder: (context) {
                        final screenWidth =
                            MediaQuery.of(context).size.width;
                        final isSmallScreen = screenWidth < 360;
                        final horizontalPadding = isSmallScreen
                            ? AppSpacing.md
                            : AppSpacing.md + 4;
                        return Padding(
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: AppSpacing.sm,
                            bottom: AppSpacing.sm,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppColors.gray100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Builder(
                              builder: (context) {
                                final screenWidth =
                                    MediaQuery.of(context).size.width;
                                final isSmallScreen = screenWidth < 360;
                                return TabBar(
                                  controller: _tabController,
                                  indicator: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  dividerColor: Colors.transparent,
                                  labelColor: AppColors.primary,
                                  unselectedLabelColor: AppColors.gray600,
                                  labelStyle:
                                      AppTextStyles.labelMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: isSmallScreen ? 11 : 12,
                                  ),
                                  unselectedLabelStyle:
                                      AppTextStyles.labelMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: isSmallScreen ? 11 : 12,
                                  ),
                                  isScrollable:
                                      false, // Tab'lar eşit genişlikte olacak
                                  tabAlignment: TabAlignment.fill,
                                  tabs: [
                                    Tab(
                                      height: 44,
                                      child: Builder(
                                        builder: (context) {
                                          final screenWidth =
                                              MediaQuery.of(context)
                                                  .size
                                                  .width;
                                          final isSmallScreen =
                                              screenWidth < 360;
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.flag_rounded,
                                                size: isSmallScreen
                                                    ? 15
                                                    : 16,
                                              ),
                                              SizedBox(
                                                  width: isSmallScreen
                                                      ? 4
                                                      : 6),
                                              Flexible(
                                                child: Text(
                                                  context.l10n.active,
                                                  style: AppTextStyles
                                                      .labelMedium
                                                      .copyWith(
                                                    fontSize: isSmallScreen
                                                        ? 11
                                                        : 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                ),
                                              ),
                                              if (activeGoals
                                                  .isNotEmpty) ...[
                                                SizedBox(
                                                    width: isSmallScreen
                                                        ? 3
                                                        : 4),
                                                Container(
                                                  padding:
                                                      EdgeInsets.symmetric(
                                                    horizontal:
                                                        isSmallScreen
                                                            ? 5
                                                            : 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration:
                                                      BoxDecoration(
                                                    color: AppColors
                                                        .primary
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(10),
                                                  ),
                                                  child: Text(
                                                    '${activeGoals.length}',
                                                    style: AppTextStyles
                                                        .labelSmall
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize:
                                                          isSmallScreen
                                                              ? 10
                                                              : 11,
                                                      color: AppColors
                                                          .primary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    Tab(
                                      height: 44,
                                      child: Builder(
                                        builder: (context) {
                                          final screenWidth =
                                              MediaQuery.of(context)
                                                  .size
                                                  .width;
                                          final isSmallScreen =
                                              screenWidth < 360;
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle_rounded,
                                                size: isSmallScreen
                                                    ? 15
                                                    : 16,
                                              ),
                                              SizedBox(
                                                  width: isSmallScreen
                                                      ? 4
                                                      : 6),
                                              Flexible(
                                                child: Text(
                                                  context.l10n.completed,
                                                  style: AppTextStyles
                                                      .labelMedium
                                                      .copyWith(
                                                    fontSize: isSmallScreen
                                                        ? 11
                                                        : 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                ),
                                              ),
                                              if (completedGoals
                                                  .isNotEmpty) ...[
                                                SizedBox(
                                                    width: isSmallScreen
                                                        ? 3
                                                        : 4),
                                                Container(
                                                  padding:
                                                      EdgeInsets.symmetric(
                                                    horizontal:
                                                        isSmallScreen
                                                            ? 5
                                                            : 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration:
                                                      BoxDecoration(
                                                    color: AppColors
                                                        .primary
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(10),
                                                  ),
                                                  child: Text(
                                                    '${completedGoals.length}',
                                                    style: AppTextStyles
                                                        .labelSmall
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize:
                                                          isSmallScreen
                                                              ? 10
                                                              : 11,
                                                      color: AppColors
                                                          .primary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Filter/Sort Buttons (sadece aktif hedeflerde göster)
                  if (_selectedTabIndex == 0)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                          top: AppSpacing.md,
                          bottom: AppSpacing.sm,
                        ),
                        child: _FilterSortButtons(
                          sortOption: _sortOption,
                          filterOption: _filterOption,
                          onSortChanged: (option) {
                            setState(() {
                              _sortOption = option;
                            });
                          },
                          onFilterChanged: (option) {
                            setState(() {
                              _filterOption = option;
                            });
                          },
                        ),
                      ),
                    ),

                  // Goals List
                  if (currentGoals.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _selectedTabIndex == 0
                          ? _EmptyState()
                          : _EmptyCompletedState(),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final goal = currentGoals[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: AppSpacing.md,
                              right: AppSpacing.md,
                              bottom: AppSpacing.md,
                            ),
                            child: _selectedTabIndex == 0
                                ? _GoalCard(goal: goal)
                                : _CompletedGoalCard(goal: goal),
                          );
                        },
                        childCount: currentGoals.length,
                      ),
                    ),

                  // Bottom padding for FAB and navigation bar
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
              // Floating Action Button - Modern Premium styling
              if (_selectedTabIndex == 0 && activeGoals.isNotEmpty)
                Positioned(
                  bottom: 24,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          offset: const Offset(0, 8),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      onPressed: () {
                        context.push(AppRoutes.goalCreate);
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
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

/// Top App Bar - Modern Premium styling
class _TopAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                context.l10n.myGoals,
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.yourSuccessJourney,
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
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.notificationsComingSoon),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              iconSize: 22,
              color: AppColors.gray700,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter and Sort Buttons - Modern design
class _FilterSortButtons extends StatelessWidget {
  const _FilterSortButtons({
    required this.sortOption,
    required this.filterOption,
    required this.onSortChanged,
    required this.onFilterChanged,
  });

  final _SortOption sortOption;
  final _FilterOption filterOption;
  final ValueChanged<_SortOption> onSortChanged;
  final ValueChanged<_FilterOption> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModernActionButton(
            icon: Icons.swap_vert_rounded,
            label: context.l10n.sort,
            onPressed: () {
              _showSortDialog(context);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ModernActionButton(
            icon: Icons.tune_rounded,
            label: context.l10n.filter,
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ),
      ],
    );
  }

  void _showSortDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.sort,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ..._SortOption.values
                  .map((option) => RadioListTile<_SortOption>(
                        title: Text(_getSortLabel(context, option)),
                        value: option,
                        groupValue: sortOption,
                        onChanged: (value) {
                          if (value != null) {
                            onSortChanged(value);
                            Navigator.pop(context);
                          }
                        },
                      )),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.filter,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ..._FilterOption.values
                  .map((option) => RadioListTile<_FilterOption>(
                        title: Text(_getFilterLabel(context, option)),
                        value: option,
                        groupValue: filterOption,
                        onChanged: (value) {
                          if (value != null) {
                            onFilterChanged(value);
                            Navigator.pop(context);
                          }
                        },
                      )),
            ],
          ),
        ),
      ),
    );
  }

  String _getSortLabel(BuildContext context, _SortOption option) {
    final l10n = context.l10n;
    switch (option) {
      case _SortOption.newest:
        return l10n.newest;
      case _SortOption.oldest:
        return l10n.oldest;
      case _SortOption.progressHigh:
        return l10n.progressHigh;
      case _SortOption.progressLow:
        return l10n.progressLow;
      case _SortOption.titleAsc:
        return l10n.titleAsc;
      case _SortOption.titleDesc:
        return l10n.titleDesc;
    }
  }

  String _getFilterLabel(BuildContext context, _FilterOption option) {
    final l10n = context.l10n;
    switch (option) {
      case _FilterOption.all:
        return l10n.all;
      case _FilterOption.health:
        return l10n.health;
      case _FilterOption.mentalHealth:
        return l10n.mentalHealth;
      case _FilterOption.finance:
        return l10n.finance;
      case _FilterOption.career:
        return l10n.career;
      case _FilterOption.relationships:
        return l10n.relationships;
      case _FilterOption.learning:
        return l10n.learning;
      case _FilterOption.creativity:
        return l10n.creativity;
      case _FilterOption.hobby:
        return l10n.hobby;
      case _FilterOption.personalGrowth:
        return l10n.personalGrowth;
    }
  }
}

/// Empty state for completed goals - Modern Design
class _EmptyCompletedState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.18),
                  AppColors.primary.withOpacity(0.08),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl + AppSpacing.md),
          Text(
            'Henüz tamamlanan hedef yok',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.gray900,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Hedeflerini tamamladıkça burada gözükecekler',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.gray600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Completed Goal Card - Simplified version for goals page
class _CompletedGoalCard extends ConsumerWidget {
  const _CompletedGoalCard({required this.goal});

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
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryColor = _getCategoryColor(goal.category);
    final completedDate =
        goal.completedAt ?? goal.targetDate ?? goal.createdAt;
    final dateFormat = DateFormat('d MMMM yyyy', 'tr_TR');

    return Container(
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
                // Header: Category badge + "Aktiflere taşı" aksiyonu
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
                    IconButton(
                      icon: const Icon(
                        Icons.restart_alt_rounded,
                        size: 20,
                        color: AppColors.gray600,
                      ),
                      tooltip: context.l10n.moveToActiveTooltip,
                      onPressed: () async {
                        final shouldUncomplete = await showDialog<bool>(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.5),
                          builder: (context) => _UncompleteGoalDialog(
                            goalTitle: goal.title,
                          ),
                        );

                        if (shouldUncomplete == true && context.mounted) {
                          final userId = ref.read(currentUserIdProvider);
                          if (userId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.l10n.mustSignInToPerformAction,
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            final repository =
                                ref.read(goalRepositoryProvider);
                            final updatedGoal = goal.copyWith(
                              isArchived: false,
                              isCompleted: false,
                              completedAt: null,
                            );
                            await repository.updateGoal(updatedGoal);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.l10n.goalMovedToActive,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.l10n
                                        .errorUpdatingGoal(e.toString()),
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
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
                            context.l10n.completed,
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

/// Completed hedefi tekrar aktifler listesine taşıma diyaloğu
class _UncompleteGoalDialog extends StatelessWidget {
  const _UncompleteGoalDialog({required this.goalTitle});

  final String goalTitle;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusXl,
      ),
      content: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.borderRadiusXl,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon circle
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                ),
                child: const Icon(
                  Icons.restart_alt_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Title
            Text(
              context.l10n.reactivateGoal,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            // Description
            Text(
              context.l10n.reactivateGoalDescription(goalTitle),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
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
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: Text(
                      context.l10n.cancel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: Text(
                      context.l10n.moveToActive,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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

/// Modern Action Button (Sort/Filter) - Premium design
class _ModernActionButton extends StatelessWidget {
  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gray200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: AppColors.gray700,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray700,
                    fontSize: 14,
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

/// Goal Card Widget - Premium styling
class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});

  final Goal goal;

  String _formatLastCheckIn(BuildContext context, DateTime? date) {
    final l10n = context.l10n;
    if (date == null) return l10n.noCheckInYet;

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n.today;
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return l10n.weeksAgo(weeks);
    } else {
      // Use localized date format
      final locale = Localizations.localeOf(context);
      return DateFormat('d MMMM', locale.toString()).format(date);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseColor = _categoryColor(goal.category);
    final backgroundColor = baseColor.withOpacity(0.12);

    final checkInsAsync = ref.watch(checkInsStreamProvider(goal.id));
    final l10n = context.l10n;
    final lastCheckInLabel = checkInsAsync.when(
      loading: () => l10n.loading,
      error: (_, __) => l10n.noCheckInYet,
      data: (checkIns) {
        if (checkIns.isEmpty) return l10n.noCheckInYet;
        final sorted = checkIns
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return l10n.lastCheckIn(
            _formatLastCheckIn(context, sorted.first.createdAt));
      },
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18), // Softer corner radius (18px)
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
            padding: const EdgeInsets.all(20), // Increased padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.3, // Increased line height
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius:
                            BorderRadius.circular(16), // Softer pill shape
                      ),
                      child: Text(
                        goal.category.getLocalizedLabel(context),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: baseColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12, // Slightly larger font
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        lastCheckInLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF6B7280), // Softer gray
                          fontWeight: FontWeight.w500, // Medium weight
                          height: 1.4, // Increased line height
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${goal.progress.toInt()}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary
                            .withOpacity(0.9), // Softer blue
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // Fully rounded progress bar with softer blue
                ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Fully rounded
                  child: LinearProgressIndicator(
                    value: goal.progress / 100,
                    minHeight: 10,
                    backgroundColor: AppColors.gray200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary
                          .withOpacity(0.85), // Softer modern blue
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

Color _categoryColor(GoalCategory category) {
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
      return const Color(0xFF3B82F6);
  }
}

/// Empty State - Modern Premium Design
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.primary.withOpacity(0.08),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.flag_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl + AppSpacing.md),
          Text(
            context.l10n.noGoalsYet,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.gray900,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.startJourneyWithGoal,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.gray600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl + AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: () {
                context.push(AppRoutes.goalCreate);
              },
              icon: const Icon(Icons.add_rounded, size: 22),
              label: Text(
                context.l10n.addNewGoal,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl + AppSpacing.md,
                  vertical: AppSpacing.md + 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
