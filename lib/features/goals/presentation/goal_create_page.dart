import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

class GoalCreatePage extends ConsumerStatefulWidget {
  const GoalCreatePage({super.key});

  @override
  ConsumerState<GoalCreatePage> createState() => _GoalCreatePageState();
}

class _GoalCreatePageState extends ConsumerState<GoalCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _reasonController = TextEditingController();
  
  GoalCategory? _selectedCategory;
  DateTime? _completionDate;

  // Premium background color
  static const Color _premiumBackground = Color(0xFFF9FAFB);

  @override
  void dispose() {
    _titleController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() {
        _completionDate = picked;
      });
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir kategori seçin')),
        );
        return;
      }
      if (_completionDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen tamamlanma tarihi seçin')),
        );
        return;
      }
      // TODO: Save goal
      context.pop();
    }
  }

  void _handleAIOptimize() {
    // TODO: AI optimization
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI optimizasyonu yakında eklenecek')),
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            iconSize: 24,
          ),
        ),
        title: Text(
          'Yeni Hedef Ekle',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w600, // Semi-bold
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
                    // Hedef Başlığı
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

                    // Kategori Seç
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

                    // Bu hedefi neden istiyorsun?
                    _FormField(
                      label: 'Bu hedefi neden istiyorsun?',
                      child: _PremiumTextArea(
                        controller: _reasonController,
                        hint: 'Motivasyonunu ve amacını yaz...',
                        maxLength: 500,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Tamamlanma Tarihi
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

            // Footer with action buttons
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
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
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 60), // Increased height
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16), // Softer radius
                          ),
                          side: BorderSide.none,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 22,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm), // Better icon spacing
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
                  const SizedBox(height: AppSpacing.md), // Consistent spacing
                  // Kaydet
                  AppButton(
                    variant: AppButtonVariant.filled,
                    onPressed: _handleSave,
                    minHeight: 60, // Increased height to match AI button
                    child: Text(
                      'Kaydet',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700, // Stronger than AI button
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

/// Form Field Wrapper
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

/// Premium Text Field with soft shadows and rounded corners
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
        borderRadius: BorderRadius.circular(16), // Softer corner radius
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
            color: _placeholderColor, // Softer gray
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, // Increased padding
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
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.error,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
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

/// Premium Text Area
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
        borderRadius: BorderRadius.circular(16), // Rounded corners
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
        maxLines: 6, // Balanced proportions
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: _placeholderColor,
          ),
          contentPadding: const EdgeInsets.all(20), // More inner padding
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
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          counterStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.gray500,
          ),
          counterText: '', // Hide default counter, we'll show it below
        ),
      ),
    );
  }
}

/// Category Dropdown - Premium styling
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
        borderRadius: BorderRadius.circular(16), // Softer corner radius
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
            horizontal: 20, // Increased padding
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
            borderSide: BorderSide(
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
        icon: Icon(
          Icons.keyboard_arrow_down_rounded, // More modern minimalist icon
          color: AppColors.gray400,
          size: 24,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

/// Date Picker Field - Premium styling
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
        padding: const EdgeInsets.symmetric(horizontal: 20), // Improved padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Softer corner radius
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
            Icon(
              Icons.calendar_today_outlined, // More lightweight calendar icon
              size: 20,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}
