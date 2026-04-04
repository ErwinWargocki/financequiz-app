import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'main_shell.dart';

class ResultScreen extends StatefulWidget {
  final QuizResult result;
  final QuizCategory category;
  final List<QuestionReview> reviews;

  const ResultScreen({
    super.key,
    required this.result,
    required this.category,
    this.reviews = const [],
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _cardController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scoreAnimation = Tween<double>(begin: 0, end: widget.result.percentage)
        .animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutCubic,
    ));

    _cardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
          parent: _scoreController, curve: const Interval(0, 0.5)),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      _scoreController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catColor = Color(widget.category.color);
    final grade = widget.result.grade;
    final gradeColor = grade == 'S' || grade == 'A'
        ? AppTheme.success
        : grade == 'B' || grade == 'C'
            ? AppTheme.accentWarm
            : AppTheme.danger;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(widget.category.icon,
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text('${widget.category.name} Results',
                      style: AppTheme.titleLarge),
                ],
              ),
            ),
            const Divider(color: AppTheme.border, height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Grade circle
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (_, child) => Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: gradeColor.withOpacity(0.1),
                          border: Border.all(color: gradeColor, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: gradeColor.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            grade,
                            style: GoogleFonts.spaceGrotesk(
                              color: gradeColor,
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Score text
                    AnimatedBuilder(
                      animation: _scoreAnimation,
                      builder: (_, __) => Text(
                        '${_scoreAnimation.value.toStringAsFixed(0)}%',
                        style: AppTheme.displayLarge.copyWith(
                          color: gradeColor,
                          fontSize: 48,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _getGradeMessage(grade),
                      style: AppTheme.bodyMedium.copyWith(
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    // Stats cards
                    FadeTransition(
                      opacity: _cardAnimation,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _StatCard(
                                icon: '✅',
                                label: 'Correct',
                                value:
                                    '${widget.result.correctAnswers}/${widget.result.totalQuestions}',
                                color: AppTheme.success,
                              ),
                              const SizedBox(width: 10),
                              _StatCard(
                                icon: '⭐',
                                label: 'Score',
                                value: '${widget.result.score}',
                                color: AppTheme.accentWarm,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _StatCard(
                                icon: '⏱️',
                                label: 'Time',
                                value:
                                    '${widget.result.timeTakenSeconds}s',
                                color: AppTheme.accentBlue,
                              ),
                              const SizedBox(width: 10),
                              _StatCard(
                                icon: '🏆',
                                label: 'Grade',
                                value: grade,
                                color: gradeColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Answer breakdown
                    FadeTransition(
                      opacity: _cardAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Breakdown',
                                style: AppTheme.titleLarge.copyWith(
                                    fontSize: 15)),
                            const SizedBox(height: 12),
                            _buildProgressBar(
                              label: 'Correct',
                              count: widget.result.correctAnswers,
                              total: widget.result.totalQuestions,
                              color: AppTheme.success,
                            ),
                            const SizedBox(height: 8),
                            _buildProgressBar(
                              label: 'Incorrect',
                              count: widget.result.totalQuestions -
                                  widget.result.correctAnswers,
                              total: widget.result.totalQuestions,
                              color: AppTheme.danger,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (widget.reviews.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      FadeTransition(
                        opacity: _cardAnimation,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Question Review',
                                style: AppTheme.titleLarge.copyWith(fontSize: 15),
                              ),
                              const SizedBox(height: 12),
                              ...widget.reviews.asMap().entries.map(
                                (entry) {
                                  final i = entry.key;
                                  final review = entry.value;
                                  return _ReviewTile(
                                    index: i + 1,
                                    review: review,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MainShell()),
                          (_) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: catColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Back to Home'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.border),
                        foregroundColor: AppTheme.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final ratio = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label,
              style: AppTheme.bodyMedium.copyWith(fontSize: 13)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: GoogleFonts.jetBrainsMono(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  String _getGradeMessage(String grade) {
    switch (grade) {
      case 'S':
        return 'Outstanding! You\'re a financial pro! 🎉';
      case 'A':
        return 'Excellent work! Keep building on this! 💪';
      case 'B':
        return 'Good job! A bit more practice and you\'ll ace it!';
      case 'C':
        return 'Not bad — review the explanations to improve!';
      default:
        return 'Keep going! Every quiz makes you smarter 📚';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: AppTheme.labelSmall.copyWith(
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final int index;
  final QuestionReview review;

  const _ReviewTile({
    required this.index,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = review.answeredCorrectly ? AppTheme.success : AppTheme.danger;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index. ${review.question}',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Your answers',
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.textMuted,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1st: ${review.firstAttemptAnswer ?? '—'}',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          if (review.secondAttemptAnswer != null) ...[
            const SizedBox(height: 2),
            Text(
              '2nd: ${review.secondAttemptAnswer}',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Correct answer',
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.success,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          if (review.answeredCorrectly)
            Text(
              review.correctAnswer,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.success,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showExplanationDialog(context, review),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              review.correctAnswer,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.success,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: AppTheme.success,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppTheme.success.withOpacity(0.9),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap for explanation',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.textMuted,
                          fontSize: 10,
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
  }

  void _showExplanationDialog(BuildContext context, QuestionReview review) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      color: AppTheme.accentWarm, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Why this is correct',
                      style: AppTheme.titleLarge.copyWith(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                review.correctAnswer,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                review.explanation.isNotEmpty
                    ? review.explanation
                    : 'No explanation available for this question.',
                style: AppTheme.bodyMedium.copyWith(height: 1.45),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Close',
                    style: AppTheme.bodyLarge.copyWith(color: AppTheme.accent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
