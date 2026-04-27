import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_spacing.dart';
import '../../data/study_topics.dart';
import '../../data/quiz_categories.dart';
import '../../models/models.dart';
import '../../database/database_helper.dart';
import '../quiz/quiz_screen.dart';

part 'study_category_card.dart';
part 'study_topics_list_screen.dart';
part 'study_topic_tile.dart';
part 'study_topic_detail.dart';

// ─── Category config ─────────────────────────────────────────────────────────
class _CategoryInfo {
  final String label;
  final String? difficulty; // null = All
  final Color color;
  final String icon;
  final String subtitle;

  const _CategoryInfo({
    required this.label,
    required this.difficulty,
    required this.color,
    required this.icon,
    required this.subtitle,
  });
}

const _categories = [
  _CategoryInfo(label: 'All Topics',    difficulty: null,           color: AppTheme.diffAll,          icon: '📚', subtitle: 'Browse everything'),
  _CategoryInfo(label: 'Beginner',      difficulty: 'Beginner',     color: AppTheme.diffBeginner,     icon: '🌰', subtitle: 'Start here'),
  _CategoryInfo(label: 'Intermediate',  difficulty: 'Intermediate', color: AppTheme.diffIntermediate, icon: '🌿', subtitle: 'Level up'),
  _CategoryInfo(label: 'Advanced',      difficulty: 'Advanced',     color: AppTheme.diffAdvanced,     icon: '🌳', subtitle: 'Master it'),
];

// ─── Study Screen (category grid) ────────────────────────────────────────────
class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

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
            expandedHeight: 0,
            title: Text('Study Topics', style: AppTheme.headlineMedium),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(height: 0.5, color: p.border),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text('Learn before you quiz.', style: AppTheme.bodyMedium),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final cat = _categories[i];
                  final topics = cat.difficulty == null
                      ? StudyTopics.all
                      : StudyTopics.byDifficulty(cat.difficulty!);
                  return _CategoryCard(
                    info: cat,
                    topicCount: topics.length,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _StudyTopicsListScreen(category: cat),
                      ),
                    ),
                  );
                },
                childCount: _categories.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.88,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: AppSpacing.xl),
        ],
      ),
    );
  }
}
