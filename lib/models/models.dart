// ─── Quiz Question Model ───────────────────────────────────────────────────
class QuizQuestion {
  final int? id;
  final String category;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String difficulty; // 'easy' | 'medium' | 'hard'

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
      options: [
        map['option0'],
        map['option1'],
        map['option2'],
        map['option3'],
      ],
      correctIndex: map['correctIndex'],
      explanation: map['explanation'],
      difficulty: map['difficulty'],
    );
  }
}

// ─── Quiz Category Model ───────────────────────────────────────────────────
class QuizCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int color;
  final int totalQuestions;
  final String difficulty;

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

// ─── User Model ────────────────────────────────────────────────────────────
class UserModel {
  final int? id;
  final String name;
  final String username;
  final String avatarInitial;
  int totalScore;
  int quizzesCompleted;
  int currentStreak;
  int longestStreak;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.username,
    required this.avatarInitial,
    this.totalScore = 0,
    this.quizzesCompleted = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatarInitial': avatarInitial,
      'totalScore': totalScore,
      'quizzesCompleted': quizzesCompleted,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      username: map['username'],
      avatarInitial: map['avatarInitial'],
      totalScore: map['totalScore'],
      quizzesCompleted: map['quizzesCompleted'],
      currentStreak: map['currentStreak'],
      longestStreak: map['longestStreak'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

// ─── Quiz Result Model ─────────────────────────────────────────────────────
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
