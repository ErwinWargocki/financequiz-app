// ─── Profile Icons ─────────────────────────────────────────────────────────
class ProfileIcons {
  static const List<String> all = [
    '🦁', '🐯', '🦊', '🐺', '🦝',
    '🐼', '🐨', '🦄', '🦋', '🐬',
    '🦅', '🦉', '🦚', '🐲', '🦈',
    '🚀', '⚡', '🔥', '💎', '🌟',
  ];

  static String get(int index) {
    if (index < 0 || index >= all.length) return '🦁';
    return all[index];
  }
}

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
  final String? email;
  final String? passwordHash;
  final String? googleId;
  int profileIconIndex;
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
    this.email,
    this.passwordHash,
    this.googleId,
    this.profileIconIndex = 0,
    this.totalScore = 0,
    this.quizzesCompleted = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get profileIcon => ProfileIcons.get(profileIconIndex);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatarInitial': avatarInitial,
      'email': email,
      'passwordHash': passwordHash,
      'googleId': googleId,
      'profileIconIndex': profileIconIndex,
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
      avatarInitial: map['avatarInitial'] ?? '',
      email: map['email'],
      passwordHash: map['passwordHash'],
      googleId: map['googleId'],
      profileIconIndex: map['profileIconIndex'] ?? 0,
      totalScore: map['totalScore'] ?? 0,
      quizzesCompleted: map['quizzesCompleted'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
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

class QuestionReview {
  final String question;
  final String correctAnswer;
  final String explanation;
  final String? firstAttemptAnswer;
  final String? secondAttemptAnswer;
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

// ─── Study Topic Models ────────────────────────────────────────────────────
class StudyTopic {
  final String id;
  final String quizCategoryId; // links to QuizCategory
  final String title;
  final String icon;
  final int color;
  final String difficulty; // 'Beginner' | 'Intermediate' | 'Advanced'
  final String summary;
  final String readingTime;
  final List<StudyLesson> lessons;

  const StudyTopic({
    required this.id,
    required this.quizCategoryId,
    required this.title,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.summary,
    required this.readingTime,
    required this.lessons,
  });
}

class StudyLesson {
  final String heading;
  final String body;

  const StudyLesson({required this.heading, required this.body});
}
