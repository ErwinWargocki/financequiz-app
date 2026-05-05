import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import '../../data/quiz_categories.dart';

// ─── History Tile ─────────────────────────────────────────────────────────────
class ProfileHistoryTile extends StatelessWidget {
  final QuizResult result;
  const ProfileHistoryTile({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final cat = QuizCategories.all.firstWhere(
      (c) => c.id == result.category,
      orElse: () => QuizCategories.all.first,
    );
    final color = Color(cat.color);
    final grade = result.grade;
    final p = AppTheme.palette(context);
    final c = AppColors.of(context);
    final gradeColor = grade == 'S' || grade == 'A'
        ? c.success
        : grade == 'B' || grade == 'C' ? AppTheme.accentWarm : c.danger;

    final date = result.completedAt;
    final dateStr = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 18))),
          ),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat.name, style: AppTheme.titleLarge.copyWith(fontSize: 14)),
                Text(dateStr, style: AppTheme.bodyMedium.copyWith(fontSize: 11, color: p.textSub)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(color: gradeColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Center(child: Text(grade, style: GoogleFonts.spaceGrotesk(color: gradeColor, fontWeight: FontWeight.w800, fontSize: 13))),
              ),
              Text('${result.correctAnswers}/${result.totalQuestions}', style: AppTheme.labelSmall.copyWith(color: p.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
