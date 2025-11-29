import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Yatay ilerleme çubuğu
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.showPercentage = false,
  }) : assert(
          progress >= 0 && progress <= 100,
          'Progress must be between 0 and 100',
        );

  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: AppRadius.borderRadiusFull,
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: height,
            backgroundColor: backgroundColor ?? AppColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? AppColors.primary,
            ),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '${progress.toInt()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.gray600,
                ),
          ),
        ],
      ],
    );
  }
}

/// Dairesel ilerleme göstergesi
class AppCircularProgress extends StatelessWidget {
  const AppCircularProgress({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.progressColor,
    this.showPercentage = true,
    this.percentageStyle,
  }) : assert(
          progress >= 0 && progress <= 100,
          'Progress must be between 0 and 100',
        );

  final double progress;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showPercentage;
  final TextStyle? percentageStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress / 100,
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor ?? AppColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? AppColors.primary,
            ),
          ),
          if (showPercentage)
            Text(
              '${progress.toInt()}%',
              style: percentageStyle ??
                  Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
            ),
        ],
      ),
    );
  }
}

