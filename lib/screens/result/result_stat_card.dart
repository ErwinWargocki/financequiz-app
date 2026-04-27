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
              color: gradeColor.withValues(alpha:0.1),
              border: Border.all(color: gradeColor, width: 3),
              boxShadow: [BoxShadow(color: gradeColor.withValues(alpha:0.3), blurRadius: 30, spreadRadius: 5)],
            ),
            child: Center(
              child: Text(grade, style: GoogleFonts.spaceGrotesk(color: gradeColor, fontSize: 52, fontWeight: FontWeight.w900)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: scoreAnimation,
          builder: (_, __) => Text(
            '${scoreAnimation.value.toStringAsFixed(0)}%',
            style: AppTheme.displayLarge.copyWith(color: gradeColor, fontSize: 48),
          ),
        ),
        const SizedBox(height: 4),
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

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

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
            child: LinearProgressIndicator(value: ratio, backgroundColor: color.withValues(alpha:0.12), valueColor: AlwaysStoppedAnimation(color), minHeight: 8),
          ),
        ),
        const SizedBox(width: 8),
        Text('$count', style: GoogleFonts.jetBrainsMono(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Breakdown', style: AppTheme.titleLarge.copyWith(fontSize: 15)),
          const SizedBox(height: 12),
          _progressBar(label: 'Correct', count: result.correctAnswers, total: result.totalQuestions, color: AppTheme.success),
          const SizedBox(height: 8),
          _progressBar(label: 'Incorrect', count: result.totalQuestions - result.correctAnswers, total: result.totalQuestions, color: AppTheme.danger),
        ],
      ),
    );
  }
}
