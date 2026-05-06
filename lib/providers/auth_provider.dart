import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/models.dart';
import 'app_providers.dart';

// Manages the currently logged-in user.
// null  = not logged in
// UserModel = logged in
class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final prefs  = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return null;
    return DatabaseHelper.instance.getUser(userId);
  }

  // Called after a successful login or registration.
  // Persists the session and updates state so dependent providers rebuild.
  Future<void> login(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    state = AsyncData(await DatabaseHelper.instance.getUser(userId));
  }

  // Clears the session and signs the user out.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = const AsyncData(null);
  }

  // Re-fetches the user row from the DB (e.g. after score update).
  Future<void> refresh() async {
    final prefs  = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) {
      state = const AsyncData(null);
      return;
    }
    state = AsyncData(await DatabaseHelper.instance.getUser(userId));
  }

  // ── Auth lookup helpers (used by the welcome/password-reset flow) ───────────

  Future<UserModel?> getUserByEmail(String email) =>
      DatabaseHelper.instance.getUserByEmail(email);

  Future<UserModel?> getUserByUsername(String username) =>
      DatabaseHelper.instance.getUserByUsername(username);

  Future<List<Map<String, dynamic>>> getSecurityAnswers(int userId) =>
      DatabaseHelper.instance.getSecurityAnswers(userId);

  Future<void> updatePassword(int userId, String passwordHash) =>
      DatabaseHelper.instance.updateUserPassword(userId, passwordHash);

  // Creates the user row, saves security Q&As, then logs in — all in one call.
  Future<void> registerUser(
    UserModel newUser,
    List<int> questionIndices,
    List<String> answerHashes,
  ) async {
    final db     = DatabaseHelper.instance;
    final userId = await db.insertUser(newUser);
    await db.saveSecurityAnswers(userId, questionIndices, answerHashes);
    await login(userId);
  }

  // ── Quiz completion ──────────────────────────────────────────────────────────

  // Updates the profile icon, persists it, and invalidates currentUserProvider.
  Future<void> updateIcon(int userId, int iconIndex) async {
    final db = DatabaseHelper.instance;
    final user = await db.getUser(userId);
    if (user == null) return;
    final updated = user.copyWith(profileIconIndex: iconIndex);
    await db.updateUser(updated);
    state = AsyncData(updated);
    ref.invalidate(currentUserProvider);
  }

  // Persists the quiz result, updates user stats, and refreshes local state.
  Future<void> completeQuiz(QuizResult result) async {
    final db = DatabaseHelper.instance;
    await db.insertResult(result);
    final user = await db.getUser(result.userId);
    if (user == null) return;

    // Day-based streak: increment only on a new consecutive calendar day
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    int newStreak;
    if (user.lastStreakDate == null) {
      newStreak = 1;
    } else {
      final last = user.lastStreakDate!;
      final lastDate = DateTime(last.year, last.month, last.day);
      final diff = todayDate.difference(lastDate).inDays;
      if (diff == 0) {
        newStreak = user.currentStreak; // same day — no change
      } else if (diff == 1) {
        newStreak = user.currentStreak + 1; // consecutive day
      } else {
        newStreak = 1; // gap — reset
      }
    }

    // XP: 10 points per correct answer; level caps at 10
    final newXp = user.xpPoints + (result.correctAnswers * 10);
    final newLevel = ((newXp ~/ 200) + 1).clamp(1, 10);

    final updated = user.copyWith(
      totalScore: user.totalScore + result.score,
      quizzesCompleted: user.quizzesCompleted + 1,
      currentStreak: newStreak,
      longestStreak: newStreak > user.longestStreak ? newStreak : user.longestStreak,
      lastStreakDate: todayDate,
      xpPoints: newXp,
      level: newLevel,
    );

    await db.updateUser(updated);
    await db.upsertCategoryBest(
        result.userId, result.category, result.score, result.percentage);
    state = AsyncData(updated);
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
