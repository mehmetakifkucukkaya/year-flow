import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/index.dart';
import '../providers/onboarding_providers.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    ref.read(onboardingStateProvider.notifier).setPage(page);
  }

  void _handleContinue() {
    final currentPage = ref.read(onboardingStateProvider).currentPage;

    if (currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Onboarding tamamlandı
      ref.read(onboardingCompletedProvider.notifier).state = true;
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingStateProvider);
    final currentPage = onboardingState.currentPage;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (sadece ilk 2 sayfada)
            if (currentPage < 2)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    ref.read(onboardingCompletedProvider.notifier).state =
                        true;
                    context.go(AppRoutes.login);
                  },
                  child: const Text('Atla'),
                ),
              ),
            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: const [
                  _OnboardingSlide1(),
                  _OnboardingSlide2(),
                  _OnboardingSlide3(),
                ],
              ),
            ),
            // Page indicators
            _PageIndicators(currentPage: currentPage),
            const SizedBox(height: 24),
            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppButton(
                onPressed: _handleContinue,
                child: Text(
                  currentPage < 2 ? 'Devam Et' : 'Hemen Başla',
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Page indicators
class _PageIndicators extends StatelessWidget {
  const _PageIndicators({required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentPage
                ? AppColors.primary
                : AppColors.gray300,
          ),
        ),
      ),
    );
  }
}

/// Slide 1: "Bu yıl hedeflerini somutlaştır"
class _OnboardingSlide1 extends StatelessWidget {
  const _OnboardingSlide1();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Illustration section (koyu teal-yeşil arka plan)
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E5E), // Koyu teal-yeşil
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(48, 64, 48, 64),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sulama kovası
                    Positioned(
                      left: 0,
                      child: Icon(
                        Icons.water_drop_outlined,
                        size: 40,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    // Bitki
                    Icon(
                      Icons.eco,
                      size: 80,
                      color: Colors.green.shade300,
                    ),
                    // GOAL ikonları (placeholder)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _GoalIcon(),
                    ),
                    Positioned(
                      top: 32,
                      left: 0,
                      child: _GoalIcon(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 24,
                      child: _GoalIcon(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Text section
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bu yıl hedeflerini somutlaştır.',
                  style:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.gray900,
                            fontWeight: FontWeight.bold,
                          ),
                  textAlign: TextAlign.center,
                ),
                AppSpacers.md,
                Text(
                  'YearFlow ile hayallerini gerçeğe dönüştür. Ulaşılabilir adımlarla büyük hedeflerine doğru ilerle.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray700,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// GOAL icon placeholder
class _GoalIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.amber.shade300,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'GOAL',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Slide 2: "Düzenli ilerlemelerle yolculuğunu takip et"
class _OnboardingSlide2 extends StatelessWidget {
  const _OnboardingSlide2();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Illustration section
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E5E), // Koyu teal-yeşil
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(48, 64, 48, 64),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder illustration - timeline/ilerleme
                    Icon(
                      Icons.timeline,
                      size: 100,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    AppSpacers.md,
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ProgressStep(isCompleted: true),
                        AppSpacers.horizontalSm,
                        _ProgressStep(isCompleted: true),
                        AppSpacers.horizontalSm,
                        _ProgressStep(isCompleted: false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Text section
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Düzenli ilerlemelerle yolculuğunu takip et.',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width < 360
                            ? 22
                            : null,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacers.md,
                Text(
                  'Aylık check-in\'lerle hedeflerindeki ilerlemeyi kaydet, motivasyonunu koru ve başarılarını kutla.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray700,
                        fontSize: MediaQuery.of(context).size.width < 360
                            ? 14
                            : null,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Progress step indicator
class _ProgressStep extends StatelessWidget {
  const _ProgressStep({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.shade300
            : Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: isCompleted
          ? const Icon(Icons.check, color: Colors.white)
          : null,
    );
  }
}

/// Slide 3: "Yıl sonunda kişisel gelişim raporunu al"
class _OnboardingSlide3 extends StatelessWidget {
  const _OnboardingSlide3();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Illustration section (açık şeftali arka plan)
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.orange.shade50, // Açık şeftali
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(48, 64, 48, 64),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Kişi figürü
                    Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.orange.shade300,
                    ),
                    // Sembolik elementler
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Icon(
                        Icons.lightbulb_outline,
                        size: 30,
                        color: Colors.orange.shade400,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        Icons.attach_money,
                        size: 30,
                        color: Colors.orange.shade400,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 24,
                      child: Icon(
                        Icons.access_time,
                        size: 30,
                        color: Colors.orange.shade400,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 24,
                      child: Icon(
                        Icons.public,
                        size: 30,
                        color: Colors.orange.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Text section
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Yıl sonunda kişisel gelişim raporunu al.',
                  style:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.gray900,
                            fontWeight: FontWeight.bold,
                          ),
                  textAlign: TextAlign.center,
                ),
                AppSpacers.md,
                Text(
                  'AI destekli raporlarla yıl boyunca kaydettiğin ilerlemeyi gör, somut verilerle gelişimini anla ve yeni hedefler için ilham al.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.gray700,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
