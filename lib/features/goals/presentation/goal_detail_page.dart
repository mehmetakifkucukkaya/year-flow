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
        final progressText = checkIn.progressDelta > 0
            ? '+${checkIn.progressDelta}% İlerleme'
            : '${checkIn.progressDelta}% İlerleme';
        items.add(_TimelineItem(
          title: 'Check-in Yapıldı: $progressText',
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
                  child: _PremiumAppBar(goalId: widget.goalId),
                ),
                _PremiumHeaderSection(
                  goal: goal != null
                      ? _GoalDetail(
                          title: goal.title,
                          category: goal.category.label,
                          progress: goal.progress.toDouble(),
                          nextCheckIn: _formatNextCheckIn(goal),
                          categoryColor: _getCategoryColor(goal.category),
                          categoryBackgroundColor:
                              _getCategoryColor(goal.category)
                                  .withOpacity(0.1),
                          timelineItems: [],
                          goalId: widget.goalId,
                          subtasks: [],
                        )
                      : _mockGoal,
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
                  child: _PremiumAppBar(goalId: widget.goalId),
                ),
                _PremiumHeaderSection(
                  goal: goal != null
                      ? _GoalDetail(
                          title: goal.title,
                          category: goal.category.label,
                          progress: goal.progress.toDouble(),
                          nextCheckIn: _formatNextCheckIn(goal),
                          categoryColor: _getCategoryColor(goal.category),
                          categoryBackgroundColor:
                              _getCategoryColor(goal.category)
                                  .withOpacity(0.1),
                          timelineItems: [],
                          goalId: widget.goalId,
                          subtasks: [],
                        )
                      : _mockGoal,
                ),
                Expanded(
                  child: Center(
                    child: Text('Check-inler yüklenirken hata: $error'),
                  ),
                ),
              ],
            ),
            data: (checkIns) {
              final timelineItems = _buildTimelineItems(goal, checkIns);

              final goalDetail = goal != null
                  ? _GoalDetail(
                      title: goal.title,
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
                    )
                  : _mockGoal;

              return Column(
                children: [
                  // Minimal App Bar
                  SafeArea(
                    bottom: false,
                    child: _PremiumAppBar(goalId: widget.goalId),
                  ),

                  // Header Section with Progress - Compact
                  _PremiumHeaderSection(goal: goalDetail),

                  // Tab Navigation
                  _PremiumTabBar(controller: _tabController),

                  // Tab Content - Expanded to take remaining space
                  Expanded(
                    child: Container(
                      color: _premiumBackground,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _TimelineTab(timelineItems: timelineItems),
                          _NotesTab(goalId: goalDetail.goalId),
                          _SubtasksTab(subtasks: goalDetail.subtasks),
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
      // Bottom Action Button - Fixed with gradient
      bottomNavigationBar: _PremiumBottomButton(
        goalId: widget.goalId,
        onCheckInCompleted: _handleCheckInCompleted,
      ),
    );
  }

  Color _getCategoryColor(GoalCategory category) {
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
        return AppColors.primary;
    }
  }

  void _handleCheckInCompleted() {
    // Check-in zaten Firestore'a kaydedildi, stream otomatik güncellenecek
    AppSnackbar.showSuccess(
      context,
      message: 'Check-in kaydedildi',
    );
  }
}

class _PremiumAppBar extends ConsumerWidget {
  const _PremiumAppBar({required this.goalId});

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
                        final repository =
                            ref.read(goalRepositoryProvider);
                        await repository.deleteGoal(goalId);
                        if (context.mounted) {
                          ref.invalidate(goalsStreamProvider);
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

/// Premium Header Section
class _PremiumHeaderSection extends StatelessWidget {
  const _PremiumHeaderSection({required this.goal});

  final _GoalDetail goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _GoalDetailPageState._premiumBackground,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Goal Title - Emoji + compact spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🌍',
                style: TextStyle(fontSize: 26),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  goal.title,
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    letterSpacing: -0.6,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Category Chip - Softer pastel colors
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
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
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Premium Progress Ring - Smaller size
          _PremiumCircularProgress(
            progress: goal.progress,
            progressColor: goal.categoryColor,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Status Text - More visible
          Text(
            'İlerleme Kaydedildi',
            style: AppTextStyles.bodyMedium.copyWith(
              color: _GoalDetailPageState._statusTextColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Next Check-in Card - Frosted glass effect with subtle arrow
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
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
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppColors.gray600,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Sonraki Check-in: ${goal.nextCheckIn}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
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

/// Premium Circular Progress - With gradient and shadow (Compact size)
class _PremiumCircularProgress extends StatelessWidget {
  const _PremiumCircularProgress({
    required this.progress,
    required this.progressColor,
  });

  final double progress;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    const size = 170.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: progressColor.withOpacity(0.22),
            offset: const Offset(0, 18),
            blurRadius: 36,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gradient progress + track
          CustomPaint(
            size: const Size.square(size),
            painter: _GradientCircularProgressPainter(
              progress: progress / 100,
              baseColor: AppColors.gray200,
              progressColor: progressColor,
            ),
          ),
          // Inner glow circle
          Container(
            width: size - 32,
            height: size - 32,
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
                  fontSize: 38,
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
  });

  final double progress;
  final Color baseColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;

    final basePaint = Paint()
      ..color = baseColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 12
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
        oldDelegate.progressColor != progressColor;
  }
}

/// Premium Tab Bar - Elegant design with pill highlight
class _PremiumTabBar extends StatelessWidget {
  const _PremiumTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _GoalDetailPageState._premiumBackground,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
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
            fontSize: 14,
          ),
          unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
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
    required this.category,
    required this.progress,
    required this.nextCheckIn,
    required this.categoryColor,
    required this.categoryBackgroundColor,
    required this.timelineItems,
    required this.goalId,
    required this.subtasks,
  });

  final String title;
  final String category;
  final double progress;
  final String nextCheckIn;
  final Color categoryColor;
  final Color categoryBackgroundColor;
  final List<_TimelineItem> timelineItems;
  final String goalId;
  final List<_Subtask> subtasks;
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

/// Mock goal data
final _mockGoal = _GoalDetail(
  title: 'Yeni Bir Dil Öğren',
  category: 'Kişisel Gelişim',
  progress: 65,
  nextCheckIn: '25 Aralık',
  categoryColor: AppColors.primary,
  categoryBackgroundColor: AppColors.primary.withOpacity(0.1),
  timelineItems: const [
    _TimelineItem(
      title: 'Hedef Oluşturuldu',
      date: '15 Kasım',
      type: _TimelineItemType.created,
    ),
    _TimelineItem(
      title: 'İlk 100 Kelime Öğrenildi',
      date: '28 Kasım',
      type: _TimelineItemType.milestone,
    ),
    _TimelineItem(
      title: 'Check-in Yapıldı: +15% İlerleme',
      date: '10 Aralık',
      type: _TimelineItemType.checkIn,
      note:
          'Bu hafta dil pratiği için bir partner buldum. Konuşma becerilerim hızla gelişiyor!',
    ),
  ],
  goalId: '',
  subtasks: const [
    _Subtask(
      title: 'Günlük 30 kelime öğren',
      isCompleted: true,
      dueDate: '20 Kasım',
    ),
    _Subtask(
      title: 'Temel gramer kurallarını öğren',
      isCompleted: true,
      dueDate: '10 Aralık',
    ),
    _Subtask(
      title: 'İlk basit diyalog yap',
      isCompleted: false,
      dueDate: '30 Aralık',
    ),
    _Subtask(
      title: '1000 kelime hazinesi oluştur',
      isCompleted: false,
      dueDate: '15 Ocak',
    ),
    _Subtask(
      title: 'İlk kitabı oku',
      isCompleted: false,
      dueDate: '1 Şubat',
    ),
  ],
);

/// Timeline Tab - Premium design with more spacing
class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.timelineItems});

  final List<_TimelineItem> timelineItems;

  @override
  Widget build(BuildContext context) {
    final items = List<_TimelineItem>.from(timelineItems);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            _PremiumTimelineItem(
              item: items[i],
              isLast: i == items.length - 1,
            ),
            if (i < items.length - 1)
              const SizedBox(height: AppSpacing.lg),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator with lighter connecting line
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
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
                  size: 16,
                  color: item.type == _TimelineItemType.checkIn
                      ? _iconColor
                      : Colors.white,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
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
        const SizedBox(width: AppSpacing.lg),
        // Content with card-like wrapper
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.date,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray600,
                    fontSize: 13,
                  ),
                ),
                if (item.note != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB), // Pastel background
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.gray200.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      item.note!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray700,
                        fontSize: 13,
                        height: 1.5,
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
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Not Ekle'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.md,
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

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < notes.length; i++) ...[
                    _NoteCard(
                      note: notes[i],
                      onDelete: () =>
                          _deleteNote(context, ref, notes[i].id),
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
                  onPressed: () => _showAddNoteDialog(context, ref),
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 24,
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
      builder: (context) => _AddNoteBottomSheet(goalId: goalId, ref: ref),
    );
  }

  Future<void> _deleteNote(
    BuildContext context,
    WidgetRef ref,
    String noteId,
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
        final repository = ref.read(goalRepositoryProvider);
        await repository.deleteNote(noteId);
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
    this.onDelete,
  });

  final Note note;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy, HH:mm', 'tr_TR');

    return Container(
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
    );
  }
}

/// Subtasks Tab - Scrollable to prevent overflow
class _SubtasksTab extends StatelessWidget {
  const _SubtasksTab({required this.subtasks});

  final List<_Subtask> subtasks;

  @override
  Widget build(BuildContext context) {
    if (subtasks.isEmpty) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 400,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.task_outlined,
                  size: 64,
                  color: AppColors.gray400,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Henüz alt görev yok',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < subtasks.length; i++) ...[
            _SubtaskCard(subtask: subtasks[i]),
            if (i < subtasks.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

/// Subtask Card Widget
class _SubtaskCard extends StatelessWidget {
  const _SubtaskCard({required this.subtask});

  final _Subtask subtask;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5F8FF),
            Color(0xFFE8F0FF),
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
      child: Row(
        children: [
          // Checkbox
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: subtask.isCompleted
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
                color: subtask.isCompleted
                    ? AppColors.primary
                    : AppColors.gray300,
                width: 2,
              ),
              boxShadow: subtask.isCompleted
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: subtask.isCompleted
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          // Task content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtask.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: subtask.isCompleted
                        ? AppColors.gray600
                        : AppColors.gray900,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: subtask.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (subtask.dueDate != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Bitiş: ${subtask.dueDate}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Add Note Bottom Sheet
class _AddNoteBottomSheet extends ConsumerStatefulWidget {
  const _AddNoteBottomSheet({
    required this.goalId,
    required this.ref,
  });

  final String goalId;
  final WidgetRef ref;

  @override
  ConsumerState<_AddNoteBottomSheet> createState() =>
      _AddNoteBottomSheetState();
}

class _AddNoteBottomSheetState extends ConsumerState<_AddNoteBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
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
      final note = Note(
        id: const Uuid().v4(),
        goalId: widget.goalId,
        userId: userId,
        createdAt: DateTime.now(),
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
                'Yeni Not Ekle',
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
