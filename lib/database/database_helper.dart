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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        avatarInitial TEXT NOT NULL,
        email TEXT,
        passwordHash TEXT,
        googleId TEXT,
        profileIconIndex INTEGER DEFAULT 0,
        totalScore INTEGER DEFAULT 0,
        quizzesCompleted INTEGER DEFAULT 0,
        currentStreak INTEGER DEFAULT 0,
        longestStreak INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

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

    await _seedQuestions(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN email TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN passwordHash TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN googleId TEXT');
      await db.execute(
          'ALTER TABLE users ADD COLUMN profileIconIndex INTEGER DEFAULT 0');

      // Seed extra questions added in v2
      await _seedExtraQuestionsV2(db);
    }
  }

  Future<void> _seedQuestions(Database db) async {
    for (final q in _baseQuestions()) {
      await db.insert('questions', q.toMap());
    }
    for (final q in _extraQuestionsV2()) {
      await db.insert('questions', q.toMap());
    }
  }

  Future<void> _seedExtraQuestionsV2(Database db) async {
    for (final q in _extraQuestionsV2()) {
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

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
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
    final totalTime = results.fold(0, (sum, r) => sum + r.timeTakenSeconds);
    return {
      'totalScore': totalScore,
      'avgScore': avgScore,
      'bestCategory': bestCategory,
      'totalTime': totalTime,
    };
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // ─── Seed Data (base v1) ───────────────────────────────────────────────
  List<QuizQuestion> _baseQuestions() {
    return const [
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
        question: 'What is "lifestyle creep" in personal finance?',
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
        question: 'What is a "sinking fund" in personal budgeting?',
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
        question: 'What is the "Rule of 72" used for in investing?',
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
        question: 'What does it mean to "consolidate" debt?',
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

  // ─── Extra Questions added in v2 ────────────────────────────────────────
  List<QuizQuestion> _extraQuestionsV2() {
    return const [
      // ── SAVINGS (extra) ───────────────────────────────────────────
      QuizQuestion(
        category: 'savings',
        question: 'What is a "Certificate of Deposit" (CD)?',
        options: [
          'A government bond with variable interest',
          'A time-deposit account that pays a fixed rate for a set term',
          'A type of stocks-and-shares ISA',
          'An insurance policy with cash value',
        ],
        correctIndex: 1,
        explanation:
            'A CD locks your money for a fixed period (e.g., 6 months, 1 year) in exchange for a guaranteed interest rate, usually higher than a regular savings account.',
        difficulty: 'medium',
      ),
      QuizQuestion(
        category: 'savings',
        question: 'What does "liquidity" mean when talking about savings?',
        options: [
          'How much interest your savings earn',
          'How quickly an asset can be converted to cash without losing value',
          'The total amount saved over a lifetime',
          'The interest rate offered by a bank',
        ],
        correctIndex: 1,
        explanation:
            'Liquidity refers to how easily and quickly you can access your money. A current account is highly liquid; a fixed-term CD is not.',
        difficulty: 'medium',
      ),
      QuizQuestion(
        category: 'savings',
        question: 'Why is it important to have savings separate from your current account?',
        options: [
          'To earn more credit card points',
          'To reduce the temptation to spend and keep savings growing',
          'Because banks require it by law',
          'To avoid paying taxes on income',
        ],
        correctIndex: 1,
        explanation:
            'Keeping savings in a separate account reduces the urge to dip into them and often earns better interest.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'savings',
        question: 'What is the "latte factor" concept in saving?',
        options: [
          'A caffeine-driven productivity hack',
          'Small daily expenses that add up to large amounts over time',
          'Investing in commodity stocks',
          'A method of compound interest calculation',
        ],
        correctIndex: 1,
        explanation:
            'The latte factor illustrates how small recurring expenses (e.g., a daily £4 coffee) can total thousands per year that could instead be saved.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'savings',
        question: 'What is the purpose of a "rainy day" fund vs an emergency fund?',
        options: [
          'They are the same thing',
          'A rainy day fund covers small, predictable expenses; an emergency fund covers large, unexpected ones',
          'A rainy day fund is invested; an emergency fund is not',
          'Rainy day funds are for businesses only',
        ],
        correctIndex: 1,
        explanation:
            'A rainy day fund (small buffer) handles minor surprises like a car service, while an emergency fund (3–6 months of expenses) covers major shocks like job loss.',
        difficulty: 'medium',
      ),

      // ── TAXES (extra) ─────────────────────────────────────────────
      QuizQuestion(
        category: 'taxes',
        question: 'What is income tax?',
        options: [
          'A tax on goods and services',
          'A tax levied on an individual\'s earnings',
          'A tax on company profits only',
          'A flat fee paid annually',
        ],
        correctIndex: 1,
        explanation:
            'Income tax is a percentage of earnings paid to the government. Most countries use a progressive system where higher earners pay a higher rate.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'taxes',
        question: 'What does "tax-exempt" mean?',
        options: [
          'You pay tax at a reduced rate',
          'Your income or asset is not subject to tax',
          'You defer tax to a later date',
          'The government refunds the tax you paid',
        ],
        correctIndex: 1,
        explanation:
            'Tax-exempt means the income or investment is completely excluded from taxation. For example, interest earned in an ISA is tax-exempt.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'taxes',
        question: 'What is VAT (Value Added Tax)?',
        options: [
          'A tax on personal savings',
          'A consumption tax added to the price of goods and services',
          'A corporate tax on profits',
          'An investment gain tax',
        ],
        correctIndex: 1,
        explanation:
            'VAT is an indirect consumption tax charged at each stage of production and ultimately paid by the end consumer.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'taxes',
        question: 'What is the purpose of a tax return?',
        options: [
          'To request a refund of all taxes paid',
          'To report income, calculate tax owed, and settle any over/underpayment',
          'To apply for tax-exempt status',
          'To notify the government of new employment',
        ],
        correctIndex: 1,
        explanation:
            'A tax return is a form submitted to HMRC (or equivalent) to declare income, claim allowances, and reconcile how much tax you owe or are owed back.',
        difficulty: 'medium',
      ),
      QuizQuestion(
        category: 'taxes',
        question: 'What is "tax avoidance" vs "tax evasion"?',
        options: [
          'Both are illegal',
          'Avoidance is legal tax minimisation; evasion is illegal non-payment',
          'Both are legal methods to reduce tax',
          'Evasion is legal; avoidance is not',
        ],
        correctIndex: 1,
        explanation:
            'Tax avoidance uses legal means (like ISAs, pensions) to reduce your bill. Tax evasion is deliberately hiding income or assets — it\'s a criminal offence.',
        difficulty: 'medium',
      ),

      // ── DEBT (extra) ──────────────────────────────────────────────
      QuizQuestion(
        category: 'debt',
        question: 'What is a credit score used for?',
        options: [
          'Tracking your savings history',
          'Assessing your creditworthiness for loans and credit',
          'Measuring your net worth',
          'Calculating your income tax band',
        ],
        correctIndex: 1,
        explanation:
            'A credit score is a numerical rating of how reliably you repay borrowed money. Higher scores unlock better interest rates and loan terms.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'debt',
        question: 'What is the difference between "good debt" and "bad debt"?',
        options: [
          'Good debt has lower interest; bad debt has higher interest',
          'Good debt generates value or income; bad debt funds depreciating consumption',
          'Good debt is government-issued; bad debt is private',
          'There is no meaningful difference',
        ],
        correctIndex: 1,
        explanation:
            'Good debt (e.g., a mortgage, student loan) can increase your earning potential or net worth. Bad debt (e.g., high-interest credit card for luxuries) costs money without building value.',
        difficulty: 'medium',
      ),
      QuizQuestion(
        category: 'debt',
        question: 'What happens if you only make minimum payments on a credit card?',
        options: [
          'You pay off debt faster than with full payments',
          'You pay much more in interest and take longer to clear the balance',
          'Your credit score improves significantly',
          'The remaining balance is forgiven after 12 months',
        ],
        correctIndex: 1,
        explanation:
            'Minimum payments barely cover interest charges. The principal balance reduces very slowly, leading to years of debt and significantly more total interest paid.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'debt',
        question: 'What is a "balance transfer" on a credit card?',
        options: [
          'Moving money from savings to pay a credit card',
          'Transferring existing debt to a new card, often with a 0% introductory rate',
          'Splitting a credit card limit between two users',
          'Paying off a loan with a credit card',
        ],
        correctIndex: 1,
        explanation:
            'A balance transfer moves your credit card debt to a new card that often offers 0% interest for an introductory period, saving you money if you pay it off in time.',
        difficulty: 'medium',
      ),

      // ── CRYPTO (extra) ─────────────────────────────────────────────
      QuizQuestion(
        category: 'crypto',
        question: 'What is Bitcoin\'s maximum supply?',
        options: [
          '100 million BTC',
          '21 million BTC',
          '1 billion BTC',
          'Unlimited',
        ],
        correctIndex: 1,
        explanation:
            'Bitcoin has a hard-coded maximum supply of 21 million coins, making it deflationary by design as demand grows against fixed supply.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'crypto',
        question: 'What is a "smart contract"?',
        options: [
          'A legal agreement between two crypto exchanges',
          'Self-executing code on a blockchain that enforces agreement terms automatically',
          'An AI-powered trading algorithm',
          'A regulatory compliance document',
        ],
        correctIndex: 1,
        explanation:
            'Smart contracts are programs stored on a blockchain that execute automatically when predefined conditions are met, removing the need for intermediaries.',
        difficulty: 'hard',
      ),
      QuizQuestion(
        category: 'crypto',
        question: 'What is "DeFi"?',
        options: [
          'Decentralised Finance — financial services on blockchain without traditional banks',
          'Default Finance — a government rescue scheme',
          'Defensive Finance — a low-risk investment strategy',
          'Digital Fiat — government digital currencies',
        ],
        correctIndex: 0,
        explanation:
            'DeFi (Decentralised Finance) uses blockchain and smart contracts to offer financial services like lending, borrowing, and trading without traditional intermediaries.',
        difficulty: 'hard',
      ),

      // ── INVESTING (extra) ──────────────────────────────────────────
      QuizQuestion(
        category: 'investing',
        question: 'What is a "bull market"?',
        options: [
          'A market with declining prices over a sustained period',
          'A market with rising prices over a sustained period',
          'A highly volatile market',
          'A market dominated by large-cap stocks',
        ],
        correctIndex: 1,
        explanation:
            'A bull market is a period of rising asset prices, generally defined as a 20%+ rise from a recent low, often accompanied by investor optimism.',
        difficulty: 'easy',
      ),
      QuizQuestion(
        category: 'investing',
        question: 'What does "asset allocation" mean?',
        options: [
          'Selecting individual stocks to buy',
          'Dividing an investment portfolio across asset classes like stocks, bonds, and cash',
          'Calculating the total value of your investments',
          'Timing the market for maximum gains',
        ],
        correctIndex: 1,
        explanation:
            'Asset allocation is the strategy of spreading investments across different asset types to balance risk and return based on your goals and timeline.',
        difficulty: 'medium',
      ),
    ];
  }
}
