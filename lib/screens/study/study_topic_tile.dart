import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';

// ─── Shared helper ────────────────────────────────────────────────────────────
Color difficultyColor(String difficulty) => switch (difficulty) {
  'Beginner'     => AppTheme.diffBeginner,
  'Intermediate' => AppTheme.diffIntermediate,
  _              => AppTheme.diffAdvanced,
};

// ─── Study Topic List Tile ────────────────────────────────────────────────────
class StudyTopicTile extends StatelessWidget {
  final StudyTopic topic;
  final VoidCallback onTap;

  const StudyTopicTile({super.key, required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(topic.color);
    final diffColor = difficultyColor(topic.difficulty);
    final p = AppTheme.palette(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.border),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(topic.icon, style: const TextStyle(fontSize: 26))),
            ),
            AppSpacing.w14,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(topic.title, style: AppTheme.titleLarge.copyWith(fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      AppSpacing.w6,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: diffColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                        child: Text(topic.difficulty, style: AppTheme.labelSmall.copyWith(color: diffColor, fontSize: 10)),
                      ),
                    ],
                  ),
                  AppSpacing.h4,
                  Text(topic.summary, style: AppTheme.bodyMedium.copyWith(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  AppSpacing.h6,
                  Row(
                    children: [
                      Icon(Icons.menu_book_outlined, size: 12, color: color.withValues(alpha: 0.7)),
                      AppSpacing.w4,
                      Text('${topic.lessons.length} lessons', style: AppTheme.labelSmall.copyWith(color: color.withValues(alpha: 0.8), fontSize: 10)),
                      AppSpacing.w10,
                      Icon(Icons.timer_outlined, size: 12, color: p.textMuted),
                      AppSpacing.w4,
                      Text(topic.readingTime, style: AppTheme.labelSmall.copyWith(color: p.textMuted, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.w8,
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.chevron_right_rounded, color: color, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
