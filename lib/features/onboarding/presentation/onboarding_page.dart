import 'dart:math' as math;

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
  final int _totalPages = 3; // 3 slides: Make goals, Track journey, Stay motivated

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
      await ref.read(onboardingCompletedProvider.notifier).setCompleted(true);
      
      // Navigation'ı güvenli bir şekilde yap
      _navigateToRegister();
    }
  }

  Future<void> _handleSkip() async {
    if (!mounted) return;
    
    // State'i güncelle - await ile state güncellenmesini bekle
    await ref.read(onboardingCompletedProvider.notifier).setCompleted(true);
    
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
                      color: isDark
                          ? AppColors.gray300
                          : AppColors.gray600,
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
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      const Color(0xFF1976D2), // Slightly darker blue
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
            SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
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
                        vertical: isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
                          // Illustration - Turn Dreams Into Reality
                          _FadeInWidget(
                            delay: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? Colors.black : Colors.blue)
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
                                    width: screenWidth * (isSmallScreen ? 0.7 : 0.75),
                                    height: isSmallScreen 
                                        ? screenHeight * 0.28 
                                        : screenHeight * 0.32,
                                    child: Image.asset(
                                      AppAssets.onboardingWelcome,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.image_not_supported);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? AppSpacing.lg : AppSpacing.xl),
                          // Headline
                          _FadeInWidget(
                            delay: 100,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: Text(
                                context.l10n.onboardingWelcomeTitle,
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: isDark ? AppColors.white : AppColors.gray900,
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
                          SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
                          // Subtitle
                          _FadeInWidget(
                            delay: 200,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                          SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
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
                        vertical: isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
                          // Illustration - Track Your Journey
                          _FadeInWidget(
                            delay: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? Colors.black : Colors.blue)
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
                                    width: screenWidth * (isSmallScreen ? 0.7 : 0.75),
                                    height: isSmallScreen 
                                        ? screenHeight * 0.28 
                                        : screenHeight * 0.32,
                                    child: Image.asset(
                                      AppAssets.onboardingTrackJourney,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.image_not_supported);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? AppSpacing.lg : AppSpacing.xl),
                          // Title
                          _FadeInWidget(
                            delay: 100,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: Text(
                                context.l10n.onboardingFeature1Title,
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: isDark ? AppColors.white : AppColors.gray900,
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
                          SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
                          // Subtitle
                          _FadeInWidget(
                            delay: 200,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                          SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
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
                        vertical: isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
                          // Illustration - Celebrate Every Win
                          _FadeInWidget(
                            delay: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? Colors.black : Colors.orange)
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
                                    width: screenWidth * (isSmallScreen ? 0.7 : 0.75),
                                    height: isSmallScreen 
                                        ? screenHeight * 0.28 
                                        : screenHeight * 0.32,
                                    child: Image.asset(
                                      AppAssets.onboardingCelebrateWin,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.image_not_supported);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? AppSpacing.lg : AppSpacing.xl),
                          // Title
                          _FadeInWidget(
                            delay: 100,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: Text(
                                context.l10n.onboardingFeature2Title,
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: isDark ? AppColors.white : AppColors.gray900,
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
                          SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
                          // Subtitle
                          _FadeInWidget(
                            delay: 200,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                          SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
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

/// Progress step indicator
class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.isCompleted,
    required this.isDark,
  });

  final bool isCompleted;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.primary
            : (isDark
                ? AppColors.gray700
                : AppColors.gray300),
        shape: BoxShape.circle,
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: isCompleted
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 18,
            )
          : null,
    );
  }
}

/// Badge icon
class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({
    required this.icon,
    required this.isDark,
  });

  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.accentOrange,
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        color: AppColors.accentOrange,
        size: 20,
      ),
    );
  }
}

/// Illustration 1: Turn Dreams Into Reality
/// Floating steps toward a glowing goal icon
class _DreamsRealityIllustration extends CustomPainter {
  _DreamsRealityIllustration({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    // Pastel color palette
    final mint = const Color(0xFFB2F5EA);
    final teal = const Color(0xFF4FD1C7);
    final softYellow = const Color(0xFFFFF9C4);
    final lightBlue = const Color(0xFFB3E5FC);
    final lilac = const Color(0xFFE1BEE7);

    final paint = Paint()..style = PaintingStyle.fill;

    // Background dream-like shapes (soft clouds)
    paint.color = lightBlue.withOpacity(0.25);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.12), 35, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.18), 30, paint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.32), 25, paint);

    // Abstract dream shapes
    paint.color = lilac.withOpacity(0.2);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.38), 40, paint);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.48), 32, paint);

    // Floating steps (rounded rectangles with gradients)
    final stepPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Step 1 (bottom)
    stepPaint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [mint, teal.withOpacity(0.8)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final step1Path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.12, size.height * 0.62, size.width * 0.28, 24),
        const Radius.circular(14),
      ));
    canvas.drawPath(step1Path, stepPaint);

    // Step 2 (middle)
    stepPaint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [mint.withOpacity(0.95), teal.withOpacity(0.7)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final step2Path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.32, size.height * 0.48, size.width * 0.32, 24),
        const Radius.circular(14),
      ));
    canvas.drawPath(step2Path, stepPaint);

    // Step 3 (top)
    stepPaint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [mint.withOpacity(0.9), teal.withOpacity(0.6)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final step3Path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.52, size.height * 0.34, size.width * 0.28, 24),
        const Radius.circular(14),
      ));
    canvas.drawPath(step3Path, stepPaint);

    // Person silhouette (simple rounded shape)
    final personPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark ? const Color(0xFF424242) : const Color(0xFF757575);
    // Head
    canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.58), 20, personPaint);
    // Body (rounded rectangle)
    final bodyPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.16, size.height * 0.66, 12, 32),
        const Radius.circular(8),
      ));
    canvas.drawPath(bodyPath, personPaint);

    // Glowing goal icon at top (star with soft glow)
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    glowPaint.shader = RadialGradient(
      colors: [
        softYellow.withOpacity(0.9),
        softYellow.withOpacity(0.5),
        softYellow.withOpacity(0.0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.68, size.height * 0.12),
      radius: 50,
    ));
    canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.12), 50, glowPaint);

    // Star icon
    final starPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = softYellow;
    _drawStar(canvas, Offset(size.width * 0.68, size.height * 0.12), 24, starPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Illustration 2: Track Your Journey
/// Line graph with rising progress and checkmarks
class _TrackJourneyIllustration extends CustomPainter {
  _TrackJourneyIllustration({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    // Pastel color palette
    final teal = const Color(0xFF4FD1C7);
    final mint = const Color(0xFFB2F5EA);
    final green = const Color(0xFF81C784);

    final paint = Paint()..style = PaintingStyle.fill;

    // Progress line graph (smooth curve rising upward)
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    linePaint.shader = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [mint, teal],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Smooth curve path
    final curvePath = Path();
    curvePath.moveTo(size.width * 0.12, size.height * 0.72);
    curvePath.quadraticBezierTo(
      size.width * 0.32,
      size.height * 0.58,
      size.width * 0.48,
      size.height * 0.48,
    );
    curvePath.quadraticBezierTo(
      size.width * 0.64,
      size.height * 0.38,
      size.width * 0.82,
      size.height * 0.28,
    );
    canvas.drawPath(curvePath, linePaint);

    // Glowing nodes on the curve
    final nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // Node 1 (completed - green with glow)
    nodePaint.shader = RadialGradient(
      colors: [
        green.withOpacity(1.0),
        green.withOpacity(0.6),
        green.withOpacity(0.0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.28, size.height * 0.62),
      radius: 24,
    ));
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.62), 24, nodePaint);
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.62), 14, paint);

    // Node 2 (completed - green with glow)
    nodePaint.shader = RadialGradient(
      colors: [
        green.withOpacity(1.0),
        green.withOpacity(0.6),
        green.withOpacity(0.0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.52, size.height * 0.44),
      radius: 24,
    ));
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.44), 24, nodePaint);
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.44), 14, paint);

    // Node 3 (upcoming - faded teal)
    nodePaint.shader = RadialGradient(
      colors: [
        teal.withOpacity(0.5),
        teal.withOpacity(0.25),
        teal.withOpacity(0.0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.82, size.height * 0.28),
      radius: 20,
    ));
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.28), 20, nodePaint);
    paint.color = Colors.white.withOpacity(0.7);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.28), 11, paint);

    // Checkmarks on completed nodes
    final checkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = green;
    final checkPath1 = Path()
      ..moveTo(size.width * 0.28 - 7, size.height * 0.62)
      ..lineTo(size.width * 0.28 - 2, size.height * 0.62 + 5)
      ..lineTo(size.width * 0.28 + 7, size.height * 0.62 - 3);
    canvas.drawPath(checkPath1, checkPaint);
    final checkPath2 = Path()
      ..moveTo(size.width * 0.52 - 7, size.height * 0.44)
      ..lineTo(size.width * 0.52 - 2, size.height * 0.44 + 5)
      ..lineTo(size.width * 0.52 + 7, size.height * 0.44 - 3);
    canvas.drawPath(checkPath2, checkPaint);

    // Character silhouette observing from the side
    final characterPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark ? const Color(0xFF424242) : const Color(0xFF757575);
    // Head
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.48), 18, characterPaint);
    // Body (rounded rectangle)
    final bodyPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.04, size.height * 0.56, 8, 28),
        const Radius.circular(6),
      ));
    canvas.drawPath(bodyPath, characterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Illustration 3: Celebrate Every Win
/// Milestone badges, trophy, confetti, and celebrating character
class _CelebrateWinIllustration extends CustomPainter {
  _CelebrateWinIllustration({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    // Warm pastel colors
    final yellow = const Color(0xFFFFF9C4);
    final peach = const Color(0xFFFFE0B2);
    final mint = const Color(0xFFB2F5EA);
    final lightBlue = const Color(0xFFB3E5FC);
    final teal = const Color(0xFF4FD1C7);

    final paint = Paint()..style = PaintingStyle.fill;

    // Progress bar at bottom
    final progressPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = mint.withOpacity(0.35);
    final progressPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.78, size.width * 0.84, 14),
        const Radius.circular(8),
      ));
    canvas.drawPath(progressPath, progressPaint);

    // Filled progress portion with gradient
    progressPaint.shader = LinearGradient(
      colors: [yellow, peach],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final filledPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.78, size.width * 0.73, 14),
        const Radius.circular(8),
      ));
    canvas.drawPath(filledPath, progressPaint);

    // Highlighted milestone marker
    final milestonePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = yellow;
    canvas.drawCircle(Offset(size.width * 0.81, size.height * 0.78), 12, milestonePaint);
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.81, size.height * 0.78), 7, paint);

    // Milestone badges (rounded shapes with gradients)
    // Badge 1 (left)
    final badge1Paint = Paint()
      ..style = PaintingStyle.fill;
    badge1Paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [yellow, peach.withOpacity(0.8)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final badge1Path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.12, size.height * 0.18, 56, 56),
        const Radius.circular(14),
      ));
    canvas.drawPath(badge1Path, badge1Paint);
    paint.color = Colors.white;
    _drawStar(canvas, Offset(size.width * 0.4, size.height * 0.46), 14, paint);

    // Badge 2 (right)
    final badge2Paint = Paint()
      ..style = PaintingStyle.fill;
    badge2Paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [peach, yellow.withOpacity(0.8)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final badge2Path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.62, size.height * 0.22, 56, 56),
        const Radius.circular(14),
      ));
    canvas.drawPath(badge2Path, badge2Paint);
    paint.color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.5), 14, paint);

    // Trophy (centered, larger)
    final trophyPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = yellow;
    // Trophy base
    final trophyPath = Path()
      ..moveTo(size.width * 0.42, size.height * 0.32)
      ..lineTo(size.width * 0.42, size.height * 0.52)
      ..lineTo(size.width * 0.48, size.height * 0.52)
      ..lineTo(size.width * 0.48, size.height * 0.32)
      ..close();
    canvas.drawPath(trophyPath, trophyPaint);
    // Trophy top (rounded)
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.32), 10, trophyPaint);
    // Trophy handle
    final handlePath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.38, size.height * 0.36, 6, 12),
        const Radius.circular(3),
      ));
    canvas.drawPath(handlePath, trophyPaint);
    final handlePath2 = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.46, size.height * 0.36, 6, 12),
        const Radius.circular(3),
      ));
    canvas.drawPath(handlePath2, trophyPaint);

    // Confetti elements (small rounded shapes scattered)
    paint.color = lightBlue;
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.12), 7, paint);
    paint.color = peach;
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.08), 6, paint);
    paint.color = mint;
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.08), 6, paint);
    paint.color = yellow;
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.12), 7, paint);
    paint.color = teal;
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.25), 5, paint);
    paint.color = lightBlue;
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.28), 6, paint);

    // Celebrating character (smiling, raising hand)
    final characterPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isDark ? const Color(0xFF424242) : const Color(0xFF757575);
    // Head
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.58), 20, characterPaint);
    // Body
    final bodyPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.44, size.height * 0.66, 12, 32),
        const Radius.circular(6),
      ));
    canvas.drawPath(bodyPath, characterPaint);
    // Raised arm
    final armPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.52, size.height * 0.66, 7, 22),
        const Radius.circular(4),
      ));
    canvas.drawPath(armPath, characterPaint);
    // Smile
    final smilePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.9);
    final smilePath = Path()
      ..moveTo(size.width * 0.5 - 9, size.height * 0.58 + 5)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.58 + 9,
        size.width * 0.5 + 9,
        size.height * 0.58 + 5,
      );
    canvas.drawPath(smilePath, smilePaint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
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
