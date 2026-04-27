import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/models.dart';

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
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);
