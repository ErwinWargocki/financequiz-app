import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import '../data/quiz_categories.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  List<QuizResult> _results = [];
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;
    final db = DatabaseHelper.instance;
    final user = await db.getUser(userId);
    final results = await db.getResultsByUser(userId);
    final stats = await db.getUserStats(userId);
    setState(() {
      _user = user;
      _results = results;
      _stats = stats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildProfileHeader()),
          SliverToBoxAdapter(child: _buildStatsGrid()),
          SliverToBoxAdapter(child: _buildAchievements()),
          if (_results.isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildSectionHeader('Quiz History')),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _HistoryTile(result: _results[i]),
                  childCount: _results.length,
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.primary,
      elevation: 0,
      title: Text('Profile', style: AppTheme.headlineMedium),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined,
              color: AppTheme.textSecondary, size: 22),
          onPressed: _showSettings,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppTheme.border),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final name = _user?.name ?? 'User';
    final username = _user?.username ?? 'user';
    final initial = _user?.avatarInitial ?? '?';
    final quizzes = _user?.quizzesCompleted ?? 0;
    final streak = _user?.currentStreak ?? 0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar with gradient ring
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
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.headlineMedium.copyWith(fontSize: 20)),
                Text('@$username',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.accent,
                    )),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MiniStat(label: 'Quizzes', value: '$quizzes'),
                    const SizedBox(width: 16),
                    _MiniStat(label: 'Streak', value: '🔥 $streak'),
                    const SizedBox(width: 16),
                    _MiniStat(
                        label: 'Best',
                        value: '${_user?.longestStreak ?? 0} days'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final totalScore = _stats['totalScore'] ?? 0;
    final avgScore = (_stats['avgScore'] ?? 0.0) as double;
    final bestCategory = _stats['bestCategory'] ?? 'N/A';
    final totalTime = _stats['totalTime'] ?? 0;
    final minutes = totalTime ~/ 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderInline('Your Stats'),
          const SizedBox(height: 10),
          Row(
            children: [
              _BigStatCard(
                icon: '⭐',
                label: 'Total Points',
                value: '$totalScore',
                color: AppTheme.accentWarm,
              ),
              const SizedBox(width: 10),
              _BigStatCard(
                icon: '📊',
                label: 'Avg Score',
                value: '${avgScore.toStringAsFixed(0)}%',
                color: AppTheme.accentBlue,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _BigStatCard(
                icon: '🏆',
                label: 'Best Topic',
                value: bestCategory == 'N/A'
                    ? 'N/A'
                    : _capitalize(bestCategory),
                color: AppTheme.accent,
              ),
              const SizedBox(width: 10),
              _BigStatCard(
                icon: '⏱️',
                label: 'Time Spent',
                value: '${minutes}m',
                color: AppTheme.catCrypto,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final quizzes = _user?.quizzesCompleted ?? 0;
    final achievements = [
      _Achievement('🎯', 'First Quiz', quizzes >= 1, 'Complete your first quiz'),
      _Achievement('🔥', 'On Fire', quizzes >= 5, '5 quizzes completed'),
      _Achievement('🏆', 'Scholar', quizzes >= 10, '10 quizzes completed'),
      _Achievement('💎', 'Master', quizzes >= 25, '25 quizzes completed'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildSectionHeaderInline('Achievements'),
          const SizedBox(height: 10),
          Row(
            children: achievements
                .map((a) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _AchievementBadge(achievement: a),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(title, style: AppTheme.titleLarge),
    );
  }

  Widget _buildSectionHeaderInline(String title) {
    return Text(title, style: AppTheme.titleLarge);
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppTheme.border),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: AppTheme.headlineMedium),
            const SizedBox(height: 20),
            _SettingsTile(
              icon: Icons.person_outline_rounded,
              label: 'Edit Profile',
              onTap: () => Navigator.pop(context),
            ),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              label: 'About FinQuiz',
              onTap: () => Navigator.pop(context),
            ),
            _SettingsTile(
              icon: Icons.logout_rounded,
              label: 'Sign Out',
              color: AppTheme.danger,
              onTap: () async {
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WelcomeScreen()),
                    (_) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            )),
        Text(label, style: AppTheme.labelSmall.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;
  const _BigStatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(label,
                style: AppTheme.labelSmall.copyWith(
                  color: color.withOpacity(0.7),
                  fontSize: 11,
                )),
          ],
        ),
      ),
    );
  }
}

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
          color: achievement.unlocked
              ? AppTheme.accentWarm.withOpacity(0.1)
              : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: achievement.unlocked
                ? AppTheme.accentWarm.withOpacity(0.4)
                : AppTheme.border,
          ),
        ),
        child: Column(
          children: [
            Text(
              achievement.icon,
              style: TextStyle(
                fontSize: 24,
                color: achievement.unlocked ? null : AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.name,
              style: AppTheme.labelSmall.copyWith(
                fontSize: 9,
                color: achievement.unlocked
                    ? AppTheme.accentWarm
                    : AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final QuizResult result;
  const _HistoryTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final cat = QuizCategories.all.firstWhere(
      (c) => c.id == result.category,
      orElse: () => QuizCategories.all.first,
    );
    final color = Color(cat.color);
    final grade = result.grade;
    final gradeColor = grade == 'S' || grade == 'A'
        ? AppTheme.success
        : grade == 'B' || grade == 'C'
            ? AppTheme.accentWarm
            : AppTheme.danger;

    final date = result.completedAt;
    final dateStr =
        '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
                child: Text(cat.icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat.name,
                    style: AppTheme.titleLarge.copyWith(fontSize: 14)),
                Text(dateStr,
                    style: AppTheme.bodyMedium.copyWith(fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: gradeColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    grade,
                    style: GoogleFonts.spaceGrotesk(
                      color: gradeColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${result.correctAnswers}/${result.totalQuestions}',
                style: AppTheme.labelSmall.copyWith(color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppTheme.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: AppTheme.bodyLarge.copyWith(color: color)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
