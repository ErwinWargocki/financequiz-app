import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../database/database_helper.dart';
import '../../data/quiz_categories.dart';
import '../../main.dart';
import '../welcome/welcome_screen.dart';

part 'profile_widgets.dart';
part 'profile_history_tile.dart';
part 'profile_settings_sheet.dart';

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
    setState(() { _user = user; _results = results; _stats = stats; _loading = false; });
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
          SliverToBoxAdapter(child: _ProfileHeader(user: _user)),
          SliverToBoxAdapter(child: _StatsGrid(stats: _stats)),
          SliverToBoxAdapter(child: _buildAchievements()),
          if (_results.isNotEmpty) ...[
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
          icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary, size: 22),
          onPressed: _showSettings,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppTheme.border),
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
          Text('Achievements', style: AppTheme.titleLarge),
          const SizedBox(height: 10),
          Row(
            children: achievements.map((a) => Expanded(
              child: Padding(padding: const EdgeInsets.only(right: 8), child: _AchievementBadge(achievement: a)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppTheme.border),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTheme.headlineMedium),
              const SizedBox(height: 20),
              _ModeSwitcherTile(
                isDarkMode: FinQuizApp.isDarkModeEnabled(context),
                onPrevious: () async { await FinQuizApp.toggleThemeMode(context); setModalState(() {}); },
                onNext: () async { await FinQuizApp.toggleThemeMode(context); setModalState(() {}); },
              ),
              _SettingsTile(icon: Icons.person_outline_rounded, label: 'Edit Profile', onTap: () => Navigator.pop(context)),
              _SettingsTile(icon: Icons.info_outline_rounded, label: 'About FinQuiz', onTap: () => Navigator.pop(context)),
              _SettingsTile(
                icon: Icons.logout_rounded,
                label: 'Sign Out',
                color: AppTheme.danger,
                onTap: () async {
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
