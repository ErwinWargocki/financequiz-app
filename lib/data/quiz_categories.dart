import '../models/models.dart';

class QuizCategories {
  static const List<QuizCategory> all = [
    QuizCategory(
      id: 'budgeting',
      name: 'Personal Finance',
      icon: '💰',
      description: 'Budgets, savings habits, and money management',
      color: 0xFF4C6EF5,
      totalQuestions: 8,
      difficulty: 'Beginner',
    ),
    QuizCategory(
      id: 'investing',
      name: 'Investing',
      icon: '📈',
      description: 'Grow wealth through markets and smart strategies',
      color: 0xFF00E5A0,
      totalQuestions: 10,
      difficulty: 'Intermediate',
    ),
    QuizCategory(
      id: 'crypto',
      name: 'Bitcoin & Crypto',
      icon: '₿',
      description: 'Navigate digital assets and blockchain technology',
      color: 0xFFFF6B35,
      totalQuestions: 8,
      difficulty: 'Advanced',
    ),
    QuizCategory(
      id: 'savings',
      name: 'Savings Strategies',
      icon: '🏦',
      description: 'Build your financial safety net faster',
      color: 0xFFFFB800,
      totalQuestions: 8,
      difficulty: 'Beginner',
    ),
    QuizCategory(
      id: 'taxes',
      name: 'Taxes',
      icon: '📋',
      description: 'Understand obligations and save legally',
      color: 0xFFB47FFF,
      totalQuestions: 8,
      difficulty: 'Intermediate',
    ),
    QuizCategory(
      id: 'debt',
      name: 'Debt Management',
      icon: '⚖️',
      description: 'Strategies to become debt-free faster',
      color: 0xFFFF4757,
      totalQuestions: 8,
      difficulty: 'Intermediate',
    ),
  ];
}
