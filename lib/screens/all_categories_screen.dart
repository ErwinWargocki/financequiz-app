import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import '../data/quiz_categories.dart';
import 'quiz/quiz_screen.dart';

/// Full list of all quiz categories (moved from Home for the "Test" tab).
class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }
    final user = await DatabaseHelper.instance.getUser(userId);
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _startQuiz(QuizCategory cat) async {
    if (_user?.id == null) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(category: cat, userId: _user!.id!),
      ),
    );
    if (result == true && mounted) _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: p.bg,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      );
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
                      left: i.isEven ? 0 : 6,
                      right: i.isEven ? 6 : 0,
                      bottom: 12,
                    ),
                    child: _CategoryGridTile(
                      category: cat,
                      onTap: () => _startQuiz(cat),
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
            const SizedBox(height: 2),
            Text(
              '${category.totalQuestions} questions',
              style: AppTheme.bodyMedium.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
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
