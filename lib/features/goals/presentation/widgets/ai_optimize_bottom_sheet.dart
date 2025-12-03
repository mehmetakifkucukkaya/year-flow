import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/index.dart';
import '../../../../shared/providers/ai_providers.dart';
import '../../../../shared/services/ai_service.dart';

String _shortenGoalTitle(String input) {
  var text = input.trim();
  if (text.isEmpty) return text;

  var words = text.split(RegExp(r'\s+'));

  // Çok kelimeli süre ifadelerini baştan kırp (örn. "3 ay içinde", "6 ay boyunca")
  if (words.length > 3) {
    final lower = words.map((w) => w.toLowerCase()).toList();
    final isNumber = RegExp(r'^\d+$').hasMatch(lower[0]);
    final isTimeUnit = ['gün', 'hafta', 'ay', 'yıl'].contains(lower[1]);
    if (isNumber && isTimeUnit) {
      var start = 2;
      if (lower.length > 2 &&
          (lower[2] == 'içinde' || lower[2] == 'boyunca')) {
        start = 3;
      }
      words = words.sublist(start);
    }
  }

  if (words.length > 5) {
    words = words.sublist(0, 5);
  }

  return words.join(' ');
}

/// AI Optimize Bottom Sheet
/// Shows AI-optimized goal suggestions and allows user to apply them
class AIOptimizeBottomSheet extends ConsumerStatefulWidget {
  const AIOptimizeBottomSheet({
    super.key,
    required this.goalTitle,
    required this.category,
    this.targetDate,
    this.motivation,
    required this.onApply,
  });

  final String goalTitle;
  final String category;
  final DateTime? targetDate;
  final String? motivation;
  final void Function(OptimizeGoalResponse) onApply;

  @override
  ConsumerState<AIOptimizeBottomSheet> createState() =>
      _AIOptimizeBottomSheetState();
}

class _AIOptimizeBottomSheetState
    extends ConsumerState<AIOptimizeBottomSheet> {
  late final OptimizeGoalParams _params;
  TextEditingController? _titleController;

  @override
  void initState() {
    super.initState();
    _params = OptimizeGoalParams(
      goalTitle: widget.goalTitle,
      category: widget.category,
      motivation: widget.motivation,
      targetDate: widget.targetDate,
    );
  }

  @override
  void dispose() {
    _titleController?.dispose();
    super.dispose();
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

                      // Initialize editable title controller once with shortened title
                      _titleController ??= TextEditingController(
                        text: _shortenGoalTitle(result.optimizedTitle),
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Optimized Title
                          const _SectionTitle('Optimize Edilmiş Hedef'),
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.zero,
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
                                  color:
                                      AppColors.primary.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _titleController,
                              maxLines: 2,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                height: 1.4,
                              ),
                              decoration: const InputDecoration(
                                contentPadding: AppSpacing.paddingMd,
                                border: InputBorder.none,
                                hintText: 'Kısa bir hedef adı yazın…',
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // Explanation
                          const _SectionTitle('Açıklama'),
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
                          const _SectionTitle('Önerilen Alt Görevler'),
                          const SizedBox(height: AppSpacing.md),
                          ...result.subGoals.asMap().entries.map((entry) {
                            final index = entry.key;
                            final subGoal = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md),
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
                                      color:
                                          Colors.black.withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.primary
                                                .withOpacity(0.8),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2),
                                        child: Text(
                                          subGoal.title,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
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
                          }),

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
                            child: const Icon(
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
                          Builder(
                            builder: (_) {
                              var message = error.toString();
                              // "Exception: " önekini temizle
                              if (message.startsWith('Exception:')) {
                                message = message
                                    .substring('Exception:'.length)
                                    .trim();
                              }
                              return Text(
                                message,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.gray600,
                                ),
                                textAlign: TextAlign.center,
                              );
                            },
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
            decoration: const BoxDecoration(
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
                final editedTitle =
                    _titleController?.text.trim().isEmpty ?? true
                        ? result.optimizedTitle
                        : _titleController!.text.trim();
                final optimizedResult = OptimizeGoalResponse(
                  optimizedTitle: editedTitle,
                  subGoals: result.subGoals,
                  explanation: result.explanation,
                );
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 56),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusMd,
                          ),
                          side: const BorderSide(
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
                              widget.onApply(optimizedResult);
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
