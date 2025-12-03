import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/index.dart';
import '../../../shared/models/goal.dart';
import '../../../shared/providers/goal_providers.dart';
import 'widgets/ai_optimize_bottom_sheet.dart';
import 'widgets/goal_form_widgets.dart';

class GoalEditPage extends ConsumerStatefulWidget {
  const GoalEditPage({
    super.key,
    required this.goalId,
  });

  final String goalId;

  @override
  ConsumerState<GoalEditPage> createState() => _GoalEditPageState();
}

class _GoalEditPageState extends ConsumerState<GoalEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _reasonController;

  GoalCategory? _selectedCategory;
  DateTime? _completionDate;
  List<SubGoal> _subGoals = const [];

  // Premium background color
  static const Color _premiumBackground = Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _reasonController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Goal'u yükle ve formu doldur
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    final goalAsync = ref.read(goalDetailProvider(widget.goalId));
    goalAsync.when(
      data: (goal) {
        if (goal != null && mounted) {
          _titleController.text = goal.title;
          _reasonController.text = goal.description ?? '';
          _selectedCategory = goal.category;
          _completionDate = goal.targetDate;
          _subGoals = goal.subGoals;
          setState(() {});
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: _completionDate ?? now.add(const Duration(days: 365)),
      firstDate: tomorrow, // Geçmiş tarih ve bugün seçilemez
      lastDate: now.add(const Duration(days: 365 * 2)),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() {
        _completionDate = picked;
      });
      // Validate form after date selection
      _formKey.currentState?.validate();
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    try {
      final repository = ref.read(goalRepositoryProvider);
      final currentGoal = await repository.fetchGoalById(widget.goalId);

      if (currentGoal == null) {
        if (mounted) {
          AppSnackbar.showError(context, message: 'Hedef bulunamadı');
        }
        return;
      }

      final updatedGoal = currentGoal.copyWith(
        title: _titleController.text.trim(),
        category: _selectedCategory!,
        targetDate: _completionDate,
        description: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        subGoals: _subGoals,
      );

      await repository.updateGoal(updatedGoal);

      if (mounted) {
        // Stream'i yeniden başlatmak için invalidate et
        ref.invalidate(goalsStreamProvider);
        // Goal detail'i de invalidate et
        ref.invalidate(goalDetailProvider(widget.goalId));

        AppSnackbar.showSuccess(context, message: 'Hedef güncellendi! ✅');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          message: 'Hedef güncellenirken bir hata oluştu: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _handleAIOptimize() async {
    // Validate all required fields before AI optimization
    if (!_formKey.currentState!.validate()) {
      AppSnackbar.showError(
        context,
        message: 'Lütfen formdaki tüm alanları doldurun',
      );
      return;
    }

    if (_selectedCategory == null) {
      AppSnackbar.showError(context, message: 'Lütfen bir kategori seçin');
      return;
    }

    if (_completionDate == null) {
      AppSnackbar.showError(context, message: 'Lütfen tamamlanma tarihi seçin');
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      AppSnackbar.showError(
        context,
        message: 'Lütfen bu hedefi neden istediğinizi açıklayın',
      );
      return;
    }

    // Show bottom sheet with AI optimization
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIOptimizeBottomSheet(
        goalTitle: _titleController.text.trim(),
        category: _selectedCategory!.name,
        targetDate: _completionDate,
        motivation: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        onApply: (result) {
          // Apply AI optimization to form
          setState(() {
            // Kısa başlık
            _titleController.text = result.optimizedTitle;
            // Alt görevleri güncelle
            _subGoals = result.subGoals;
            // Detaylı SMART açıklamasını motivasyon alanına öneri olarak doldur
            if (_reasonController.text.trim().isEmpty) {
              _reasonController.text = result.explanation;
            }
          });

          AppSnackbar.showSuccess(
            context,
            message: 'Hedef optimize edildi! ✨',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _premiumBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm),
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            iconSize: 24,
          ),
        ),
        title: Text(
          'Hedefi Düzenle',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoalFormFields(
              formKey: _formKey,
              titleController: _titleController,
              reasonController: _reasonController,
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category as GoalCategory?;
                });
              },
              completionDate: _completionDate,
              onDateSelected: _selectDate,
            ),
          ),
          Container(
              padding: AppSpacing.paddingMd,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.gray200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.borderRadiusMd,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _handleAIOptimize,
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              AppColors.primary.withOpacity(0.1),
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 60),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide.none,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 22,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'AI ile Optimize Et',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    variant: AppButtonVariant.filled,
                    onPressed: _handleSave,
                    minHeight: 60,
                    child: Text(
                      'Güncelle',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
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
