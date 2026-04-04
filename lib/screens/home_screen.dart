import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import '../data/quiz_categories.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  List<QuizResult> _recentResults = [];
  bool _loading = true;
  final PageController _featuredPageController = PageController();
  Timer? _featuredRotateTimer;
  List<QuizCategory> _featuredCategories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _featuredRotateTimer?.cancel();
    _featuredPageController.dispose();
    super.dispose();
  }

  void _scheduleFeaturedRotation() {
    _featuredRotateTimer?.cancel();
    if (_featuredCategories.length <= 1) return;
    _featuredRotateTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;
      if (!_featuredPageController.hasClients) return;
      final cur = _featuredPageController.page?.round() ?? 0;
      final next = (cur + 1) % _featuredCategories.length;
      _featuredPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;

    final db = DatabaseHelper.instance;
    final user = await db.getUser(userId);
    final results = await db.getRecentResults(userId, limit: 3);
    final allResults = await db.getResultsByUser(userId);
    final attempted = allResults.map((r) => r.category).toSet();
    var incomplete =
        QuizCategories.all.where((c) => !attempted.contains(c.id)).toList();
    if (incomplete.isEmpty) {
      incomplete = List<QuizCategory>.from(QuizCategories.all);
    }

    setState(() {
      _user = user;
      _recentResults = results;
      _featuredCategories = incomplete;
      _loading = false;
    });
    _scheduleFeaturedRotation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_featuredPageController.hasClients && _featuredCategories.isNotEmpty) {
        final idx = _featuredPageController.page?.round() ?? 0;
        if (idx >= _featuredCategories.length) {
          _featuredPageController.jumpToPage(0);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildContinueLearningSectionHeader()),
          SliverToBoxAdapter(child: _buildFeaturedCarousel()),
          if (_recentResults.isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildSectionHeader('Recent Activity')),
            SliverToBoxAdapter(child: _buildRecentActivity()),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.primary,
      elevation: 0,
      expandedHeight: 0,
      title: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'FIN',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'QUIZ',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Streak indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accentWarm.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.accentWarm.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${_user?.currentStreak ?? 0}',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.accentWarm,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          _buildAvatar(size: 36),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppTheme.border),
      ),
    );
  }

  Widget _buildAvatar({double size = 40}) {
    final hasIcon = _user != null && _user!.profileIconIndex > 0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasIcon
            ? null
            : const LinearGradient(
                colors: [AppTheme.accent, AppTheme.accentBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: hasIcon ? AppTheme.surfaceLight : null,
        border: Border.all(color: AppTheme.border, width: 1.5),
      ),
      child: Center(
        child: hasIcon
            ? Text(
                _user!.profileIcon,
                style: TextStyle(fontSize: size * 0.52),
              )
            : Text(
                _user?.avatarInitial ?? '?',
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.primary,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final completed = _user?.quizzesCompleted ?? 0;
    final score = _user?.totalScore ?? 0;
    final streak = _user?.currentStreak ?? 0;
    final firstName = (_user == null || _user!.name.trim().isEmpty)
        ? 'there'
        : _user!.name.trim().split(' ').first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hey $firstName 👋',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text('Ready to level up your finances?', style: AppTheme.bodyMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                label: 'Quizzes',
                value: '$completed',
                icon: '📝',
                color: AppTheme.accentBlue,
              ),
              const SizedBox(width: 10),
              _StatChip(
                label: 'Points',
                value: '$score',
                icon: '⭐',
                color: AppTheme.accentWarm,
              ),
              const SizedBox(width: 10),
              _StatChip(
                label: 'Streak',
                value: '$streak days',
                icon: '🔥',
                color: AppTheme.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearningSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('Continue Learning', style: AppTheme.titleLarge),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showSeeAll = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.titleLarge),
          if (showSeeAll)
            Text('See all',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.accent,
                )),
        ],
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    if (_featuredCategories.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 160,
        child: PageView.builder(
          controller: _featuredPageController,
          itemCount: _featuredCategories.length,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return _buildFeaturedPage(_featuredCategories[index]);
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedPage(QuizCategory featured) {
    final catColor = Color(featured.color);
    return GestureDetector(
        onTap: () => _startQuiz(featured),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/images/continue_learning_bg.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      opacity: const AlwaysStoppedAnimation(0.22),
                      errorBuilder: (_, __, ___) => Center(
                        child: Opacity(
                          opacity: 0.14,
                          child: Text(
                            featured.icon,
                            style: TextStyle(
                              fontSize: 140,
                              height: 1,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          catColor.withOpacity(0.92),
                          catColor.withOpacity(0.58),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: -40,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('FEATURED',
                            style: AppTheme.labelSmall.copyWith(
                              color: Colors.white,
                              letterSpacing: 1.5,
                            )),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(featured.icon,
                              style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  featured.name,
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${featured.totalQuestions} questions · ${featured.difficulty}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 22),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _recentResults.map((r) => _ResultTile(result: r)).toList(),
      ),
    );
  }

  void _startQuiz(QuizCategory cat) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(category: cat, userId: _user!.id!),
      ),
    );
    if (result == true) _loadData();
  }
}

// ─── Stat Chip ─────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(label,
                style: AppTheme.labelSmall
                    .copyWith(color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

// ─── Result Tile ───────────────────────────────────────────────────────────
class _ResultTile extends StatelessWidget {
  final QuizResult result;

  const _ResultTile({required this.result});

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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1),
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
                Text(
                  '${result.correctAnswers}/${result.totalQuestions} correct',
                  style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 32,
                height: 32,
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
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${result.score} pts',
                style: AppTheme.labelSmall.copyWith(color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
