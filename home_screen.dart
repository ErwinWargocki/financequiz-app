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
    final results = await db.getRecentResults(userId, limit: 3);

    setState(() {
      _user = user;
      _recentResults = results;
      _loading = false;
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
          SliverToBoxAdapter(child: _buildSectionHeader('Continue Learning')),
          SliverToBoxAdapter(child: _buildFeaturedCard()),
          SliverToBoxAdapter(
              child: _buildSectionHeader('All Categories', showSeeAll: true)),
          _buildCategoryGrid(),
          if (_recentResults.isNotEmpty) ...[
            SliverToBoxAdapter(
                child: _buildSectionHeader('Recent Activity')),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
    final initial = _user?.avatarInitial ?? '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.accent, AppTheme.accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initial,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hey ${_user?.name?.split(' ').first ?? 'there'} 👋',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text('Ready to level up your finances?',
              style: AppTheme.bodyMedium),
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

  Widget _buildFeaturedCard() {
    final featured = QuizCategories.all.first;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _startQuiz(featured),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Color(featured.color),
                Color(featured.color).withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
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
              // Content
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              featured.name,
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
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
                        const Spacer(),
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

  SliverGrid _buildCategoryGrid() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final cat = QuizCategories.all[i];
          return Padding(
            padding: EdgeInsets.only(
              left: i.isEven ? 16 : 6,
              right: i.isEven ? 6 : 16,
              bottom: 12,
            ),
            child: _CategoryCard(
              category: cat,
              onTap: () => _startQuiz(cat),
            ),
          );
        },
        childCount: QuizCategories.all.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 140,
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _recentResults
            .map((r) => _ResultTile(result: r))
            .toList(),
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
                style: AppTheme.labelSmall.copyWith(color: color.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

// ─── Category Card ─────────────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final QuizCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(category.icon,
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppTheme.textMuted),
              ],
            ),
            const Spacer(),
            Text(
              category.name,
              style: AppTheme.titleLarge.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              '${category.totalQuestions} questions',
              style: AppTheme.bodyMedium.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                category.difficulty,
                style: AppTheme.labelSmall.copyWith(
                  color: color,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
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
            child:
                Center(child: Text(cat.icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat.name, style: AppTheme.titleLarge.copyWith(fontSize: 14)),
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
