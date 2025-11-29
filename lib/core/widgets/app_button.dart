import 'package:flutter/material.dart';

import '../theme/app_radius.dart';

/// Uygulama buton widget'ı
/// Farklı button stilleri için wrapper
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
    this.isFullWidth = true,
    this.minHeight = 56,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final button = _buildButton(context);

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButton(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: minHeight,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    switch (variant) {
      case AppButtonVariant.filled:
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            minimumSize: Size(0, minHeight),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusMd,
            ),
          ),
          child: child,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(0, minHeight),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusMd,
            ),
          ),
          child: child,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size(0, minHeight),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusMd,
            ),
          ),
          child: child,
        );
    }
  }
}

/// Button variant'ları
enum AppButtonVariant {
  filled,
  outlined,
  text,
}

/// Icon button wrapper
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: icon,
      onPressed: onPressed,
      style: backgroundColor != null
          ? IconButton.styleFrom(backgroundColor: backgroundColor)
          : null,
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
