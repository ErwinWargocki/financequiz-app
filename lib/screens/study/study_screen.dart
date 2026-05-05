import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_spacing.dart';
import '../../data/study_topics.dart';
import '../../data/study_category_info.dart';
import '../../navigation/app_routes.dart';

import 'study_category_card.dart';

const _categories = [
  StudyCategoryInfo(label: 'All Topics',    difficulty: null,           color: AppTheme.diffAll,          icon: '📚', subtitle: 'Browse everything'),
  StudyCategoryInfo(label: 'Beginner',      difficulty: 'Beginner',     color: AppTheme.diffBeginner,     icon: '🌰', subtitle: 'Start here'),
  StudyCategoryInfo(label: 'Intermediate',  difficulty: 'Intermediate', color: AppTheme.diffIntermediate, icon: '🌿', subtitle: 'Level up'),
  StudyCategoryInfo(label: 'Advanced',      difficulty: 'Advanced',     color: AppTheme.diffAdvanced,     icon: '🌳', subtitle: 'Master it'),
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
                  return StudyCategoryCard(
                    info: cat,
                    topicCount: topics.length,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.studyTopics,
                      arguments: cat,
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
