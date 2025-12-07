import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/models/yearly_report.dart';

/// BuildContext extension'ları
extension ContextExtensions on BuildContext {
  /// AppLocalizations erişimi
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  /// Theme erişimi
  ThemeData get theme => Theme.of(this);

  /// ColorScheme erişimi
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// TextTheme erişimi
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// MediaQuery erişimi
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Ekran boyutları
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// Padding
  EdgeInsets get padding => mediaQuery.padding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// SnackBar gösterme
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }
}

/// DateTime extension'ları
extension DateTimeExtensions on DateTime {
  /// Türkçe tarih formatı (15 Ocak 2025)
  String get formatted {
    return DateFormat('d MMMM yyyy', 'tr_TR').format(this);
  }

  /// Kısa tarih formatı (15 Oca)
  String get shortFormatted {
    return DateFormat('d MMM', 'tr_TR').format(this);
  }

  /// Göreceli zaman (3 gün önce)
  String get relative {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else {
      return formatted;
    }
  }

  /// Ay ve yıl formatı (Ocak 2025)
  String get monthYear {
    return DateFormat('MMMM yyyy', 'tr_TR').format(this);
  }
}

/// String extension'ları
extension StringExtensions on String {
  /// İlk harfi büyük yap
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Her kelimenin ilk harfini büyük yap
  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }
}

/// Int extension'ları
extension IntExtensions on int {
  /// Yüzde formatı
  String get asPercent => '$this%';
}

/// GoalCategory extension for localized labels
extension GoalCategoryLocalized on GoalCategory {
  String getLocalizedLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case GoalCategory.health:
        return l10n.health;
      case GoalCategory.mentalHealth:
        return l10n.mentalHealth;
      case GoalCategory.finance:
        return l10n.finance;
      case GoalCategory.career:
        return l10n.career;
      case GoalCategory.relationships:
        return l10n.relationships;
      case GoalCategory.learning:
        return l10n.learning;
      case GoalCategory.creativity:
        return l10n.creativity;
      case GoalCategory.hobby:
        return l10n.hobby;
      case GoalCategory.personalGrowth:
        return l10n.personalGrowth;
    }
  }
}

/// ReportType extension for localized labels
extension ReportTypeLocalized on ReportType {
  String getLocalizedLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (this) {
      case ReportType.weekly:
        return l10n.weekly;
      case ReportType.monthly:
        return l10n.monthly;
      case ReportType.yearly:
        return l10n.yearly;
    }
  }
}

