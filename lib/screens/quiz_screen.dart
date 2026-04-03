import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../database/database_helper.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuizCategory category;
  final int userId;

  const QuizScreen({
    super.key,
    required this.category,
    required this.userId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _correctCount = 0;
  int _score = 0;
  bool _loading = true;

  // Timer
  late Timer _timer;
  int _timeLeft = 20;
  int _totalTimeTaken = 0;
  final int _timePerQuestion = 20;

  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _shakeController;
  late AnimationController _slideController;
  late Animation<double> _shakeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _timePerQuestion),
    )..addListener(() => setState(() {}));

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await DatabaseHelper.instance
        .getQuestionsByCategory(widget.category.id, limit: 10);
    setState(() {
      _questions = questions;
      _loading = false;
    });
    _startTimer();
    _slideController.forward();
  }

  void _startTimer() {
    _timeLeft = _timePerQuestion;
    _progressController.reset();
    _progressController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 0) {
        t.cancel();
        _autoSubmit();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _stopTimer() {
    _timer.cancel();
    _progressController.stop();
    _totalTimeTaken += _timePerQuestion - _timeLeft;
  }

  void _autoSubmit() {
    if (!_answered) {
      _stopTimer();
      setState(() {
        _answered = true;
        _selectedOption = -1;
      });
      _shakeController.forward(from: 0);
      HapticFeedback.heavyImpact();
    }
  }

  void _selectOption(int index) {
    if (_answered) return;
    _stopTimer();
    HapticFeedback.selectionClick();

    final isCorrect = index == _questions[_currentIndex].correctIndex;
    if (isCorrect) {
      _correctCount++;
      _score += 10 + (_timeLeft * 2); // time bonus
      HapticFeedback.mediumImpact();
    } else {
      _shakeController.forward(from: 0);
      HapticFeedback.heavyImpact();
    }

    setState(() {
      _selectedOption = index;
      _answered = true;
    });
  }

  void _nextQuestion() {
    if (_currentIndex >= _questions.length - 1) {
      _finishQuiz();
      return;
    }

    _slideController.reset();
    setState(() {
      _currentIndex++;
      _selectedOption = null;
      _answered = false;
    });
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

    // Update user stats
    final user = await db.getUser(widget.userId);
    if (user != null) {
      user.totalScore += _score;
      user.quizzesCompleted += 1;
      user.currentStreak += 1;
      if (user.currentStreak > user.longestStreak) {
        user.longestStreak = user.currentStreak;
      }
      await db.updateUser(user);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: result, category: widget.category),
        ),
      );
    }
  }

  @override
  void dispose() {
    try {
      _timer.cancel();
    } catch (_) {}
    _progressController.dispose();
    _shakeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.accent),
              const SizedBox(height: 16),
              Text('Loading quiz...', style: AppTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📭', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text('No questions found', style: AppTheme.headlineMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go back',
                    style: AppTheme.bodyLarge.copyWith(color: AppTheme.accent)),
              ),
            ],
          ),
        ),
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
            // Header
            _buildHeader(catColor, progress),

            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timer bar
                      _buildTimerBar(catColor),
                      const SizedBox(height: 24),

                      // Question card
                      _buildQuestionCard(question),
                      const SizedBox(height: 20),

                      // Options
                      ...List.generate(question.options.length, (i) {
                        return _buildOptionTile(
                            question, i, catColor);
                      }),

                      // Explanation
                      if (_answered) ...[
                        const SizedBox(height: 16),
                        _buildExplanation(question),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom action
            if (_answered) _buildNextButton(catColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color catColor, double progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _showExitDialog(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: AppTheme.textSecondary, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(widget.category.icon,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(widget.category.name,
                            style: AppTheme.titleLarge.copyWith(fontSize: 15)),
                      ],
                    ),
                    Text(
                      '${_currentIndex + 1} of ${_questions.length}',
                      style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Score
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '⭐ $_score',
                  style: GoogleFonts.spaceGrotesk(
                    color: catColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation(catColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar(Color catColor) {
    final timerColor = _timeLeft > 10
        ? catColor
        : _timeLeft > 5
            ? AppTheme.accentWarm
            : AppTheme.danger;

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: timerColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: timerColor.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.timer_outlined, size: 15, color: timerColor),
              const SizedBox(width: 5),
              Text(
                '$_timeLeft s',
                style: GoogleFonts.jetBrainsMono(
                  color: timerColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _timeLeft / _timePerQuestion,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation(timerColor),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    final diffColor = question.difficulty == 'easy'
        ? AppTheme.success
        : question.difficulty == 'medium'
            ? AppTheme.accentWarm
            : AppTheme.danger;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: diffColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              question.difficulty.toUpperCase(),
              style: AppTheme.labelSmall.copyWith(
                color: diffColor,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: AppTheme.titleLarge.copyWith(
              fontSize: 17,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
      QuizQuestion question, int index, Color catColor) {
    final isSelected = _selectedOption == index;
    final isCorrect = index == question.correctIndex;
    final showResult = _answered;

    Color borderColor = AppTheme.border;
    Color bgColor = AppTheme.cardBg;
    Color textColor = AppTheme.textPrimary;
    IconData? trailingIcon;

    if (showResult) {
      if (isCorrect) {
        borderColor = AppTheme.success;
        bgColor = AppTheme.success.withOpacity(0.1);
        trailingIcon = Icons.check_circle_rounded;
        textColor = AppTheme.success;
      } else if (isSelected && !isCorrect) {
        borderColor = AppTheme.danger;
        bgColor = AppTheme.danger.withOpacity(0.1);
        trailingIcon = Icons.cancel_rounded;
        textColor = AppTheme.danger;
      }
    } else if (isSelected) {
      borderColor = catColor;
      bgColor = catColor.withOpacity(0.1);
    }

    final optionLetters = ['A', 'B', 'C', 'D'];

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: (isSelected && _answered && !isCorrect)
              ? Offset(_shakeAnimation.value, 0)
              : Offset.zero,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => _selectOption(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: showResult && isCorrect
                      ? AppTheme.success
                      : showResult && isSelected && !isCorrect
                          ? AppTheme.danger
                          : isSelected
                              ? catColor
                              : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    optionLetters[index],
                    style: GoogleFonts.spaceGrotesk(
                      color: isSelected || (showResult && isCorrect)
                          ? Colors.white
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.options[index],
                  style: AppTheme.bodyLarge.copyWith(
                    color: textColor,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, color: textColor, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanation(QuizQuestion question) {
    final isCorrect = _selectedOption == question.correctIndex;
    final color = isCorrect ? AppTheme.success : AppTheme.danger;
    final emoji = isCorrect ? '✅' : '❌';
    final label = isCorrect ? 'Correct!' : 'Not quite!';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(Color catColor) {
    final isLast = _currentIndex >= _questions.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        border: const Border(
            top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _nextQuestion,
          style: ElevatedButton.styleFrom(
            backgroundColor: catColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            isLast ? 'See Results 🏁' : 'Next Question →',
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text('Quit Quiz?', style: AppTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Your progress will be lost.',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.border),
                        foregroundColor: AppTheme.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Stay'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.danger,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Quit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
