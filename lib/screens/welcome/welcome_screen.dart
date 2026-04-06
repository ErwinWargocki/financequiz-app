import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../models/models.dart';
import '../main_shell.dart';

part 'welcome_onboarding.dart';
part 'welcome_auth_choice.dart';
part 'welcome_auth_forms.dart';
part 'welcome_icon_selection.dart';

// ─── Auth Step ────────────────────────────────────────────────────────────────
enum _AuthStep { onboarding, authChoice, login, register, iconSelection }

class WelcomeScreen extends StatefulWidget {
  final bool onboardingDone;
  const WelcomeScreen({super.key, this.onboardingDone = false});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late _AuthStep _step;
  final PageController _pageController = PageController();
  int _currentPage = 0;

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

  String? _pendingName;
  String? _pendingUsername;
  String? _pendingEmail;
  String? _pendingPasswordHash;

  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  final List<_OnboardPage> _pages = const [
    _OnboardPage(emoji: '📊', title: 'Financial\nIntelligence', subtitle: 'Test and build your money knowledge with curated quizzes across 6 key areas.', accent: AppTheme.accent),
    _OnboardPage(emoji: '🏆', title: 'Track Your\nProgress', subtitle: 'Watch your scores improve over time. Earn streaks, unlock grades, see your stats grow.', accent: AppTheme.accentBlue),
    _OnboardPage(emoji: '💡', title: 'Learn As\nYou Play', subtitle: 'Every question comes with a clear explanation — so you always walk away smarter.', accent: AppTheme.accentWarm),
  ];

  @override
  void initState() {
    super.initState();
    _step = widget.onboardingDone ? _AuthStep.authChoice : _AuthStep.onboarding;

    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    _nameCtrl.dispose(); _usernameCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _loginEmailCtrl.dispose(); _loginPasswordCtrl.dispose();
    super.dispose();
  }

  String _hashPassword(String password) => sha256.convert(utf8.encode(password)).toString();

  void _goToStep(_AuthStep step) => setState(() { _error = null; _step = step; });

  void _nextOnboardPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    } else {
      _markOnboardingDone();
      _goToStep(_AuthStep.authChoice);
    }
  }

  Future<void> _markOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', true);
  }

  Future<void> _login() async {
    final email = _loginEmailCtrl.text.trim().toLowerCase();
    final password = _loginPasswordCtrl.text;
    if (email.isEmpty || password.isEmpty) { setState(() => _error = 'Please fill in all fields'); return; }

    setState(() { _isLoading = true; _error = null; });
    try {
      final db = DatabaseHelper.instance;
      final user = await db.getUserByEmail(email);
      if (user == null) { setState(() { _error = 'No account found with that email'; _isLoading = false; }); return; }
      if (user.passwordHash != _hashPassword(password)) { setState(() { _error = 'Incorrect password'; _isLoading = false; }); return; }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id!);
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
    } catch (_) {
      setState(() { _error = 'Something went wrong. Please try again.'; _isLoading = false; });
    }
  }

  Future<void> _submitRegister() async {
    final name = _nameCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) { setState(() => _error = 'Please fill in all fields'); return; }
    if (username.contains(' ')) { setState(() => _error = 'Username cannot contain spaces'); return; }
    if (!email.contains('@') || !email.contains('.')) { setState(() => _error = 'Please enter a valid email'); return; }
    if (password.length < 6) { setState(() => _error = 'Password must be at least 6 characters'); return; }

    setState(() { _isLoading = true; _error = null; });
    try {
      final db = DatabaseHelper.instance;
      if (await db.getUserByUsername(username) != null) { setState(() { _error = 'Username already taken'; _isLoading = false; }); return; }
      if (await db.getUserByEmail(email) != null) { setState(() { _error = 'An account with this email already exists'; _isLoading = false; }); return; }

      _pendingName = name; _pendingUsername = username; _pendingEmail = email;
      _pendingPasswordHash = _hashPassword(password);
      setState(() { _isLoading = false; _step = _AuthStep.iconSelection; });
    } catch (_) {
      setState(() { _error = 'Something went wrong. Please try again.'; _isLoading = false; });
    }
  }

  Future<void> _finishRegister() async {
    setState(() => _isLoading = true);
    try {
      final user = UserModel(
        name: _pendingName!, username: _pendingUsername!,
        avatarInitial: _pendingName![0].toUpperCase(),
        email: _pendingEmail, passwordHash: _pendingPasswordHash,
        profileIconIndex: _selectedIconIndex,
      );
      final id = await DatabaseHelper.instance.insertUser(user);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', id);
      await prefs.setBool('onboardingDone', true);
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
    } catch (_) {
      setState(() { _error = 'Something went wrong. Please try again.'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 350), child: _buildCurrentStep()),
    );
  }

  Widget _buildCurrentStep() {
    return switch (_step) {
      _AuthStep.onboarding => _OnboardingStep(
          pages: _pages, currentPage: _currentPage, floatAnimation: _floatAnimation,
          pulseAnimation: _pulseAnimation, pageController: _pageController,
          onPageChanged: (i) => setState(() => _currentPage = i),
          onNext: _nextOnboardPage,
          onSkip: () { _markOnboardingDone(); _goToStep(_AuthStep.authChoice); },
        ),
      _AuthStep.authChoice => _AuthChoiceStep(
          onRegister: () => _goToStep(_AuthStep.register),
          onLogin: () => _goToStep(_AuthStep.login),
        ),
      _AuthStep.login => _LoginStep(
          emailCtrl: _loginEmailCtrl, passwordCtrl: _loginPasswordCtrl,
          obscurePassword: _obscureLoginPassword,
          onToggleObscure: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
          error: _error, isLoading: _isLoading,
          onLogin: _login, onGoToRegister: () => _goToStep(_AuthStep.register),
          onBack: () => _goToStep(_AuthStep.authChoice),
        ),
      _AuthStep.register => _RegisterStep(
          nameCtrl: _nameCtrl, usernameCtrl: _usernameCtrl,
          emailCtrl: _emailCtrl, passwordCtrl: _passwordCtrl,
          obscurePassword: _obscurePassword,
          onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
          error: _error, isLoading: _isLoading,
          onSubmit: _submitRegister, onGoToLogin: () => _goToStep(_AuthStep.login),
          onBack: () => _goToStep(_AuthStep.authChoice),
        ),
      _AuthStep.iconSelection => _IconSelectionStep(
          selectedIconIndex: _selectedIconIndex,
          onSelectIcon: (i) => setState(() => _selectedIconIndex = i),
          error: _error, isLoading: _isLoading,
          onFinish: _finishRegister, onBack: () => _goToStep(_AuthStep.register),
        ),
    };
  }
}
