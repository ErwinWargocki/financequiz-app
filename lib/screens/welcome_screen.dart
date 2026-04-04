import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../models/models.dart';
import 'main_shell.dart';

// ─── Auth Step Enum ────────────────────────────────────────────────────────
enum _AuthStep { onboarding, authChoice, login, register, iconSelection }

class WelcomeScreen extends StatefulWidget {
  final bool onboardingDone;

  const WelcomeScreen({super.key, this.onboardingDone = false});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late _AuthStep _step;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form controllers
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureLoginPassword = true;
  String? _error;
  int _selectedIconIndex = 0;

  // Pending user data carried from register → icon selection
  String? _pendingName;
  String? _pendingUsername;
  String? _pendingEmail;
  String? _pendingPasswordHash;

  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  final List<_OnboardPage> _pages = const [
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
    _step = widget.onboardingDone ? _AuthStep.authChoice : _AuthStep.onboarding;

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
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    super.dispose();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  void _goToStep(_AuthStep step) {
    setState(() {
      _error = null;
      _step = step;
    });
  }

  // ─── Onboarding ─────────────────────────────────────────────────────────
  void _nextOnboardPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _markOnboardingDone();
      _goToStep(_AuthStep.authChoice);
    }
  }

  Future<void> _markOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', true);
  }

  // ─── Login ───────────────────────────────────────────────────────────────
  Future<void> _login() async {
    final email = _loginEmailCtrl.text.trim().toLowerCase();
    final password = _loginPasswordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = DatabaseHelper.instance;
      final user = await db.getUserByEmail(email);

      if (user == null) {
        setState(() {
          _error = 'No account found with that email';
          _isLoading = false;
        });
        return;
      }

      final hash = _hashPassword(password);
      if (user.passwordHash != hash) {
        setState(() {
          _error = 'Incorrect password';
          _isLoading = false;
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id!);

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

  // ─── Register Step 1 ─────────────────────────────────────────────────────
  Future<void> _submitRegister() async {
    final name = _nameCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (username.contains(' ')) {
      setState(() => _error = 'Username cannot contain spaces');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'Please enter a valid email');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = DatabaseHelper.instance;

      final existingUsername = await db.getUserByUsername(username);
      if (existingUsername != null) {
        setState(() {
          _error = 'Username already taken';
          _isLoading = false;
        });
        return;
      }

      final existingEmail = await db.getUserByEmail(email);
      if (existingEmail != null) {
        setState(() {
          _error = 'An account with this email already exists';
          _isLoading = false;
        });
        return;
      }

      _pendingName = name;
      _pendingUsername = username;
      _pendingEmail = email;
      _pendingPasswordHash = _hashPassword(password);

      setState(() {
        _isLoading = false;
        _step = _AuthStep.iconSelection;
      });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  // ─── Register Step 2 (icon selected) ─────────────────────────────────────
  Future<void> _finishRegister() async {
    setState(() => _isLoading = true);

    try {
      final db = DatabaseHelper.instance;
      final user = UserModel(
        name: _pendingName!,
        username: _pendingUsername!,
        avatarInitial: _pendingName![0].toUpperCase(),
        email: _pendingEmail,
        passwordHash: _pendingPasswordHash,
        profileIconIndex: _selectedIconIndex,
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

  // ─── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case _AuthStep.onboarding:
        return _buildOnboarding();
      case _AuthStep.authChoice:
        return _buildAuthChoice();
      case _AuthStep.login:
        return _buildLoginForm();
      case _AuthStep.register:
        return _buildRegisterForm();
      case _AuthStep.iconSelection:
        return _buildIconSelection();
    }
  }

  // ─── Onboarding ─────────────────────────────────────────────────────────
  Widget _buildOnboarding() {
    final page = _pages[_currentPage];
    return SafeArea(
      key: const ValueKey('onboarding'),
      child: Column(
        children: [
          const SizedBox(height: 20),
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
                      Text('FIN',
                          style: AppTheme.labelSmall.copyWith(
                            color: page.accent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          )),
                      Text('QUIZ',
                          style: AppTheme.labelSmall.copyWith(
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
                    onPressed: () {
                      _markOnboardingDone();
                      _goToStep(_AuthStep.authChoice);
                    },
                    child: Text('Skip',
                        style: AppTheme.bodyMedium
                            .copyWith(color: AppTheme.textSecondary)),
                  ),
              ],
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, __) => Transform.scale(
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
            ),
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                SizedBox(
                  height: 170,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (_, i) {
                      final p = _pages[i];
                      return Column(
                        children: [
                          Text(p.title,
                              style: AppTheme.displayLarge
                                  .copyWith(fontSize: 36),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          Text(p.subtitle,
                              style: AppTheme.bodyLarge.copyWith(
                                  color: AppTheme.textSecondary, height: 1.6),
                              textAlign: TextAlign.center),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextOnboardPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: page.accent,
                  foregroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _currentPage < _pages.length - 1
                      ? 'Continue'
                      : 'Get Started',
                  style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      letterSpacing: 0.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Auth Choice ─────────────────────────────────────────────────────────
  Widget _buildAuthChoice() {
    return SafeArea(
      key: const ValueKey('authChoice'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: 'FIN',
                    style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.accent,
                        fontSize: 28,
                        fontWeight: FontWeight.w800)),
                TextSpan(
                    text: 'QUIZ',
                    style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 16),
            Text('Your financial\nlearning journey\nstarts here.',
                style: AppTheme.displayLarge.copyWith(fontSize: 32)),
            const SizedBox(height: 8),
            Text('Quiz-based learning for real-world money skills.',
                style:
                    AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary)),
            const Spacer(),
            // Create Account
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _goToStep(_AuthStep.register),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Create Account',
                    style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            // Login
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () => _goToStep(_AuthStep.login),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.border, width: 1.5),
                  foregroundColor: AppTheme.textPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Log In',
                    style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            // Google (placeholder — requires backend)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Google Sign-In requires backend setup.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Text('G',
                    style: TextStyle(
                        color: AppTheme.accentBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                label: Text('Continue with Google',
                    style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Login Form ──────────────────────────────────────────────────────────
  Widget _buildLoginForm() {
    return SafeArea(
      key: const ValueKey('login'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            IconButton(
              onPressed: () => _goToStep(_AuthStep.authChoice),
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppTheme.textPrimary),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.accent.withOpacity(0.2), width: 1),
              ),
              child: const Text('👋', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: 20),
            Text('Welcome back', style: AppTheme.displayLarge),
            const SizedBox(height: 6),
            Text('Log in to continue your learning streak.',
                style: AppTheme.bodyMedium),
            const SizedBox(height: 36),
            _label('EMAIL'),
            const SizedBox(height: 8),
            TextField(
              controller: _loginEmailCtrl,
              style: AppTheme.bodyLarge,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() => _error = null),
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                prefixIcon:
                    Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 20),
              ),
            ),
            const SizedBox(height: 20),
            _label('PASSWORD'),
            const SizedBox(height: 8),
            TextField(
              controller: _loginPasswordCtrl,
              style: AppTheme.bodyLarge,
              obscureText: _obscureLoginPassword,
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline,
                    color: AppTheme.textMuted, size: 20),
                suffixIcon: GestureDetector(
                  onTap: () => setState(
                      () => _obscureLoginPassword = !_obscureLoginPassword),
                  child: Icon(
                    _obscureLoginPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.textMuted,
                    size: 20,
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style:
                      AppTheme.bodyMedium.copyWith(color: AppTheme.danger)),
            ],
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: AppTheme.primary))
                    : const Text('Log In →'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? ",
                    style: AppTheme.bodyMedium),
                GestureDetector(
                  onTap: () => _goToStep(_AuthStep.register),
                  child: Text('Sign Up',
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.accent, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Register Form ───────────────────────────────────────────────────────
  Widget _buildRegisterForm() {
    return SafeArea(
      key: const ValueKey('register'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            IconButton(
              onPressed: () => _goToStep(_AuthStep.authChoice),
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppTheme.textPrimary),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.accentBlue.withOpacity(0.2), width: 1),
              ),
              child: const Text('🚀', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: 20),
            Text('Create account', style: AppTheme.displayLarge),
            const SizedBox(height: 6),
            Text('Join and start levelling up your financial IQ.',
                style: AppTheme.bodyMedium),
            const SizedBox(height: 36),
            _label('YOUR NAME'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: AppTheme.bodyLarge,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() => _error = null),
              decoration: const InputDecoration(
                hintText: 'e.g. Alex Johnson',
                prefixIcon: Icon(Icons.person_outline,
                    color: AppTheme.textMuted, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            _label('USERNAME'),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameCtrl,
              style: AppTheme.bodyLarge,
              onChanged: (_) => setState(() => _error = null),
              decoration: const InputDecoration(
                hintText: 'e.g. alex_fin',
                prefixIcon: Icon(Icons.alternate_email,
                    color: AppTheme.textMuted, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            _label('EMAIL'),
            const SizedBox(height: 8),
            TextField(
              controller: _emailCtrl,
              style: AppTheme.bodyLarge,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() => _error = null),
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.email_outlined,
                    color: AppTheme.textMuted, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            _label('PASSWORD'),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordCtrl,
              style: AppTheme.bodyLarge,
              obscureText: _obscurePassword,
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                hintText: 'Min. 6 characters',
                prefixIcon: const Icon(Icons.lock_outline,
                    color: AppTheme.textMuted, size: 20),
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.textMuted,
                    size: 20,
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style:
                      AppTheme.bodyMedium.copyWith(color: AppTheme.danger)),
            ],
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRegister,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: AppTheme.primary))
                    : const Text('Continue →'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account? ', style: AppTheme.bodyMedium),
                GestureDetector(
                  onTap: () => _goToStep(_AuthStep.login),
                  child: Text('Log In',
                      style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.accent, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Icon Selection ───────────────────────────────────────────────────────
  Widget _buildIconSelection() {
    return SafeArea(
      key: const ValueKey('iconSelection'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: IconButton(
              onPressed: () => _goToStep(_AuthStep.register),
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppTheme.textPrimary),
              padding: EdgeInsets.zero,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose your\nprofile icon',
                    style: AppTheme.displayLarge.copyWith(fontSize: 30)),
                const SizedBox(height: 8),
                Text('Pick the one that represents you best.',
                    style: AppTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1,
              ),
              itemCount: ProfileIcons.all.length,
              itemBuilder: (_, i) {
                final selected = _selectedIconIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIconIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.accent.withOpacity(0.15)
                          : AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? AppTheme.accent : AppTheme.border,
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppTheme.accent.withOpacity(0.25),
                                blurRadius: 12,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(ProfileIcons.all[i],
                          style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                if (_error != null) ...[
                  Text(_error!,
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.danger)),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _finishRegister,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: AppTheme.primary))
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(ProfileIcons.all[_selectedIconIndex],
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              const Text('Start Learning →'),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: AppTheme.labelSmall.copyWith(
          color: AppTheme.textSecondary, letterSpacing: 1.5),
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
