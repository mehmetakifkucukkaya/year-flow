import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
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
  finance,
  career,
  relationship,
  learning,
  habit,
  personalGrowth,
}

class GoalsPage extends ConsumerStatefulWidget {
  const GoalsPage({super.key});

  @override
  ConsumerState<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends ConsumerState<GoalsPage> {
  // Premium background color
  static const Color _premiumBackground = Color(0xFFF9FAFB);

  _SortOption _sortOption = _SortOption.newest;
  _FilterOption _filterOption = _FilterOption.all;

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
      case _FilterOption.finance:
        return GoalCategory.finance;
      case _FilterOption.career:
        return GoalCategory.career;
      case _FilterOption.relationship:
        return GoalCategory.relationship;
      case _FilterOption.learning:
        return GoalCategory.learning;
      case _FilterOption.habit:
        return GoalCategory.habit;
      case _FilterOption.personalGrowth:
        return GoalCategory.personalGrowth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalsStreamProvider);

    return Container(
      color: _premiumBackground,
      child: Stack(
        children: [
          goalsAsync.when(
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
                        'Hedefler yüklenirken bir hata oluştu.',
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
                        child: const Text('Yeniden Dene'),
                      ),
                    ],
                  ),
                ),
              );
            },
            data: (goals) {
              final filteredAndSortedGoals = _filterAndSortGoals(goals);
              return CustomScrollView(
                slivers: [
                  // SafeArea for status bar
                  SliverSafeArea(
                    bottom: false,
                    sliver: SliverToBoxAdapter(
                      child: _TopAppBar(),
                    ),
                  ),

                  // Filter/Sort Buttons
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
                  if (filteredAndSortedGoals.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final goal = filteredAndSortedGoals[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: AppSpacing.md,
                              right: AppSpacing.md,
                              bottom: AppSpacing.md,
                            ),
                            child: _GoalCard(goal: goal),
                          );
                        },
                        childCount: filteredAndSortedGoals.length,
                      ),
                    ),

                  // Bottom padding for FAB and navigation bar
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              );
            },
          ),
          // Floating Action Button - Premium styling
          Positioned(
            bottom: 24,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  context.push(AppRoutes.goalCreate);
                },
                backgroundColor: AppColors.primary
                    .withOpacity(0.9), // Softer pastel blue
                elevation: 0,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24, // Slightly smaller icon
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Top App Bar - Premium styling
class _TopAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Hedeflerim',
            style: AppTextStyles.headlineLarge.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.notifications_none), // More minimal icon
            onPressed: () {
              // Şimdilik basit bir snackbar göster
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Bildirimler yakında eklenecek'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            iconSize: 22, // Reduced size
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// Filter and Sort Buttons - Minimalist design
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
        _ActionButton(
          icon: Icons.swap_vert,
          label: 'Sırala',
          onPressed: () {
            _showSortDialog(context);
          },
        ),
        const SizedBox(width: AppSpacing.sm),
        _ActionButton(
          icon: Icons.filter_list,
          label: 'Filtrele',
          onPressed: () {
            _showFilterDialog(context);
          },
        ),
      ],
    );
  }

  void _showSortDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sırala',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._SortOption.values
                .map((option) => RadioListTile<_SortOption>(
                      title: Text(_getSortLabel(option)),
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
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrele',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._FilterOption.values
                .map((option) => RadioListTile<_FilterOption>(
                      title: Text(_getFilterLabel(option)),
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
    );
  }

  String _getSortLabel(_SortOption option) {
    switch (option) {
      case _SortOption.newest:
        return 'En Yeni';
      case _SortOption.oldest:
        return 'En Eski';
      case _SortOption.progressHigh:
        return 'İlerleme (Yüksek)';
      case _SortOption.progressLow:
        return 'İlerleme (Düşük)';
      case _SortOption.titleAsc:
        return 'Başlık (A-Z)';
      case _SortOption.titleDesc:
        return 'Başlık (Z-A)';
    }
  }

  String _getFilterLabel(_FilterOption option) {
    switch (option) {
      case _FilterOption.all:
        return 'Tümü';
      case _FilterOption.health:
        return 'Sağlık';
      case _FilterOption.finance:
        return 'Finans';
      case _FilterOption.career:
        return 'Kariyer';
      case _FilterOption.relationship:
        return 'İlişkiler';
      case _FilterOption.learning:
        return 'Öğrenme';
      case _FilterOption.habit:
        return 'Alışkanlık';
      case _FilterOption.personalGrowth:
        return 'Kişisel Gelişim';
    }
  }
}

/// Action Button (Sort/Filter) - Smaller, softer, minimalist
class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
        borderRadius: BorderRadius.circular(20), // Softer pill shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16, // Smaller icon
                  color: AppColors.gray700,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray700,
                    fontSize: 13,
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

  String _formatLastCheckIn(DateTime? date) {
    if (date == null) return 'Henüz Check-in yok';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else {
      return DateFormat('d MMMM', 'tr_TR').format(date);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseColor = _categoryColor(goal.category);
    final backgroundColor = baseColor.withOpacity(0.12);

    final checkInsAsync = ref.watch(checkInsStreamProvider(goal.id));
    final lastCheckInLabel = checkInsAsync.when(
      loading: () => 'Yükleniyor...',
      error: (_, __) => 'Henüz Check-in yok',
      data: (checkIns) {
        if (checkIns.isEmpty) return 'Henüz Check-in yok';
        final sorted = checkIns
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return 'Son Check-in: ${_formatLastCheckIn(sorted.first.createdAt)}';
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
                        goal.category.label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: baseColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 11, // Smaller font
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
                    Text(
                      lastCheckInLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF6B7280), // Softer gray
                        fontWeight: FontWeight.w500, // Medium weight
                        height: 1.4, // Increased line height
                      ),
                    ),
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
    case GoalCategory.finance:
      return const Color(0xFF009688);
    case GoalCategory.career:
      return const Color(0xFF2196F3);
    case GoalCategory.relationship:
      return const Color(0xFFE91E63);
    case GoalCategory.learning:
      return const Color(0xFF9C27B0);
    case GoalCategory.habit:
      return const Color(0xFFFF9800);
    case GoalCategory.personalGrowth:
      return const Color(0xFF3B82F6);
  }
}

/// Empty State
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_circle_outline,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Henüz bir hedefin yok',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Hadi, ilk hedefini ekleyerek yolculuğuna başla!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
