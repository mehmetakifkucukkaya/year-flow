import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Spacing widget'ları
class AppSpacer extends StatelessWidget {
  const AppSpacer({
    super.key,
    this.height,
    this.width,
  }) : assert(
          height == null || width == null,
          'Cannot specify both height and width',
        );

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (height != null) {
      return SizedBox(height: height);
    }
    if (width != null) {
      return SizedBox(width: width);
    }
    return const SizedBox.shrink();
  }
}

/// Predefined spacing widgets
class AppSpacers {
  AppSpacers._();

  static const Widget xxs = SizedBox(height: AppSpacing.xxs);
  static const Widget xs = SizedBox(height: AppSpacing.xs);
  static const Widget sm = SizedBox(height: AppSpacing.sm);
  static const Widget md = SizedBox(height: AppSpacing.md);
  static const Widget lg = SizedBox(height: AppSpacing.lg);
  static const Widget xl = SizedBox(height: AppSpacing.xl);
  static const Widget xxl = SizedBox(height: AppSpacing.xxl);
  static const Widget xxxl = SizedBox(height: AppSpacing.xxxl);

  static const Widget horizontalXxs = SizedBox(width: AppSpacing.xxs);
  static const Widget horizontalXs = SizedBox(width: AppSpacing.xs);
  static const Widget horizontalSm = SizedBox(width: AppSpacing.sm);
  static const Widget horizontalMd = SizedBox(width: AppSpacing.md);
  static const Widget horizontalLg = SizedBox(width: AppSpacing.lg);
  static const Widget horizontalXl = SizedBox(width: AppSpacing.xl);
}

