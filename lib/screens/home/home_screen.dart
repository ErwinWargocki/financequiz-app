import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../database/database_helper.dart';
import '../../data/quiz_categories.dart';
import '../quiz/quiz_screen.dart';
import '../study/study_screen.dart';

part 'home_featured_card.dart';
part 'home_stat_chip.dart';
part 'home_result_tile.dart';

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
      if (!mounted || !_featuredPageController.hasClients) return;
      final cur = _featuredPageController.page?.round() ?? 0;
      final next = (cur + 1) % _featuredCategories.length;
      _featuredPageController.animateToPage(next, duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
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
    var incomplete = QuizCategories.all.where((c) => !attempted.contains(c.id)).toList();
    if (incomplete.isEmpty) incomplete = List<QuizCategory>.from(QuizCategories.all);

    setState(() {
      _user = user;
      _recentResults = results;
      _featuredCategories = incomplete;
      _loading = false;
    });
    _scheduleFeaturedRotation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_featuredPageController.hasClients || _featuredCategories.isEmpty) return;
      if ((_featuredPageController.page?.round() ?? 0) >= _featuredCategories.length) {
        _featuredPageController.jumpToPage(0);
      }
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
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildSectionHeader('Study Time')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _StudyTimeCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyScreen())),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildSectionHeader('Time to test yourself')),
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
          Text.rich(TextSpan(children: [
            TextSpan(text: 'FIN', style: GoogleFonts.spaceGrotesk(color: AppTheme.accent, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            TextSpan(text: 'QUIZ', style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          ])),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accentWarm.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentWarm.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text('${_user?.currentStreak ?? 0}', style: AppTheme.labelSmall.copyWith(color: AppTheme.accentWarm, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 10),
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
        gradient: hasIcon ? null : const LinearGradient(colors: [AppTheme.accent, AppTheme.accentBlue], begin: Alignment.topLeft, end: Alignment.bottomRight),
        color: hasIcon ? AppTheme.surfaceLight : null,
        border: Border.all(color: AppTheme.border, width: 1.5),
      ),
      child: Center(
        child: hasIcon
            ? Text(_user!.profileIcon, style: TextStyle(fontSize: size * 0.52))
            : Text(_user?.avatarInitial ?? '?', style: GoogleFonts.spaceGrotesk(color: AppTheme.primary, fontSize: size * 0.4, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _buildStatsRow() {
    final firstName = (_user == null || _user!.name.trim().isEmpty)
        ? 'there'
        : _user!.name.trim().split(' ').first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hey $firstName 👋', style: AppTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('Ready to level up your finances?', style: AppTheme.bodyMedium),
          const SizedBox(height: 16),
          Row(children: [
            _StatChip(label: 'Quizzes', value: '${_user?.quizzesCompleted ?? 0}', icon: '📝', color: AppTheme.accentBlue),
            const SizedBox(width: 10),
            _StatChip(label: 'Points', value: '${_user?.totalScore ?? 0}', icon: '⭐', color: AppTheme.accentWarm),
            const SizedBox(width: 10),
            _StatChip(label: 'Streak', value: '${_user?.currentStreak ?? 0} days', icon: '🔥', color: AppTheme.danger),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
    child: Text(title, style: AppTheme.titleLarge),
  );

  Widget _buildFeaturedCarousel() {
    if (_featuredCategories.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 160,
        child: PageView.builder(
          controller: _featuredPageController,
          itemCount: _featuredCategories.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (_, i) => _FeaturedCard(category: _featuredCategories[i], onTap: () => _startQuiz(_featuredCategories[i])),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(children: _recentResults.map((r) => _ResultTile(result: r)).toList()),
  );

  void _startQuiz(QuizCategory cat) async {
    final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => QuizScreen(category: cat, userId: _user!.id!)));
    if (result == true) _loadData();
  }
}
