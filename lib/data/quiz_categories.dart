import '../models/models.dart';

class QuizCategories {
  static const List<QuizCategory> all = [
    QuizCategory(
      id: 'budgeting',
      name: 'Budgeting',
      icon: '💰',
      description: 'Master your monthly money flow',
      color: 0xFF4C6EF5,
      totalQuestions: 8,
      difficulty: 'Beginner',
    ),
    QuizCategory(
      id: 'investing',
      name: 'Investing',
      icon: '📈',
      description: 'Grow wealth through markets',
      color: 0xFF00E5A0,
      totalQuestions: 8,
      difficulty: 'Intermediate',
    ),
    QuizCategory(
      id: 'crypto',
      name: 'Crypto',
      icon: '₿',
      description: 'Navigate digital assets',
      color: 0xFFFF6B35,
      totalQuestions: 5,
      difficulty: 'Advanced',
    ),
    QuizCategory(
      id: 'savings',
      name: 'Savings',
      icon: '🏦',
      description: 'Build your financial safety net',
      color: 0xFFFFB800,
      totalQuestions: 3,
      difficulty: 'Beginner',
    ),
    QuizCategory(
      id: 'taxes',
      name: 'Taxes',
      icon: '📋',
      description: 'Understand your obligations',
      color: 0xFFB47FFF,
      totalQuestions: 3,
      difficulty: 'Intermediate',
    ),
    QuizCategory(
      id: 'debt',
      name: 'Debt',
      icon: '⚖️',
      description: 'Strategies to become debt-free',
      color: 0xFFFF4757,
      totalQuestions: 4,
      difficulty: 'Intermediate',
    ),
  ];
}
