import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../providers/shell_provider.dart';
import '../../widgets/stat_display.dart';

part 'result_stat_card.dart';
part 'result_review_tile.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final QuizResult result;
  final QuizCategory category;
  final List<QuestionReview> reviews;

  const ResultScreen({super.key, required this.result, required this.category, this.reviews = const []});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _cardController;
  late Animation<double> _scoreAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _cardController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _scoreAnimation = Tween<double>(begin: 0, end: widget.result.percentage)
        .animate(CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic));
    _cardAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _scoreController, curve: const Interval(0, 0.5)));

    Future.delayed(const Duration(milliseconds: 200), () => _scoreController.forward());
    Future.delayed(const Duration(milliseconds: 600), () => _cardController.forward());
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  String _getGradeMessage(String grade) => switch (grade) {
    'S' => "Outstanding! You're a financial pro! 🎉",
    'A' => 'Excellent work! Keep building on this! 💪',
    'B' => "Good job! A bit more practice and you'll ace it!",
    'C' => 'Not bad — review the explanations to improve!',
    _ => 'Keep going! Every quiz makes you smarter 📚',
  };

  @override
  Widget build(BuildContext context) {
    final catColor = Color(widget.category.color);
    final grade = widget.result.grade;
    final gradeColor = grade == 'S' || grade == 'A'
        ? AppTheme.success
        : grade == 'B' || grade == 'C' ? AppTheme.accentWarm : AppTheme.danger;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Text(widget.category.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text('${widget.category.name} Results', style: AppTheme.titleLarge),
              ]),
            ),
            const Divider(color: AppTheme.border, height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _GradeSection(grade: grade, gradeColor: gradeColor, scaleAnimation: _scaleAnimation, scoreAnimation: _scoreAnimation, message: _getGradeMessage(grade)),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _cardAnimation,
                      child: Column(children: [
                        Row(children: [
                          _StatCard(icon: '✅', label: 'Correct', value: '${widget.result.correctAnswers}/${widget.result.totalQuestions}', color: AppTheme.success),
                          const SizedBox(width: 10),
                          _StatCard(icon: '⭐', label: 'Score', value: '${widget.result.score}', color: AppTheme.accentWarm),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          _StatCard(icon: '⏱️', label: 'Time', value: '${widget.result.timeTakenSeconds}s', color: AppTheme.accentBlue),
                          const SizedBox(width: 10),
                          _StatCard(icon: '🏆', label: 'Grade', value: grade, color: gradeColor),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(opacity: _cardAnimation, child: _ResultBreakdownCard(result: widget.result)),
                    if (widget.reviews.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      FadeTransition(
                        opacity: _cardAnimation,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Question Review', style: AppTheme.titleLarge.copyWith(fontSize: 15)),
                              const SizedBox(height: 12),
                              ...widget.reviews.indexed.map((e) => _ReviewTile(index: e.$1 + 1, review: e.$2)),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final userId = ref.read(currentUserIdProvider).asData?.value;
                        if (userId != null) {
                          ref.invalidate(currentUserProvider);
                          ref.invalidate(recentResultsProvider(userId));
                          ref.invalidate(weeklyResultsProvider(userId));
                          ref.invalidate(userStatsProvider(userId));
                        }
                        ref.read(shellIndexProvider.notifier).setIndex(0);
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: catColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text('Back to Home'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.border), foregroundColor: AppTheme.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
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
}
