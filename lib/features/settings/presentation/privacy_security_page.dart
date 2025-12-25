import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';

class PrivacySecurityPage extends ConsumerWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F7FF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: const SafeArea(
          bottom: false,
          child: Column(
            children: [
              _PrivacyAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PrivacyIntroCard(),
                      SizedBox(height: AppSpacing.xl),
                      _PrivacyOptionsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyAppBar extends StatelessWidget {
  const _PrivacyAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: AppColors.gray900,
              iconSize: 18,
              padding: EdgeInsets.zero,
            ),
          ),
          const Spacer(),
          Text(
            context.l10n.privacyAndSecurity,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _PrivacyIntroCard extends StatelessWidget {
  const _PrivacyIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFF4FF),
            Color(0xFFE0F2FE),
          ],
        ),
        borderRadius: AppRadius.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.privacyTitle,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.privacyDescription,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyOptionsSection extends StatelessWidget {
  const _PrivacyOptionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.dataProcessingSecurity,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.gray500,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.borderRadiusXl,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.gdprDataProtection,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _BulletText(
                  text: context.l10n.privacyBullet1,
                ),
                _BulletText(
                  text: context.l10n.privacyBullet2,
                ),
                _BulletText(
                  text: context.l10n.privacyBullet3,
                ),
                _BulletText(
                  text: context.l10n.privacyBullet4,
                ),
                _BulletText(
                  text: context.l10n.privacyBullet5,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          context.l10n.security,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.gray500,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.borderRadiusXl,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BulletText(
                  text: context.l10n.securityBullet1,
                ),
                _BulletText(
                  text: context.l10n.securityBullet2,
                ),
                _BulletText(
                  text: context.l10n.securityBullet3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BulletText extends ConsumerWidget {
  const _BulletText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•  ',
            style: TextStyle(
              color: AppColors.gray600,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
