import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/index.dart';
import '../providers/auth_providers.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    await ref.read(authStateProvider.notifier).signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
  }

  Future<void> _handleGoogleSignIn() async {
    if (!mounted) return;

    await ref.read(authStateProvider.notifier).signInWithGoogle();

    if (!mounted) return;

    final authState = ref.read(authStateProvider);

    if (authState.errorMessage != null) {
      AppSnackbar.showError(context, message: authState.errorMessage!);
    } else if (authState.isAuthenticated) {
      // Kullanıcıya bilgi mesajı göster
      final user = authState.currentUser;
      if (user != null) {
        if (user.isNewUser) {
          AppSnackbar.showSuccess(
            context,
            message: context.l10n.welcome,
            duration: const Duration(seconds: 2),
          );
        } else {
          AppSnackbar.showInfo(
            context,
            message: context.l10n.signInSuccess,
            duration: const Duration(seconds: 2),
          );
        }
      }
      // Kısa bir gecikme sonrası home'a yönlendir (mesajın görünmesi için)
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sadece loading state'ini watch et, böylece form state'i korunur
    final isEmailLoading =
        ref.watch(authStateProvider.select((s) => s.isEmailLoading));
    final isGoogleLoading =
        ref.watch(authStateProvider.select((s) => s.isGoogleLoading));

    // State değişikliklerini dinle (sadece state değiştiğinde çağrılır)
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (!mounted) return;

      // Hata mesajı varsa göster
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        try {
          AppSnackbar.showError(context, message: next.errorMessage!);
        } catch (e) {
          debugPrint('Snackbar error: $e');
        }
      }

      // Başarılı kayıt yapıldıysa yönlendir
      if (next.isAuthenticated && !(previous?.isAuthenticated ?? false)) {
        try {
          context.go(AppRoutes.home);
        } catch (e) {
          debugPrint('Register navigation error: $e');
        }
      }
    });

    return Scaffold(
      body: Container(
        // Soft gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F9FF), // Very light blue
              Color(0xFFEEF3FF), // Slightly darker light blue
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05),
                  // Logo + App Name Header Component
                  _LogoHeader(
                    logoPath: AppAssets.appLogo,
                    appName: context.l10n.appName,
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06),
                  // Register Title
                  Text(
                    context.l10n.register,
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Name field
                  AppTextField(
                    label: context.l10n.name,
                    hint: context.l10n.nameHint,
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.person_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.nameRequired;
                      }
                      if (value.trim().length < 2) {
                        return context.l10n.nameMinLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Email field
                  AppTextField(
                    label: context.l10n.email,
                    hint: context.l10n.emailHint,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.emailRequired;
                      }
                      if (!value.contains('@')) {
                        return context.l10n.emailInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Password field
                  AppTextField(
                    label: context.l10n.password,
                    hint: context.l10n.createPassword,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.passwordRequired;
                      }
                      if (value.length < 6) {
                        return context.l10n.passwordMinLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Premium Register button with glossy effect
                  _PremiumButton(
                    onPressed: (isEmailLoading || isGoogleLoading)
                        ? null
                        : _handleRegister,
                    isLoading: isEmailLoading,
                    child: Text(
                      context.l10n.register,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Separator
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.gray300.withOpacity(0.5),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm),
                        child: Text(
                          context.l10n.or,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.gray500,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.gray300.withOpacity(0.5),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Modern Google Sign-In button
                  _GoogleSignInButton(
                    onPressed: (isEmailLoading || isGoogleLoading)
                        ? null
                        : _handleGoogleSignIn,
                    isLoading: isGoogleLoading,
                    text: context.l10n.continueWithGoogleRegister,
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03),
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.alreadyHaveAccount,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: AppColors.gray600,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go(AppRoutes.login);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: AppSpacing.xs,
                          ),
                        ),
                        child: Text(
                          context.l10n.signIn,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).padding.bottom +
                          AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo + App Name Header Component
class _LogoHeader extends StatelessWidget {
  const _LogoHeader({
    required this.logoPath,
    required this.appName,
  });

  final String logoPath;
  final String appName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo with soft shadow - transparent background
        // Logo PNG dosyasının şeffaf arka planlı olması gerekiyor
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              logoPath,
              width: 72,
              height: 72,
              fit: BoxFit.contain,
              cacheWidth: 144,
              // PNG dosyasının alpha channel'ı korunur
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Logo load error: $error');
                return Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 48,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // App Name
        Text(
          appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
                fontSize: 24,
                letterSpacing: -0.3,
                height: 1.2,
              ),
        ),
      ],
    );
  }
}

/// Premium Button with glossy effect
class _PremiumButton extends StatelessWidget {
  const _PremiumButton({
    required this.onPressed,
    required this.child,
    this.isLoading = false,
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
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.onPressed,
    required this.text,
    this.isLoading = false,
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
                      const _GoogleIcon(),
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

/// Google ikonu widget'ı - Google'ın resmi logosunu kullanır
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon({this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.7,
      height: size,
      child: Builder(
        builder: (context) {
          try {
            return SvgPicture.asset(
              'assets/icons/google_logo.svg',
              width: size * 1.7,
              height: size,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => const Icon(
                Icons.g_mobiledata,
                size: 20,
              ),
            );
          } catch (e) {
            // SVG dosyası yoksa veya yüklenemezse fallback göster
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
