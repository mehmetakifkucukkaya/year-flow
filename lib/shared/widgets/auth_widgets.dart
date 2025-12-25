import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Premium Button with glossy effect
/// Used across auth pages for primary action buttons
class PremiumButton extends StatelessWidget {
  const PremiumButton({
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: onPressed == null
              ? [
                  AppColors.gray300,
                  AppColors.gray400,
                ]
              : [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : DefaultTextStyle(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    child: child,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Modern Google Sign-In Button
/// Used across auth pages for Google authentication
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gray300.withOpacity(0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.gray600),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const GoogleIcon(),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        text,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              color: AppColors.gray900,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Google icon widget - Uses Google's official logo
/// Falls back to material icon if SVG is not available
class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 20,
      child: Builder(
        builder: (context) {
          try {
            return SvgPicture.asset(
              'assets/icons/google_logo.svg',
              width: 34,
              height: 20,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => const Icon(
                Icons.g_mobiledata,
                size: 20,
              ),
            );
          } catch (e) {
            // Fallback to material icon if SVG fails
            return const Icon(
              Icons.g_mobiledata,
              size: 20,
              color: AppColors.gray700,
            );
          }
        },
      ),
    );
  }
}

/// Logo Header Component (without app name)
/// Used across auth pages for brand display
class AuthLogoHeader extends StatelessWidget {
  const AuthLogoHeader({
    required this.logoPath,
    required this.appName,
    super.key,
  });

  final String logoPath;
  final String
      appName; // Kept for backwards compatibility but not displayed

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo with soft shadow
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              logoPath,
              width: 96,
              height: 96,
              fit: BoxFit.contain,
              cacheWidth: 192,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Logo load error: $error');
                return Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 64,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
