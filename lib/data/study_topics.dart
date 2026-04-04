import '../models/models.dart';

class StudyTopics {
  static const List<StudyTopic> all = [
    // ── BUDGETING / PERSONAL FINANCE ────────────────────────────────────
    StudyTopic(
      id: 'budgeting_basics',
      quizCategoryId: 'budgeting',
      title: 'Budgeting Basics',
      icon: '💰',
      color: 0xFF4C6EF5,
      difficulty: 'Beginner',
      summary:
          'Learn how to take control of your money by creating a budget that actually works for your lifestyle.',
      readingTime: '4 min',
      lessons: [
        StudyLesson(
          heading: 'What is a budget?',
          body:
              'A budget is a plan that allocates your income across expenses, savings, and goals. It gives every pound a purpose before you spend it, preventing overspending and building financial awareness.',
        ),
        StudyLesson(
          heading: 'The 50/30/20 Rule',
          body:
              'Allocate 50% of after-tax income to needs (rent, groceries, bills), 30% to wants (dining, hobbies, subscriptions), and 20% to savings or debt repayment. It\'s a simple starting framework that works for most people.',
        ),
        StudyLesson(
          heading: 'Fixed vs Variable Expenses',
          body:
              'Fixed expenses (rent, loan payments) stay constant each month. Variable expenses (groceries, entertainment) fluctuate. Knowing which is which helps you find areas to cut when needed.',
        ),
        StudyLesson(
          heading: 'Zero-Based Budgeting',
          body:
              'Every pound of income is assigned a job — income minus all allocations equals zero. This doesn\'t mean spending everything; savings and investments count as allocations too.',
        ),
        StudyLesson(
          heading: 'Envelope Method',
          body:
              'Divide spending money into categories (food, transport, fun). When an envelope is empty, spending in that category stops. Works with cash physically or with digital budgeting apps.',
        ),
      ],
    ),

    StudyTopic(
      id: 'emergency_fund',
      quizCategoryId: 'budgeting',
      title: 'Emergency Fund & Safety Net',
      icon: '🛡️',
      color: 0xFF4C6EF5,
      difficulty: 'Beginner',
      summary:
          'Build a financial cushion that protects you from life\'s unexpected events without going into debt.',
      readingTime: '3 min',
      lessons: [
        StudyLesson(
          heading: 'Why you need an emergency fund',
          body:
              'Without savings, any unexpected expense — car repair, medical bill, job loss — forces you into debt. An emergency fund breaks this cycle and gives you breathing room.',
        ),
        StudyLesson(
          heading: 'How much to save',
          body:
              'Aim for 3–6 months of essential living expenses. If your income is variable or your job is insecure, lean toward 6 months. Start small — even £500 prevents many minor crises.',
        ),
        StudyLesson(
          heading: 'Where to keep it',
          body:
              'Keep it in an easy-access savings account separate from your current account. You want it liquid (accessible quickly) but not so easy to reach that you\'re tempted to dip in.',
        ),
        StudyLesson(
          heading: 'Rainy day fund vs emergency fund',
          body:
              'A rainy day fund (£200–500) handles small, predictable surprises like a phone screen repair. An emergency fund (3–6 months) covers major shocks. Build both, separately.',
        ),
      ],
    ),

    // ── INVESTING ───────────────────────────────────────────────────────
    StudyTopic(
      id: 'investing_intro',
      quizCategoryId: 'investing',
      title: 'Introduction to Investing',
      icon: '📈',
      color: 0xFF00E5A0,
      difficulty: 'Intermediate',
      summary:
          'Understand how investing works, why it beats saving alone, and the core concepts every new investor needs.',
      readingTime: '5 min',
      lessons: [
        StudyLesson(
          heading: 'Why invest?',
          body:
              'Savings accounts often pay less than inflation, meaning your money loses purchasing power over time. Investing in assets that grow (stocks, funds, property) lets your money outpace inflation and compound over decades.',
        ),
        StudyLesson(
          heading: 'Compound interest — the eighth wonder',
          body:
              'Compound interest means earning returns on your returns. £10,000 at 8% annually becomes ~£21,600 in 10 years, ~£46,600 in 20 years. Time in the market is more important than timing the market.',
        ),
        StudyLesson(
          heading: 'Risk and return',
          body:
              'Higher potential returns come with higher risk. Cash is low-risk/low-return. Index funds are moderate risk/moderate-high return over long periods. Individual stocks can be volatile. Match your risk tolerance to your timeline.',
        ),
        StudyLesson(
          heading: 'Diversification',
          body:
              'Never put all your eggs in one basket. Spreading investments across sectors, geographies, and asset classes (stocks, bonds, property) reduces the damage any single loss can cause to your portfolio.',
        ),
        StudyLesson(
          heading: 'Index funds & ETFs',
          body:
              'Index funds passively track a market index (like the S&P 500 or FTSE 100), giving you exposure to hundreds of companies in one investment. Low fees and broad diversification make them ideal for most investors.',
        ),
      ],
    ),

    StudyTopic(
      id: 'investing_strategies',
      quizCategoryId: 'investing',
      title: 'Investment Strategies',
      icon: '🧠',
      color: 0xFF00E5A0,
      difficulty: 'Advanced',
      summary:
          'Explore proven strategies — from dollar-cost averaging to asset allocation — used by experienced investors.',
      readingTime: '5 min',
      lessons: [
        StudyLesson(
          heading: 'Dollar-Cost Averaging (DCA)',
          body:
              'Invest a fixed amount at regular intervals (e.g., £200/month) regardless of market conditions. When prices are low you buy more units; when high, fewer. Removes the stress of trying to time the market.',
        ),
        StudyLesson(
          heading: 'Asset allocation',
          body:
              'Distribute your portfolio across asset classes: stocks (high growth, high risk), bonds (lower growth, lower risk), cash, and alternatives. A common rule: subtract your age from 110 to get your stock percentage.',
        ),
        StudyLesson(
          heading: 'Rebalancing',
          body:
              'Over time your portfolio drifts as different assets grow at different rates. Rebalancing (selling overweight assets, buying underweight ones) returns it to your target allocation, forcing you to buy low and sell high.',
        ),
        StudyLesson(
          heading: 'The Rule of 72',
          body:
              'Divide 72 by your annual return rate to estimate how many years your money takes to double. At 6% it takes 12 years; at 9%, 8 years. A quick mental tool for comparing investment options.',
        ),
        StudyLesson(
          heading: 'Tax-efficient investing',
          body:
              'Use tax wrappers like a Stocks & Shares ISA (UK) to invest up to £20,000/year with zero tax on gains or dividends. Pension contributions get tax relief on the way in. Always use these before taxable accounts.',
        ),
      ],
    ),

    // ── BITCOIN / CRYPTO ────────────────────────────────────────────────
    StudyTopic(
      id: 'bitcoin_intro',
      quizCategoryId: 'crypto',
      title: 'Bitcoin & Crypto Fundamentals',
      icon: '₿',
      color: 0xFFFF6B35,
      difficulty: 'Beginner',
      summary:
          'Understand what Bitcoin and cryptocurrencies are, how blockchain works, and the key concepts every beginner needs.',
      readingTime: '5 min',
      lessons: [
        StudyLesson(
          heading: 'What is Bitcoin?',
          body:
              'Bitcoin (BTC) is a decentralised digital currency created in 2009 by Satoshi Nakamoto. It allows peer-to-peer transactions without a central authority (like a bank) and has a fixed maximum supply of 21 million coins.',
        ),
        StudyLesson(
          heading: 'Blockchain technology',
          body:
              'A blockchain is a distributed ledger — a chain of transaction records (blocks) stored across thousands of computers simultaneously. This makes it transparent, tamper-resistant, and eliminates the need for a trusted intermediary.',
        ),
        StudyLesson(
          heading: 'Crypto wallets',
          body:
              'A crypto wallet stores your private keys — the cryptographic proof of ownership. "Not your keys, not your coins" is the guiding principle. Hardware wallets (offline) are the most secure; exchange wallets are convenient but carry counterparty risk.',
        ),
        StudyLesson(
          heading: 'Volatility and risk',
          body:
              'Bitcoin has seen 80%+ price drops ("crypto winters") and 10x rises in short periods. Only invest what you can afford to lose entirely. Volatility decreases over longer time horizons, but remains far higher than traditional assets.',
        ),
        StudyLesson(
          heading: 'HODL and long-term thinking',
          body:
              'HODL (hold on for dear life) describes the strategy of not panic-selling during market downturns. Historically, long-term holders have been rewarded, but past performance does not guarantee future results.',
        ),
      ],
    ),

    StudyTopic(
      id: 'crypto_advanced',
      quizCategoryId: 'crypto',
      title: 'DeFi, Smart Contracts & Web3',
      icon: '⛓️',
      color: 0xFFFF6B35,
      difficulty: 'Advanced',
      summary:
          'Explore the world beyond Bitcoin — from smart contracts and DeFi protocols to NFTs and stablecoins.',
      readingTime: '6 min',
      lessons: [
        StudyLesson(
          heading: 'Smart contracts',
          body:
              'Smart contracts are self-executing programs stored on a blockchain that run automatically when conditions are met. For example, releasing payment once goods are confirmed delivered — no intermediary needed.',
        ),
        StudyLesson(
          heading: 'Decentralised Finance (DeFi)',
          body:
              'DeFi recreates traditional financial services (lending, borrowing, trading) using blockchain and smart contracts. Users interact directly with protocols rather than banks. High yield potential, but also high risk of hacks and exploits.',
        ),
        StudyLesson(
          heading: 'Stablecoins',
          body:
              'Stablecoins (USDC, USDT, DAI) are cryptocurrencies pegged to a stable asset like the US dollar. They combine blockchain efficiency with price stability, making them useful for trading and DeFi without crypto volatility.',
        ),
        StudyLesson(
          heading: 'Proof of Work vs Proof of Stake',
          body:
              'Bitcoin uses Proof of Work (miners solve puzzles = energy-intensive). Ethereum switched to Proof of Stake (validators lock up crypto as collateral = far less energy). Both are consensus mechanisms to validate transactions.',
        ),
        StudyLesson(
          heading: 'Risks in crypto',
          body:
              'Smart contract bugs, exchange hacks, regulatory changes, and rug pulls (developers abandoning projects) are real risks. Due diligence, diversification, and using hardware wallets are essential risk management tools.',
        ),
      ],
    ),

    // ── SAVINGS STRATEGIES ──────────────────────────────────────────────
    StudyTopic(
      id: 'savings_strategies',
      quizCategoryId: 'savings',
      title: 'Savings Strategies',
      icon: '🏦',
      color: 0xFFFFB800,
      difficulty: 'Beginner',
      summary:
          'Discover proven strategies to build savings faster, make your money work harder, and create lasting habits.',
      readingTime: '4 min',
      lessons: [
        StudyLesson(
          heading: 'Pay yourself first',
          body:
              'Automate a transfer to savings the moment your salary arrives — before you pay bills or spend anything. What you don\'t see, you don\'t spend. Even 10% of income makes a significant difference compounded over years.',
        ),
        StudyLesson(
          heading: 'High-yield savings accounts',
          body:
              'Regular savings accounts often pay near-zero interest. High-yield accounts (or cash ISAs) pay significantly more. The difference of even 2–3% extra APY on £10,000 is £200–300 per year in free money.',
        ),
        StudyLesson(
          heading: 'Sinking funds',
          body:
              'Instead of letting large annual expenses surprise you, divide them by 12 and save monthly. £1,200 for car insurance = £100/month saved. Sinking funds prevent "budget emergencies" for expenses that were predictable.',
        ),
        StudyLesson(
          heading: 'The latte factor',
          body:
              'Small recurring expenses compound dramatically. A daily £4.50 coffee adds up to £1,642/year. Redirected into a 5% savings account for 10 years = over £20,000. Small cuts, invested consistently, build significant wealth.',
        ),
        StudyLesson(
          heading: 'Savings rate matters most',
          body:
              'Your savings rate (% of income saved) is the single biggest predictor of financial independence. A 20% rate is good; 30–50% allows early financial freedom. Increasing income while maintaining expenses is the fastest path.',
        ),
      ],
    ),

    // ── TAXES ────────────────────────────────────────────────────────────
    StudyTopic(
      id: 'tax_basics',
      quizCategoryId: 'taxes',
      title: 'Tax Fundamentals',
      icon: '📋',
      color: 0xFFB47FFF,
      difficulty: 'Intermediate',
      summary:
          'Understand how income tax, capital gains, and deductions work so you never pay more than you owe.',
      readingTime: '5 min',
      lessons: [
        StudyLesson(
          heading: 'How income tax works',
          body:
              'Income tax is progressive — you pay a higher rate only on income above each threshold, not on everything. In the UK: Personal Allowance (0%), Basic Rate (20%), Higher Rate (40%), Additional Rate (45%). Understanding this prevents overpaying.',
        ),
        StudyLesson(
          heading: 'Tax deductions vs credits',
          body:
              'A deduction reduces your taxable income (e.g., pension contributions reduce the amount of income taxed). A credit directly reduces the tax you owe — pound for pound more valuable. Both are worth claiming.',
        ),
        StudyLesson(
          heading: 'Capital Gains Tax (CGT)',
          body:
              'CGT is paid on profits from selling assets (shares, property, crypto). In the UK, you have an annual CGT allowance before tax kicks in. Hold assets for over a year to potentially benefit from lower rates in some countries.',
        ),
        StudyLesson(
          heading: 'Tax-advantaged accounts',
          body:
              'ISAs, pensions, and Lifetime ISAs shelter your money from tax. A Stocks & Shares ISA lets you invest £20,000/year with zero tax on gains or dividends — legally avoiding tax is called tax avoidance (legal) vs evasion (illegal).',
        ),
        StudyLesson(
          heading: 'Self-assessment & tax returns',
          body:
              'If you\'re self-employed, earn over £100k, or have complex income, you must file a Self-Assessment return by 31 January. Failing to file or pay on time incurs penalties. Keep accurate records throughout the year.',
        ),
      ],
    ),

    // ── DEBT MANAGEMENT ─────────────────────────────────────────────────
    StudyTopic(
      id: 'debt_management',
      quizCategoryId: 'debt',
      title: 'Debt Management Strategies',
      icon: '⚖️',
      color: 0xFFFF4757,
      difficulty: 'Intermediate',
      summary:
          'Learn proven strategies to eliminate debt faster, understand credit scores, and break free from the debt cycle.',
      readingTime: '5 min',
      lessons: [
        StudyLesson(
          heading: 'Good debt vs bad debt',
          body:
              'Good debt (mortgage, student loan, business loan) potentially increases your net worth or earning capacity. Bad debt (high-interest credit cards for lifestyle spending) erodes wealth. The interest rate is often the key differentiator.',
        ),
        StudyLesson(
          heading: 'Debt avalanche — the maths-optimal approach',
          body:
              'List all debts by interest rate. Pay minimums on everything, then direct all extra money to the highest-interest debt. Once cleared, roll that payment to the next. Minimises total interest paid — the mathematically optimal strategy.',
        ),
        StudyLesson(
          heading: 'Debt snowball — the motivational approach',
          body:
              'Pay off smallest balances first regardless of interest rate. The quick wins build momentum and psychological motivation. You may pay slightly more interest, but you\'re more likely to stick with the plan.',
        ),
        StudyLesson(
          heading: 'Credit scores demystified',
          body:
              'A credit score (300–999 in the UK) tells lenders how reliably you repay debt. Factors: payment history (most important), credit utilisation (keep below 30%), length of history, types of credit, and new applications. Check yours free via Experian or ClearScore.',
        ),
        StudyLesson(
          heading: 'Balance transfers & consolidation',
          body:
              'Balance transfer cards offer 0% interest for an introductory period (often 12–24 months). A debt consolidation loan combines multiple debts into one lower-rate loan. Both can save significant interest if you commit to paying off the principal.',
        ),
      ],
    ),
  ];

  static List<StudyTopic> byDifficulty(String difficulty) {
    return all.where((t) => t.difficulty == difficulty).toList();
  }

  static List<StudyTopic> byCategory(String quizCategoryId) {
    return all.where((t) => t.quizCategoryId == quizCategoryId).toList();
  }
}
