import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding tamamlandı mı kontrolü - Persistent state
final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingCompletedNotifier, bool>((ref) {
  final notifier = OnboardingCompletedNotifier();
  // Başlangıçta state'i yükle (async ama await etmeden - fire and forget)
  // State güncellendiğinde provider otomatik olarak rebuild edecek
  // NOT: Initialize işlemi widget tree hazır olduktan sonra yapılmalı
  WidgetsBinding.instance.addPostFrameCallback((_) {
    notifier.initialize().catchError((error) {
      // Hata durumunda sessizce devam et
      debugPrint('Onboarding provider initialization error: $error');
    });
  });
  return notifier;
});

/// Onboarding completed notifier - SharedPreferences ile persistent
class OnboardingCompletedNotifier extends StateNotifier<bool> {
  OnboardingCompletedNotifier() : super(false);

  static const String _key = 'onboarding_completed';

  /// State'i başlat (kaydedilmiş değeri yükle)
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isCompleted = prefs.getBool(_key) ?? false;
      state = isCompleted;
    } catch (e) {
      // Hata durumunda varsayılan olarak false
      state = false;
    }
  }

  /// Onboarding'i tamamlandı olarak işaretle
  Future<void> setCompleted(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, value);
      state = value;
    } catch (e) {
      // Hata durumunda sadece state'i güncelle (persistent olmayabilir)
      state = value;
    }
  }

  /// Onboarding durumunu sıfırla (test için)
  Future<void> reset() async {
    await setCompleted(false);
  }
}

/// Onboarding state provider
final onboardingStateProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);

/// Onboarding state
class OnboardingState {
  const OnboardingState({
    this.currentPage = 0,
  });

  final int currentPage;

  OnboardingState copyWith({
    int? currentPage,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Onboarding notifier
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void nextPage() {
    if (state.currentPage < 2) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }
}

