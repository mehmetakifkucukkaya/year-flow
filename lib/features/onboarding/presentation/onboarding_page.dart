import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../providers/onboarding_providers.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages =
      3; // 3 slides: Make goals, Track journey, Stay motivated

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    if (mounted && page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
      ref.read(onboardingStateProvider.notifier).setPage(page);
    }
  }

  Future<void> _handleContinue() async {
    if (!mounted) return;

    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Onboarding tamamlandı - await ile state güncellenmesini bekle
      await ref
          .read(onboardingCompletedProvider.notifier)
          .setCompleted(true);

      // Navigation'ı güvenli bir şekilde yap
      _navigateToRegister();
    }
  }

  Future<void> _handleSkip() async {
    if (!mounted) return;

    // State'i güncelle - await ile state güncellenmesini bekle
    await ref
        .read(onboardingCompletedProvider.notifier)
        .setCompleted(true);

    // Navigation'ı güvenli bir şekilde yap
    _navigateToRegister();
  }

  void _navigateToRegister() {
    if (!mounted) return;

    // State güncellendikten sonra router'ın yeniden hesaplaması için bekle
    // Router provider watch edildiği için state değişikliği router'ı otomatik refresh edecek
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      // Widget tree hazır olduktan sonra navigation yap
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        try {
          // Router'ı direkt kullan
          final router = ref.read(routerProvider);
          router.go(AppRoutes.register);
        } catch (e, stackTrace) {
          debugPrint('Router navigation error: $e');
          debugPrint('Stack trace: $stackTrace');

          // Fallback: context.go kullan
          if (mounted) {
            try {
              context.go(AppRoutes.register);
            } catch (e2) {
              debugPrint('Context navigation error: $e2');
              // Son çare: Navigator kullan
              if (mounted) {
                try {
                  Navigator.of(context).pushReplacementNamed('/register');
                } catch (e3) {
                  debugPrint('Navigator navigation error: $e3');
                }
              }
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (tüm sayfalarda göster)
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.md,
                right: AppSpacing.md,
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _handleSkip,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  child: Text(
                    context.l10n.skip,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color:
                          isDark ? AppColors.gray300 : AppColors.gray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                children: const [
                  _WelcomeScreen(), // Make your goals real
                  _FeatureSlide1(), // Track your journey
                  _FeatureSlide2(), // Stay motivated, celebrate
                ],
              ),
            ),
            // Page indicators
            _PageIndicators(
              currentPage: _currentPage,
              totalPages: _totalPages,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      Color(0xFF1976D2), // Slightly darker blue
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleContinue,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: Text(
                        _currentPage == _totalPages - 1
                            ? context.l10n.letsStart
                            : context.l10n.continueButton,
                        style: AppTextStyles.buttonText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
                height:
                    MediaQuery.of(context).padding.bottom + AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

/// Page indicators
class _PageIndicators extends StatelessWidget {
  const _PageIndicators({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
          width: index == currentPage ? 36 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: index == currentPage
                ? AppColors.primary
                : (isDark ? AppColors.gray700 : AppColors.gray300),
            boxShadow: index == currentPage
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

/// Welcome Screen
class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0A4A4A), // Dark teal
                  const Color(0xFF1A5A5A), // Dark teal lighter
                ]
              : [
                  const Color(0xFF7DD3FC), // Light teal / sky blue
                  const Color(0xFFA5F3FC), // Aqua / cyan
                  const Color(0xFFE0F7FA), // Soft white-blue
                ],
        ),
      ),
      child: Stack(
        children: [
          // Soft abstract background pattern
          _SoftBackgroundPattern(isDark: isDark),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;
                final screenWidth = constraints.maxWidth;
                final isSmallScreen = screenHeight < 700;

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical:
                            isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.md
                                  : AppSpacing.lg),
                          // Illustration - Turn Dreams Into Reality
                          _FadeInWidget(
                            delay: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark
                                            ? Colors.black
                                            : Colors.blue)
                                        .withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: isSmallScreen ? 260 : 300,
                                    maxHeight: isSmallScreen ? 240 : 300,
                                    minWidth: 200,
                                    minHeight: 200,
                                  ),
                                  child: SizedBox(
                                    width: screenWidth *
                                        (isSmallScreen ? 0.7 : 0.75),
                                    height: isSmallScreen
                                        ? screenHeight * 0.28
                                        : screenHeight * 0.32,
                                    child: Image.asset(
                                      AppAssets.onboardingWelcome,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                            Icons.image_not_supported);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.lg
                                  : AppSpacing.xl),
                          // Headline
                          _FadeInWidget(
                            delay: 100,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              child: Text(
                                context.l10n.onboardingWelcomeTitle,
                                style:
                                    AppTextStyles.headlineLarge.copyWith(
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.gray900,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                  height: 1.2,
                                  fontSize: isSmallScreen ? 26 : 30,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.md
                                  : AppSpacing.lg),
                          // Subtitle
                          _FadeInWidget(
                            delay: 200,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg),
                              child: Text(
                                context.l10n.onboardingWelcomeSubtitle,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: isDark
                                      ? AppColors.gray300
                                      : AppColors.gray700,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                  fontSize: isSmallScreen ? 15 : 16,
                                  letterSpacing: 0.1,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.md
                                  : AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Feature Slide 1: Track your journey
class _FeatureSlide1 extends StatelessWidget {
  const _FeatureSlide1();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A237E), // Dark indigo
                  const Color(0xFF283593), // Dark indigo lighter
                ]
              : [
                  const Color(0xFFDBEAFE), // Soft blue
                  const Color(0xFFE9D5FF), // Lavender
                  const Color(0xFFF5F3FF), // Soft purple-white
                ],
        ),
      ),
      child: Stack(
        children: [
          // Soft abstract background pattern
          _SoftBackgroundPattern(isDark: isDark),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;
                final screenWidth = constraints.maxWidth;
                final isSmallScreen = screenHeight < 700;

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical:
                            isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.md
                                  : AppSpacing.lg),
                          // Illustration - Track Your Journey
                          _FadeInWidget(
                            delay: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark
                                            ? Colors.black
                                            : Colors.blue)
                                        .withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: isSmallScreen ? 260 : 300,
                                    maxHeight: isSmallScreen ? 240 : 300,
                                    minWidth: 200,
                                    minHeight: 200,
                                  ),
                                  child: SizedBox(
                                    width: screenWidth *
                                        (isSmallScreen ? 0.7 : 0.75),
                                    height: isSmallScreen
                                        ? screenHeight * 0.28
                                        : screenHeight * 0.32,
                                    child: Image.asset(
                                      AppAssets.onboardingTrackJourney,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                            Icons.image_not_supported);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.lg
                                  : AppSpacing.xl),
                          // Title
                          _FadeInWidget(
                            delay: 100,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              child: Text(
                                context.l10n.onboardingFeature1Title,
                                style:
                                    AppTextStyles.headlineLarge.copyWith(
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.gray900,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                  height: 1.2,
                                  fontSize: isSmallScreen ? 26 : 30,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.md
                                  : AppSpacing.lg),
                          // Subtitle
                          _FadeInWidget(
                            delay: 200,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg),
                              child: Text(
                                context.l10n.onboardingFeature1Subtitle,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: isDark
                                      ? AppColors.gray300
                                      : AppColors.gray700,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                  fontSize: isSmallScreen ? 15 : 16,
                                  letterSpacing: 0.1,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.md
                                  : AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Feature Slide 2: Stay motivated
class _FeatureSlide2 extends StatelessWidget {
  const _FeatureSlide2();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF4A148C), // Dark purple
                  const Color(0xFF6A1B9A), // Dark purple lighter
                ]
              : [
                  const Color(0xFFFFE5D9), // Peach
                  const Color(0xFFFFD6E8), // Pink
                  const Color(0xFFFFF4E6), // Warm gold-white
                ],
        ),
      ),
      child: Stack(
        children: [
          // Soft abstract background pattern
          _SoftBackgroundPattern(isDark: isDark),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;
                final screenWidth = constraints.maxWidth;
                final isSmallScreen = screenHeight < 700;

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical:
                            isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.md
                                  : AppSpacing.lg),
                          // Illustration - Celebrate Every Win
                          _FadeInWidget(
                            delay: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark
                                            ? Colors.black
                                            : Colors.orange)
                                        .withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: isSmallScreen ? 260 : 300,
                                    maxHeight: isSmallScreen ? 240 : 300,
                                    minWidth: 200,
                                    minHeight: 200,
                                  ),
                                  child: SizedBox(
                                    width: screenWidth *
                                        (isSmallScreen ? 0.7 : 0.75),
                                    height: isSmallScreen
                                        ? screenHeight * 0.28
                                        : screenHeight * 0.32,
                                    child: Image.asset(
                                      AppAssets.onboardingCelebrateWin,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                            Icons.image_not_supported);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.lg
                                  : AppSpacing.xl),
                          // Title
                          _FadeInWidget(
                            delay: 100,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              child: Text(
                                context.l10n.onboardingFeature2Title,
                                style:
                                    AppTextStyles.headlineLarge.copyWith(
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.gray900,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                  height: 1.2,
                                  fontSize: isSmallScreen ? 26 : 30,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.md
                                  : AppSpacing.lg),
                          // Subtitle
                          _FadeInWidget(
                            delay: 200,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg),
                              child: Text(
                                context.l10n.onboardingFeature2Subtitle,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: isDark
                                      ? AppColors.gray300
                                      : AppColors.gray700,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                  fontSize: isSmallScreen ? 15 : 16,
                                  letterSpacing: 0.1,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(
                              height: isSmallScreen
                                  ? AppSpacing.md
                                  : AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft abstract background pattern with pastel gradients
class _SoftBackgroundPattern extends StatelessWidget {
  const _SoftBackgroundPattern({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SoftPatternPainter(isDark: isDark),
      size: Size.infinite,
    );
  }
}

/// Custom painter for soft abstract background pattern
class _SoftPatternPainter extends CustomPainter {
  _SoftPatternPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (isDark) {
      // Dark mode: very subtle patterns
      _paintDarkPattern(canvas, size);
    } else {
      // Light mode: pastel patterns
      _paintLightPattern(canvas, size);
    }
  }

  void _paintLightPattern(Canvas canvas, Size size) {
    // Pastel colors with very low opacity
    final mint = const Color(0xFFB2F5EA).withOpacity(0.08);
    final babyBlue = const Color(0xFFB3E5FC).withOpacity(0.08);
    final softPeach = const Color(0xFFFFE0B2).withOpacity(0.08);

    // Organic rounded shapes
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    // Top-left organic blob (mint)
    final path1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.1,
        size.width * 0.3,
        size.height * 0.15,
      )
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.2,
        size.width * 0.25,
        size.height * 0.25,
      )
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.25,
        size.width * 0.1,
        size.height * 0.2,
      )
      ..close();

    paint.color = mint;
    canvas.drawPath(path1, paint);

    // Top-right organic blob (baby blue)
    final path2 = Path()
      ..moveTo(size.width * 0.7, size.height * 0.1)
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.05,
        size.width * 0.9,
        size.height * 0.12,
      )
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 0.2,
        size.width * 0.8,
        size.height * 0.22,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.2,
        size.width * 0.7,
        size.height * 0.15,
      )
      ..close();

    paint.color = babyBlue;
    canvas.drawPath(path2, paint);

    // Bottom-center organic blob (soft peach)
    final path3 = Path()
      ..moveTo(size.width * 0.4, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.65,
        size.width * 0.6,
        size.height * 0.7,
      )
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.75,
        size.width * 0.55,
        size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.8,
        size.width * 0.4,
        size.height * 0.75,
      )
      ..close();

    paint.color = softPeach;
    canvas.drawPath(path3, paint);

    // Additional subtle circles
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    // Small mint circle
    paint.color = mint;
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.6),
      size.width * 0.15,
      paint,
    );

    // Small baby blue circle
    paint.color = babyBlue;
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.5),
      size.width * 0.12,
      paint,
    );

    // Small soft peach circle
    paint.color = softPeach;
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.85),
      size.width * 0.1,
      paint,
    );
  }

  void _paintDarkPattern(Canvas canvas, Size size) {
    // Dark mode: even more subtle patterns
    final darkMint = const Color(0xFF4A9B8E).withOpacity(0.05);
    final darkBlue = const Color(0xFF5A8FA8).withOpacity(0.05);
    final darkPeach = const Color(0xFF8A7A6A).withOpacity(0.05);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    // Very subtle organic shapes
    final path1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.1,
        size.width * 0.3,
        size.height * 0.15,
      )
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.2,
        size.width * 0.1,
        size.height * 0.15,
      )
      ..close();

    paint.color = darkMint;
    canvas.drawPath(path1, paint);

    paint.color = darkBlue;
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      size.width * 0.12,
      paint,
    );

    paint.color = darkPeach;
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.7),
      size.width * 0.1,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fade-in animation widget
class _FadeInWidget extends StatefulWidget {
  const _FadeInWidget({
    required this.child,
    this.delay = 0,
  });

  final Widget child;
  final int delay;

  @override
  State<_FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<_FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Delay animation
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_animation),
        child: widget.child,
      ),
    );
  }
}
