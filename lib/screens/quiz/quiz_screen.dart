import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../database/database_helper.dart';
import '../result/result_screen.dart';

part 'quiz_widgets.dart';
part 'quiz_dialogs.dart';

class QuizScreen extends StatefulWidget {
  final QuizCategory category;
  final int userId;

  const QuizScreen({super.key, required this.category, required this.userId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _correctCount = 0;
  int _score = 0;
  bool _loading = true;
  int _attemptNumber = 1;
  int? _firstAttemptSelection;
  String? _attemptHint;
  final List<QuestionReview> _questionReviews = [];

  late Timer _timer;
  int _timeLeft = 20;
  int _totalTimeTaken = 0;
  final int _timePerQuestion = 20;

  late AnimationController _progressController;
  late AnimationController _shakeController;
  late AnimationController _slideController;
  late Animation<double> _shakeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this, duration: Duration(seconds: _timePerQuestion))
      ..addListener(() => setState(() {}));
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnimation = Tween<double>(begin: 0, end: 8).animate(CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await DatabaseHelper.instance.getQuestionsByCategory(widget.category.id, limit: 10);
    final randomized = questions.map(_shuffleQuestionOptions).toList()..shuffle(Random());
    setState(() { _questions = randomized; _loading = false; });
    _startTimer();
    _slideController.forward();
  }

  void _startTimer() {
    _timeLeft = _timePerQuestion;
    _progressController.reset();
    _progressController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 0) { t.cancel(); _autoSubmit(); }
      else { setState(() => _timeLeft--); }
    });
  }

  void _stopTimer() {
    _timer.cancel();
    _progressController.stop();
    _totalTimeTaken += _timePerQuestion - _timeLeft;
  }

  void _autoSubmit() {
    if (_answered) return;
    _stopTimer();
    final question = _questions[_currentIndex];
    _questionReviews.add(QuestionReview(
      question: question.question,
      correctAnswer: question.options[question.correctIndex],
      explanation: question.explanation,
      firstAttemptAnswer: _firstAttemptSelection == null ? null : question.options[_firstAttemptSelection!],
      secondAttemptAnswer: null,
      answeredCorrectly: false,
    ));
    setState(() { _answered = true; _selectedOption = -1; _attemptHint = 'Time is up for this question.'; });
    _shakeController.forward(from: 0);
    HapticFeedback.heavyImpact();
  }

  void _selectOption(int index) {
    if (_answered) return;
    HapticFeedback.selectionClick();
    final question = _questions[_currentIndex];
    final isCorrect = index == question.correctIndex;

    if (!isCorrect && _attemptNumber == 1) {
      setState(() { _firstAttemptSelection = index; _attemptNumber = 2; _attemptHint = 'Not correct. Try one more time.'; });
      _shakeController.forward(from: 0);
      HapticFeedback.heavyImpact();
      return;
    }

    _stopTimer();
    if (isCorrect) {
      _correctCount++;
      _score += (_attemptNumber == 1 ? 10 : 5) + (_timeLeft * 2);
      HapticFeedback.mediumImpact();
    } else {
      _shakeController.forward(from: 0);
      HapticFeedback.heavyImpact();
    }

    _questionReviews.add(QuestionReview(
      question: question.question,
      correctAnswer: question.options[question.correctIndex],
      explanation: question.explanation,
      firstAttemptAnswer: _firstAttemptSelection == null ? question.options[index] : question.options[_firstAttemptSelection!],
      secondAttemptAnswer: _firstAttemptSelection == null ? null : question.options[index],
      answeredCorrectly: isCorrect,
    ));
    setState(() { _selectedOption = index; _answered = true; _attemptHint = null; });
  }

  void _nextQuestion() {
    if (_currentIndex >= _questions.length - 1) { _finishQuiz(); return; }
    _slideController.reset();
    _shakeController.reset();
    setState(() { _currentIndex++; _selectedOption = null; _answered = false; _attemptNumber = 1; _firstAttemptSelection = null; _attemptHint = null; });
    _startTimer();
    _slideController.forward();
  }

  Future<void> _finishQuiz() async {
    final result = QuizResult(
      userId: widget.userId,
      category: widget.category.id,
      score: _score,
      totalQuestions: _questions.length,
      correctAnswers: _correctCount,
      timeTakenSeconds: _totalTimeTaken,
      completedAt: DateTime.now(),
    );
    final db = DatabaseHelper.instance;
    await db.insertResult(result);
    final user = await db.getUser(widget.userId);
    if (user != null) {
      final newStreak = user.currentStreak + 1;
      final updated = user.copyWith(
        totalScore: user.totalScore + _score,
        quizzesCompleted: user.quizzesCompleted + 1,
        currentStreak: newStreak,
        longestStreak: newStreak > user.longestStreak ? newStreak : user.longestStreak,
      );
      await db.updateUser(updated);
    }
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => ResultScreen(result: result, category: widget.category, reviews: _questionReviews),
      ));
    }
  }

  @override
  void dispose() {
    try { _timer.cancel(); } catch (_) {}
    _progressController.dispose();
    _shakeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  QuizQuestion _shuffleQuestionOptions(QuizQuestion question) {
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
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(color: AppTheme.accent),
          const SizedBox(height: 16),
          Text('Loading quiz...', style: AppTheme.bodyMedium),
        ])),
      );
    }
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('📭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('No questions found', style: AppTheme.headlineMedium),
          const SizedBox(height: 8),
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Go back', style: AppTheme.bodyLarge.copyWith(color: AppTheme.accent))),
        ])),
      );
    }

    final question = _questions[_currentIndex];
    final catColor = Color(widget.category.color);
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            _QuizHeader(
              category: widget.category,
              currentIndex: _currentIndex,
              totalCount: _questions.length,
              score: _score,
              catColor: catColor,
              progress: progress,
              onExit: () => _showQuizExitDialog(context),
            ),
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    key: ValueKey<int>(_currentIndex),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TimerBar(timeLeft: _timeLeft, timePerQuestion: _timePerQuestion, catColor: catColor),
                      const SizedBox(height: 24),
                      _QuestionCard(question: question),
                      const SizedBox(height: 20),
                      ...List.generate(question.options.length, (i) => _OptionTile(
                        question: question, index: i, catColor: catColor,
                        selectedOption: _selectedOption, firstAttemptSelection: _firstAttemptSelection,
                        answered: _answered, shakeAnimation: _shakeAnimation, onSelect: _selectOption,
                      )),
                      if (!_answered && _attemptHint != null) ...[
                        const SizedBox(height: 8),
                        Text(_attemptHint!, style: AppTheme.bodyMedium.copyWith(color: AppTheme.accentWarm)),
                      ],
                      if (_answered) ...[
                        const SizedBox(height: 16),
                        _ExplanationCard(question: question, selectedOption: _selectedOption),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            if (_answered) _NextButton(
              isLast: _currentIndex >= _questions.length - 1,
              catColor: catColor,
              onNext: _nextQuestion,
            ),
          ],
        ),
      ),
    );
  }
}
