import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/goal_providers.dart';
import '../../auth/providers/auth_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF4F2FF),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              _ProfileAppBar(),
              const Expanded(
                child: _ProfileBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerStatefulWidget {
  const _ProfileBody();

  @override
  ConsumerState<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<_ProfileBody> {
  String? _name;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = ref.read(authStateProvider);
    final user = authState.currentUser;
    setState(() {
      _name = user?.displayName ?? 'Kullanıcı';
      _email = user?.email ?? '';
    });
  }

  Future<void> _showEditProfileSheet(BuildContext context) async {
    final nameController = TextEditingController(text: _name ?? '');
    final emailController = TextEditingController(text: _email ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusTopXl,
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profili Düzenle',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _name = nameController.text.trim().isEmpty
                          ? _name
                          : nameController.text.trim();
                      _email = emailController.text.trim().isEmpty
                          ? _email
                          : emailController.text.trim();
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.currentUser;
    final displayName = user?.displayName ?? _name ?? 'Kullanıcı';
    final email = user?.email ?? _email ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeaderCard(
            name: displayName,
            email: email,
            createdAt: user != null ? _getUserCreatedAt(user.uid) : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          const _ProfileStatsSection(),
          const SizedBox(height: AppSpacing.xl),
          _ProfileInfoSection(
            name: displayName,
            email: email,
            onEdit: () => _showEditProfileSheet(context),
          ),
        ],
      ),
    );
  }

  String? _getUserCreatedAt(String uid) {
    // Firebase'den kullanıcı oluşturulma tarihini almak için
    // Şimdilik null döndürüyoruz, gerekirse Firestore'dan alınabilir
    return null;
  }
}

class _ProfileAppBar extends StatelessWidget {
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
            'Profil',
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

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.name,
    required this.email,
    this.createdAt,
  });

  final String name;
  final String email;
  final String? createdAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderRadiusXl,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
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
              border: Border.all(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
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
                        color: const Color(0xFF2B8CEE).withOpacity(0.55),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.gray900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        email,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.gray700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (createdAt != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          createdAt!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.gray700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Light streak highlight
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                borderRadius: AppRadius.borderRadiusXl,
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.35),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsSection extends ConsumerWidget {
  const _ProfileStatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allGoalsAsync = ref.watch(allGoalsStreamProvider);

    return allGoalsAsync.when(
      loading: () => const Row(
        children: [
          Expanded(
            child: _ProfileStatCard(
              label: 'Toplam Hedef',
              value: '0',
              icon: Icons.flag_rounded,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _ProfileStatCard(
              label: 'Yıllık Rapor',
              value: '0',
              icon: Icons.auto_graph_rounded,
            ),
          ),
        ],
      ),
      error: (_, __) => const Row(
        children: [
          Expanded(
            child: _ProfileStatCard(
              label: 'Toplam Hedef',
              value: '0',
              icon: Icons.flag_rounded,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _ProfileStatCard(
              label: 'Yıllık Rapor',
              value: '0',
              icon: Icons.auto_graph_rounded,
            ),
          ),
        ],
      ),
      data: (goals) {
        final totalGoals = goals.length;
        // Yıllık rapor sayısı için şimdilik 0 gösteriyoruz
        // Gerçek veriyi almak için ayrı bir provider gerekebilir
        return Row(
          children: [
            Expanded(
              child: _ProfileStatCard(
                label: 'Toplam Hedef',
                value: totalGoals.toString(),
                icon: Icons.flag_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: _ProfileStatCard(
                label: 'Yıllık Rapor',
                value: '0',
                icon: Icons.auto_graph_rounded,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEEF2FF),
            Color(0xFFE0F2FE),
          ],
        ),
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: Colors.white.withOpacity(0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.9),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.gray800,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
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

class _ProfileInfoSection extends StatelessWidget {
  const _ProfileInfoSection({
    required this.name,
    required this.email,
    required this.onEdit,
  });

  final String name;
  final String email;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hesap Bilgileri',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.gray500,
                letterSpacing: 0.8,
              ),
            ),
            TextButton(
              onPressed: onEdit,
              child: const Text('Düzenle'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProfileFieldCard(
          label: 'Ad Soyad',
          value: name,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ProfileFieldCard(
          label: 'E-posta',
          value: email,
        ),
      ],
    );
  }
}

class _ProfileFieldCard extends StatelessWidget {
  const _ProfileFieldCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 1,
              width: double.infinity,
              color: AppColors.gray100,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.gray900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
