import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

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

  @override
  Widget build(BuildContext context) {
    // Mock goal data
    final goal = _mockGoal;

    return Scaffold(
      backgroundColor: _premiumBackground,
      body: Column(
        children: [
          // Minimal App Bar
          SafeArea(
            bottom: false,
            child: _PremiumAppBar(goalId: widget.goalId),
          ),

          // Header Section with Progress - Compact
          _PremiumHeaderSection(goal: goal),

          // Tab Navigation
          _PremiumTabBar(controller: _tabController),

          // Tab Content - Expanded to take remaining space
          Expanded(
            child: Container(
              color: _premiumBackground,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TimelineTab(timelineItems: goal.timelineItems),
                  _NotesTab(notes: goal.notes),
                  _SubtasksTab(subtasks: goal.subtasks),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom Action Button - Fixed with gradient
      bottomNavigationBar: _PremiumBottomButton(goalId: widget.goalId),
    );
  }
}

class _PremiumAppBar extends StatelessWidget {
  const _PremiumAppBar({required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context) {
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
            'Tamamlandı',
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
                    Icon(
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
  bool shouldRepaint(covariant _GradientCircularProgressPainter oldDelegate) {
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
    required this.notes,
    required this.subtasks,
  });

  final String title;
  final String category;
  final double progress;
  final String nextCheckIn;
  final Color categoryColor;
  final Color categoryBackgroundColor;
  final List<_TimelineItem> timelineItems;
  final List<_Note> notes;
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
      note: 'Bu hafta dil pratiği için bir partner buldum. Konuşma becerilerim hızla gelişiyor!',
    ),
  ],
  notes: const [
    _Note(
      content: 'Duolingo uygulaması ile günde 30 dakika çalışıyorum. Temel kelimeleri öğrenmeye başladım.',
      date: '20 Kasım',
    ),
    _Note(
      content: 'Yerel bir dil değişim grubuna katıldım. Haftada 2 kez buluşuyoruz ve pratik yapıyoruz.',
      date: '5 Aralık',
    ),
    _Note(
      content: 'İlk basit cümleleri kurmaya başladım. Gramer kurallarını öğrenmek için bir kitap aldım.',
      date: '12 Aralık',
    ),
  ],
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < timelineItems.length; i++) ...[
            _PremiumTimelineItem(
              item: timelineItems[i],
              isLast: i == timelineItems.length - 1,
            ),
            if (i < timelineItems.length - 1)
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
                    color: AppColors.gray200.withOpacity(0.6), // Lighter line
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
class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.notes});

  final List<_Note> notes;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
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
                  Icons.note_outlined,
                  size: 64,
                  color: AppColors.gray400,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Henüz not yok',
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
          for (int i = 0; i < notes.length; i++) ...[
            _NoteCard(note: notes[i]),
            if (i < notes.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

/// Note Card Widget
class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final _Note note;

  @override
  Widget build(BuildContext context) {
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
              Icon(
                Icons.note_outlined,
                size: 18,
                color: AppColors.gray600,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                note.date,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
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
            if (i < subtasks.length - 1) const SizedBox(height: AppSpacing.md),
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
                      Icon(
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

/// Premium Bottom Button - Increased visual weight
class _PremiumBottomButton extends StatelessWidget {
  const _PremiumBottomButton({required this.goalId});

  final String goalId;

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
            onPressed: () {
              context.push(AppRoutes.checkInPath(goalId));
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
