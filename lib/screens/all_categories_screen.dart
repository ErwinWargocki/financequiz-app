import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';
import '../models/models.dart';
import '../data/quiz_categories.dart';
import '../providers/app_providers.dart';
import '../navigation/app_routes.dart';

/// Full list of all quiz categories (moved from Home for the "Test" tab).
class AllCategoriesScreen extends ConsumerWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p         = AppTheme.palette(context);
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => Scaffold(
        backgroundColor: p.bg,
        body: const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      ),
      error: (_, __) => Scaffold(backgroundColor: p.bg, body: const SizedBox()),
      data: (user) {
        if (user == null) {
          return Scaffold(backgroundColor: p.bg, body: const SizedBox());
        }
        return Scaffold(
          backgroundColor: p.bg,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: p.bg,
                elevation: 0,
                title: Text('All Categories', style: AppTheme.headlineMedium),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0.5),
                  child: Container(height: 0.5, color: p.border),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final cat = QuizCategories.all[i];
                      return Padding(
                        padding: EdgeInsets.only(
                          left:   i.isEven ? 0 : 6,
                          right:  i.isEven ? 6 : 0,
                          bottom: 12,
                        ),
                        child: _CategoryGridTile(
                          category: cat,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.quiz,
                            arguments: QuizArgs(category: cat, userId: user.id!),
                          ),
                        ),
                      );
                    },
                    childCount: QuizCategories.all.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 152,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryGridTile extends StatelessWidget {
  final QuizCategory category;
  final VoidCallback onTap;

  const _CategoryGridTile({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);
    final p = AppTheme.palette(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.border),
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
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(category.icon,
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: p.textMuted),
              ],
            ),
            const Spacer(),
            Text(
              category.name,
              style: AppTheme.titleLarge.copyWith(fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${category.totalQuestions} questions',
              style: AppTheme.bodyMedium.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.h6,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
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
