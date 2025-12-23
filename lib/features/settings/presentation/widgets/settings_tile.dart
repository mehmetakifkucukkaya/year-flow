import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:year_flow/core/providers/locale_provider.dart';
import 'package:year_flow/core/theme/app_colors.dart';
import 'package:year_flow/core/theme/app_radius.dart';
import 'package:year_flow/core/theme/app_spacing.dart';
import 'package:year_flow/core/theme/app_text_styles.dart';
import 'package:year_flow/core/utils/extensions.dart';

/// Settings tile widget with icon, title, and optional trailing widget
class SettingsTile extends ConsumerWidget {
  const SettingsTile._({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  // Public constructor for generic settings tiles
  const SettingsTile.plain({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  const SettingsTile.notification({super.key})
      : icon = Icons.notifications_rounded,
        title = '', // Will be set in build method
        trailing = const _NotificationSwitch(),
        onTap = null;

  const SettingsTile.language({super.key})
      : icon = Icons.language_rounded,
        title = '',
        trailing = null,
        onTap = null;

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isLanguageTile = icon == Icons.language_rounded;
    final currentLocale =
        isLanguageTile ? ref.watch(localeProvider) : null;
    final currentLanguageLabel = currentLocale != null
        ? (currentLocale.languageCode == 'tr'
            ? l10n.turkish
            : l10n.english)
        : null;
    final displayTitle = isLanguageTile
        ? l10n.language
        : (title.isEmpty ? l10n.notifications : title);

    return InkWell(
      onTap: trailing is _NotificationSwitch
          ? null
          : isLanguageTile
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
              ChevronWithLabel(label: currentLanguageLabel),
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

/// Notification switch widget for settings tile
class _NotificationSwitch extends StatefulWidget {
  const _NotificationSwitch();

  @override
  State<_NotificationSwitch> createState() => _NotificationSwitchState();
}

class _NotificationSwitchState extends State<_NotificationSwitch> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.85,
      child: Switch(
        value: _value,
        onChanged: (value) {
          setState(() {
            _value = value;
          });
        },
      ),
    );
  }
}

/// Chevron with optional label widget
class ChevronWithLabel extends StatelessWidget {
  const ChevronWithLabel({super.key, required this.label});

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
