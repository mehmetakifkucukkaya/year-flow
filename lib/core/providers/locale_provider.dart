import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locale provider - uygulama dilini yönetir
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final notifier = LocaleNotifier();
  // Başlangıçta locale'yi yükle
  notifier.initialize();
  return notifier;
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('tr', 'TR'));

  static const String _languageCodeKey = 'language_code';
  static const String _countryCodeKey = 'country_code';

  /// Locale'yi başlat (kaydedilmiş veya cihaz dilini yükle)
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageCodeKey);
      final countryCode = prefs.getString(_countryCodeKey);

      if (languageCode != null) {
        // Kaydedilmiş locale varsa onu kullan
        state = Locale(
          languageCode,
          countryCode,
        );
        return;
      }

      // Kaydedilmiş locale yoksa cihazın dilini kontrol et
      final deviceLocale = PlatformDispatcher.instance.locale;
      final supportedLocales = const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ];

      // Cihazın dili destekleniyor mu?
      final isSupported = supportedLocales.any(
        (locale) => locale.languageCode == deviceLocale.languageCode,
      );

      if (isSupported) {
        // Destekleniyorsa cihazın dilini kullan
        final matchedLocale = supportedLocales.firstWhere(
          (locale) => locale.languageCode == deviceLocale.languageCode,
        );
        state = matchedLocale;
        // Cihaz dilini kaydet
        await _saveLocale(matchedLocale);
      } else {
        // Desteklenmiyorsa varsayılan olarak Türkçe
        state = const Locale('tr', 'TR');
      }
    } catch (e) {
      // Hata durumunda varsayılan locale
      state = const Locale('tr', 'TR');
    }
  }

  /// Locale'yi SharedPreferences'a kaydet
  Future<void> _saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageCodeKey, locale.languageCode);
      if (locale.countryCode != null) {
        await prefs.setString(_countryCodeKey, locale.countryCode!);
      } else {
        await prefs.remove(_countryCodeKey);
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  /// Dili değiştir
  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _saveLocale(locale);
  }

  /// Türkçe'ye geç
  Future<void> setTurkish() async {
    await setLocale(const Locale('tr', 'TR'));
  }

  /// İngilizce'ye geç
  Future<void> setEnglish() async {
    await setLocale(const Locale('en', 'US'));
  }

  /// Mevcut dil kodunu döndür
  String get currentLanguageCode => state.languageCode;
}

