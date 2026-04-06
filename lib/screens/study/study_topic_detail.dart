part of 'study_screen.dart';

// ─── Topic Detail Bottom Sheet ────────────────────────────────────────────────
class _TopicDetailSheet extends StatelessWidget {
  final StudyTopic topic;
  final VoidCallback? onTakeQuiz;

  const _TopicDetailSheet({required this.topic, this.onTakeQuiz});

  @override
  Widget build(BuildContext context) {
    final color = Color(topic.color);
    final diffColor = _difficultyColor(topic.difficulty);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: Column(
          children: [
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
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha:0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(child: Text(topic.icon, style: const TextStyle(fontSize: 28))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(topic.title, style: AppTheme.headlineMedium.copyWith(fontSize: 20)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: diffColor.withValues(alpha:0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      topic.difficulty,
                                      style: AppTheme.labelSmall.copyWith(color: diffColor, fontSize: 10),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('· ${topic.readingTime}', style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha:0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha:0.15)),
                      ),
                      child: Text(
                        topic.summary,
                        style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimary, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text("What you'll learn", style: AppTheme.titleLarge.copyWith(fontSize: 16)),
                    const SizedBox(height: 14),
                    ...topic.lessons.indexed.map(
                      (e) => _LessonCard(index: e.$1 + 1, lesson: e.$2, color: color),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.quiz_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Take Quiz →',
                          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Lesson Card ──────────────────────────────────────────────────────────────
class _LessonCard extends StatefulWidget {
  final int index;
  final StudyLesson lesson;
  final Color color;

  const _LessonCard({required this.index, required this.lesson, required this.color});

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
            color: _expanded ? widget.color.withValues(alpha:0.4) : AppTheme.border,
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
                    color: widget.color.withValues(alpha:0.12),
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
                  child: Text(widget.lesson.heading, style: AppTheme.titleLarge.copyWith(fontSize: 14)),
                ),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
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
