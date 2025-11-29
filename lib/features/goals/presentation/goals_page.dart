import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  // Premium background color
  static const Color _premiumBackground = Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = _mockGoals;

    return Container(
      color: _premiumBackground,
      child: Stack(
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

              // Filter/Sort Buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    top: AppSpacing.md,
                    bottom: AppSpacing.sm,
                  ),
                  child: _FilterSortButtons(),
                ),
              ),

              // Goals List
              if (goals.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                ),

              // Bottom padding for FAB and navigation bar
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
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
                backgroundColor: AppColors.primary.withOpacity(0.9), // Softer pastel blue
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
            icon: const Icon(Icons.notifications_none), // More minimal icon
            onPressed: () {
              // TODO: Navigate to notifications
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
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: Icons.swap_vert,
          label: 'Sırala',
          onPressed: () {
            // TODO: Show sort options
          },
        ),
        const SizedBox(width: AppSpacing.sm),
        _ActionButton(
          icon: Icons.filter_list,
          label: 'Filtrele',
          onPressed: () {
            // TODO: Show filter options
          },
        ),
      ],
    );
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

/// Goal Card Model
class _GoalData {
  const _GoalData({
    required this.title,
    required this.category,
    required this.progress,
    required this.lastCheckIn,
    required this.categoryColor,
    required this.categoryBackgroundColor,
  });

  final String title;
  final String category;
  final double progress;
  final String lastCheckIn;
  final Color categoryColor;
  final Color categoryBackgroundColor;
}

/// Mock goals data
final _mockGoals = [
  const _GoalData(
    title: 'Haftada 3 Gün Spor Yap',
    category: 'Sağlık',
    progress: 75,
    lastCheckIn: '3 gün önce',
    categoryColor: Color(0xFF4CAF50), // Green
    categoryBackgroundColor: Color(0xFFE8F5E9), // Light green
  ),
  const _GoalData(
    title: 'Aylık 1 Kitap Oku',
    category: 'Kişisel Gelişim',
    progress: 50,
    lastCheckIn: '1 hafta önce',
    categoryColor: Color(0xFF9C27B0), // Purple
    categoryBackgroundColor: Color(0xFFF3E5F5), // Light purple
  ),
  const _GoalData(
    title: 'Yeni Bir Programlama Dili Öğren',
    category: 'Kariyer',
    progress: 20,
    lastCheckIn: 'dün',
    categoryColor: Color(0xFF2196F3), // Blue
    categoryBackgroundColor: Color(0xFFE3F2FD), // Light blue
  ),
];

/// Goal Card Widget - Premium styling
class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final _GoalData goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18), // Softer corner radius (18px)
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
            context.push(AppRoutes.goalDetailPath('1'));
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
                        color: goal.categoryBackgroundColor,
                        borderRadius: BorderRadius.circular(16), // Softer pill shape
                      ),
                      child: Text(
                        goal.category,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: goal.categoryColor,
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
                      'Son Check-in: ${goal.lastCheckIn}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF6B7280), // Softer gray
                        fontWeight: FontWeight.w500, // Medium weight
                        height: 1.4, // Increased line height
                      ),
                    ),
                    Text(
                      '${goal.progress.toInt()}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary.withOpacity(0.9), // Softer blue
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
                      AppColors.primary.withOpacity(0.85), // Softer modern blue
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

/// Empty State
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
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
