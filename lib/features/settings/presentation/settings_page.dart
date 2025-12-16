import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/index.dart';
import '../../../shared/providers/goal_providers.dart';
import '../../auth/providers/auth_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  // Premium background color
  static const Color _premiumBackground = Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: _premiumBackground,
      child: CustomScrollView(
        slivers: [
          // SafeArea for status bar
          SliverSafeArea(
            bottom: false,
            sliver: SliverToBoxAdapter(
              child: _SettingsAppBar(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileSection(),
                  SizedBox(height: AppSpacing.xl),
                  _AppSettingsSection(),
                  SizedBox(height: AppSpacing.xl),
                  _DataAndPrivacySection(),
                  SizedBox(height: AppSpacing.xl),
                  _SecuritySection(),
                  SizedBox(height: AppSpacing.xl),
                  _LogoutSection(),
                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settings,
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.settingsSubtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 48), // Notification button yerine boşluk
        ],
      ),
    );
  }
}

class _ProfileSection extends ConsumerWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final authState = ref.watch(authStateProvider);
    final user = authState.currentUser;
    final displayName = user?.displayName ?? l10n.user;
    final email = user?.email ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.borderRadiusXl,
        onTap: () {
          context.push(AppRoutes.profile);
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEEF2FF),
                Color(0xFFE0F2FE),
              ],
            ),
            borderRadius: AppRadius.borderRadiusXl,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4F46E5),
                      Color(0xFF2B8CEE),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2B8CEE).withOpacity(0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppSettingsSection extends ConsumerWidget {
  const _AppSettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            context.l10n.applicationSettings,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.gray500,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.borderRadiusXl,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Column(
            children: [
              _SettingsTile.notification(),
              Divider(height: 1),
              _SettingsTile.language(),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends ConsumerWidget {
  const _SettingsTile._({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.isLanguage = false,
  });

  const _SettingsTile.notification()
      : icon = Icons.notifications_rounded,
        title = '', // Will be set in build method
        trailing = const _NotificationSwitch(),
        onTap = null,
        isLanguage = false;

  const _SettingsTile.language()
      : icon = Icons.language_rounded,
        title = '',
        trailing = null,
        onTap = null,
        isLanguage = true;

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLanguage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale = isLanguage ? ref.watch(localeProvider) : null;
    final currentLanguageLabel = currentLocale != null
        ? (currentLocale.languageCode == 'tr'
            ? l10n.turkish
            : l10n.english)
        : null;
    final displayTitle = isLanguage
        ? l10n.language
        : (title.isEmpty ? l10n.notifications : title);

    return InkWell(
      onTap: trailing is _NotificationSwitch
          ? null
          : isLanguage
              ? () => _showLanguageDialog(context, ref)
              : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md + 2,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.gray50,
                borderRadius: AppRadius.borderRadiusLg,
              ),
              child: Icon(
                icon,
                color: AppColors.gray700,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                displayTitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (currentLanguageLabel != null)
              _ChevronWithLabel(label: currentLanguageLabel),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale = ref.read(localeProvider);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              title: Text(l10n.turkish),
              value: const Locale('tr', 'TR'),
              groupValue: currentLocale,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(value);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
            RadioListTile<Locale>(
              title: Text(l10n.english),
              value: const Locale('en', 'US'),
              groupValue: currentLocale,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(value);
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSwitch extends StatefulWidget {
  const _NotificationSwitch();

  @override
  State<_NotificationSwitch> createState() => _NotificationSwitchState();
}

class _NotificationSwitchState extends State<_NotificationSwitch> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      onChanged: (value) {
        setState(() {
          _value = value;
        });
      },
    );
  }
}

class _ChevronWithLabel extends StatelessWidget {
  const _ChevronWithLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final hasLabel = label.isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasLabel)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 6,
            ),
            decoration: const BoxDecoration(
              color: AppColors.gray50,
              borderRadius: AppRadius.borderRadiusFull,
            ),
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (hasLabel) const SizedBox(width: AppSpacing.xs),
        const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.gray400,
        ),
      ],
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            context.l10n.securityAndSupport,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.gray500,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.borderRadiusXl,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _SettingsTile._(
            icon: Icons.shield_rounded,
            title: context.l10n.privacyAndSecurity,
            trailing: const _ChevronWithLabel(label: ''),
            onTap: () {
              context.push(AppRoutes.privacySecurity);
            },
          ),
        ),
      ],
    );
  }
}

class _DataAndPrivacySection extends ConsumerWidget {
  const _DataAndPrivacySection();

  void _showExportOptionsDialog(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExportOptionsBottomSheet(type: type),
    );
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    // Kullanıcıya uyarı göster: mevcut veriler silinecek
    final shouldImport = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadius.borderRadiusXl,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.borderRadiusFull,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFB74D),
                        Color(0xFFF57C00),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF57C00).withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.l10n.restoreFromBackupTitle,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.restoreFromBackupWarning,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: AppColors.gray300,
                            width: 1.5,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusLg,
                          ),
                        ),
                        child: Text(
                          context.l10n.cancel,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(true),
                        style: FilledButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.borderRadiusLg,
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.l10n.yesContinue,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldImport != true) {
      return;
    }

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      AppSnackbar.showError(context, message: context.l10n.loginRequired);
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        // Kullanıcı seçim yapmadan çıktı
        return;
      }

      final filePath = result.files.single.path!;
      final exportService = ref.read(exportServiceProvider);
      await exportService.importBackupFromJson(
        userId: userId,
        filePath: filePath,
      );

      if (context.mounted) {
        AppSnackbar.showSuccess(
          context,
          message: context.l10n.backupImportedSuccess,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            context.l10n.data,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.gray500,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.borderRadiusXl,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _SettingsTile._(
                icon: Icons.file_download_rounded,
                title: context.l10n.downloadAllMyData,
                trailing: const _ChevronWithLabel(label: 'JSON / CSV'),
                onTap: () {
                  _showExportOptionsDialog(context, 'all_data');
                },
              ),
              const Divider(height: 1),
              _SettingsTile._(
                icon: Icons.upload_rounded,
                title: context.l10n.restoreFromBackup,
                trailing: const _ChevronWithLabel(label: 'JSON'),
                onTap: () {
                  _importBackup(context, ref);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogoutSection extends ConsumerWidget {
  const _LogoutSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () async {
          // Modern onay dialogu göster
          final shouldLogout = await showDialog<bool>(
            context: context,
            barrierColor: Colors.black.withOpacity(0.5),
            builder: (context) => const _LogoutConfirmationDialog(),
          );

          if (shouldLogout == true && context.mounted) {
            await ref.read(authStateProvider.notifier).signOut();
            if (context.mounted) {
              context.go(AppRoutes.login);
            }
          }
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppColors.gray300.withOpacity(0.9),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusXl,
          ),
        ),
        icon: const Icon(
          Icons.logout_rounded,
          color: AppColors.gray700,
        ),
        label: Text(
          context.l10n.logOut,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.gray800,
          ),
        ),
      ),
    );
  }
}

class _LogoutConfirmationDialog extends StatelessWidget {
  const _LogoutConfirmationDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.borderRadiusXl,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // İkon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6B6B),
                    Color(0xFFFF5252),
                  ],
                ),
                borderRadius: AppRadius.borderRadiusFull,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5252).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            // Başlık
            Text(
              context.l10n.logOut,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 12),
            // Açıklama
            Text(
              context.l10n.logOutConfirmation,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: AppColors.gray300,
                        width: 1.5,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusLg,
                      ),
                    ),
                    child: Text(
                      context.l10n.cancel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFFFF5252),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusLg,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      context.l10n.logOut,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerZoneSection extends ConsumerWidget {
  const _DangerZoneSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              _showChangePasswordDialog(context, ref);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppColors.gray300.withOpacity(0.9),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.borderRadiusXl,
              ),
            ),
            child: Text(
              context.l10n.changePassword,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.gray800,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF4B4B),
                  Color(0xFFDC2626),
                ],
              ),
              borderRadius: AppRadius.borderRadiusXl,
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: () {
                _showDeleteAccountDialog(context, ref);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.borderRadiusXl,
                ),
              ),
              icon: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.white,
              ),
              label: Text(
                'Hesabı Sil',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog(
      BuildContext context, WidgetRef ref) async {
    // Result: true = başarılı, String = hata mesajı, null = iptal
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _ChangePasswordBottomSheet(
        ref: ref,
        parentContext: context,
      ),
    );

    if (!context.mounted) return;

    // Hata durumu - String döndü
    if (result is String) {
      AppSnackbar.showError(
        context,
        message: result,
      );
      return;
    }

    // Şifre başarıyla değiştirildi - true döndü
    if (result == true) {
      // Snackbar'ı göster (bottom sheet kapandıktan sonra, context hala geçerli)
      AppSnackbar.showSuccess(
        context,
        message: context.l10n.passwordChangedSuccess,
        duration: const Duration(seconds: 2),
      );

      // 2 saniye bekle (snackbar görünsün)
      await Future.delayed(const Duration(seconds: 2));

      // Logout yap ve login'e yönlendir
      if (context.mounted) {
        await ref.read(authStateProvider.notifier).signOut();
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      }
    }
  }

  void _showDeleteAccountDialog(
      BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => const _DeleteAccountConfirmationDialog(),
    );

    if (shouldDelete == true && context.mounted) {
      try {
        await ref.read(authStateProvider.notifier).deleteAccount();
        if (context.mounted) {
          AppSnackbar.showSuccess(
            context,
            message: context.l10n.accountDeletedSuccess,
          );
          await Future.delayed(const Duration(milliseconds: 500));
          if (context.mounted) {
            context.go(AppRoutes.login);
          }
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.showError(
            context,
            message: context.l10n.errorDeletingAccount,
          );
        }
      }
    }
  }
}

/// Change Password Bottom Sheet
class _ChangePasswordBottomSheet extends ConsumerStatefulWidget {
  const _ChangePasswordBottomSheet({
    required this.ref,
    required this.parentContext,
  });

  final WidgetRef ref;
  final BuildContext parentContext;

  @override
  ConsumerState<_ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState
    extends ConsumerState<_ChangePasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      AppSnackbar.showError(
        context,
        message: context.l10n.passwordsDoNotMatch,
      );
      return;
    }

    setState(() => _isLoading = true);

    // Auth listener'ı pause et (şifre değiştirme sırasında auth event'lerini yoksay)
    widget.ref.read(authStateProvider.notifier).startPasswordChange();

    try {
      // Firebase'den doğrudan şifre değiştir
      final authRepository = widget.ref.read(authRepositoryProvider);
      await authRepository.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        // Başarılı: Bottom sheet'i kapat ve true döndür
        // Snackbar ve logout işlemleri parent'ta yapılacak
        // NOT: endPasswordChange() signOut() içinde çağrılacak
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Hata durumunda auth listener'ı resume et
      widget.ref.read(authStateProvider.notifier).endPasswordChange();

      // Hata durumunda: Bottom sheet'i kapat ve hata mesajını döndür
      if (mounted) {
        // Lokalize hata mesajı
        final errorMessage =
            e.toString().contains('Mevcut şifre yanlış') ||
                    e.toString().contains('wrong-password') ||
                    e.toString().contains('invalid-credential')
                ? context.l10n.errorWrongCurrentPassword
                : e.toString().replaceFirst('Exception: ', '');
        Navigator.of(context).pop(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                context.l10n.changePassword,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: context.l10n.currentPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword =
                              !_obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n.enterCurrentPassword;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: context.l10n.newPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n.enterNewPassword;
                    }
                    if (value.length < 6) {
                      return context.l10n.passwordMinLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: context.l10n.newPasswordRepeat,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n.reEnterNewPassword;
                    }
                    if (value != _newPasswordController.text) {
                      return context.l10n.passwordsMismatch;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                      color: AppColors.gray300,
                      width: 1.5,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusLg,
                    ),
                  ),
                  child: Text(
                    context.l10n.cancel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleChangePassword,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusLg,
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                      : Text(
                          context.l10n.changePassword,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Delete Account Confirmation Dialog
class _DeleteAccountConfirmationDialog extends StatelessWidget {
  const _DeleteAccountConfirmationDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusXl,
      ),
      content: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.borderRadiusXl,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF7070),
                    Color(0xFFDC2626),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.deleteAccount,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.deleteAccountConfirmation,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: AppColors.gray300,
                        width: 1.5,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusLg,
                      ),
                    ),
                    child: Text(
                      context.l10n.cancel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFFFF5252),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.borderRadiusLg,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      context.l10n.deleteAccount,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Export Options Bottom Sheet
class _ExportOptionsBottomSheet extends ConsumerStatefulWidget {
  const _ExportOptionsBottomSheet({required this.type});

  final String type; // 'goals_reports' or 'all_data'

  @override
  ConsumerState<_ExportOptionsBottomSheet> createState() =>
      _ExportOptionsBottomSheetState();
}

class _ExportOptionsBottomSheetState
    extends ConsumerState<_ExportOptionsBottomSheet> {
  bool _isLoading = false;

  Future<void> _handleExport(String format) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      AppSnackbar.showError(context, message: context.l10n.loginRequired);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final exportService = ref.read(exportServiceProvider);

      if (widget.type == 'goals_reports') {
        if (format == 'json') {
          await exportService.exportGoalsAndReportsAsJson(userId);
        } else {
          await exportService.exportGoalsAndReportsAsCsv(userId);
        }
      } else {
        if (format == 'json') {
          await exportService.exportAllDataAsJson(userId);
        } else {
          await exportService.exportAllDataAsCsv(userId);
        }
      }

      if (mounted) {
        AppSnackbar.showSuccess(
          context,
          message: context.l10n.exportCompleted,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.exportAllData,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.exportDataFormatQuestion,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _isLoading ? null : () => _handleExport('csv'),
                  icon: const Icon(Icons.table_chart_rounded),
                  label: Text(context.l10n.tableCsv),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                      color: AppColors.gray300,
                      width: 1.5,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusLg,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _isLoading ? null : () => _handleExport('json'),
                  icon: const Icon(Icons.code_rounded),
                  label: Text(context.l10n.advancedJson),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                      color: AppColors.gray300,
                      width: 1.5,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusLg,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading) ...[
            const SizedBox(height: AppSpacing.md),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ],
      ),
    );
  }
}
