import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart';

class QuizController extends ChangeNotifier {
  // ── Domain state ─────────────────────────────────────────────────────────────
  List<QuizQuestion> questions = [];
  int currentIndex = 0;
  int? selectedOption;
  bool answered = false;
  int correctCount = 0;
  int score = 0;
  bool loading = true;
  final List<QuestionReview> questionReviews = [];

  // ── Attempt flow ──────────────────────────────────────────────────────────────
  int attemptNumber = 1;
  int? firstAttemptSelection;
  String? attemptHint;

  // ── Timer ─────────────────────────────────────────────────────────────────────
  static const int timePerQuestion = 20;
  int timeLeft = timePerQuestion;
  int totalTimeTaken = 0;
  Timer? _timer;

  // Called from initState — loads shuffled questions then starts the timer.
  // The [onReady] callback fires when questions are ready so the parent
  // StatefulWidget can trigger the slide-in animation.
  Future<void> loadQuestions(Future<List<QuizQuestion>> future, {VoidCallback? onReady}) async {
    final qs = await future;
    questions = qs;
    loading = false;
    notifyListeners();
    onReady?.call();
    startTimer();
  }

  void startTimer({VoidCallback? onExpire}) {
    timeLeft = timePerQuestion;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 0) {
        t.cancel();
        _autoSubmit();
        onExpire?.call();
      } else {
        timeLeft--;
        notifyListeners();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    totalTimeTaken += timePerQuestion - timeLeft;
  }

  void _autoSubmit() {
    if (answered) return;
    stopTimer();
    final q = questions[currentIndex];
    questionReviews.add(QuestionReview(
      question: q.question,
      correctAnswer: q.options[q.correctIndex],
      explanation: q.explanation,
      firstAttemptAnswer: firstAttemptSelection == null ? null : q.options[firstAttemptSelection!],
      secondAttemptAnswer: null,
      answeredCorrectly: false,
    ));
    answered = true;
    selectedOption = -1;
    attemptHint = 'Time is up for this question.';
    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  // Returns true if the quiz is now finished (last question answered).
  bool selectOption(int index) {
    if (answered) return false;
    HapticFeedback.selectionClick();
    final q = questions[currentIndex];
    final isCorrect = index == q.correctIndex;

    if (!isCorrect && attemptNumber == 1) {
      firstAttemptSelection = index;
      attemptNumber = 2;
      attemptHint = 'Not correct. Try one more time.';
      HapticFeedback.heavyImpact();
      notifyListeners();
      return false;
    }

    stopTimer();
    if (isCorrect) {
      correctCount++;
      score += (attemptNumber == 1 ? 10 : 5) + (timeLeft * 2);
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    questionReviews.add(QuestionReview(
      question: q.question,
      correctAnswer: q.options[q.correctIndex],
      explanation: q.explanation,
      firstAttemptAnswer: firstAttemptSelection == null ? q.options[index] : q.options[firstAttemptSelection!],
      secondAttemptAnswer: firstAttemptSelection == null ? null : q.options[index],
      answeredCorrectly: isCorrect,
    ));
    selectedOption = index;
    answered = true;
    attemptHint = null;
    notifyListeners();
    return false;
  }

  // Returns true if this was the last question (caller should navigate to results).
  bool nextQuestion() {
    if (currentIndex >= questions.length - 1) return true;
    currentIndex++;
    selectedOption = null;
    answered = false;
    attemptNumber = 1;
    firstAttemptSelection = null;
    attemptHint = null;
    notifyListeners();
    startTimer();
    return false;
  }

  bool get isLastQuestion => currentIndex >= questions.length - 1;

  QuizResult buildResult(int userId, String categoryId) => QuizResult(
    userId: userId,
    category: categoryId,
    score: score,
    totalQuestions: questions.length,
    correctAnswers: correctCount,
    timeTakenSeconds: totalTimeTaken,
    completedAt: DateTime.now(),
  );

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
