import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../data/study_topics.dart';
import '../data/quiz_categories.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import 'quiz_screen.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  String _selectedDifficulty = 'All';
  UserModel? _user;

  final difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];

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

  List<StudyTopic> get _filtered {
    if (_selectedDifficulty == 'All') return StudyTopics.all;
    return StudyTopics.byDifficulty(_selectedDifficulty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.primary,
            elevation: 0,
            expandedHeight: 0,
            title: Text('Study Topics', style: AppTheme.headlineMedium),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(height: 0.5, color: AppTheme.border),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Learn before you quiz.',
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  // Difficulty filter chips
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: difficulties.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                              color: selected
                                  ? AppTheme.accent
                                  : AppTheme.cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.accent
                                    : AppTheme.border,
                              ),
                            ),
                            child: Text(
                              diff,
                              style: AppTheme.labelSmall.copyWith(
                                color: selected
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
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
                  final topic = _filtered[i];
                  return _StudyTopicTile(
                    topic: topic,
                    onTap: () => _openTopic(topic),
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

  void _openTopic(StudyTopic topic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TopicDetailSheet(
        topic: topic,
        onTakeQuiz: _user != null
            ? () {
                Navigator.pop(context);
                _startQuiz(topic);
              }
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
      MaterialPageRoute(
        builder: (_) => QuizScreen(category: cat, userId: _user!.id!),
      ),
    );
  }
}

// ─── Study Topic List Tile ─────────────────────────────────────────────────
class _StudyTopicTile extends StatelessWidget {
  final StudyTopic topic;
  final VoidCallback onTap;

  const _StudyTopicTile({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(topic.color);
    final diffColor = topic.difficulty == 'Beginner'
        ? AppTheme.success
        : topic.difficulty == 'Intermediate'
            ? AppTheme.accentWarm
            : AppTheme.danger;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(topic.icon, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(topic.title,
                            style: AppTheme.titleLarge.copyWith(fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: diffColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          topic.difficulty,
                          style: AppTheme.labelSmall.copyWith(
                            color: diffColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic.summary,
                    style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.menu_book_outlined,
                          size: 12, color: color.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text('${topic.lessons.length} lessons',
                          style: AppTheme.labelSmall.copyWith(
                              color: color.withOpacity(0.8), fontSize: 10)),
                      const SizedBox(width: 10),
                      Icon(Icons.timer_outlined,
                          size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(topic.readingTime,
                          style: AppTheme.labelSmall
                              .copyWith(color: AppTheme.textMuted, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.chevron_right_rounded, color: color, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Topic Detail Bottom Sheet ─────────────────────────────────────────────
class _TopicDetailSheet extends StatelessWidget {
  final StudyTopic topic;
  final VoidCallback? onTakeQuiz;

  const _TopicDetailSheet({required this.topic, this.onTakeQuiz});

  @override
  Widget build(BuildContext context) {
    final color = Color(topic.color);
    final diffColor = topic.difficulty == 'Beginner'
        ? AppTheme.success
        : topic.difficulty == 'Intermediate'
            ? AppTheme.accentWarm
            : AppTheme.danger;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Topic header
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(topic.icon,
                                  style: const TextStyle(fontSize: 28)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(topic.title,
                                    style: AppTheme.headlineMedium
                                        .copyWith(fontSize: 20)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: diffColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        topic.difficulty,
                                        style: AppTheme.labelSmall.copyWith(
                                            color: diffColor, fontSize: 10),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('· ${topic.readingTime}',
                                        style: AppTheme.bodyMedium
                                            .copyWith(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Summary
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: color.withOpacity(0.15)),
                        ),
                        child: Text(
                          topic.summary,
                          style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.textPrimary, height: 1.5),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text('What you\'ll learn',
                          style: AppTheme.titleLarge.copyWith(fontSize: 16)),
                      const SizedBox(height: 14),

                      // Lessons
                      ...topic.lessons.asMap().entries.map((entry) {
                        final i = entry.key;
                        final lesson = entry.value;
                        return _LessonCard(
                          index: i + 1,
                          lesson: lesson,
                          color: color,
                        );
                      }),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Take Quiz CTA
              if (onTakeQuiz != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: onTakeQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.quiz_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Take Quiz →',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
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

// ─── Lesson Card ───────────────────────────────────────────────────────────
class _LessonCard extends StatefulWidget {
  final int index;
  final StudyLesson lesson;
  final Color color;

  const _LessonCard({
    required this.index,
    required this.lesson,
    required this.color,
  });

  @override
  State<_LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<_LessonCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expanded
                ? widget.color.withOpacity(0.4)
                : AppTheme.border,
            width: _expanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index}',
                      style: GoogleFonts.spaceGrotesk(
                        color: widget.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.lesson.heading,
                    style: AppTheme.titleLarge.copyWith(fontSize: 14),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Container(height: 1, color: AppTheme.border),
              const SizedBox(height: 12),
              Text(
                widget.lesson.body,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
