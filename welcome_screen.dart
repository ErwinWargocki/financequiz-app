import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../models/models.dart';
import 'main_shell.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showSetup = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  final List<_OnboardPage> _pages = [
    _OnboardPage(
      emoji: '📊',
      title: 'Financial\nIntelligence',
      subtitle:
          'Test and build your money knowledge with curated quizzes across 6 key areas.',
      accent: AppTheme.accent,
    ),
    _OnboardPage(
      emoji: '🏆',
      title: 'Track Your\nProgress',
      subtitle:
          'Watch your scores improve over time. Earn streaks, unlock grades, see your stats grow.',
      accent: AppTheme.accentBlue,
    ),
    _OnboardPage(
      emoji: '💡',
      title: 'Learn As\nYou Play',
      subtitle:
          'Every question comes with a clear explanation — so you always walk away smarter.',
      accent: AppTheme.accentWarm,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      setState(() => _showSetup = true);
    }
  }

  Future<void> _createProfile() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();

    if (name.isEmpty || username.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (username.contains(' ')) {
      setState(() => _error = 'Username cannot contain spaces');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = DatabaseHelper.instance;
      final existing = await db.getUserByUsername(username);
      if (existing != null) {
        setState(() {
          _error = 'Username already taken';
          _isLoading = false;
        });
        return;
      }

      final user = UserModel(
        name: name,
        username: username,
        avatarInitial: name[0].toUpperCase(),
      );
      final id = await db.insertUser(user);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', id);
      await prefs.setBool('onboardingDone', true);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _showSetup ? _buildSetupPage() : _buildOnboarding(),
      ),
    );
  }

  Widget _buildOnboarding() {
    final page = _pages[_currentPage];
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: page.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: page.accent.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Text('FIN', style: AppTheme.labelSmall.copyWith(
                        color: page.accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      )),
                      Text('QUIZ', style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      )),
                    ],
                  ),
                ),
                const Spacer(),
                if (_currentPage < _pages.length - 1)
                  TextButton(
                    onPressed: () => setState(() => _showSetup = true),
                    child: Text('Skip',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        )),
                  ),
              ],
            ),
          ),

          const Spacer(),

          // Floating emoji
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, _) => Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: page.accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: page.accent.withOpacity(0.2), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: page.accent.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(page.emoji,
                            style: const TextStyle(fontSize: 60)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 48),

          // Page content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) {
                    final p = _pages[i];
                    return Column(
                      children: [
                        Text(
                          p.title,
                          style: AppTheme.displayLarge.copyWith(fontSize: 36),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.subtitle,
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 24 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? page.accent
                            : AppTheme.textMuted,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const Spacer(),

          // CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: page.accent,
                  foregroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _currentPage < _pages.length - 1
                      ? 'Continue'
                      : 'Get Started',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupPage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.accent.withOpacity(0.2), width: 1),
              ),
              child: const Text('👤', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 24),
            Text('Create your\nprofile', style: AppTheme.displayLarge),
            const SizedBox(height: 8),
            Text(
              'Your progress is saved locally — no account needed.',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 40),

            // Name field
            _buildLabel('YOUR NAME'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: AppTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'e.g. Alex Johnson',
                prefixIcon: const Icon(Icons.person_outline,
                    color: AppTheme.textMuted, size: 20),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 20),

            // Username field
            _buildLabel('USERNAME'),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              style: AppTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'e.g. alex_fin',
                prefixIcon: const Icon(Icons.alternate_email,
                    color: AppTheme.textMuted, size: 20),
              ),
              onChanged: (_) => setState(() => _error = null),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.danger)),
            ],

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createProfile,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppTheme.primary,
                        ),
                      )
                    : const Text('Start Learning →'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTheme.labelSmall.copyWith(
        color: AppTheme.textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _OnboardPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;
  const _OnboardPage(
      {required this.emoji,
      required this.title,
      required this.subtitle,
      required this.accent});
}
