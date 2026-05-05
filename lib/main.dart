import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/app_providers.dart';
import 'theme/app_theme.dart';
import 'navigation/app_routes.dart';
import 'screens/intro/loading_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/main_shell.dart';
import 'screens/study/study_screen.dart';
import 'screens/study/study_topics_list_screen.dart';
import 'data/study_category_info.dart';
import 'screens/all_categories_screen.dart';
import 'screens/quiz/quiz_screen.dart';
import 'screens/result/result_screen.dart';

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
        AppRoutes.welcome:    (_) => const WelcomeScreen(),
        AppRoutes.home:       (_) => const MainShell(),
        AppRoutes.study:      (_) => const StudyScreen(),
        AppRoutes.categories: (_) => const AllCategoriesScreen(),
        AppRoutes.quiz: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as QuizArgs;
          return QuizScreen(category: args.category, userId: args.userId);
        },
        AppRoutes.studyTopics: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as StudyCategoryInfo;
          return StudyTopicsListScreen(category: args);
        },
        AppRoutes.result: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as ResultArgs;
          return ResultScreen(result: args.result, category: args.category, reviews: args.reviews);
        },
      },
    );
  }
}
