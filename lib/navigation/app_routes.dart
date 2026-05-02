import '../models/models.dart';

abstract final class AppRoutes {
  static const welcome = '/welcome';
  static const home = '/home';
  static const study = '/study';
  static const categories = '/categories';
  static const quiz = '/quiz';
  static const studyTopics = '/study/topics';
}

class QuizArgs {
  final QuizCategory category;
  final int userId;
  const QuizArgs({required this.category, required this.userId});
}
