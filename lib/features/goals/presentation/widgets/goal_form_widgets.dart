import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';

class GoalFormFields extends StatelessWidget {
  const GoalFormFields({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.reasonController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.completionDate,
    required this.onDateSelected,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController reasonController;
  final GoalCategory? selectedCategory;
  final ValueChanged<GoalCategory?> onCategoryChanged;
  final DateTime? completionDate;
  final VoidCallback onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormField(
                    label: context.l10n.goalTitle,
                    child: _PremiumTextField(
                      controller: titleController,
                      hint: context.l10n.goalTitleHint,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.goalTitleRequired;
                        }
                        if (value.trim().length < 3) {
                          return context.l10n.goalTitleMinLength;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _FormField(
                    label: context.l10n.selectCategory,
                    child: _CategoryDropdown(
                      selectedCategory: selectedCategory,
                      onChanged: onCategoryChanged,
                      validator: (value) {
                        if (value == null) {
                          return context.l10n.categoryRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _FormField(
                    label: context.l10n.whyThisGoal,
                    child: _PremiumTextArea(
                      controller: reasonController,
                      hint: context.l10n.motivationHint,
                      maxLength: 500,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.motivationRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _FormField(
                    label: context.l10n.completionDate,
                    child: _DatePickerField(
                      selectedDate: completionDate,
                      onTap: onDateSelected,
                      validator: (value) {
                        if (value == null) {
                          return context.l10n.dateRequired;
                        }
                        return null;
                      },
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
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(
              color: AppColors.error,
              width: 1,
            ),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(
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
    this.validator,
  });

  static const Color _placeholderColor = Color(0xFF9CA3AF);

  final TextEditingController controller;
  final String hint;
  final int? maxLength;
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
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(
              color: AppColors.error,
              width: 1,
            ),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(
              color: AppColors.error,
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
    this.validator,
  });

  static const Color _placeholderColor = Color(0xFF9CA3AF);

  final GoalCategory? selectedCategory;
  final ValueChanged<GoalCategory?> onChanged;
  final FormFieldValidator<GoalCategory?>? validator;

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
        validator: validator,
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
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          hintText: context.l10n.categoryExample,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: _placeholderColor,
          ),
          filled: true,
          fillColor: Colors.white,
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(
              color: AppColors.error,
              width: 1,
            ),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
        ),
        items: GoalCategory.values.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Row(
              children: [
                Text(category.emoji),
                const SizedBox(width: AppSpacing.sm),
                Text(category.getLocalizedLabel(context)),
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

class _DatePickerField extends FormField<DateTime> {
  _DatePickerField({
    required DateTime? selectedDate,
    required VoidCallback onTap,
    super.validator,
  }) : super(
          key: ValueKey(selectedDate), // Rebuild when selectedDate changes
          initialValue: selectedDate,
          builder: (FormFieldState<DateTime> field) {
            return _DatePickerFieldWidget(
              selectedDate: field.value,
              onTap: () {
                onTap();
              },
              errorText: field.errorText,
            );
          },
        );
}

class _DatePickerFieldWidget extends StatelessWidget {
  const _DatePickerFieldWidget({
    required this.selectedDate,
    required this.onTap,
    this.errorText,
  });

  static const Color _placeholderColor = Color(0xFF9CA3AF);

  final DateTime? selectedDate;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate != null
        ? selectedDate!.formatted
        : context.l10n.selectDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: errorText != null
                  ? Border.all(
                      color: AppColors.error,
                      width: 1,
                    )
                  : null,
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
                          color: errorText != null
                              ? AppColors.error
                              : _placeholderColor,
                        ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: errorText != null
                      ? AppColors.error
                      : AppColors.gray400,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              errorText!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
