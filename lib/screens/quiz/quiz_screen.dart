import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/app_routes.dart';
import 'quiz_controller.dart';
import 'quiz_widgets.dart';
import 'quiz_dialogs.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final QuizCategory category;
  final int userId;

  const QuizScreen({super.key, required this.category, required this.userId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> with TickerProviderStateMixin {
  late final QuizController _ctrl;

  late AnimationController _progressController;
  late AnimationController _shakeController;
  late AnimationController _slideController;
  late Animation<double> _shakeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _ctrl = QuizController();

    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: QuizController.timePerQuestion))
      ..addListener(() => setState(() {}));
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnimation = Tween<double>(begin: 0, end: 8)
        .animate(CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _ctrl.addListener(_onControllerChange);
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final raw = await ref.read(questionsProvider(widget.category.id).future);
    final shuffled = raw.map(_shuffleOptions).toList()..shuffle(Random());
    if (!mounted) return;
    await _ctrl.loadQuestions(Future.value(shuffled), onReady: () {
      _progressController.reset();
      _progressController.forward();
      _slideController.forward();
    });
  }

  void _onControllerChange() {
    if (!mounted) return;
    // Trigger shake on wrong answer
    if (_ctrl.answered &&
        _ctrl.selectedOption != null &&
        _ctrl.selectedOption != -1 &&
        _ctrl.selectedOption != _ctrl.questions[_ctrl.currentIndex].correctIndex) {
      _shakeController.forward(from: 0);
    }
  }

  void _handleNextQuestion() {
    final isFinished = _ctrl.nextQuestion();
    if (isFinished) {
      _finishQuiz();
    } else {
      _slideController.reset();
      _shakeController.reset();
      _progressController.reset();
      _progressController.forward();
      _slideController.forward();
    }
  }

  Future<void> _finishQuiz() async {
    final result = _ctrl.buildResult(widget.userId, widget.category.id);
    await ref.read(authProvider.notifier).completeQuiz(result);
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.result,
        arguments: ResultArgs(result: result, category: widget.category, reviews: List.of(_ctrl.questionReviews)),
      );
    }
  }

  QuizQuestion _shuffleOptions(QuizQuestion question) {
    final random = Random();
    final indexed = question.options.asMap().entries.toList()..shuffle(random);
    return QuizQuestion(
      id: question.id,
      category: question.category,
      question: question.question,
      options: indexed.map((e) => e.value).toList(),
      correctIndex: indexed.indexWhere((e) => e.key == question.correctIndex),
      explanation: question.explanation,
      difficulty: question.difficulty,
    );
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChange);
    _ctrl.dispose();
    _progressController.dispose();
    _shakeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette(context);

    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        if (_ctrl.loading) {
          return Scaffold(
            backgroundColor: p.bg,
            body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const CircularProgressIndicator(color: AppTheme.accent),
              AppSpacing.md,
              Text('Loading quiz...', style: AppTheme.bodyMedium),
            ])),
          );
        }
        if (_ctrl.questions.isEmpty) {
          return Scaffold(
            backgroundColor: p.bg,
            body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('📭', style: TextStyle(fontSize: 48)),
              AppSpacing.md,
              Text('No questions found', style: AppTheme.headlineMedium),
              AppSpacing.sm,
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Go back', style: AppTheme.bodyLarge.copyWith(color: AppTheme.accent))),
            ])),
          );
        }

        final question = _ctrl.questions[_ctrl.currentIndex];
        final catColor = Color(widget.category.color);
        final progress = (_ctrl.currentIndex + 1) / _ctrl.questions.length;

        return Scaffold(
          backgroundColor: p.bg,
          body: SafeArea(
            child: Column(
              children: [
                QuizHeader(
                  category: widget.category,
                  currentIndex: _ctrl.currentIndex,
                  totalCount: _ctrl.questions.length,
                  score: _ctrl.score,
                  catColor: catColor,
                  progress: progress,
                  onExit: () => showQuizExitDialog(context),
                ),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        key: ValueKey<int>(_ctrl.currentIndex),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          QuizTimerBar(timeLeft: _ctrl.timeLeft, timePerQuestion: QuizController.timePerQuestion, catColor: catColor),
                          AppSpacing.lg,
                          QuizQuestionCard(question: question),
                          AppSpacing.h20,
                          ...List.generate(question.options.length, (i) => QuizOptionTile(
                            question: question, index: i, catColor: catColor,
                            selectedOption: _ctrl.selectedOption,
                            firstAttemptSelection: _ctrl.firstAttemptSelection,
                            answered: _ctrl.answered,
                            shakeAnimation: _shakeAnimation,
                            onSelect: _ctrl.selectOption,
                          )),
                          if (!_ctrl.answered && _ctrl.attemptHint != null) ...[
                            AppSpacing.sm,
                            Text(_ctrl.attemptHint!, style: AppTheme.bodyMedium.copyWith(color: AppTheme.accentWarm)),
                          ],
                          if (_ctrl.answered) ...[
                            AppSpacing.md,
                            QuizExplanationCard(question: question, selectedOption: _ctrl.selectedOption),
                          ],
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_ctrl.answered) QuizNextButton(
                  isLast: _ctrl.isLastQuestion,
                  catColor: catColor,
                  onNext: _handleNextQuestion,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
