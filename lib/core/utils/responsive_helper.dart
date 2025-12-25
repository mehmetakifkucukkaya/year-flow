import 'package:flutter/material.dart';

/// Centralized responsive breakpoints and utilities
class ResponsiveHelper {
  const ResponsiveHelper._();

  // Breakpoints
  static const double mobileSmall = 320;
  static const double mobile = 360;
  static const double mobileLarge = 428;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double desktopLarge = 1440;

  /// Check if screen is very small mobile (<360)
  static bool isVerySmallMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  /// Check if screen is mobile (< tablet)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tablet;
  }

  /// Check if screen is tablet (>= tablet && < desktop)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < desktop;
  }

  /// Check if screen is desktop (>= desktop)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  /// Get screen width
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get responsive value based on screen size
  ///
  /// Example:
  /// ```dart
  /// final padding = ResponsiveHelper.value(
  ///   context,
  ///   mobile: 16.0,
  ///   tablet: 24.0,
  ///   desktop: 32.0,
  /// );
  /// ```
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final screenWidth = width(context);

    if (screenWidth >= ResponsiveHelper.desktop) {
      return desktop ?? tablet ?? mobile;
    } else if (screenWidth >= ResponsiveHelper.tablet) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// Get responsive font size
  static double fontSize(
    BuildContext context, {
    required double base,
    double? tablet,
    double? desktop,
  }) {
    return value<double>(
      context,
      mobile: base,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive spacing
  static double spacing(
    BuildContext context, {
    required double base,
    double? tablet,
    double? desktop,
  }) {
    return value<double>(
      context,
      mobile: base,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get number of grid columns based on screen size
  static int gridColumns(
    BuildContext context, {
    int mobile = 1,
    int? tablet,
    int? desktop,
  }) {
    return value<int>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Get responsive horizontal margin for content
  static double contentMargin(BuildContext context) {
    final screenWidth = width(context);

    if (screenWidth >= desktopLarge) {
      return (screenWidth - 1200) / 2; // Max content width 1200
    } else if (screenWidth >= desktop) {
      return 48;
    } else if (screenWidth >= tablet) {
      return 32;
    } else {
      return 16;
    }
  }

  /// Get responsive max content width
  static double maxContentWidth(BuildContext context) {
    final screenWidth = width(context);

    if (screenWidth >= desktop) {
      return 1200;
    } else if (screenWidth >= tablet) {
      return 800;
    } else {
      return screenWidth;
    }
  }
}

/// Extension for easier access to responsive utilities
extension ResponsiveExtension on BuildContext {
  /// Check if screen is very small mobile (<360)
  bool get isVerySmallMobile => ResponsiveHelper.isVerySmallMobile(this);

  /// Check if screen is mobile (< tablet)
  bool get isMobile => ResponsiveHelper.isMobile(this);

  /// Check if screen is tablet
  bool get isTablet => ResponsiveHelper.isTablet(this);

  /// Check if screen is desktop
  bool get isDesktop => ResponsiveHelper.isDesktop(this);

  /// Get screen width
  double get screenWidth => ResponsiveHelper.width(this);

  /// Get screen height
  double get screenHeight => ResponsiveHelper.height(this);

  /// Get responsive value
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return ResponsiveHelper.value<T>(
      this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}
