import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Determine initial route
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboardingDone') ?? false;

  runApp(FinQuizApp(showHome: onboardingDone));
}

class FinQuizApp extends StatelessWidget {
  final bool showHome;

  const FinQuizApp({super.key, required this.showHome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinQuiz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: showHome ? const MainShell() : const WelcomeScreen(),
    );
  }
}
