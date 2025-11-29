import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onboarding tamamlandı mı kontrolü
final onboardingCompletedProvider = StateProvider<bool>((ref) => false);

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

