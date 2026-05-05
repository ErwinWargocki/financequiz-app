import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import 'study_topic_tile.dart';

// ─── Topic Detail Bottom Sheet ────────────────────────────────────────────────
class StudyTopicDetailSheet extends StatelessWidget {
  final StudyTopic topic;
  final VoidCallback? onTakeQuiz;

  const StudyTopicDetailSheet({super.key, required this.topic, this.onTakeQuiz});

  @override
  Widget build(BuildContext context) {
    final color = Color(topic.color);
    final diffColor = difficultyColor(topic.difficulty);
    final p = AppTheme.palette(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scrollController) => Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: p.border)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: p.border, borderRadius: BorderRadius.circular(2)),
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
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                          child: Center(child: Text(topic.icon, style: const TextStyle(fontSize: 28))),
                        ),
                        AppSpacing.w14,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(topic.title, style: AppTheme.headlineMedium.copyWith(fontSize: 20)),
                              AppSpacing.h4,
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: diffColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                                    child: Text(topic.difficulty, style: AppTheme.labelSmall.copyWith(color: diffColor, fontSize: 10)),
                                  ),
                                  AppSpacing.w8,
                                  Text('· ${topic.readingTime}', style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.h20,
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha: 0.15)),
                      ),
                      child: Text(topic.summary, style: AppTheme.bodyLarge.copyWith(height: 1.5)),
                    ),
                    AppSpacing.h24,
                    Text("What you'll learn", style: AppTheme.titleLarge.copyWith(fontSize: 16)),
                    AppSpacing.h14,
                    ...topic.lessons.indexed.map(
                      (e) => _LessonCard(index: e.$1 + 1, lesson: e.$2, color: color),
                    ),
                    AppSpacing.h24,
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
                        AppSpacing.w8,
                        Text('Take Quiz →', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 16)),
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

// ─── Lesson Card (private — used only within this file) ───────────────────────
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
    final p = AppTheme.palette(context);
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expanded ? widget.color.withValues(alpha: 0.4) : p.border,
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
                  decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(7)),
                  child: Center(
                    child: Text(
                      '${widget.index}',
                      style: GoogleFonts.spaceGrotesk(color: widget.color, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ),
                AppSpacing.w10,
                Expanded(child: Text(widget.lesson.heading, style: AppTheme.titleLarge.copyWith(fontSize: 14))),
                Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: p.textMuted, size: 20),
              ],
            ),
            if (_expanded) ...[
              AppSpacing.h12,
              Container(height: 1, color: p.border),
              AppSpacing.h12,
              Text(widget.lesson.body, style: AppTheme.bodyMedium.copyWith(height: 1.6, fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }
}
