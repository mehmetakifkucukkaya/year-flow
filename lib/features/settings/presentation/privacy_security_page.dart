import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

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
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _PrivacyAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
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
            'Gizlilik & Güvenlik',
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
                  'Verilerin Senin Kontrolünde',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'YearFlow, hedef, check-in ve rapor verilerini KVKK ve ilgili veri koruma mevzuatına uygun şekilde işler. '
                  'Kişisel verilerin reklam amaçlı üçüncü kişilerle paylaşılmaz; yalnızca uygulama deneyimini geliştirmek, kişiselleştirilmiş içerik üretmek ve ürün analitiği yapmak için kullanılır. '
                  'Dilediğin zaman verilerini indirip inceleyebilir veya hesap silme sürecini kullanarak verilerinin sistemden kaldırılmasını talep edebilirsin.',
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
          'Veri İşleme ve Güvenlik',
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
                  'KVKK ve Veri Koruma',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _BulletText(
                  text:
                      'YearFlow’da tuttuğun tüm hedef, check-in ve rapor verileri KVKK ve ilgili mevzuata uygun şekilde işlenir.',
                ),
                _BulletText(
                  text:
                      'Verilerin; uygulama deneyimini iyileştirmek, kişiselleştirilmiş içerikler sunmak ve ürün analitiği yapmak dışında başka bir amaçla kullanılmaz.',
                ),
                _BulletText(
                  text:
                      'Kişisel verilerin reklam, pazarlama veya profilleme amaçlı üçüncü taraflarla paylaşılmaz.',
                ),
                _BulletText(
                  text:
                      'Hesabını sildiğinde, kimliğini doğrudan belirleyen kişisel verilerin makul bir süre içinde sistemden silinmesi hedeflenir.',
                ),
                _BulletText(
                  text:
                      'Yasal yükümlülükler gereği tutulması zorunlu olan kayıtlar, yalnızca mevzuata uygun süre boyunca saklanır ve süresi dolduğunda güvenli biçimde imha edilir.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Güvenlik',
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
              children: const [
                _BulletText(
                  text:
                      'Verilerin, endüstri standartlarına uygun biçimde yetkisiz erişime, kayba veya kötüye kullanıma karşı korunur.',
                ),
                _BulletText(
                  text:
                      'Sistem içindeki tüm veri iletimi şifrelenmiş bağlantılar üzerinden gerçekleşir.',
                ),
                _BulletText(
                  text:
                      'Güvenlik uygulamaları belirli aralıklarla gözden geçirilir ve iyileştirilir.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
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

class _PrivacyOptionTile extends StatelessWidget {
  const _PrivacyOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.gray50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.gray900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}


