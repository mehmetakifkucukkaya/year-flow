import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Kategori chip widget'ı
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.onTap,
  });

  final GoalCategory category;
  final VoidCallback? onTap;

  Color get _backgroundColor {
    final categoryKey = category.name.toLowerCase();
    return AppColors.categoryBackgroundColors[categoryKey] ??
        AppColors.gray100;
  }

  Color get _textColor {
    final categoryKey = category.name.toLowerCase();
    return AppColors.categoryColors[categoryKey] ?? AppColors.gray900;
  }

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: AppRadius.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.emoji,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusFull,
        child: chip,
      );
    }

    return chip;
  }
}

/// Genel amaçlı chip widget'ı
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.onDeleted,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  final String label;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      onDeleted: onDeleted,
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(color: textColor),
      avatar: icon,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusFull,
      ),
    );
  }
}
