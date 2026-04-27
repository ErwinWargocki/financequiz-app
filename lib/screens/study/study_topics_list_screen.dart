part of 'study_screen.dart';

// ─── Category folder metadata ─────────────────────────────────────────────────
const _folderMeta = {
  'budgeting': ('Budgeting', '💰'),
  'investing': ('Investing', '📈'),
  'crypto':    ('Crypto', '₿'),
  'savings':   ('Savings', '🏦'),
  'taxes':     ('Taxes', '📋'),
  'debt':      ('Debt Management', '⚖️'),
};

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

  /// Groups topics by quizCategoryId, preserving insertion order.
  Map<String, List<StudyTopic>> get _grouped {
    final map = <String, List<StudyTopic>>{};
    for (final t in _topics) {
      (map[t.quizCategoryId] ??= []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.category.color;
    final grouped = _grouped;
    final totalTopics = _topics.length;
    final p = AppTheme.palette(context);

    // Build a flat list: [header, tile, tile, header, tile, ...]
    final items = <_ListItem>[];
    for (final entry in grouped.entries) {
      items.add(_ListItem.header(entry.key));
      for (final topic in entry.value) {
        items.add(_ListItem.topic(topic));
      }
    }

    return Scaffold(
      backgroundColor: p.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: p.bg,
            elevation: 0,
            expandedHeight: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: p.text, size: 20),
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
              child: Container(height: 0.5, color: p.border),
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
                  '$totalTopics ${totalTopics == 1 ? 'topic' : 'topics'}',
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
                (context, i) {
                  final item = items[i];
                  if (item.isHeader) {
                    return _FolderHeader(categoryId: item.categoryId!, color: color);
                  }
                  final topic = item.topic!;
                  return _StudyTopicTile(topic: topic, onTap: () => _openTopic(topic));
                },
                childCount: items.length,
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

// ─── Flat list item discriminated union ──────────────────────────────────────
class _ListItem {
  final bool isHeader;
  final String? categoryId;
  final StudyTopic? topic;

  const _ListItem.header(String id)
      : isHeader = true,
        categoryId = id,
        topic = null;

  const _ListItem.topic(StudyTopic t)
      : isHeader = false,
        categoryId = null,
        topic = t;
}

// ─── Folder header widget ─────────────────────────────────────────────────────
class _FolderHeader extends StatelessWidget {
  final String categoryId;
  final Color color;

  const _FolderHeader({required this.categoryId, required this.color});

  @override
  Widget build(BuildContext context) {
    final meta = _folderMeta[categoryId];
    final label = meta?.$1 ?? categoryId[0].toUpperCase() + categoryId.substring(1);
    final icon  = meta?.$2 ?? '📁';
    final p = AppTheme.palette(context);

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              color: p.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 1, color: p.border)),
        ],
      ),
    );
  }
}
