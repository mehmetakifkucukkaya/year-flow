import 'package:flutter/material.dart';

/// Uygulama renk paleti
/// Tasarımlara göre mavi tonları ve nötr renkler
class AppColors {
  AppColors._();

  // Primary - Ana mavi ton
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);

  // Secondary - Koyu mavi (butonlar için)
  static const Color secondary = Color(0xFF1565C0);
  static const Color secondaryLight = Color(0xFF1E88E5);
  static const Color secondaryDark = Color(0xFF0D47A1);

  // Accent colors - Kategoriler için
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentPink = Color(0xFFE91E63);
  static const Color accentTeal = Color(0xFF009688);
  static const Color accentIndigo = Color(0xFF3F51B5);

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Gray scale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Background colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);

  // Surface colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Card colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);

  // Category colors (chip/badge için)
  static const Map<String, Color> categoryColors = {
    'health': accentGreen,
    'finance': accentOrange,
    'career': primary,
    'relationship': accentPink,
    'learning': accentIndigo,
    'habit': accentTeal,
    'personalGrowth': accentPurple,
  };

  // Category background colors (açık tonlar)
  static const Map<String, Color> categoryBackgroundColors = {
    'health': Color(0xFFE8F5E9),
    'finance': Color(0xFFFFF3E0),
    'career': Color(0xFFE3F2FD),
    'relationship': Color(0xFFFCE4EC),
    'learning': Color(0xFFE8EAF6),
    'habit': Color(0xFFE0F2F1),
    'personalGrowth': Color(0xFFF3E5F5),
  };
}

