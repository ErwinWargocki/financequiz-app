import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/app_providers.dart';
import 'theme/app_theme.dart';
import 'screens/intro/loading_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/main_shell.dart';
import 'screens/study/study_screen.dart';
import 'screens/all_categories_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: FinQuizApp()));
}

class FinQuizApp extends ConsumerWidget {
  const FinQuizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'FinQuiz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const LoadingScreen(),
      routes: {
        '/welcome':    (_) => const WelcomeScreen(),
        '/home':       (_) => const MainShell(),
        '/study':      (_) => const StudyScreen(),
        '/categories': (_) => const AllCategoriesScreen(),
      },
    );
  }
}
