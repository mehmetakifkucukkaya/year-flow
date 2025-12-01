import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class CheckInPage extends ConsumerStatefulWidget {
  const CheckInPage({
    super.key,
    required this.goalId,
  });

  final String goalId;

  @override
  ConsumerState<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends ConsumerState<CheckInPage> {
  final TextEditingController _progressController =
      TextEditingController();
  final TextEditingController _challengeController =
      TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  double _score = 7;

  @override
  void dispose() {
    _progressController.dispose();
    _challengeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4F6FF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverSafeArea(
              bottom: false,
              sliver: SliverToBoxAdapter(
                child: _CheckInAppBar(goalId: widget.goalId),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ScoreCard(
                      score: _score,
                      onChanged: (value) {
                        setState(() {
                          _score = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _QuestionCard(
                      title: 'Bu ay bu hedef için ne yaptın?',
                      subtitle:
                          'Küçük adımlar da sayılır. Kısa yazman yeterli.',
                      hintText:
                          'Örn: Haftada 3 kez çalıştım, iki bölüm okudum, kelime pratiği yaptım…',
                      controller: _progressController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _QuestionCard(
                      title:
                          'Bu süreçte seni en çok ne zorladı? Bununla nasıl başa çıktın?',
                      subtitle:
                          'İstersen sadece zorlandığın kısmı da yazabilirsin.',
                      hintText:
                          'Örn: İş yükü rutinimi bozdu; tekrar toparlanmak için haftalık plan yapmaya başladım…',
                      controller: _challengeController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _QuestionCard(
                      title:
                          'Gelecekteki kendine küçük bir not bırakmak ister misin?',
                      subtitle: null,
                      hintText:
                          'Örn: Harika gidiyorsun. Tutarlı kal ve sürece güven.',
                      controller: _noteController,
                      maxLines: 3,
                      optional: true,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF2B8CEE),
                              Color(0xFF4F46E5),
                            ],
                          ),
                          borderRadius: AppRadius.borderRadiusXl,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.borderRadiusXl,
                            ),
                          ),
                          onPressed: _submit,
                          child: const Text('Check-in’i Kaydet'),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckInAppBar extends StatelessWidget {
  const _CheckInAppBar({required this.goalId});

  final String goalId;

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Aylık Check-in',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Kısa bir yansıma molası ver',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.score,
    required this.onChanged,
  });

  final double score;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFEAF3FF),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bu ayki ilerlemeni nasıl değerlendirirsin?',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '1 çok düşük ilerleme, 10 mükemmel ilerleme anlamına gelir.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text(
                '1',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray500,
                ),
              ),
              Expanded(
                child: Slider(
                  value: score,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: score.round().toString(),
                  onChanged: onChanged,
                ),
              ),
              Text(
                '10',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Skor: ${score.round()} / 10',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.title,
    required this.hintText,
    required this.controller,
    required this.maxLines,
    this.optional = false,
    this.subtitle,
  });

  final String title;
  final String hintText;
  final TextEditingController controller;
  final int maxLines;
  final bool optional;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF2F6FF),
          ],
        ),
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (optional)
                  TextSpan(
                    text: '  Opsiyonel',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray400,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
