import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
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
            message: 'Hoş geldiniz! 🎉',
            duration: const Duration(seconds: 2),
          );
        } else {
          AppSnackbar.showInfo(
            context,
            message: 'Giriş başarılı! Hoş geldiniz 👋',
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
    final isEmailLoading = ref.watch(authStateProvider.select((s) => s.isEmailLoading));
    final isGoogleLoading = ref.watch(authStateProvider.select((s) => s.isGoogleLoading));
    
    // State değişikliklerini dinle (sadece state değiştiğinde çağrılır)
    ref.listenManual<AuthState>(authStateProvider, (previous, next) {
      if (!mounted) return;
      
      // Hata mesajı varsa göster
      if (next.errorMessage != null && 
          next.errorMessage != previous?.errorMessage) {
        AppSnackbar.showError(context, message: next.errorMessage!);
      }
      
      // Başarılı kayıt yapıldıysa yönlendir
      if (next.isAuthenticated && !(previous?.isAuthenticated ?? false)) {
        context.go(AppRoutes.home);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Logo
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 64,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'YearFlow',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              color: AppColors.gray900,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Başlık
                Text(
                  'Kayıt Ol',
                  style:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.gray900,
                            fontWeight: FontWeight.bold,
                          ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Name field
                AppTextField(
                  label: 'İsim',
                  hint: 'Adınızı ve soyadınızı girin',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'İsim gereklidir';
                    }
                    if (value.trim().length < 2) {
                      return 'İsim en az 2 karakter olmalıdır';
                    }
                    return null;
                  },
                ),
                AppSpacers.md,
                // Email field
                AppTextField(
                  label: 'E-posta',
                  hint: 'E-posta adresinizi girin',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta adresi gereklidir';
                    }
                    if (!value.contains('@')) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                ),
                AppSpacers.md,
                // Password field
                AppTextField(
                  label: 'Şifre',
                  hint: 'Şifrenizi oluşturun',
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
                      return 'Şifre gereklidir';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalı';
                    }
                    return null;
                  },
                ),
                AppSpacers.lg,
                // Register button
                AppButton(
                  onPressed: (isEmailLoading || isGoogleLoading)
                      ? null
                      : _handleRegister,
                  isLoading: isEmailLoading,
                  child: const Text('Kayıt Ol'),
                ),
                AppSpacers.lg,
                // Separator
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: AppColors.gray200,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'veya',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.gray500,
                              ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Divider(
                        color: AppColors.gray200,
                      ),
                    ),
                  ],
                ),
                AppSpacers.lg,
                // Google Sign-Up (Sign-In) button
                AppButton(
                  onPressed: (isEmailLoading || isGoogleLoading)
                      ? null
                      : _handleGoogleSignIn,
                  variant: AppButtonVariant.outlined,
                  isLoading: isGoogleLoading,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Google Icon
                      _GoogleIcon(),
                      SizedBox(width: 8),
                      Text(
                        'Google ile kayıt ol / devam et',
                      ),
                    ],
                  ),
                ),
                AppSpacers.xl,
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Zaten bir hesabın var mı? '),
                    TextButton(
                      onPressed: () {
                        context.go(AppRoutes.login);
                      },
                      child: const Text('Giriş Yap'),
                    ),
                  ],
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
  const _GoogleIcon({this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.7,
      height: size,
      child: SvgPicture.asset(
        'assets/icons/google_logo.svg',
        width: size * 1.7,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
