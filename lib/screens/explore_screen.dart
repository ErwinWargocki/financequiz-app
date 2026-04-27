import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../data/quiz_categories.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import 'quiz/quiz_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDifficulty = 'All';

  final difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QuizCategory> get _filtered {
    return QuizCategories.all.where((cat) {
      final matchesSearch = cat.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          cat.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDiff =
          _selectedDifficulty == 'All' || cat.difficulty == _selectedDifficulty;
      return matchesSearch && matchesDiff;
    }).toList();
  }

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
            title: Text('Explore', style: AppTheme.headlineMedium),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(height: 0.5, color: p.border),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    style: AppTheme.bodyLarge,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search topics...',
                      prefixIcon: Icon(Icons.search_rounded, color: p.textMuted),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: Icon(Icons.close_rounded,
                                  color: p.textMuted, size: 18),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Difficulty filter chips
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: difficulties.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final diff = difficulties[i];
                        final selected = _selectedDifficulty == diff;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedDifficulty = diff),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected ? AppTheme.accent : p.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected ? AppTheme.accent : p.border,
                              ),
                            ),
                            child: Text(
                              diff,
                              style: AppTheme.labelSmall.copyWith(
                                color: selected ? Colors.black87 : p.textSub,
                                fontSize: 12,
                                letterSpacing: 0.5,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final cat = _filtered[i];
                  return _ExploreCategoryTile(
                    category: cat,
                    onTap: () => _startQuiz(cat),
                  );
                },
                childCount: _filtered.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _startQuiz(QuizCategory cat) async {
    final user = ref.read(currentUserProvider).asData?.value;
    if (user == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(category: cat, userId: user.id!),
      ),
    );
  }
}

class _ExploreCategoryTile extends StatelessWidget {
  final QuizCategory category;
  final VoidCallback onTap;

  const _ExploreCategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);
    final p = AppTheme.palette(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(category.icon,
                    style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(category.name,
                          style:
                              AppTheme.titleLarge.copyWith(fontSize: 16)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category.difficulty,
                          style: AppTheme.labelSmall.copyWith(
                            color: color,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(category.description,
                      style: AppTheme.bodyMedium.copyWith(fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    '${category.totalQuestions} questions',
                    style: AppTheme.labelSmall.copyWith(
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(Icons.play_arrow_rounded, color: color, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
