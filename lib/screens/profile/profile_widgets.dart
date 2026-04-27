part of 'profile_screen.dart';

// ─── Profile Header ───────────────────────────────────────────────────────────
class _ProfileHeader extends ConsumerWidget {
  final UserModel? user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user?.name ?? 'User';
    final username = user?.username ?? 'user';
    final initial = user?.avatarInitial ?? '?';
    final p = AppTheme.palette(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: user != null ? () => _showIconPicker(context, ref, user!) : null,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.accent, AppTheme.accentBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: p.bg),
                    child: Center(
                      child: (user != null && user!.profileIconIndex > 0)
                          ? Text(user!.profileIcon, style: const TextStyle(fontSize: 34))
                          : Text(initial, style: GoogleFonts.spaceGrotesk(color: p.text, fontSize: 28, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: p.bg, width: 2),
                    ),
                    child: const Icon(Icons.edit_rounded, size: 11, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.headlineMedium.copyWith(fontSize: 20)),
                Text('@$username', style: AppTheme.bodyMedium.copyWith(color: AppTheme.accent)),
                const SizedBox(height: 8),
                Row(children: [
                  _MiniStat(label: 'Quizzes', value: '${user?.quizzesCompleted ?? 0}'),
                  const SizedBox(width: 16),
                  _MiniStat(label: 'Streak', value: ' ${user?.currentStreak ?? 0}'),
                  const SizedBox(width: 16),
                  _MiniStat(label: 'Best', value: '${user?.longestStreak ?? 0} days'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showIconPicker(BuildContext context, WidgetRef ref, UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Consumer(
        builder: (ctx, innerRef, _) {
          final ip = AppTheme.palette(ctx);
          return Container(
            decoration: BoxDecoration(
              color: ip.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: ip.border),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choose Avatar', style: AppTheme.headlineMedium),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: ProfileIcons.all.length,
                    itemBuilder: (ctx, i) {
                      final selected = i == user.profileIconIndex;
                      return GestureDetector(
                        onTap: () async {
                          Navigator.pop(ctx);
                          await DatabaseHelper.instance
                              .updateUser(user.copyWith(profileIconIndex: i));
                          ref.invalidate(currentUserProvider);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? AppTheme.accent.withValues(alpha: 0.15)
                                : ip.surface,
                            border: Border.all(
                              color: selected ? AppTheme.accent : ip.border,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(ProfileIcons.all[i], style: const TextStyle(fontSize: 26)),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Stats Grid ───────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsGrid({required this.stats});

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final totalScore = stats['totalScore'] ?? 0;
    final avgScore = (stats['avgScore'] ?? 0.0) as double;
    final bestCategory = stats['bestCategory'] ?? 'N/A';
    final minutes = ((stats['totalTime'] ?? 0) as int) ~/ 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Stats', style: AppTheme.titleLarge),
          const SizedBox(height: 10),
          Row(children: [
            _BigStatCard(icon: '⭐', label: 'Total Points', value: '$totalScore', color: AppTheme.accentWarm),
            const SizedBox(width: 10),
            _BigStatCard(icon: '📊', label: 'Avg Score', value: '${avgScore.toStringAsFixed(0)}%', color: AppTheme.accentBlue),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _BigStatCard(
              icon: '🏆',
              label: 'Best Topic',
              value: bestCategory == 'N/A' ? 'N/A' : _capitalize(bestCategory as String),
              color: AppTheme.accent,
            ),
            const SizedBox(width: 10),
            _BigStatCard(icon: '⏱️', label: 'Time Spent', value: '${minutes}m', color: AppTheme.catCrypto),
          ]),
        ],
      ),
    );
  }
}

// ─── Mini Stat ────────────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: GoogleFonts.spaceGrotesk(color: p.text, fontSize: 14, fontWeight: FontWeight.w700)),
        Text(label, style: AppTheme.labelSmall.copyWith(fontSize: 10, color: p.textMuted)),
      ],
    );
  }
}

// ─── Big Stat Card ────────────────────────────────────────────────────────────
class _BigStatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  const _BigStatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color.withValues(alpha:0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha:0.2))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.spaceGrotesk(color: color, fontSize: 20, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
            Text(label, style: AppTheme.labelSmall.copyWith(color: color.withValues(alpha:0.7), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ─── Achievement ──────────────────────────────────────────────────────────────
/*class _Achievement {
  final String icon;
  final String name;
  final bool unlocked;
  final String description;
  const _Achievement(this.icon, this.name, this.unlocked, this.description);
}
  class _AchievementBadge extends StatelessWidget {
  final _Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: achievement.description,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: achievement.unlocked ? AppTheme.accentWarm.withValues(alpha: 0.1) : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: achievement.unlocked ? AppTheme.accentWarm.withValues(alpha: 0.4) : AppTheme.border),
        ),
        child: Column(
          children: [
            Text(achievement.icon, style: TextStyle(fontSize: 24, color: achievement.unlocked ? null : AppTheme.textMuted)),
            const SizedBox(height: 4),
            Text(
              achievement.name,
              style: AppTheme.labelSmall.copyWith(fontSize: 9, color: achievement.unlocked ? AppTheme.accentWarm : AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}*/
