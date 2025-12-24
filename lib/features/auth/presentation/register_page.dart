import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:year_flow/core/theme/app_colors.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/connectivity_helper.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/index.dart';
import '../../../shared/utils/auth_utils.dart';
import '../../../shared/widgets/auth_widgets.dart';
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

    // İnternet bağlantısını kontrol et
    final isOnline = await ConnectivityHelper.isOnline();
    if (!isOnline) {
      if (mounted) {
        AppSnackbar.showWarning(
          context,
          message:
              'Kayıt olmak için internet bağlantısı gereklidir. Lütfen bağlantınızı kontrol edip tekrar deneyin.',
        );
      }
      return;
    }

    await ref.read(authStateProvider.notifier).signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
  }

  Future<void> _handleGoogleSignIn() async {
    if (!mounted) return;

    // İnternet bağlantısını kontrol et
    final isOnline = await ConnectivityHelper.isOnline();
    if (!isOnline) {
      if (mounted) {
        AppSnackbar.showWarning(
          context,
          message:
              'Giriş yapmak için internet bağlantısı gereklidir. Lütfen bağlantınızı kontrol edip tekrar deneyin.',
        );
      }
      return;
    }

    await ref.read(authStateProvider.notifier).signInWithGoogle();

    if (!mounted) return;

    final authState = ref.read(authStateProvider);

    if (authState.errorMessage != null || authState.errorCode != null) {
      final message = resolveAuthError(
        context,
        authState.errorMessage,
        authState.errorCode,
      );
      AppSnackbar.showError(context, message: message);
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
    // Cache MediaQuery for performance
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Sadece loading state'ini watch et, böylece form state'i korunur
    final isEmailLoading =
        ref.watch(authStateProvider.select((s) => s.isEmailLoading));
    final isGoogleLoading =
        ref.watch(authStateProvider.select((s) => s.isGoogleLoading));

    // State değişikliklerini dinle (sadece state değiştiğinde çağrılır)
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (!mounted) return;

      // Hata mesajı varsa göster ve yönlendirme yapma
      if ((next.errorMessage != null || next.errorCode != null) &&
          (next.errorMessage != previous?.errorMessage ||
              next.errorCode != previous?.errorCode)) {
        final resolvedMessage = resolveAuthError(
          context,
          next.errorMessage,
          next.errorCode,
        );
        try {
          AppSnackbar.showError(context, message: resolvedMessage);
        } catch (e) {
          debugPrint('Snackbar error: $e');
        }
        // Hata durumunda yönlendirme yapma, kullanıcı kayıt sayfasında kalsın
        // email-already-in-use hatası için özel bir işlem yapılabilir ama şimdilik sadece hata göster
        return;
      }

      // Sadece başarılı kayıt yapıldıysa ve hata yoksa yönlendir
      // Hata durumunda (errorMessage veya errorCode varsa) yönlendirme yapma
      if (next.isAuthenticated &&
          !(previous?.isAuthenticated ?? false) &&
          next.errorMessage == null &&
          next.errorCode == null) {
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
                  SizedBox(height: screenHeight * 0.05),
                  // Logo + App Name Header Component
                  AuthLogoHeader(
                    logoPath: AppAssets.appLogo,
                    appName: context.l10n.appName,
                  ),
                  SizedBox(height: screenHeight * 0.06),
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
                  PremiumButton(
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
                  GoogleSignInButton(
                    onPressed: (isEmailLoading || isGoogleLoading)
                        ? null
                        : _handleGoogleSignIn,
                    isLoading: isGoogleLoading,
                    text: context.l10n.continueWithGoogleRegister,
                  ),
                  SizedBox(height: screenHeight * 0.03),
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
                  SizedBox(height: bottomPadding + AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
