import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // Premium background color
  static const Color _premiumBackground = Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final goals = _mockGoals;
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
              childCount: _mockGoals.length,
            ),
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
                'Yaklaşan Check-in',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Günün Sorusu Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: _DailyQuestionCard(),
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

/// Goal Card Model
class _GoalData {
  const _GoalData({
    required this.title,
    required this.category,
    required this.progress,
    required this.categoryColor,
    required this.categoryBackgroundColor,
  });

  final String title;
  final String category;
  final double progress;
  final Color categoryColor;
  final Color categoryBackgroundColor;
}

/// Mock goals data
final _mockGoals = [
  const _GoalData(
    title: 'Yeni Bir Dil Öğren',
    category: 'Kariyer',
    progress: 75,
    categoryColor: Color(0xFF9C27B0), // Purple
    categoryBackgroundColor: Color(0xFFF3E5F5), // Light purple
  ),
  const _GoalData(
    title: 'Haftada 3 Gün Spor Yap',
    category: 'Sağlık',
    progress: 40,
    categoryColor: Color(0xFF4CAF50), // Green
    categoryBackgroundColor: Color(0xFFE8F5E9), // Light green
  ),
];

/// Goal Card Widget with premium styling
class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final _GoalData goal;

  @override
  Widget build(BuildContext context) {
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
                          color: goal.categoryBackgroundColor,
                          borderRadius:
                              BorderRadius.circular(22), // 22px radius
                        ),
                        child: Text(
                          goal.category,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: goal.categoryColor,
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
                  '${goal.progress.toInt()}%',
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
                value: goal.progress / 100,
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
    );
  }
}

/// Daily Question Card with premium styling
class _DailyQuestionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                  // GoalsPage'e yönlendir - kullanıcı oradan bir goal seçip check-in yapabilir
                  context.push(AppRoutes.goals);
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
