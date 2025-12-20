import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/feedback_helper.dart';
import '../../../core/widgets/index.dart';
import '../../../shared/models/goal.dart';
import '../../../shared/providers/goal_providers.dart';
import 'widgets/ai_optimize_bottom_sheet.dart';
import 'widgets/goal_form_widgets.dart';

class GoalCreatePage extends ConsumerStatefulWidget {
  const GoalCreatePage({super.key});

  @override
  ConsumerState<GoalCreatePage> createState() => _GoalCreatePageState();
}

class _GoalCreatePageState extends ConsumerState<GoalCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _reasonController = TextEditingController();
  List<SubGoal> _subGoals = const [];
  GoalCategory? _selectedCategory;
  DateTime? _completionDate;
  bool _isSaving = false; // Prevent multiple saves

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
      initialDate: _completionDate ?? tomorrow,
      firstDate: tomorrow, // Geçmiş tarih ve bugün seçilemez
      lastDate: now.add(const Duration(days: 365 * 2)),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() {
        _completionDate = picked;
        // Validate form after date selection
        _formKey.currentState?.validate();
      });
    }
  }

  void _scrollToFirstError() {
    // Find the first error field and scroll to it
    final formState = _formKey.currentState;
    if (formState != null) {
      // Trigger validation to show errors
      formState.validate();
    }
  }

  Future<void> _handleSave() async {
    // Prevent multiple saves
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      // Form validation failed, scroll to first error
      _scrollToFirstError();
      return;
    }

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      AppSnackbar.showError(context, message: context.l10n.loginRequired);
      return;
    }

    if (!mounted) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = ref.read(goalRepositoryProvider);

      final goal = Goal(
        id: const Uuid().v4(),
        userId: userId,
        title: _titleController.text.trim(),
        category: _selectedCategory!,
        createdAt: DateTime.now(),
        targetDate: _completionDate,
        description: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        subGoals: _subGoals,
        progress: 0,
        isArchived: false,
        isCompleted: false,
      );

      await repository.createGoal(goal);

      if (mounted) {
        // Stream'i yeniden başlatmak için invalidate et
        ref.invalidate(goalsStreamProvider);

        // Önce kullanıcıyı bilgilendir
        FeedbackHelper.showSuccess(
          context,
          context.l10n.goalCreatedSuccess,
        );

        // Snackbar görünsün diye kısa bekle, sonra sayfayı kapat
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          context.pop();
        }
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        final appError = ErrorHandler.handle(e, stackTrace);
        FeedbackHelper.showAppError(
          context,
          appError,
        );
      }
    }
  }

  Future<void> _handleAIOptimize() async {
    // Validate all required fields before AI optimization
    if (!_formKey.currentState!.validate()) {
      _scrollToFirstError();
      AppSnackbar.showError(
        context,
        message: context.l10n.pleaseFillAllFields,
      );
      return;
    }

    if (_selectedCategory == null) {
      AppSnackbar.showError(context,
          message: context.l10n.pleaseSelectCategory);
      return;
    }

    if (_completionDate == null) {
      AppSnackbar.showError(context,
          message: context.l10n.pleaseSelectCompletionDate);
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      AppSnackbar.showError(
        context,
        message: context.l10n.pleaseExplainWhy,
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
            // Alt görevleri kaydet
            _subGoals = result.subGoals;
            // Detaylı SMART açıklamasını motivasyon alanına öneri olarak doldur
            if (_reasonController.text.trim().isEmpty) {
              _reasonController.text = result.explanation;
            }
          });

          AppSnackbar.showSuccess(
            context,
            message: context.l10n.goalOptimizedSuccess,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.premiumBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            iconSize: 24,
          ),
        ),
        title: Text(
          context.l10n.newGoal,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w600, // Semi-bold
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
                  _selectedCategory = category;
                });
              },
              completionDate: _completionDate,
              onDateSelected: _selectDate,
            ),
          ),
          // Footer with action buttons
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
                // AI ile Optimize Et
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
                        minimumSize: const Size(
                            double.infinity, 60), // Increased height
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16), // Softer radius
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
                          const SizedBox(
                              width: AppSpacing.sm), // Better icon spacing
                          Text(
                            context.l10n.optimizeWithAI,
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
                const SizedBox(
                    height: AppSpacing.md), // Consistent spacing
                // Kaydet
                AppButton(
                  variant: AppButtonVariant.filled,
                  onPressed: _isSaving ? null : _handleSave,
                  minHeight: 60, // Increased height to match AI button
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                      : Text(
                          context.l10n.save,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight:
                                FontWeight.w700, // Stronger than AI button
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
