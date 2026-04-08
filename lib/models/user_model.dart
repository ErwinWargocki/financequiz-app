// ─── Profile Icon Catalogue ────────────────────────────────────────────────────
// 20 animal/symbol emojis the user can pick as their profile picture.
// Stored as an integer index so the DB never has to deal with emoji encoding.
class ProfileIcons {
  static const List<String> all = [
    '🦁', '🐯', '🦊', '🐺', '🦝',
    '🐼', '🐨', '🦄', '🦋', '🐬',
    '🦅', '🦉', '🦚', '🐲', '🦈',
    '🚀', '⚡', '🔥', '💎', '🌟',
  ];

  // Returns the emoji at [index], falling back to the lion if out of range.
  static String get(int index) {
    if (index < 0 || index >= all.length) return '🦁';
    return all[index];
  }
}

// ─── User Model ────────────────────────────────────────────────────────────────
// Represents a registered user stored in the local SQLite 'users' table.
// Mutable fields (score, streak, icon) are updated after quizzes complete.
class UserModel {
  final int? id;
  final String name;
  final String username;
  final String avatarInitial;
  final String? email;
  final String? passwordHash;  // SHA-256 hex digest; never plain text
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

  // Convenience getter — resolves the stored index to the emoji string
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
