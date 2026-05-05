import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';

// ─── Review Tile ──────────────────────────────────────────────────────────────
class ResultReviewTile extends StatelessWidget {
  final int index;
  final QuestionReview review;
  const ResultReviewTile({super.key, required this.index, required this.review});

  void _showExplanationDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final p = AppTheme.palette(ctx);
        final c = AppColors.of(ctx);
        return Dialog(
          backgroundColor: p.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: p.border)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.accentWarm, size: 22),
                  AppSpacing.smH,
                  Expanded(child: Text('Why this is correct', style: AppTheme.titleLarge.copyWith(fontSize: 16))),
                ]),
                AppSpacing.h12,
                Text(review.correctAnswer, style: AppTheme.bodyLarge.copyWith(color: c.success, fontWeight: FontWeight.w600)),
                AppSpacing.h12,
                Text(
                  review.explanation.isNotEmpty ? review.explanation : 'No explanation available for this question.',
                  style: AppTheme.bodyMedium.copyWith(height: 1.45),
                ),
                AppSpacing.h20,
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Close', style: AppTheme.bodyLarge.copyWith(color: AppTheme.accent)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final p = AppTheme.palette(context);
    final statusColor = review.answeredCorrectly ? c.success : c.danger;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$index. ${review.question}', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          AppSpacing.sm,
          Text('Your answers', style: AppTheme.labelSmall.copyWith(color: p.textMuted, letterSpacing: 0.6)),
          AppSpacing.xs,
          Text('1st: ${review.firstAttemptAnswer ?? '—'}', style: AppTheme.bodyMedium.copyWith(color: p.textSub)),
          if (review.secondAttemptAnswer != null) ...[
            Text('2nd: ${review.secondAttemptAnswer}', style: AppTheme.bodyMedium.copyWith(color: p.textSub)),
          ],
          AppSpacing.sm,
          Text('Correct answer', style: AppTheme.labelSmall.copyWith(color: c.success, letterSpacing: 0.6)),
          AppSpacing.xs,
          if (review.answeredCorrectly)
            Text(review.correctAnswer, style: AppTheme.bodyMedium.copyWith(color: c.success, fontWeight: FontWeight.w600))
          else
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showExplanationDialog(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(review.correctAnswer, style: AppTheme.bodyMedium.copyWith(
                              color: c.success, fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline, decorationColor: c.success,
                            )),
                          ),
                          Icon(Icons.info_outline_rounded, size: 18, color: c.success.withValues(alpha: 0.9)),
                        ],
                      ),
                      AppSpacing.xs,
                      Text('Tap for explanation', style: AppTheme.labelSmall.copyWith(color: p.textMuted, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
