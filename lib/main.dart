// App entry point.
// Reads the user's theme preference from disk, then launches the app.
// The very first widget shown is SplashScreen — it handles the branded
// animation and then routes the user to either the main app or the
// login / register flow.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/intro/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation — the UI is designed for portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Read the saved theme so the app opens in the correct mode immediately
  final prefs     = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? true;

  runApp(FinQuizApp(isDarkMode: isDarkMode));
}

// Root widget.  Owns the ThemeMode so any descendant can toggle it by
// calling FinQuizApp.toggleThemeMode(context) without a state-management
// package — the state is found by walking up the widget tree.
class FinQuizApp extends StatefulWidget {
  final bool isDarkMode;

  const FinQuizApp({super.key, required this.isDarkMode});

  // Read the current dark-mode flag from the nearest FinQuizApp ancestor
  static bool isDarkModeEnabled(BuildContext context) {
    final state = context.findAncestorStateOfType<_FinQuizAppState>();
    return state?.isDarkMode ?? true;
  }

  // Toggle dark ↔ light and persist the choice to SharedPreferences
  static Future<void> toggleThemeMode(BuildContext context) async {
    final state = context.findAncestorStateOfType<_FinQuizAppState>();
    await state?.toggleTheme();
  }

  @override
  State<FinQuizApp> createState() => _FinQuizAppState();
}

class _FinQuizAppState extends State<FinQuizApp> {
  late ThemeMode _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final next = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setState(() => _themeMode = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', next == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinQuiz',
      debugShowCheckedModeBanner: false,
      theme:      AppTheme.lightTheme,
      darkTheme:  AppTheme.darkTheme,
      themeMode:  _themeMode,
      // LoadingScreen plays the branded intro, then routes to MainShell or WelcomeScreen
      home: const LoadingScreen(),
    );
  }
}
