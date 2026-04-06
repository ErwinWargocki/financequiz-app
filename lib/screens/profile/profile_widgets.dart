part of 'profile_screen.dart';

// ─── Profile Header ───────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final UserModel? user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'User';
    final username = user?.username ?? 'user';
    final initial = user?.avatarInitial ?? '?';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppTheme.accent, AppTheme.accentBlue], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Container(
              width: 70, height: 70,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary),
              child: Center(
                child: (user != null && user!.profileIconIndex > 0)
                    ? Text(user!.profileIcon, style: const TextStyle(fontSize: 34))
                    : Text(initial, style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w800)),
              ),
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
                  _MiniStat(label: 'Streak', value: '🔥 ${user?.currentStreak ?? 0}'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
        Text(label, style: AppTheme.labelSmall.copyWith(fontSize: 10)),
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
class _Achievement {
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
}
