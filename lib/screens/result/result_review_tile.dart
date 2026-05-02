part of 'result_screen.dart';

// ─── Review Tile ──────────────────────────────────────────────────────────────
class _ReviewTile extends StatelessWidget {
  final int index;
  final QuestionReview review;
  const _ReviewTile({required this.index, required this.review});

  void _showExplanationDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.border)),
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
              Text(review.correctAnswer, style: AppTheme.bodyLarge.copyWith(color: AppTheme.success, fontWeight: FontWeight.w600)),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = review.answeredCorrectly ? AppTheme.success : AppTheme.danger;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: statusColor.withValues(alpha:0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withValues(alpha:0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$index. ${review.question}', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          AppSpacing.sm,
          Text('Your answers', style: AppTheme.labelSmall.copyWith(color: AppTheme.textMuted, letterSpacing: 0.6)),
          AppSpacing.xs,
          Text('1st: ${review.firstAttemptAnswer ?? '—'}', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
          if (review.secondAttemptAnswer != null) ...[
            const SizedBox(height: 2),
            Text('2nd: ${review.secondAttemptAnswer}', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
          ],
          AppSpacing.sm,
          Text('Correct answer', style: AppTheme.labelSmall.copyWith(color: AppTheme.success, letterSpacing: 0.6)),
          AppSpacing.xs,
          if (review.answeredCorrectly)
            Text(review.correctAnswer, style: AppTheme.bodyMedium.copyWith(color: AppTheme.success, fontWeight: FontWeight.w600))
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
                              color: AppTheme.success, fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline, decorationColor: AppTheme.success,
                            )),
                          ),
                          Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.success.withValues(alpha:0.9)),
                        ],
                      ),
                      AppSpacing.xs,
                      Text('Tap for explanation', style: AppTheme.labelSmall.copyWith(color: AppTheme.textMuted, fontSize: 10)),
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
