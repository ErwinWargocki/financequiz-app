import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import '../../data/quiz_categories.dart';
import '../../providers/app_providers.dart';
import '../../widgets/stat_display.dart';

part 'home_featured_card.dart';
part 'home_stat_chip.dart';
part 'home_result_tile.dart';
part 'home_weekly_chart.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const _HomeLoadingScaffold(),
      error: (_, __) => const _HomeLoadingScaffold(),
      data: (user) {
        if (user == null) return const _HomeLoadingScaffold();
        final recentAsync = ref.watch(recentResultsProvider(user.id!));
        final weeklyAsync = ref.watch(weeklyResultsProvider(user.id!));
        return recentAsync.when(
          loading: () => const _HomeLoadingScaffold(),
          error: (_, __) => const _HomeLoadingScaffold(),
          data: (recent) => weeklyAsync.when(
            loading: () => const _HomeLoadingScaffold(),
            error: (_, __) => const _HomeLoadingScaffold(),
            data: (weekly) => _HomeContent(
              user: user,
              recentResults: recent,
              weeklyTestCounts: weekly,
            ),
          ),
        );
      },
    );
  }
}

class _HomeLoadingScaffold extends StatelessWidget {
  const _HomeLoadingScaffold();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.palette(context).bg,
        body: const Center(
            child: CircularProgressIndicator(color: AppTheme.accent)),
      );
}

class _HomeContent extends StatelessWidget {
  final UserModel user;
  final List<QuizResult> recentResults;
  final List<int> weeklyTestCounts;

  const _HomeContent({
    required this.user,
    required this.recentResults,
    required this.weeklyTestCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.palette(context).bg,
      body: CustomScrollView(
        slivers: [
          _HomeAppBar(user: user),
          SliverToBoxAdapter(child: _HomeStatsRow(user: user)),
          const SliverToBoxAdapter(child: _HomeSectionHeader(title: 'Study Time')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _StudyTimeCard(
                onTap: () => Navigator.pushNamed(context, '/study'),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: _HomeSectionHeader(title: 'Test Time')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _TestTimeCard(
                onTap: () => Navigator.pushNamed(context, '/categories'),
              ),
            ),
          ),
          const SliverToBoxAdapter(
              child: _HomeSectionHeader(
                  title: 'Number of quizzes completed this week')),
          SliverToBoxAdapter(
              child: _WeeklyProgressChart(counts: weeklyTestCounts)),
          if (recentResults.isNotEmpty) ...[
            const SliverToBoxAdapter(
                child: _HomeSectionHeader(title: 'Recent Activity')),
            SliverToBoxAdapter(
                child: _HomeRecentActivity(results: recentResults)),
          ],
          const SliverToBoxAdapter(child: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────
class _HomeAppBar extends StatelessWidget {
  final UserModel user;
  const _HomeAppBar({required this.user});

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 36;
    final hasIcon = user.profileIconIndex > 0;
    final p = AppTheme.palette(context);
    return SliverAppBar(
      pinned: true,
      backgroundColor: p.bg,
      elevation: 0,
      expandedHeight: 0,
      title: Row(
        children: [
          Text.rich(TextSpan(children: [
            TextSpan(
                text: 'FIN',
                style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5)),
            TextSpan(
                text: 'QUIZ',
                style: GoogleFonts.spaceGrotesk(
                    color: p.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5)),
          ])),
          const Spacer(),
          AppSpacing.w10,
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasIcon
                  ? null
                  : const LinearGradient(
                      colors: [AppTheme.accent, AppTheme.accentBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
              color: hasIcon ? p.surface : null,
              border: Border.all(color: p.border, width: 1.5),
            ),
            child: Center(
              child: hasIcon
                  ? Text(user.profileIcon,
                      style: const TextStyle(fontSize: avatarSize * 0.52))
                  : Text(user.avatarInitial,
                      style: GoogleFonts.spaceGrotesk(
                          color: p.bg,
                          fontSize: avatarSize * 0.4,
                          fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: p.border),
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _HomeStatsRow extends StatelessWidget {
  final UserModel user;
  const _HomeStatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final firstName = user.name.trim().isEmpty
        ? 'there'
        : user.name.trim().split(' ').first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hey $firstName 👋', style: AppTheme.headlineMedium),
          AppSpacing.xs,
          Text('Ready to level up your finances?',
              style: AppTheme.bodyMedium),
          AppSpacing.md,
          Row(children: [
            _StatChip(
                label: 'Quizzes',
                value: '${user.quizzesCompleted}',
                icon: '📝',
                color: AppTheme.accentBlue),
            AppSpacing.w10,
            _StatChip(
                label: 'Points',
                value: '${user.totalScore}',
                icon: '⭐',
                color: AppTheme.accentWarm),
            AppSpacing.w10,
          ]),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _HomeSectionHeader extends StatelessWidget {
  final String title;
  const _HomeSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text(title, style: AppTheme.titleLarge),
      );
}

// ─── Recent Activity ──────────────────────────────────────────────────────────
class _HomeRecentActivity extends StatelessWidget {
  final List<QuizResult> results;
  const _HomeRecentActivity({required this.results});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
            children: results.map((r) => _ResultTile(result: r)).toList()),
      );
}
