import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_progress_bar.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Navigate to edit goal
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              children: [
                // Goal Title
                Text(
                  goal.title,
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                // Category Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: goal.categoryBackgroundColor.withOpacity(0.2),
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                  child: Text(
                    goal.category,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: goal.categoryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Progress Ring
                Column(
                  children: [
                    AppCircularProgress(
                      progress: goal.progress,
                      size: 192,
                      strokeWidth: 12,
                      progressColor: goal.categoryColor,
                      backgroundColor: AppColors.gray200,
                      showPercentage: true,
                      percentageStyle: AppTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tamamlandı',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Next Check-in Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppColors.gray600,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Sonraki Check-in: ${goal.nextCheckIn}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Navigation
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.gray600,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              labelStyle: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Timeline'),
                Tab(text: 'Notlar'),
                Tab(text: 'Alt Görevler'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: Container(
              color: Colors.white,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TimelineTab(timelineItems: goal.timelineItems),
                  const _NotesTab(),
                  const _SubtasksTab(),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0),
                  Colors.white,
                ],
              ),
            ),
            child: AppButton(
              variant: AppButtonVariant.filled,
              onPressed: () {
                context.push(AppRoutes.checkInPath(widget.goalId));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 20),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Check-in Yap',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
  });

  final String title;
  final String category;
  final double progress;
  final String nextCheckIn;
  final Color categoryColor;
  final Color categoryBackgroundColor;
  final List<_TimelineItem> timelineItems;
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
);

/// Timeline Tab
class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.timelineItems});

  final List<_TimelineItem> timelineItems;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          for (int i = 0; i < timelineItems.length; i++) ...[
            _TimelineItemWidget(
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

/// Timeline Item Widget
class _TimelineItemWidget extends StatelessWidget {
  const _TimelineItemWidget({
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
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _backgroundColor,
                shape: BoxShape.circle,
                border: item.type == _TimelineItemType.checkIn
                    ? Border.all(
                        color: _iconColor,
                        width: 2,
                      )
                    : null,
              ),
              child: Icon(
                _icon,
                size: 14,
                color: item.type == _TimelineItemType.checkIn
                    ? _iconColor
                    : Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: AppColors.gray200,
                margin: const EdgeInsets.only(top: AppSpacing.xs),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.date,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                ),
              ),
              if (item.note != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: AppSpacing.paddingSm,
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Text(
                    item.note!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Notes Tab
class _NotesTab extends StatelessWidget {
  const _NotesTab();

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}

/// Subtasks Tab
class _SubtasksTab extends StatelessWidget {
  const _SubtasksTab();

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}

