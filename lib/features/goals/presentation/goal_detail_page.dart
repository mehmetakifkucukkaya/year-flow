import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/index.dart';
import '../../../shared/models/check_in.dart';
import '../../../shared/models/goal.dart';
import '../../../shared/models/note.dart';
import '../../../shared/providers/ai_providers.dart';
import '../../../shared/providers/goal_providers.dart';

class GoalDetailPage extends ConsumerStatefulWidget {
  const GoalDetailPage({
    super.key,
    required this.goalId,
  });

  final String goalId;

  @override
  ConsumerState<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends ConsumerState<GoalDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Premium background color
  static const Color _premiumBackground = Color(0xFFF9FAFB);
  static const Color _statusTextColor = Color(0xFF4B5563);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_TimelineItem> _buildTimelineItems(
      Goal? goal, List<CheckIn> checkIns) {
    final items = <_TimelineItem>[];

    if (goal != null) {
      // Goal created item
      final createdDate =
          DateFormat('d MMMM', 'tr_TR').format(goal.createdAt);
      items.add(_TimelineItem(
        title: 'Hedef Oluşturuldu',
        date: createdDate,
        type: _TimelineItemType.created,
      ));

      // Check-in items
      for (final checkIn in checkIns) {
        final checkInDate =
            DateFormat('d MMMM', 'tr_TR').format(checkIn.createdAt);
        items.add(_TimelineItem(
          title: 'Check-in Yapıldı: Skor ${checkIn.score}/10',
          date: checkInDate,
          type: _TimelineItemType.checkIn,
          note: checkIn.note,
        ));
      }
    }

    return items;
  }

  String _formatNextCheckIn(Goal? goal) {
    if (goal?.targetDate == null) return 'Belirtilmemiş';

    final now = DateTime.now();
    final target = goal!.targetDate!;
    final daysLeft = target.difference(now).inDays;

    if (daysLeft < 0) return 'Süresi doldu';
    if (daysLeft == 0) return 'Bugün';
    if (daysLeft == 1) return 'Yarın';
    if (daysLeft < 7) return '$daysLeft gün sonra';

    return DateFormat('d MMMM', 'tr_TR').format(target);
  }

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(goalDetailProvider(widget.goalId));
    final checkInsAsync = ref.watch(checkInsStreamProvider(widget.goalId));

    return Scaffold(
      backgroundColor: _premiumBackground,
      body: goalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Hedef yüklenirken hata oluştu: $error'),
        ),
        data: (goal) {
          // Check-ins stream'ini düzgün handle et
          return checkInsAsync.when(
            loading: () => Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: _PremiumAppBar(
                    goalId: widget.goalId,
                  ),
                ),
                _PremiumHeaderSection(
                  goal: goal != null
                      ? _GoalDetail(
                          title: goal.title,
                          description: goal.description,
                          category: goal.category.label,
                          progress: goal.progress.toDouble(),
                          nextCheckIn: _formatNextCheckIn(goal),
                          categoryColor: _getCategoryColor(goal.category),
                          categoryBackgroundColor:
                              _getCategoryColor(goal.category)
                                  .withOpacity(0.1),
                          isCompleted: goal.isCompleted,
                          timelineItems: [],
                          goalId: widget.goalId,
                          subtasks: [],
                        )
                      : _GoalDetail(
                          title: '',
                          description: null,
                          category: '',
                          progress: 0,
                          nextCheckIn: 'Belirtilmemiş',
                          categoryColor: AppColors.primary,
                          categoryBackgroundColor:
                              AppColors.primary.withOpacity(0.1),
                          timelineItems: const [],
                          goalId: widget.goalId,
                          subtasks: const [],
                          isCompleted: false,
                        ),
                ),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
            error: (error, _) => Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: _PremiumAppBar(
                    goalId: widget.goalId,
                  ),
                ),
                _PremiumHeaderSection(
                  goal: goal != null
                      ? _GoalDetail(
                          title: goal.title,
                          description: goal.description,
                          category: goal.category.label,
                          progress: goal.progress.toDouble(),
                          nextCheckIn: _formatNextCheckIn(goal),
                          categoryColor: _getCategoryColor(goal.category),
                          categoryBackgroundColor:
                              _getCategoryColor(goal.category)
                                  .withOpacity(0.1),
                          isCompleted: goal.isCompleted,
                          timelineItems: [],
                          goalId: widget.goalId,
                          subtasks: [],
                        )
                      : _GoalDetail(
                          title: '',
                          description: null,
                          category: '',
                          progress: 0,
                          nextCheckIn: 'Belirtilmemiş',
                          categoryColor: AppColors.primary,
                          categoryBackgroundColor:
                              AppColors.primary.withOpacity(0.1),
                          timelineItems: const [],
                          goalId: widget.goalId,
                          subtasks: const [],
                          isCompleted: false,
                        ),
                ),
                Expanded(
                  child: Center(
                    child: Text('Check-in\'ler yüklenirken hata: $error'),
                  ),
                ),
              ],
            ),
            data: (checkIns) {
              final timelineItems = _buildTimelineItems(goal, checkIns);

              final goalDetail = goal != null
                  ? _GoalDetail(
                      title: goal.title,
                      description: goal.description,
                      category: goal.category.label,
                      progress: goal.progress.toDouble(),
                      nextCheckIn: _formatNextCheckIn(goal),
                      categoryColor: _getCategoryColor(goal.category),
                      categoryBackgroundColor:
                          _getCategoryColor(goal.category)
                              .withOpacity(0.1),
                      timelineItems: timelineItems,
                      goalId: widget.goalId,
                      subtasks: goal.subGoals
                          .map((sg) => _Subtask(
                                title: sg.title,
                                isCompleted: sg.isCompleted,
                                dueDate: sg.dueDate != null
                                    ? DateFormat('d MMMM', 'tr_TR')
                                        .format(sg.dueDate!)
                                    : null,
                              ))
                          .toList(),
                      isCompleted: goal.isCompleted,
                    )
                  : _GoalDetail(
                      title: '',
                      description: null,
                      category: '',
                      progress: 0,
                      nextCheckIn: 'Belirtilmemiş',
                      categoryColor: AppColors.primary,
                      categoryBackgroundColor:
                          AppColors.primary.withOpacity(0.1),
                      timelineItems: timelineItems,
                      goalId: widget.goalId,
                      subtasks: const [],
                      isCompleted: false,
                    );

              return Column(
                children: [
                  // Minimal App Bar
                  SafeArea(
                    bottom: false,
                    child: _PremiumAppBar(
                      goalId: widget.goalId,
                    ),
                  ),

                  // Header Section - %55 alan içinde scroll edilebilir
                  Flexible(
                    flex: 55,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: _PremiumHeaderSection(goal: goalDetail),
                    ),
                  ),

                  // TabBar - Sabit, her zaman görünür
                  _PremiumTabBar(controller: _tabController),

                  // Tab Content - %45 alan
                  Flexible(
                    flex: 45,
                    child: Container(
                      color: _premiumBackground,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          _TimelineTab(timelineItems: timelineItems),
                          _NotesTab(goalId: goalDetail.goalId),
                          if (goal != null)
                            _SubtasksTab(
                              goalId: goalDetail.goalId,
                              subGoals: goal.subGoals,
                              goalTitle: goal.title,
                              goalDescription: goal.description,
                              goalCategoryKey: goal.category.name,
                              isGoalCompleted: goal.isCompleted,
                            )
                          else
                            const _SubtasksTab(
                              goalId: '',
                              subGoals: [],
                              goalTitle: '',
                              goalDescription: null,
                              goalCategoryKey: '',
                              isGoalCompleted: false,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      // Bottom Action Button - Tamamlanan hedeflerde gizle
      bottomNavigationBar: (goalAsync.valueOrNull?.isCompleted ?? false)
          ? null
          : _PremiumBottomButton(
              goalId: widget.goalId,
              onCheckInCompleted: _handleCheckInCompleted,
            ),
    );
  }

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

  void _handleCheckInCompleted() {
    // Check-in sonrası hedef detayını tazele
    ref.invalidate(goalDetailProvider(widget.goalId));
    AppSnackbar.showSuccess(
      context,
      message: 'Check-in kaydedildi! ✅',
    );
  }
}

class _PremiumAppBar extends ConsumerWidget {
  const _PremiumAppBar({
    required this.goalId,
  });

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hedefi Tamamla butonu (sadece tamamlanmamışsa göster)
              Consumer(
                builder: (context, ref, _) {
                  final goalAsync = ref.watch(goalDetailProvider(goalId));
                  final goal = goalAsync.maybeWhen(
                    data: (goal) => goal,
                    orElse: () => null,
                  );
                  final completed = goal?.isCompleted ?? false;

                  if (completed) {
                    return const SizedBox.shrink();
                  }

                  return IconButton(
                    icon: const Icon(Icons.check_circle_outline, size: 22),
                    color: AppColors.primary,
                    onPressed: () async {
                      if (goal == null) {
                        if (context.mounted) {
                          AppSnackbar.showError(
                            context,
                            message: 'Hedef bulunamadı',
                          );
                        }
                        return;
                      }

                      final shouldComplete = await showDialog<bool>(
                        context: context,
                        barrierColor: Colors.black.withOpacity(0.5),
                        builder: (context) => _CompleteConfirmationDialog(
                          goalTitle: goal.title,
                        ),
                      );

                      if (shouldComplete == true && context.mounted) {
                        try {
                          final repository =
                              ref.read(goalRepositoryProvider);
                          // Goal'u tamamla ve arşive taşı (userId'yi goal'dan al)
                          final completedGoal = goal.copyWith(
                            isCompleted: true,
                            isArchived: true,
                            progress: 100,
                            completedAt: DateTime.now(),
                          );
                          await repository.updateGoal(completedGoal);

                          if (context.mounted) {
                            ref.invalidate(goalsStreamProvider);
                            ref.invalidate(goalDetailProvider(goalId));
                            AppSnackbar.showSuccess(
                              context,
                              message: 'Hedef tamamlandı! 🎉',
                            );
                            context.pop();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackbar.showError(
                              context,
                              message:
                                  'Hedef tamamlanırken hata oluştu: $e',
                            );
                          }
                        }
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    tooltip: 'Hedefi Tamamla',
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 22),
                onPressed: () {
                  context.push(AppRoutes.goalEditPath(goalId));
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                onSelected: (value) async {
                  if (value == 'delete') {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      barrierColor: Colors.black.withOpacity(0.5),
                      builder: (context) => _DeleteConfirmationDialog(
                        goalId: goalId,
                      ),
                    );

                    if (shouldDelete == true && context.mounted) {
                      try {
                        // Goal'u al ve userId'yi kullanarak direkt sil
                        final goalAsync =
                            ref.read(goalDetailProvider(goalId));
                        final goal = goalAsync.maybeWhen(
                          data: (goal) => goal,
                          orElse: () => null,
                        );

                        if (goal == null) {
                          if (context.mounted) {
                            AppSnackbar.showError(
                              context,
                              message: 'Hedef bulunamadı',
                            );
                          }
                          return;
                        }

                        // userId ile direkt sil (yeni Firestore yapısı: users/{userId}/goals/{goalId})
                        final firestore = ref.read(firestoreProvider);
                        await firestore
                            .collection('users')
                            .doc(goal.userId)
                            .collection('goals')
                            .doc(goalId)
                            .delete();

                        if (context.mounted) {
                          ref.invalidate(goalsStreamProvider);
                          ref.invalidate(goalDetailProvider(goalId));
                          AppSnackbar.showSuccess(
                            context,
                            message: 'Hedef başarıyla silindi',
                          );
                          context.pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AppSnackbar.showError(
                            context,
                            message: 'Hedef silinirken hata oluştu: $e',
                          );
                        }
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppColors.error),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Hedefi Sil',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Premium Header Section - Responsive and Compact
class _PremiumHeaderSection extends StatelessWidget {
  const _PremiumHeaderSection({required this.goal});

  final _GoalDetail goal;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700 || screenWidth < 360;
    final isVerySmallScreen = screenHeight < 650 || screenWidth < 340;

    // Responsive progress size - %35 alan için çok daha küçük
    final progressSize =
        isVerySmallScreen ? 60.0 : (isSmallScreen ? 70.0 : 80.0);
    final titleFontSize =
        isVerySmallScreen ? 14.0 : (isSmallScreen ? 16.0 : 18.0);
    final verticalPadding = isVerySmallScreen
        ? 4.0
        : (isSmallScreen ? AppSpacing.xs : AppSpacing.sm);
    final spacingBetween =
        isVerySmallScreen ? 2.0 : (isSmallScreen ? 4.0 : 6.0);

    return Container(
      color: _GoalDetailPageState._premiumBackground,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 360 ? AppSpacing.md : AppSpacing.lg,
        vertical: verticalPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Goal Title - compact spacing
          Text(
            goal.title,
            style: AppTextStyles.headlineLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
              letterSpacing: -0.6,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: isSmallScreen ? 2 : 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacingBetween),

          if (goal.description != null &&
              goal.description!.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? AppSpacing.xs : AppSpacing.md,
              ),
              child: Text(
                goal.description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray700,
                  height: 1.4,
                  fontSize: isSmallScreen ? 11 : null,
                ),
                textAlign: TextAlign.center,
                maxLines: isSmallScreen ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: spacingBetween),
          ],

          // Category Chip - Softer pastel colors (Daha küçük)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal:
                  isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12),
              vertical: isVerySmallScreen ? 3 : (isSmallScreen ? 4 : 5),
            ),
            decoration: BoxDecoration(
              color: goal.categoryBackgroundColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              goal.category,
              style: AppTextStyles.labelMedium.copyWith(
                color: goal.categoryColor,
                fontWeight: FontWeight.w600,
                fontSize:
                    isVerySmallScreen ? 10 : (isSmallScreen ? 11 : 12),
              ),
            ),
          ),
          SizedBox(height: spacingBetween),

          // Premium Progress Ring - Responsive size
          _PremiumCircularProgress(
            progress: goal.progress,
            progressColor:
                goal.isCompleted ? AppColors.success : goal.categoryColor,
            size: progressSize,
          ),
          SizedBox(height: spacingBetween),

          // Status Text - Daha küçük
          Text(
            goal.isCompleted
                ? 'Hedef Tamamlandı 🎉'
                : 'İlerleme Kaydedildi',
            style: AppTextStyles.bodyMedium.copyWith(
              color: goal.isCompleted
                  ? AppColors.success
                  : _GoalDetailPageState._statusTextColor,
              fontWeight: FontWeight.w500,
              fontSize: isVerySmallScreen ? 10 : (isSmallScreen ? 11 : 12),
            ),
          ),
          SizedBox(height: spacingBetween),

          // Next Check-in Card - Frosted glass effect with subtle arrow
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      offset: const Offset(0, 10),
                      blurRadius: 24,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: isVerySmallScreen
                          ? 14
                          : (isSmallScreen ? 15 : 16),
                      color: AppColors.gray600,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Sonraki Check-in: ${goal.nextCheckIn}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray700,
                          fontSize: isVerySmallScreen
                              ? 10
                              : (isSmallScreen ? 11 : 12),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: isVerySmallScreen
                          ? 10
                          : (isSmallScreen ? 11 : 12),
                      color: AppColors.gray500,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium Circular Progress - With gradient and shadow (Responsive size)
class _PremiumCircularProgress extends StatelessWidget {
  const _PremiumCircularProgress({
    required this.progress,
    required this.progressColor,
    this.size = 120.0,
  });

  final double progress;
  final Color progressColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fontSize = size * 0.25; // Responsive font size
    final strokeWidth = size * 0.08; // Responsive stroke width
    final innerSize = size - (size * 0.2); // Responsive inner circle

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: progressColor.withOpacity(0.22),
            offset: Offset(0, size * 0.12),
            blurRadius: size * 0.24,
            spreadRadius: -(size * 0.05),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gradient progress + track
          CustomPaint(
            size: Size.square(size),
            painter: _GradientCircularProgressPainter(
              progress: progress / 100,
              baseColor: AppColors.gray200,
              progressColor: progressColor,
              strokeWidth: strokeWidth,
            ),
          ),
          // Inner glow circle
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white,
                  Colors.white,
                  progressColor.withOpacity(0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          // Percentage text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${progress.toInt()}%',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: fontSize,
                  letterSpacing: -1.4,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  _GradientCircularProgressPainter({
    required this.progress,
    required this.baseColor,
    required this.progressColor,
    this.strokeWidth = 12.0,
  });

  final double progress;
  final Color baseColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    final basePaint = Paint()
      ..color = baseColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -3.14 / 2;
    final sweepAngle = 2 * 3.14 * progress;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * 3.14,
      false,
      basePaint..color = baseColor.withOpacity(0.45),
    );

    // Progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Premium Tab Bar - Elegant design with pill highlight (Responsive)
class _PremiumTabBar extends StatelessWidget {
  const _PremiumTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 340;

    return Container(
      color: _GoalDetailPageState._premiumBackground,
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmallScreen
            ? AppSpacing.sm
            : (isSmallScreen ? AppSpacing.md : AppSpacing.lg),
        vertical: isVerySmallScreen ? 4.0 : (isSmallScreen ? 6.0 : 8.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: TabBar(
          controller: controller,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.gray600,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.primary.withOpacity(0.1),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 12 : 14,
          ),
          unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 12 : 14,
          ),
          isScrollable:
              isSmallScreen, // Küçük ekranlarda scroll edilebilir
          tabs: const [
            Tab(text: 'Timeline'),
            Tab(text: 'Notlar'),
            Tab(text: 'Alt Görevler'),
          ],
        ),
      ),
    );
  }
}

/// Goal Model
class _GoalDetail {
  const _GoalDetail({
    required this.title,
    this.description,
    required this.category,
    required this.progress,
    required this.nextCheckIn,
    required this.categoryColor,
    required this.categoryBackgroundColor,
    required this.timelineItems,
    required this.goalId,
    required this.subtasks,
    required this.isCompleted,
  });

  final String title;
  final String? description;
  final String category;
  final double progress;
  final String nextCheckIn;
  final Color categoryColor;
  final Color categoryBackgroundColor;
  final List<_TimelineItem> timelineItems;
  final String goalId;
  final List<_Subtask> subtasks;
  final bool isCompleted;
}

/// Note Model
class _Note {
  const _Note({
    required this.content,
    required this.date,
  });

  final String content;
  final String date;
}

/// Subtask Model
class _Subtask {
  const _Subtask({
    required this.title,
    required this.isCompleted,
    this.dueDate,
  });

  final String title;
  final bool isCompleted;
  final String? dueDate;
}

/// Timeline Item Model
class _TimelineItem {
  const _TimelineItem({
    required this.title,
    required this.date,
    required this.type,
    this.note,
  });

  final String title;
  final String date;
  final _TimelineItemType type;
  final String? note;
}

enum _TimelineItemType {
  created,
  milestone,
  checkIn,
}

/// Timeline Tab - Premium design with more spacing (Büyütüldü)
class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.timelineItems});

  final List<_TimelineItem> timelineItems;

  @override
  Widget build(BuildContext context) {
    final items = List<_TimelineItem>.from(timelineItems);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = isSmallScreen ? AppSpacing.md : AppSpacing.lg;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i == 0 || items[i].date != items[i - 1].date) ...[
              Text(
                items[i].date,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray700,
                  fontSize: isSmallScreen ? 14 : 15,
                ),
              ),
              SizedBox(
                  height: isSmallScreen ? AppSpacing.xs : AppSpacing.sm),
            ],
            _PremiumTimelineItem(
              item: items[i],
              isLast: i == items.length - 1,
            ),
            if (i < items.length - 1)
              SizedBox(
                  height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

/// Premium Timeline Item - Card-like wrapper, pastel tones
class _PremiumTimelineItem extends StatelessWidget {
  const _PremiumTimelineItem({
    required this.item,
    required this.isLast,
  });

  final _TimelineItem item;
  final bool isLast;

  IconData get _icon {
    switch (item.type) {
      case _TimelineItemType.created:
        return Icons.check;
      case _TimelineItemType.milestone:
        return Icons.flag;
      case _TimelineItemType.checkIn:
        return Icons.add_task;
    }
  }

  Color get _iconColor {
    switch (item.type) {
      case _TimelineItemType.created:
      case _TimelineItemType.milestone:
        return AppColors.primary;
      case _TimelineItemType.checkIn:
        return const Color(0xFFF5A623); // Coral
    }
  }

  Color get _backgroundColor {
    switch (item.type) {
      case _TimelineItemType.created:
      case _TimelineItemType.milestone:
        return AppColors.primary;
      case _TimelineItemType.checkIn:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final iconSize = isSmallScreen ? 26.0 : 28.0;
    final iconInnerSize = isSmallScreen ? 14.0 : 16.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator with lighter connecting line (Küçültüldü)
        SizedBox(
          width: iconSize,
          child: Column(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  shape: BoxShape.circle,
                  border: item.type == _TimelineItemType.checkIn
                      ? Border.all(
                          color: _iconColor,
                          width: 2.5,
                        )
                      : null,
                  boxShadow: item.type != _TimelineItemType.checkIn
                      ? [
                          BoxShadow(
                            color: _iconColor.withOpacity(0.25),
                            offset: const Offset(0, 3),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  _icon,
                  size: iconInnerSize,
                  color: item.type == _TimelineItemType.checkIn
                      ? _iconColor
                      : Colors.white,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: isSmallScreen ? 50 : 60,
                  margin: const EdgeInsets.only(top: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color:
                        AppColors.gray200.withOpacity(0.6), // Lighter line
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: isSmallScreen ? AppSpacing.sm : AppSpacing.md),
        // Content with card-like wrapper (Küçültüldü)
        Expanded(
          child: Container(
            padding: EdgeInsets.all(
                isSmallScreen ? AppSpacing.sm : AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 13 : 14,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 2 : AppSpacing.xs),
                Text(
                  item.date,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray600,
                    fontSize: isSmallScreen ? 11 : 12,
                  ),
                ),
                if (item.note != null) ...[
                  SizedBox(
                      height:
                          isSmallScreen ? AppSpacing.xs : AppSpacing.sm),
                  Container(
                    padding: EdgeInsets.all(
                        isSmallScreen ? AppSpacing.xs : AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB), // Pastel background
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.gray200.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      item.note!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray700,
                        fontSize: isSmallScreen ? 11 : 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Notes Tab - Scrollable to prevent overflow
class _NotesTab extends ConsumerWidget {
  const _NotesTab({required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesStreamProvider(goalId));

    return notesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) {
        final errorString = error.toString();
        final isIndexBuilding =
            errorString.contains('failed-precondition') ||
                errorString.contains('index') ||
                errorString.contains('building');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.hourglass_empty_rounded,
                  size: 64,
                  color: AppColors.warning,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  isIndexBuilding
                      ? 'Index Oluşturuluyor'
                      : 'Notlar Yüklenirken Hata',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isIndexBuilding
                      ? 'Firestore index\'i henüz hazır değil. Lütfen birkaç dakika bekleyin ve tekrar deneyin.'
                      : 'Bir hata oluştu. Lütfen tekrar deneyin.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray700,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isIndexBuilding) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          ),
        );
      },
      data: (notes) {
        if (notes.isEmpty) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.note_outlined,
                          size: 64,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Henüz not yok',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'İlk notunuzu ekleyerek başlayın',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.gray500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        FilledButton.icon(
                          onPressed: () =>
                              _showAddNoteDialog(context, ref),
                          icon: Icon(
                            Icons.add_rounded,
                            size: MediaQuery.of(context).size.width < 360
                                ? 18
                                : 20,
                          ),
                          label: Text(
                            'Not Ekle',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize:
                                  MediaQuery.of(context).size.width < 360
                                      ? 13
                                      : 14,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width < 360
                                      ? AppSpacing.lg
                                      : AppSpacing.xl,
                              vertical:
                                  MediaQuery.of(context).size.width < 360
                                      ? AppSpacing.sm
                                      : AppSpacing.md,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.borderRadiusLg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        final padding = isSmallScreen ? AppSpacing.md : AppSpacing.lg;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: isSmallScreen ? 14 : 16,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Notu düzenlemek için karta dokun, silmek için sağdaki çöp ikonuna bas.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.gray500,
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height:
                          isSmallScreen ? AppSpacing.sm : AppSpacing.md),
                  for (int i = 0; i < notes.length; i++) ...[
                    _NoteCard(
                      note: notes[i],
                      onTap: () => _editNote(context, ref, notes[i]),
                      onDelete: () => _deleteNote(context, ref, notes[i]),
                    ),
                    if (i < notes.length - 1)
                      const SizedBox(height: AppSpacing.md),
                  ],
                  // Bottom padding for FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
            // Floating Action Button - Minimal and elegant
            Positioned(
              bottom: 20,
              right: 14,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      offset: const Offset(0, 3),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () => _showAddNoteDialog(context, ref),
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  mini: true,
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size:
                        MediaQuery.of(context).size.width < 360 ? 20 : 22,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddNoteDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AddNoteBottomSheet(
        goalId: goalId,
        ref: ref,
      ),
    );
  }

  Future<void> _editNote(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AddNoteBottomSheet(
        goalId: goalId,
        ref: ref,
        existingNote: note,
      ),
    );
  }

  Future<void> _deleteNote(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusXl,
        ),
        content: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.borderRadiusXl,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Notu Sil',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Bu notu silmek istediğinize emin misiniz?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray700,
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                          color: AppColors.gray300,
                          width: 1.5,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusLg,
                        ),
                      ),
                      child: Text(
                        'İptal',
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.error,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.borderRadiusLg,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Sil',
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
      ),
    );

    if (shouldDelete == true && context.mounted) {
      try {
        // userId ile direkt sil (yeni Firestore yapısı: users/{userId}/notes/{noteId})
        final firestore = ref.read(firestoreProvider);
        await firestore
            .collection('users')
            .doc(note.userId)
            .collection('notes')
            .doc(note.id)
            .delete();
        if (context.mounted) {
          AppSnackbar.showSuccess(context, message: 'Not silindi');
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.showError(
            context,
            message: 'Not silinirken hata oluştu: $e',
          );
        }
      }
    }
  }
}

/// Note Card Widget
class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    this.onTap,
    this.onDelete,
  });

  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy, HH:mm', 'tr_TR');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF3F7FF),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, 8),
              blurRadius: 18,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.note_outlined,
                  size: 18,
                  color: AppColors.gray600,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    dateFormat.format(note.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              note.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray900,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Subtasks Tab - Scrollable + CRUD
class _SubtasksTab extends ConsumerStatefulWidget {
  const _SubtasksTab({
    required this.goalId,
    required this.subGoals,
    required this.goalTitle,
    required this.goalDescription,
    required this.goalCategoryKey,
    this.isGoalCompleted = false,
  });

  final String goalId;
  final List<SubGoal> subGoals;
  final String goalTitle;
  final String? goalDescription;
  final String goalCategoryKey;
  final bool isGoalCompleted;

  @override
  ConsumerState<_SubtasksTab> createState() => _SubtasksTabState();
}

class _SubtasksTabState extends ConsumerState<_SubtasksTab> {
  late List<SubGoal> _subGoals;
  bool _isSuggesting = false;

  @override
  void initState() {
    super.initState();
    _subGoals = List<SubGoal>.from(widget.subGoals);
  }

  Future<void> _suggestSubGoalsWithAI() async {
    if (widget.isGoalCompleted) return;
    if (widget.goalId.isEmpty) return;
    final aiService = ref.read(aiServiceProvider);

    setState(() {
      _isSuggesting = true;
    });

    try {
      final titles = await aiService.suggestSubGoals(
        goalTitle: widget.goalTitle,
        category: widget.goalCategoryKey,
        description: widget.goalDescription,
      );

      if (!mounted) return;

      if (titles.isEmpty) {
        AppSnackbar.showError(
          context,
          message:
              'Şu anda alt görev önerisi üretilemedi. Lütfen tekrar dene.',
        );
        return;
      }

      final selected = await showModalBottomSheet<List<String>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          final ValueNotifier<Set<int>> selectedIndexes =
              ValueNotifier<Set<int>>(
            {for (int i = 0; i < titles.length; i++) i},
          );

          return Container(
            color: Colors.black.withOpacity(0.35),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.borderRadiusXl,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.16),
                          blurRadius: 30,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'AI ile alt görev önerileri',
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () =>
                                  Navigator.of(context).pop(<String>[]),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Bu hedef için önerilen alt görevlerden istediklerini seçip listeye ekleyebilirsin.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ConstrainedBox(
                          constraints:
                              const BoxConstraints(maxHeight: 320),
                          child: ValueListenableBuilder<Set<int>>(
                            valueListenable: selectedIndexes,
                            builder: (context, selectedSet, _) {
                              return ListView.separated(
                                shrinkWrap: true,
                                itemCount: titles.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, index) {
                                  final isSelected =
                                      selectedSet.contains(index);
                                  final title = titles[index];
                                  return InkWell(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    onTap: () {
                                      final next =
                                          Set<int>.from(selectedSet);
                                      if (isSelected) {
                                        next.remove(index);
                                      } else {
                                        next.add(index);
                                      }
                                      selectedIndexes.value = next;
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.md,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.gray200,
                                        ),
                                        color: isSelected
                                            ? AppColors.primary
                                                .withOpacity(0.06)
                                            : Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSelected
                                                ? Icons
                                                    .check_circle_rounded
                                                : Icons
                                                    .radio_button_unchecked,
                                            size: 20,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.gray400,
                                          ),
                                          const SizedBox(
                                            width: AppSpacing.sm,
                                          ),
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: AppTextStyles
                                                  .bodyMedium
                                                  .copyWith(
                                                color: AppColors.gray900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(<String>[]),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadius.borderRadiusLg,
                                  ),
                                ),
                                child: Text(
                                  'İptal',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  final currentSelection =
                                      selectedIndexes.value;
                                  final selectedTitles = <String>[];
                                  for (final index in currentSelection) {
                                    if (index >= 0 &&
                                        index < titles.length) {
                                      selectedTitles.add(titles[index]);
                                    }
                                  }
                                  Navigator.of(context)
                                      .pop(selectedTitles);
                                },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadius.borderRadiusLg,
                                  ),
                                ),
                                child: Text(
                                  'Seçilenleri ekle',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

      if (!mounted) return;

      final selectedTitles = selected ?? <String>[];
      if (selectedTitles.isEmpty) {
        return;
      }

      setState(() {
        _subGoals = [
          ..._subGoals,
          for (final title in selectedTitles)
            SubGoal(
              id: const Uuid().v4(),
              title: title,
            ),
        ];
      });

      await _saveSubGoals();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        message: e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSuggesting = false;
        });
      }
    }
  }

  Future<void> _saveSubGoals() async {
    if (widget.isGoalCompleted) return;
    if (widget.goalId.isEmpty) return;
    final current =
        await ref.read(goalDetailProvider(widget.goalId).future);
    if (current == null) return;

    final repository = ref.read(goalRepositoryProvider);

    // Alt görevler tek ilerleme kaynağı: oran neyse progress de o olmalı.
    int newProgress = current.progress;
    if (_subGoals.isNotEmpty) {
      final completedCount =
          _subGoals.where((sg) => sg.isCompleted).length.toDouble();
      final ratio = completedCount / _subGoals.length;
      newProgress = (ratio * 100).round().clamp(0, 100);
    } else {
      newProgress = 0;
    }

    await repository.updateGoal(
      current.copyWith(
        subGoals: _subGoals,
        progress: newProgress,
      ),
    );
    ref.invalidate(goalsStreamProvider);
    ref.invalidate(goalDetailProvider(widget.goalId));

    if (!mounted) return;
  }

  Future<void> _toggleCompleted(SubGoal subGoal) async {
    if (widget.isGoalCompleted) return;
    setState(() {
      _subGoals = _subGoals
          .map(
            (sg) => sg.id == subGoal.id
                ? SubGoal(
                    id: sg.id,
                    title: sg.title,
                    isCompleted: !sg.isCompleted,
                    dueDate: sg.dueDate,
                  )
                : sg,
          )
          .toList();
    });
    await _saveSubGoals();
  }

  Future<void> _deleteSubGoal(SubGoal subGoal) async {
    if (widget.isGoalCompleted) return;
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => AlertDialog(
        title: const Text('Alt görevi sil'),
        content: const Text('Bu alt görevi silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Sil',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() {
      _subGoals = _subGoals.where((sg) => sg.id != subGoal.id).toList();
    });
    await _saveSubGoals();
  }

  Future<void> _showEditDialog({SubGoal? existing}) async {
    if (widget.isGoalCompleted) return;
    final controller = TextEditingController(text: existing?.title ?? '');
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Container(
          color: Colors.black.withOpacity(0.35),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.borderRadiusXl,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            existing == null
                                ? 'Alt Görev Ekle'
                                : 'Alt Görevi Düzenle',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Bu hedefe ait küçük, uygulanabilir bir adım tanımla.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        controller: controller,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'Örn: Haftada 3 gün 30 dakika İngilizce çalışmak',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.gray400,
                          ),
                          contentPadding: const EdgeInsets.all(
                            AppSpacing.md,
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: AppRadius.borderRadiusLg,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: AppRadius.borderRadiusLg,
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadius.borderRadiusLg,
                                ),
                              ),
                              child: Text(
                                'İptal',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                final text = controller.text.trim();
                                if (text.isEmpty) return;
                                Navigator.of(context).pop(text);
                              },
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadius.borderRadiusLg,
                                ),
                              ),
                              child: Text(
                                'Kaydet',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (result == null || result.trim().isEmpty) return;

    setState(() {
      if (existing == null) {
        _subGoals = [
          ..._subGoals,
          SubGoal(
            id: const Uuid().v4(),
            title: result.trim(),
          ),
        ];
      } else {
        _subGoals = _subGoals
            .map(
              (sg) => sg.id == existing.id
                  ? SubGoal(
                      id: sg.id,
                      title: result.trim(),
                      isCompleted: sg.isCompleted,
                      dueDate: sg.dueDate,
                    )
                  : sg,
            )
            .toList();
      }
    });

    await _saveSubGoals();
  }

  @override
  Widget build(BuildContext context) {
    if (_subGoals.isEmpty) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 400,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF5F7FF),
                      Color(0xFFEFF3FF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon + halo
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFE0ECFF),
                            Color(0xFFD0E2FF),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.task_alt_rounded,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Bu hedefi adımlara bölelim',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Alt görevler, hedefini günlük ve haftalık uygulanabilir adımlara dönüştürmene yardım eder.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.gray600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'İstersen AI senin için öneri üretsin',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.gray700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _showEditDialog(),
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.width < 360
                                        ? 12
                                        : 13,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadius.borderRadiusLg,
                              ),
                            ),
                            child: Text(
                              'Alt Görev Oluştur',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width < 360
                                        ? 13
                                        : 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton.icon(
                      onPressed:
                          _isSuggesting ? null : _suggestSubGoalsWithAI,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: _isSuggesting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.auto_awesome_rounded,
                              size: 18,
                            ),
                      label: Text(
                        'AI ile alt görev öner',
                        style: AppTextStyles.bodySmall.copyWith(
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
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = isSmallScreen ? AppSpacing.md : AppSpacing.lg;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: isSmallScreen ? 14 : 16,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alt görevi düzenlemek için karta dokun, tamamlamak için soldaki çembere bas.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.gray500,
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextButton.icon(
                          onPressed: _isSuggesting
                              ? null
                              : _suggestSubGoalsWithAI,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size.zero,
                          ),
                          icon: _isSuggesting
                              ? SizedBox(
                                  width: isSmallScreen ? 12 : 14,
                                  height: isSmallScreen ? 12 : 14,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.auto_awesome_rounded,
                                  size: isSmallScreen ? 14 : 15,
                                ),
                          label: Text(
                            'AI ile alt görev öner',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 11 : 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
              for (int i = 0; i < _subGoals.length; i++) ...[
                _SubtaskCard(
                  subGoal: _subGoals[i],
                  onToggle: widget.isGoalCompleted
                      ? null
                      : () => _toggleCompleted(_subGoals[i]),
                  onEdit: widget.isGoalCompleted
                      ? null
                      : () => _showEditDialog(existing: _subGoals[i]),
                  onDelete: widget.isGoalCompleted
                      ? null
                      : () => _deleteSubGoal(_subGoals[i]),
                ),
                if (i < _subGoals.length - 1)
                  SizedBox(
                      height:
                          isSmallScreen ? AppSpacing.md : AppSpacing.lg),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
        if (!widget.isGoalCompleted)
          Positioned(
            bottom: 20,
            right: 14,
            child: FloatingActionButton(
              onPressed: () => _showEditDialog(),
              backgroundColor: AppColors.primary,
              elevation: 0,
              mini: true,
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: MediaQuery.of(context).size.width < 360 ? 20 : 22,
              ),
            ),
          ),
      ],
    );
  }
}

/// Subtask Card Widget
class _SubtaskCard extends StatelessWidget {
  const _SubtaskCard({
    required this.subGoal,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  final SubGoal subGoal;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final cardPadding = isSmallScreen ? AppSpacing.sm : AppSpacing.md;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F8FF),
              Color(0xFFE8F0FF),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, 6),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox (Küçültüldü)
            InkWell(
              onTap: onToggle,
              child: Container(
                width: isSmallScreen ? 22 : 24,
                height: isSmallScreen ? 22 : 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: subGoal.isCompleted
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF2563EB),
                          ],
                        )
                      : const LinearGradient(
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFFE5EDFF),
                          ],
                        ),
                  border: Border.all(
                    color: subGoal.isCompleted
                        ? AppColors.primary
                        : AppColors.gray300,
                    width: 2,
                  ),
                  boxShadow: subGoal.isCompleted
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: subGoal.isCompleted
                    ? Icon(
                        Icons.check,
                        size: isSmallScreen ? 14 : 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            SizedBox(width: isSmallScreen ? AppSpacing.sm : AppSpacing.md),
            // Task content (Küçültüldü)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subGoal.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: subGoal.isCompleted
                          ? AppColors.gray600
                          : AppColors.gray900,
                      fontSize: isSmallScreen ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      decoration: subGoal.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: isSmallScreen ? 18 : 20,
                color: AppColors.error,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Add Note Bottom Sheet
class _AddNoteBottomSheet extends ConsumerStatefulWidget {
  const _AddNoteBottomSheet({
    required this.goalId,
    required this.ref,
    this.existingNote,
  });

  final String goalId;
  final WidgetRef ref;
  final Note? existingNote;

  @override
  ConsumerState<_AddNoteBottomSheet> createState() =>
      _AddNoteBottomSheetState();
}

class _AddNoteBottomSheetState extends ConsumerState<_AddNoteBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController =
      TextEditingController(text: widget.existingNote?.content ?? '');
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final content = _contentController.text.trim();
    if (content.isEmpty) {
      AppSnackbar.showError(context, message: 'Lütfen not içeriği girin');
      return;
    }

    final userId = widget.ref.read(currentUserIdProvider);
    if (userId == null) {
      AppSnackbar.showError(context, message: 'Giriş yapmanız gerekiyor');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = widget.ref.read(goalRepositoryProvider);
      final note = widget.existingNote == null
          ? Note(
              id: const Uuid().v4(),
              goalId: widget.goalId,
              userId: userId,
              createdAt: DateTime.now(),
              content: content,
            )
          : Note(
              id: widget.existingNote!.id,
              goalId: widget.existingNote!.goalId,
              userId: widget.existingNote!.userId,
              createdAt: widget.existingNote!.createdAt,
              content: content,
            );

      await repository.addNote(note);

      if (mounted) {
        AppSnackbar.showSuccess(context, message: 'Not eklendi');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          message: 'Not eklenirken hata oluştu: $e',
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
                widget.existingNote == null
                    ? 'Yeni Not Ekle'
                    : 'Notu Düzenle',
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
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _contentController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Not İçeriği',
                hintText: 'Notunuzu buraya yazın...',
                border: OutlineInputBorder(
                  borderRadius: AppRadius.borderRadiusLg,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lütfen not içeriği girin';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
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
                  child: Text(
                    'İptal',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusLg,
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                      : Text(
                          'Kaydet',
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
    );
  }
}

/// Premium Bottom Button - Increased visual weight
class _PremiumBottomButton extends StatelessWidget {
  const _PremiumBottomButton({
    required this.goalId,
    required this.onCheckInCompleted,
  });

  final String goalId;
  final VoidCallback onCheckInCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.xl,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _GoalDetailPageState._premiumBackground.withOpacity(0),
            Colors.white,
          ],
          stops: const [0.0, 0.4],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3B82F6),
                Color(0xFF2563EB),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                offset: const Offset(0, 10),
                blurRadius: 24,
                spreadRadius: -4,
              ),
            ],
          ),
          child: FilledButton(
            onPressed: () async {
              final result = await context.push(
                AppRoutes.checkInPath(goalId),
              );
              if (result == true) {
                onCheckInCompleted();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: const Size.fromHeight(60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 22,
                  color: Colors.white,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Check-in Yap',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
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

/// Complete Confirmation Dialog
class _CompleteConfirmationDialog extends StatelessWidget {
  const _CompleteConfirmationDialog({required this.goalTitle});

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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.borderRadiusXl,
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
                Icons.check_circle_outline,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Hedefi Tamamla',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '"$goalTitle" hedefini tamamlamak istediğinize emin misiniz?',
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
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusMd,
                      ),
                    ),
                    child: const Text('İptal'),
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
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusMd,
                      ),
                    ),
                    child: const Text('Tamamla'),
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

/// Delete Confirmation Dialog
class _DeleteConfirmationDialog extends StatelessWidget {
  const _DeleteConfirmationDialog({required this.goalId});

  final String goalId;

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
          color: AppColors.white,
          borderRadius: AppRadius.borderRadiusXl,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF7070),
                    Color(0xFFDC2626),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Hedefi Sil',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bu hedefi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray700,
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: AppColors.gray300,
                        width: 1.5,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusLg,
                      ),
                    ),
                    child: Text(
                      'İptal',
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFFFF5252),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusLg,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Sil',
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
