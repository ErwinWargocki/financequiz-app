import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/models.dart';

// ─── Theme ─────────────────────────────────────────────────────────────────────

/// Persisted ThemeMode. On first build returns [ThemeMode.dark] immediately,
/// then asynchronously reads `isDarkMode` from SharedPreferences and updates
/// state. [toggle()] flips the mode and persists the new value.
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.dark;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', next == ThemeMode.dark);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

// ─── Current User ──────────────────────────────────────────────────────────────

/// `userId` stored in SharedPreferences. `null` means not logged in.
/// Invalidate this provider after login/logout to refresh downstream providers.
final currentUserIdProvider = FutureProvider<int?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('userId');
});

/// The current [UserModel]. `null` if not logged in.
/// Depends on [currentUserIdProvider] — invalidating that also invalidates this.
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return null;
  return DatabaseHelper.instance.getUser(userId);
});

// ─── Quiz Results ──────────────────────────────────────────────────────────────

/// The 3 most recent [QuizResult]s for [userId].
/// Invalidate after a quiz completes to update home/activity widgets.
final recentResultsProvider =
    FutureProvider.family<List<QuizResult>, int>((ref, userId) async {
  return DatabaseHelper.instance.getRecentResults(userId, limit: 3);
});

/// Full quiz history for [userId], ordered most-recent first.
final quizHistoryProvider =
    FutureProvider.family<List<QuizResult>, int>((ref, userId) async {
  return DatabaseHelper.instance.getResultsByUser(userId);
});

// ─── Stats ─────────────────────────────────────────────────────────────────────

/// Aggregate stats for [userId]: `totalScore`, `avgScore`, `bestCategory`,
/// `totalTime`. Shape matches [DatabaseHelper.getUserStats].
final userStatsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, userId) async {
  return DatabaseHelper.instance.getUserStats(userId);
});

/// Daily quiz counts for the current ISO week (Mon=0 … Sun=6) for [userId].
/// Recomputed from the DB; invalidate after a quiz completes.
final weeklyResultsProvider =
    FutureProvider.family<List<int>, int>((ref, userId) async {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final weekStart = DateTime(monday.year, monday.month, monday.day);
  final results =
      await DatabaseHelper.instance.getResultsForWeek(userId, weekStart);
  final counts = List<int>.filled(7, 0);
  for (final r in results) {
    counts[r.completedAt.weekday - 1]++;
  }
  return counts;
});
