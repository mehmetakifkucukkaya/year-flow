import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/index.dart';
import '../../../shared/providers/goal_providers.dart';
import 'widgets/ai_optimize_bottom_sheet.dart';

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
          _reasonController.text = goal.motivation ?? '';
          _selectedCategory = goal.category;
          _completionDate = goal.targetDate;
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
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      AppSnackbar.showError(context, message: 'Lütfen bir kategori seçin');
      return;
    }

    if (_completionDate == null) {
      AppSnackbar.showError(context,
          message: 'Lütfen tamamlanma tarihi seçin');
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
        motivation: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
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
    // Validate required fields
    if (_titleController.text.trim().isEmpty) {
      AppSnackbar.showError(context,
          message: 'Lütfen hedef başlığı girin');
      return;
    }

    if (_selectedCategory == null) {
      AppSnackbar.showError(context, message: 'Lütfen bir kategori seçin');
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
        motivation: _reasonController.text.trim().isEmpty
            ? null
            : _reasonController.text.trim(),
        onApply: (result) {
          // Apply AI optimization to form
          setState(() {
            _titleController.text = result.optimizedTitle;
            // Update sub-goals if needed (for future use)
            // For now, we just update the title
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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormField(
                      label: 'Hedef Başlığı',
                      child: _PremiumTextField(
                        controller: _titleController,
                        hint: 'Yeni bir dil öğrenmek',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen hedef başlığı girin';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _FormField(
                      label: 'Kategori Seç',
                      child: _CategoryDropdown(
                        selectedCategory: _selectedCategory,
                        onChanged: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _FormField(
                      label: 'Bu hedefi neden istiyorsun?',
                      child: _PremiumTextArea(
                        controller: _reasonController,
                        hint: 'Motivasyonunu ve amacını yaz...',
                        maxLength: 500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _FormField(
                      label: 'Tamamlanma Tarihi',
                      child: _DatePickerField(
                        selectedDate: _completionDate,
                        onTap: _selectDate,
                      ),
                    ),
                  ],
                ),
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
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    required this.controller,
    required this.hint,
    this.validator,
  });

  static const Color _placeholderColor = Color(0xFF9CA3AF);

  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: _placeholderColor,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class _PremiumTextArea extends StatelessWidget {
  const _PremiumTextArea({
    required this.controller,
    required this.hint,
    this.maxLength,
  });

  static const Color _placeholderColor = Color(0xFF9CA3AF);

  final TextEditingController controller;
  final String hint;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        maxLines: 6,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: _placeholderColor,
          ),
          contentPadding: const EdgeInsets.all(20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          counterStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.gray500,
          ),
          counterText: '',
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.selectedCategory,
    required this.onChanged,
  });

  static const Color _placeholderColor = Color(0xFF9CA3AF);

  final GoalCategory? selectedCategory;
  final ValueChanged<GoalCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: DropdownButtonFormField<GoalCategory>(
        value: selectedCategory,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          hintText: 'örn: Kariyer, Sağlık',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: _placeholderColor,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: GoalCategory.values.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Row(
              children: [
                Text(category.emoji),
                const SizedBox(width: AppSpacing.sm),
                Text(category.label),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.gray400,
          size: 24,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.selectedDate,
    required this.onTap,
  });

  static const Color _placeholderColor = Color(0xFF9CA3AF);

  final DateTime? selectedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate != null
        ? DateFormat('dd MMMM yyyy', 'tr_TR').format(selectedDate!)
        : 'Tarih seçin';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateText,
              style: selectedDate != null
                  ? AppTextStyles.bodyMedium
                  : AppTextStyles.bodyMedium.copyWith(
                      color: _placeholderColor,
                    ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}
