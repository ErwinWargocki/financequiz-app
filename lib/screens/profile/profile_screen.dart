import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../navigation/app_routes.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_loading_scaffold.dart';

import 'profile_widgets.dart';
import 'profile_history_tile.dart';
import 'profile_settings_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const AppLoadingScaffold(),
      error: (_, __) => const AppLoadingScaffold(),
      data: (user) {
        if (user == null) return const AppLoadingScaffold();
        final statsAsync = ref.watch(userStatsProvider(user.id!));
        final history = ref.watch(quizHistoryProvider(user.id!)).asData?.value ?? [];
        return statsAsync.when(
          loading: () => const AppLoadingScaffold(),
          error: (_, __) => const AppLoadingScaffold(),
          data: (stats) => _ProfileScaffold(
            user: user,
            stats: stats,
            history: history,
            onSettings: () => _showSettings(context, ref),
          ),
        );
      },
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Consumer(
        builder: (ctx, innerRef, _) {
          final p = AppTheme.palette(ctx);
          final c = AppColors.of(ctx);
          return Container(
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: p.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: AppTheme.headlineMedium),
                  AppSpacing.h20,
                  ProfileModeSwitcherTile(
                    isDarkMode:
                        innerRef.watch(themeModeProvider) == ThemeMode.dark,
                    onPrevious: () =>
                        innerRef.read(themeModeProvider.notifier).toggle(),
                    onNext: () =>
                        innerRef.read(themeModeProvider.notifier).toggle(),
                  ),
                  ProfileSettingsTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile',
                    onTap: () => Navigator.pop(ctx),
                  ),
                  ProfileSettingsTile(
                    icon: Icons.info_outline_rounded,
                    label: 'About FinQuiz',
                    onTap: () => Navigator.pop(ctx),
                  ),
                  ProfileSettingsTile(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    color: c.danger,
                    onTap: () async {
                      Navigator.pop(ctx);
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, AppRoutes.welcome, (_) => false);
                      }
                    },
                  ),
                  AppSpacing.sm,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileScaffold extends StatelessWidget {
  final UserModel user;
  final Map<String, dynamic> stats;
  final List<QuizResult> history;
  final VoidCallback onSettings;

  const _ProfileScaffold({
    required this.user,
    required this.stats,
    required this.history,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: p.bg,
            elevation: 0,
            title: Text('Profile', style: AppTheme.headlineMedium),
            actions: [
              IconButton(
                icon: Icon(Icons.settings_outlined,
                    color: p.textSub, size: 22),
                onPressed: onSettings,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(height: 0.5, color: p.border),
            ),
          ),
          SliverToBoxAdapter(child: ProfileHeader(user: user)),
          SliverToBoxAdapter(child: ProfileStatsGrid(stats: stats)),
          if (history.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Text('Quiz History', style: AppTheme.titleLarge),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ProfileHistoryTile(result: history[i]),
                  childCount: history.length,
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: AppSpacing.xl),
        ],
      ),
    );
  }
}
