// ─── Quiz Question ─────────────────────────────────────────────────────────────
// A single multiple-choice question. Options are stored as a flat list of 4
// strings; correctIndex indicates which one is right (0–3). The question
// can be shuffled (options reordered + correctIndex updated) without touching
// the original data in the database.
class QuizQuestion {
  final int? id;
  final String category;
  final String question;
  final List<String> options;   // always 4 options
  final int correctIndex;       // index into [options] after any shuffle
  final String explanation;     // shown to the user after answering
  final String difficulty;      // 'easy' | 'medium' | 'hard'

  const QuizQuestion({
    this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'question': question,
      'option0': options[0],
      'option1': options[1],
      'option2': options[2],
      'option3': options[3],
      'correctIndex': correctIndex,
      'explanation': explanation,
      'difficulty': difficulty,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'],
      category: map['category'],
      question: map['question'],
      options: [map['option0'], map['option1'], map['option2'], map['option3']],
      correctIndex: map['correctIndex'],
      explanation: map['explanation'],
      difficulty: map['difficulty'],
    );
  }
}

// ─── Quiz Category ─────────────────────────────────────────────────────────────
// Static metadata for one of the 6 quiz topics shown on the Explore screen.
// The [color] field is stored as an int (ARGB) so it can be used directly
// with Flutter's Color constructor: Color(category.color).
class QuizCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int color;           // ARGB integer, e.g. 0xFF4C6EF5
  final int totalQuestions;
  final String difficulty;   // 'Beginner' | 'Intermediate' | 'Advanced'

  const QuizCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
    required this.totalQuestions,
    required this.difficulty,
  });
}

// ─── Quiz Result ───────────────────────────────────────────────────────────────
// Records a completed quiz session. Persisted to the local 'results' table
// so the profile and stats screens can show historical performance.
class QuizResult {
  final int? id;
  final int userId;
  final String category;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int timeTakenSeconds;
  final DateTime completedAt;

  const QuizResult({
    this.id,
    required this.userId,
    required this.category,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTakenSeconds,
    required this.completedAt,
  });

  // Derived stats used by the result screen and grade display
  double get percentage => (correctAnswers / totalQuestions) * 100;

  String get grade {
    if (percentage >= 90) return 'S';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    return 'D';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timeTakenSeconds': timeTakenSeconds,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'],
      userId: map['userId'],
      category: map['category'],
      score: map['score'],
      totalQuestions: map['totalQuestions'],
      correctAnswers: map['correctAnswers'],
      timeTakenSeconds: map['timeTakenSeconds'],
      completedAt: DateTime.parse(map['completedAt']),
    );
  }
}

// ─── Question Review ───────────────────────────────────────────────────────────
// Holds the per-question summary used on the result review screen.
// Created in memory during a quiz session and passed to ResultScreen;
// never persisted to the database.
class QuestionReview {
  final String question;
  final String correctAnswer;
  final String explanation;
  final String? firstAttemptAnswer;   // null if answered correctly first try
  final String? secondAttemptAnswer;  // null if not needed or time ran out
  final bool answeredCorrectly;

  const QuestionReview({
    required this.question,
    required this.correctAnswer,
    required this.explanation,
    required this.firstAttemptAnswer,
    required this.secondAttemptAnswer,
    required this.answeredCorrectly,
  });
}
