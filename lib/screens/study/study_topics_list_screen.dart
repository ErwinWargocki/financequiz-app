part of 'study_screen.dart';

// ─── Topics List Screen ───────────────────────────────────────────────────────
class _StudyTopicsListScreen extends StatefulWidget {
  final _CategoryInfo category;
  const _StudyTopicsListScreen({required this.category});

  @override
  State<_StudyTopicsListScreen> createState() => _StudyTopicsListScreenState();
}

class _StudyTopicsListScreenState extends State<_StudyTopicsListScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;
    final user = await DatabaseHelper.instance.getUser(userId);
    if (mounted) setState(() => _user = user);
  }

  List<StudyTopic> get _topics => widget.category.difficulty == null
      ? StudyTopics.all
      : StudyTopics.byDifficulty(widget.category.difficulty!);

  @override
  Widget build(BuildContext context) {
    final color = widget.category.color;
    final topics = _topics;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.primary,
            elevation: 0,
            expandedHeight: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Text(widget.category.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(widget.category.label, style: AppTheme.headlineMedium),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(height: 0.5, color: AppTheme.border),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${topics.length} ${topics.length == 1 ? 'topic' : 'topics'}',
                  style: AppTheme.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _StudyTopicTile(topic: topics[i], onTap: () => _openTopic(topics[i])),
                childCount: topics.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _openTopic(StudyTopic topic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TopicDetailSheet(
        topic: topic,
        onTakeQuiz: _user != null
            ? () { Navigator.pop(context); _startQuiz(topic); }
            : null,
      ),
    );
  }

  void _startQuiz(StudyTopic topic) {
    if (_user?.id == null) return;
    final cat = QuizCategories.all.firstWhere(
      (c) => c.id == topic.quizCategoryId,
      orElse: () => QuizCategories.all.first,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizScreen(category: cat, userId: _user!.id!)),
    );
  }
}
