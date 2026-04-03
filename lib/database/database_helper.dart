import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finquiz.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        avatarInitial TEXT NOT NULL,
        totalScore INTEGER DEFAULT 0,
        quizzesCompleted INTEGER DEFAULT 0,
        currentStreak INTEGER DEFAULT 0,
        longestStreak INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Questions table
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        question TEXT NOT NULL,
        option0 TEXT NOT NULL,
        option1 TEXT NOT NULL,
        option2 TEXT NOT NULL,
        option3 TEXT NOT NULL,
        correctIndex INTEGER NOT NULL,
        explanation TEXT NOT NULL,
        difficulty TEXT NOT NULL
      )
    ''');

    // Results table
    await db.execute('''
      CREATE TABLE results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        category TEXT NOT NULL,
        score INTEGER NOT NULL,
        totalQuestions INTEGER NOT NULL,
        correctAnswers INTEGER NOT NULL,
        timeTakenSeconds INTEGER NOT NULL,
        completedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Seed questions
    await _seedQuestions(db);
  }

  Future<void> _seedQuestions(Database db) async {
    final questions = _getInitialQuestions();
    for (final q in questions) {
      await db.insert('questions', q.toMap());
    }
  }

  // ─── User CRUD ─────────────────────────────────────────────────────────
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> getUser(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final db = await database;
    final maps =
        await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ─── Questions CRUD ────────────────────────────────────────────────────
  Future<List<QuizQuestion>> getQuestionsByCategory(String category,
      {int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'questions',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'RANDOM()',
      limit: limit,
    );
    return maps.map((m) => QuizQuestion.fromMap(m)).toList();
  }

  Future<List<QuizQuestion>> getAllQuestions() async {
    final db = await database;
    final maps = await db.query('questions');
    return maps.map((m) => QuizQuestion.fromMap(m)).toList();
  }

  // ─── Results CRUD ──────────────────────────────────────────────────────
  Future<int> insertResult(QuizResult result) async {
    final db = await database;
    return await db.insert('results', result.toMap());
  }

  Future<List<QuizResult>> getResultsByUser(int userId) async {
    final db = await database;
    final maps = await db.query(
      'results',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'completedAt DESC',
    );
    return maps.map((m) => QuizResult.fromMap(m)).toList();
  }

  Future<List<QuizResult>> getRecentResults(int userId,
      {int limit = 5}) async {
    final db = await database;
    final maps = await db.query(
      'results',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'completedAt DESC',
      limit: limit,
    );
    return maps.map((m) => QuizResult.fromMap(m)).toList();
  }

  Future<Map<String, dynamic>> getUserStats(int userId) async {
    final results = await getResultsByUser(userId);
    if (results.isEmpty) {
      return {
        'totalScore': 0,
        'avgScore': 0.0,
        'bestCategory': 'N/A',
        'totalTime': 0,
      };
    }
    final totalScore = results.fold(0, (sum, r) => sum + r.score);
    final avgScore = results.map((r) => r.percentage).reduce((a, b) => a + b) /
        results.length;
    final categoryCount = <String, int>{};
    for (final r in results) {
      categoryCount[r.category] = (categoryCount[r.category] ?? 0) + 1;
    }
    final bestCategory =
        categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final totalTime =
        results.fold(0, (sum, r) => sum + r.timeTakenSeconds);
    return {
      'totalScore': totalScore,
      'avgScore': avgScore,
      'bestCategory': bestCategory,
      'totalTime': totalTime,
    };
  }

  // ─── Seed Data ─────────────────────────────────────────────────────────
  List<QuizQuestion> _getInitialQuestions() {
    return [
      // ── BUDGETING ──────────────────────────────────────────────────
      QuizQuestion(
        category: 'budgeting',
        question: 'What is the 50/30/20 budgeting rule?',
        options: [
          '50% wants, 30% needs, 20% savings',
          '50% needs, 30% wants, 20% savings',
          '50% savings, 30% needs, 20% wants',
          '50% investments, 30% needs, 20% fun',
        ],
        correctIndex: 1,
        explanation:
            'The 50/30/20 rule allocates 50% of after-tax income to needs, 30% to wants, and 20% to savings or debt repayment.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'budgeting',
        question: 'Which budgeting method assigns every dollar a specific job?',
        options: [
          'Envelope budgeting',
          'Zero-based budgeting',
          'Pay-yourself-first',
          'Percentage budgeting',
        ],
        correctIndex: 1,
        explanation:
            'Zero-based budgeting means income minus all expenses equals zero — every dollar is assigned a purpose.',
        difficulty: 'medium',
      ),
      QuizQuestion(
        category: 'budgeting',
        question:
            'An emergency fund should ideally cover how many months of expenses?',
        options: ['1–2 months', '3–6 months', '8–10 months', '12+ months'],
        correctIndex: 1,
        explanation:
            'Financial experts recommend 3–6 months of living expenses in an easily accessible emergency fund.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'budgeting',
        question:
            'What is "lifestyle creep" in personal finance?',
        options: [
          'Investing more as income rises',
          'Spending increasing as income grows',
          'Reducing expenses gradually',
          'Diversifying spending categories',
        ],
        correctIndex: 1,
        explanation:
            'Lifestyle creep (or lifestyle inflation) occurs when spending increases alongside income, preventing wealth accumulation.',
        difficulty: 'medium',
      ),
      QuizQuestion(
        category: 'budgeting',
        question: 'What does "paying yourself first" mean?',
        options: [
          'Buying luxury items before bills',
          'Saving before spending on other things',
          'Paying off all debt first',
          'Earning income from multiple sources',
        ],
        correctIndex: 1,
        explanation:
            'Paying yourself first means automatically saving or investing a portion of income before spending on anything else.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'budgeting',
        question: 'What is the envelope budgeting system?',
        options: [
          'Mailing bills to creditors',
          'Allocating cash in physical or digital envelopes per category',
          'A tax deduction strategy',
          'Automatic bill payment setup',
        ],
        correctIndex: 1,
        explanation:
            'Envelope budgeting divides cash into envelopes for each spending category. When the envelope is empty, spending stops.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'budgeting',
        question: 'Which of these is a "fixed" expense?',
        options: [
          'Groceries',
          'Entertainment',
          'Monthly rent',
          'Dining out',
        ],
        correctIndex: 2,
        explanation:
            'Fixed expenses remain constant each month, like rent or a car payment. Variable expenses like groceries fluctuate.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'budgeting',
        question:
            'What is a "sinking fund" in personal budgeting?',
        options: [
          'A fund for risky investments',
          'Saving gradually for a known future expense',
          'An emergency overdraft account',
          'A retirement account type',
        ],
        correctIndex: 1,
        explanation:
            'A sinking fund is money set aside regularly for a predictable future expense, like a holiday or car repair.',
        difficulty: 'medium',
      ),

      // ── INVESTING ─────────────────────────────────────────────────
      QuizQuestion(
        category: 'investing',
        question: 'What does "diversification" mean in investing?',
        options: [
          'Investing all money in the best-performing stock',
          'Spreading investments to reduce risk',
          'Only buying government bonds',
          'Changing your portfolio every day',
        ],
        correctIndex: 1,
        explanation:
            'Diversification spreads investments across different assets, sectors, or geographies to reduce the impact of any single loss.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'investing',
        question: 'What is compound interest often called?',
        options: [
          'The silent killer',
          'The eighth wonder of the world',
          'The golden rule',
          'The prime multiplier',
        ],
        correctIndex: 1,
        explanation:
            'Albert Einstein (apocryphally) called compound interest "the eighth wonder of the world" — earning returns on returns.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'investing',
        question: 'What is a P/E ratio used for?',
        options: [
          'Measuring inflation rate',
          'Valuing a stock relative to earnings',
          'Calculating bond yields',
          'Tracking dividend history',
        ],
        correctIndex: 1,
        explanation:
            'Price-to-Earnings (P/E) ratio measures a company\'s current share price relative to its earnings per share.',
        difficulty: 'medium',
      ),
      QuizQuestion(
        category: 'investing',
        question:
            'What type of fund tracks a market index like the S&P 500?',
        options: [
          'Hedge fund',
          'Index fund',
          'Money market fund',
          'Venture fund',
        ],
        correctIndex: 1,
        explanation:
            'An index fund passively tracks a market index, offering broad market exposure with low fees.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'investing',
        question: 'What is "dollar-cost averaging"?',
        options: [
          'Buying only when prices are at their lowest',
          'Investing a fixed amount at regular intervals regardless of price',
          'Converting currency at the best exchange rate',
          'Averaging dividend payments over the year',
        ],
        correctIndex: 1,
        explanation:
            'DCA involves investing a fixed amount regularly regardless of market conditions, reducing the impact of volatility.',
        difficulty: 'medium',
      ),
      QuizQuestion(
        category: 'investing',
        question: 'What does ETF stand for?',
        options: [
          'Equity Transfer Fund',
          'Exchange-Traded Fund',
          'Extended Term Finance',
          'Earnings to Float',
        ],
        correctIndex: 1,
        explanation:
            'An Exchange-Traded Fund (ETF) is a basket of securities traded on a stock exchange, combining features of stocks and funds.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'investing',
        question:
            'What is the "Rule of 72" used for in investing?',
        options: [
          'Calculating tax on capital gains',
          'Estimating how long money takes to double at a given interest rate',
          'Determining safe withdrawal rates',
          'Measuring portfolio volatility',
        ],
        correctIndex: 1,
        explanation:
            'Divide 72 by the annual interest rate to estimate the years needed for an investment to double (e.g., 72 ÷ 8% = 9 years).',
        difficulty: 'medium',
      ),
      QuizQuestion(
        category: 'investing',
        question: 'What is a dividend?',
        options: [
          'A fee charged by brokers',
          'A portion of company profits paid to shareholders',
          'A type of bond payment',
          'An investment loss deduction',
        ],
        correctIndex: 1,
        explanation:
            'A dividend is a distribution of a company\'s earnings to its shareholders, usually paid quarterly.',
        difficulty: 'easy',
      ),

      // ── CRYPTO ────────────────────────────────────────────────────
      QuizQuestion(
        category: 'crypto',
        question: 'What technology underpins most cryptocurrencies?',
        options: ['Cloud computing', 'Blockchain', 'AI networks', 'SWIFT'],
        correctIndex: 1,
        explanation:
            'Blockchain is a distributed ledger technology that records transactions across a network of computers.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'crypto',
        question: 'What does "HODL" mean in crypto culture?',
        options: [
          'Highest Open Daily Limit',
          'Hold on for dear life (holding instead of selling)',
          'High-Output Digital Ledger',
          'Hashing Optimized Data Layer',
        ],
        correctIndex: 1,
        explanation:
            'HODL originated from a misspelled forum post and evolved to mean "hold on for dear life" — not selling during volatility.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'crypto',
        question: 'What is a "crypto wallet" used for?',
        options: [
          'Physically storing crypto coins',
          'Storing private keys to access cryptocurrency',
          'Mining new coins',
          'Converting crypto to fiat currency',
        ],
        correctIndex: 1,
        explanation:
            'A crypto wallet stores private keys that prove ownership and allow you to send/receive cryptocurrencies.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'crypto',
        question: 'What is "proof of work" in blockchain?',
        options: [
          'A contract between miners and exchanges',
          'A consensus mechanism requiring computational effort to validate transactions',
          'An audit trail for transactions',
          'A type of smart contract',
        ],
        correctIndex: 1,
        explanation:
            'Proof of Work (PoW) requires miners to solve complex mathematical puzzles to validate transactions and create new blocks.',
        difficulty: 'hard',
      ),
      QuizQuestion(
        category: 'crypto',
        question: 'What is a "stablecoin"?',
        options: [
          'A cryptocurrency with locked trading hours',
          'A crypto pegged to a stable asset like the US dollar',
          'Bitcoin during low volatility periods',
          'A government-regulated digital currency',
        ],
        correctIndex: 1,
        explanation:
            'A stablecoin maintains a stable value by being pegged to a real-world asset like USD (e.g., USDC, Tether).',
        difficulty: 'medium',
      ),

      // ── SAVINGS ───────────────────────────────────────────────────
      QuizQuestion(
        category: 'savings',
        question: 'What is an ISA in the UK?',
        options: [
          'International Savings Account',
          'Individual Savings Account — a tax-free savings wrapper',
          'Inflation-Secured Asset',
          'Investment Shares Agreement',
        ],
        correctIndex: 1,
        explanation:
            'An ISA (Individual Savings Account) lets UK residents save or invest up to £20,000/year tax-free.',
        difficulty: 'medium',
      ),
      QuizQuestion(
        category: 'savings',
        question: 'What is the main benefit of a high-yield savings account?',
        options: [
          'Access to stock markets',
          'Higher interest rates than traditional savings accounts',
          'No withdrawal limits',
          'Government-backed returns',
        ],
        correctIndex: 1,
        explanation:
            'High-yield savings accounts offer significantly higher APY than regular savings accounts, helping your money grow faster.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'savings',
        question: 'What does APY stand for?',
        options: [
          'Annual Percentage Yield',
          'Average Profit Yearly',
          'Adjusted Portfolio Yield',
          'Annual Payment Year',
        ],
        correctIndex: 0,
        explanation:
            'APY (Annual Percentage Yield) accounts for compound interest, giving a more accurate picture of yearly returns.',
        difficulty: 'easy',
      ),

      // ── TAXES ─────────────────────────────────────────────────────
      QuizQuestion(
        category: 'taxes',
        question: 'What is a tax deduction?',
        options: [
          'A refund from the government',
          'An amount reducing your taxable income',
          'A penalty for late filing',
          'A type of tax credit',
        ],
        correctIndex: 1,
        explanation:
            'A tax deduction reduces your taxable income, lowering the overall amount of tax you owe.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'taxes',
        question: 'What is capital gains tax?',
        options: [
          'Tax on your annual salary',
          'Tax on profits made from selling assets',
          'Tax on dividends only',
          'A surcharge on high earners',
        ],
        correctIndex: 1,
        explanation:
            'Capital gains tax is levied on the profit from the sale of an asset like shares, property, or crypto.',
        difficulty: 'medium',
      ),
      QuizQuestion(
        category: 'taxes',
        question: 'What is a tax credit vs a tax deduction?',
        options: [
          'Both reduce taxable income equally',
          'A credit reduces your tax bill directly; a deduction reduces taxable income',
          'A deduction gives a refund; a credit does not',
          'They are the same thing',
        ],
        correctIndex: 1,
        explanation:
            'A tax credit is a direct reduction of your tax owed (pound for pound), while a deduction reduces the income that is taxed.',
        difficulty: 'medium',
      ),

      // ── DEBT ──────────────────────────────────────────────────────
      QuizQuestion(
        category: 'debt',
        question: 'What is the "debt avalanche" method?',
        options: [
          'Paying minimum on all debts equally',
          'Paying off highest-interest debt first',
          'Paying off smallest balance first',
          'Consolidating all debts into one',
        ],
        correctIndex: 1,
        explanation:
            'The debt avalanche method targets the highest-interest debt first, minimizing total interest paid over time.',
        difficulty: 'medium',
      ),
      QuizQuestion(
        category: 'debt',
        question: 'What is the "debt snowball" method?',
        options: [
          'Investing while in debt',
          'Paying off smallest debt balances first for motivation',
          'Transferring debt to 0% cards',
          'Paying maximum on all debts at once',
        ],
        correctIndex: 1,
        explanation:
            'The debt snowball method pays off the smallest debts first, building momentum and psychological wins.',
        difficulty: 'medium',
      ),
      QuizQuestion(
        category: 'debt',
        question: 'What is a "debt-to-income" (DTI) ratio?',
        options: [
          'Monthly income divided by total debt',
          'Monthly debt payments divided by gross monthly income',
          'Total assets minus total liabilities',
          'Annual expenses over annual income',
        ],
        correctIndex: 1,
        explanation:
            'DTI ratio is your monthly debt payments divided by gross monthly income. Lenders use it to assess borrowing risk.',
        difficulty: 'hard',
      ),
      QuizQuestion(
        category: 'debt',
        question:
            'What does it mean to "consolidate" debt?',
        options: [
          'Declare bankruptcy',
          'Combine multiple debts into one loan, ideally at a lower interest rate',
          'Pay only minimum balances',
          'Transfer debt to family members',
        ],
        correctIndex: 1,
        explanation:
            'Debt consolidation combines multiple debts into a single loan, often with a lower interest rate, simplifying repayment.',
        difficulty: 'easy',
      ),
    ];
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
