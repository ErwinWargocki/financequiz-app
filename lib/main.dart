import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId');
  final onboardingDone = prefs.getBool('onboardingDone') ?? false;
  final isDarkMode = prefs.getBool('isDarkMode') ?? true;

  runApp(FinQuizApp(
    isLoggedIn: userId != null,
    onboardingDone: onboardingDone,
    isDarkMode: isDarkMode,
  ));
}

class FinQuizApp extends StatefulWidget {
  final bool isLoggedIn;
  final bool onboardingDone;
  final bool isDarkMode;

  const FinQuizApp({
    super.key,
    required this.isLoggedIn,
    required this.onboardingDone,
    required this.isDarkMode,
  });

  static bool isDarkModeEnabled(BuildContext context) {
    final state = context.findAncestorStateOfType<_FinQuizAppState>();
    return state?.isDarkMode ?? true;
  }

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
    final nextMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setState(() => _themeMode = nextMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', nextMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinQuiz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: widget.isLoggedIn
          ? const MainShell()
          : WelcomeScreen(onboardingDone: widget.onboardingDone),
    );
  }
}
