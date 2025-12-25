import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

/// Firebase Analytics instance - global erişim için
FirebaseAnalytics? analytics;

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Firebase başlangıcı
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Firebase Analytics başlat
      analytics = FirebaseAnalytics.instance;

      // Firebase Crashlytics başlat
      // Debug modda crashlytics'i devre dışı bırak (isteğe bağlı)
      if (kDebugMode) {
        // Debug modda crash raporlarını devre dışı bırakabilirsiniz
        // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      }

      // Flutter framework hatalarını Crashlytics'e gönder
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      // Async hataları yakala (Flutter framework dışındaki hatalar)
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance
            .recordError(error, stack, fatal: true);
        return true;
      };

      // Firestore offline persistence
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Firebase initialization error: $e');
        debugPrint('Stack: $stack');
        debugPrint('Current platform: $defaultTargetPlatform');
      }
      // Hata durumunda uygulama yine de çalışsın (mock mode)
      // Firebase olmadan devam et
    }

    // Tarih formatlaması için desteklenen dilleri başlat
    // Hem Türkçe hem İngilizce için date formatting'i başlatıyoruz
    await initializeDateFormatting('tr_TR', null);
    await initializeDateFormatting('en_US', null);

    // Status bar rengini ayarla
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Sadece dikey mod
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(
      const ProviderScope(
        child: YearFlowApp(),
      ),
    );
  }, (error, stack) {
    // runZonedGuarded ile yakalanan hatalar
    if (kDebugMode) {
      debugPrint('Uncaught error: $error');
      debugPrint('Stack: $stack');
    }
    // Crashlytics varsa gönder
    try {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } catch (_) {
      // Firebase init başarısızsa sessizce devam et
    }
  });
}

class YearFlowApp extends ConsumerWidget {
  const YearFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'YearFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
    );
  }
}
