import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/index.dart';
import '../../../../shared/providers/ai_providers.dart';
import '../../../../shared/services/ai_service.dart';

/// AI Optimize Bottom Sheet
/// Shows AI-optimized goal suggestions and allows user to apply them
class AIOptimizeBottomSheet extends ConsumerStatefulWidget {
  const AIOptimizeBottomSheet({
    super.key,
    required this.goalTitle,
    required this.category,
    this.motivation,
    required this.onApply,
  });

  final String goalTitle;
  final String category;
  final String? motivation;
  final void Function(OptimizeGoalResponse) onApply;

  @override
  ConsumerState<AIOptimizeBottomSheet> createState() =>
      _AIOptimizeBottomSheetState();
}

class _AIOptimizeBottomSheetState
    extends ConsumerState<AIOptimizeBottomSheet> {
  late final OptimizeGoalParams _params;

  @override
  void initState() {
    super.initState();
    _params = OptimizeGoalParams(
      goalTitle: widget.goalTitle,
      category: widget.category,
      motivation: widget.motivation,
    );
  }

  @override
  Widget build(BuildContext context) {
    final optimizedAsync = ref.watch(optimizedGoalProvider(_params));
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.15),
                              AppColors.primary.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Optimizasyonu',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hedefiniz SMART formatına çevrildi',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Content
                  optimizedAsync.when(
                    data: (result) {
                      if (result == null) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: Text('Optimizasyon sonucu bulunamadı'),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Optimized Title
                          _SectionTitle('Optimize Edilmiş Hedef'),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            width: double.infinity,
                            padding: AppSpacing.paddingMd,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.08),
                                  AppColors.primary.withOpacity(0.03),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: AppRadius.borderRadiusMd,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              result.optimizedTitle,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                height: 1.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Explanation
                          _SectionTitle('Açıklama'),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            width: double.infinity,
                            padding: AppSpacing.paddingMd,
                            decoration: BoxDecoration(
                              color: AppColors.gray50,
                              borderRadius: AppRadius.borderRadiusMd,
                              border: Border.all(
                                color: AppColors.gray200,
                              ),
                            ),
                            child: Text(
                              result.explanation,
                              style: AppTextStyles.bodyMedium.copyWith(
                                height: 1.5,
                                color: AppColors.gray700,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Sub Goals
                          _SectionTitle('Önerilen Alt Görevler'),
                          const SizedBox(height: AppSpacing.md),
                          ...result.subGoals.asMap().entries.map((entry) {
                            final index = entry.key;
                            final subGoal = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: Container(
                                padding: AppSpacing.paddingMd,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppRadius.borderRadiusMd,
                                  border: Border.all(
                                    color: AppColors.gray200,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.primary.withOpacity(0.8),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          subGoal.title,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            height: 1.4,
                                            color: AppColors.gray800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),

                          // Bottom spacing for action buttons
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stackTrace) => Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Optimizasyon başarısız',
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            error.toString(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.gray600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppButton(
                            variant: AppButtonVariant.outlined,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Kapat'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed Action Buttons
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: AppColors.gray200,
                  width: 1,
                ),
              ),
            ),
            child: optimizedAsync.when(
              data: (result) {
                if (result == null) {
                  return const SizedBox.shrink();
                }
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusMd,
                          ),
                          side: BorderSide(
                            color: AppColors.gray300,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'İptal',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.9),
                            ],
                          ),
                          borderRadius: AppRadius.borderRadiusMd,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              widget.onApply(result);
                              Navigator.of(context).pop();
                            },
                            borderRadius: AppRadius.borderRadiusMd,
                            child: Container(
                              height: 56,
                              alignment: Alignment.center,
                              child: Text(
                                'Uygula',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.gray700,
      ),
    );
  }
}

