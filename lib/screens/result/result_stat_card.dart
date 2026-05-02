part of 'result_screen.dart';

// ─── Grade Section ────────────────────────────────────────────────────────────
class _GradeSection extends StatelessWidget {
  final String grade;
  final Color gradeColor;
  final Animation<double> scaleAnimation;
  final Animation<double> scoreAnimation;
  final String message;

  const _GradeSection({
    required this.grade, required this.gradeColor,
    required this.scaleAnimation, required this.scoreAnimation, required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: scaleAnimation,
          builder: (_, child) => Transform.scale(scale: scaleAnimation.value, child: child),
          child: Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gradeColor.withValues(alpha: 0.1),
              border: Border.all(color: gradeColor, width: 3),
              boxShadow: [BoxShadow(color: gradeColor.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)],
            ),
            child: Center(
              child: Text(grade, style: GoogleFonts.spaceGrotesk(color: gradeColor, fontSize: 52, fontWeight: FontWeight.w900)),
            ),
          ),
        ),
        AppSpacing.h20,
        AnimatedBuilder(
          animation: scoreAnimation,
          builder: (_, __) => Text(
            '${scoreAnimation.value.toStringAsFixed(0)}%',
            style: AppTheme.displayLarge.copyWith(color: gradeColor, fontSize: 48),
          ),
        ),
        AppSpacing.xs,
        Text(message, style: AppTheme.bodyMedium.copyWith(fontSize: 15), textAlign: TextAlign.center),
      ],
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return StatDisplay(
      icon: icon,
      value: value,
      label: label,
      color: color,
      size: StatDisplaySize.large,
    );
  }
}

// ─── Breakdown Card ───────────────────────────────────────────────────────────
class _ResultBreakdownCard extends StatelessWidget {
  final QuizResult result;
  const _ResultBreakdownCard({required this.result});

  Widget _progressBar({required String label, required int count, required int total, required Color color}) {
    final ratio = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: AppTheme.bodyMedium.copyWith(fontSize: 13))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: ratio, backgroundColor: color.withValues(alpha: 0.12), valueColor: AlwaysStoppedAnimation(color), minHeight: 8),
          ),
        ),
        AppSpacing.smH,
        Text('$count', style: GoogleFonts.jetBrainsMono(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette(context);
    final c = AppColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Breakdown', style: AppTheme.titleLarge.copyWith(fontSize: 15)),
          AppSpacing.h12,
          _progressBar(label: 'Correct', count: result.correctAnswers, total: result.totalQuestions, color: c.success),
          AppSpacing.sm,
          _progressBar(label: 'Incorrect', count: result.totalQuestions - result.correctAnswers, total: result.totalQuestions, color: c.danger),
        ],
      ),
    );
  }
}
