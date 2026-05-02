// Host library for the entire authentication flow.
// Every 'part' file below contributes widgets and methods to this library
// so they can all reference private symbols (those starting with _).
//
// Navigation flow:
//   introScreen → WelcomeScreen (authChoice) → login  → MainShell
//                                              → register → iconSelection
//                                                         → securityQuestions
//                                                         → onboarding  ← NEW USERS ONLY
//                                                                       → MainShell
//
// The onboarding carousel is shown exactly once: immediately after a brand-new
// account is created.  It is never shown on subsequent app opens.

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import '../main_shell.dart';

// Each part file is literally part of this same Dart library, so it can
// access any private class, method, or constant defined here.
part 'welcome_onboarding.dart';
part 'welcome_auth_choice.dart';
part 'welcome_auth_forms.dart';
part 'welcome_register_form.dart';
part 'welcome_icon_selection.dart';
part 'welcome_security_questions.dart';
part 'welcome_forgot_password.dart';
part 'welcome_reset_password.dart';
part 'welcome_auth_actions.dart';

// Every step in the registration / login / password-reset funnel
enum _AuthStep {
  onboarding,         // 3-slide "how it works" carousel (new users only)
  authChoice,         // landing page: Create Account / Log In
  login,              // email + password login form
  register,           // name / username / email / password form
  iconSelection,      // pick a profile emoji icon
  securityQuestions,  // choose 3 security Q&As for account recovery
  forgotEmail,        // enter email to start password reset
  securityChallenge,  // answer one of the saved security questions
  newPassword,        // enter and confirm the new password
}

// The 7 personal questions a user can choose from during registration.
// Stored as question indices (0-6) in the database — the text lives here.
const List<String> _kSecurityQuestions = [
  'What was the name of your first pet?',
  'What was your first car?',
  'What is your favourite city?',
  'What was the name of your childhood best friend?',
  'What street did you grow up on?',
  "What is your mother's maiden name?",
  'What was the name of your primary school?',
];

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  // ── Current step ────────────────────────────────────────────────────────
  late _AuthStep _step;

  // ── Onboarding carousel ──────────────────────────────────────────────────
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── Registration form controllers ────────────────────────────────────────
  final _nameCtrl          = TextEditingController();
  final _usernameCtrl      = TextEditingController();
  final _emailCtrl         = TextEditingController();
  final _passwordCtrl      = TextEditingController();

  // ── Login form controllers ───────────────────────────────────────────────
  final _loginEmailCtrl    = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  // ── Security Q&A controllers (3 answer fields, one per question slot) ───
  final List<int?> _selectedQuestions = [null, null, null];
  final List<TextEditingController> _secAnswerCtrls =
      List.generate(3, (_) => TextEditingController());

  // ── Forgot-password / reset flow ─────────────────────────────────────────
  final _forgotEmailCtrl       = TextEditingController();
  final _challengeAnswerCtrl   = TextEditingController();
  final _newPasswordCtrl       = TextEditingController();
  final _confirmNewPasswordCtrl = TextEditingController();
  bool _obscureNewPassword     = true;
  bool _obscureConfirmPassword = true;
  int  _forgotUserId           = -1;
  int  _challengeAttempts      = 0;
  bool _isLocked               = false;
  String _challengeQuestion    = '';
  int  _challengeQuestionIndex = -1;

  // ── Shared UI state ──────────────────────────────────────────────────────
  bool    _isLoading          = false;
  bool    _obscurePassword    = true;
  bool    _obscureLoginPassword = true;
  String? _error;
  int     _selectedIconIndex  = 0;

  // Registration data held in memory between steps
  String? _pendingName;
  String? _pendingUsername;
  String? _pendingEmail;
  String? _pendingPasswordHash;

  // ── Onboarding animation controllers ────────────────────────────────────
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double>   _floatAnimation;
  late Animation<double>   _pulseAnimation;

  // Static content for the three onboarding slides
  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      emoji: '📊', title: 'Financial\nIntelligence',
      subtitle: 'Test and build your money knowledge with curated quizzes across 6 key areas.',
      accent: AppTheme.accent,
    ),
    _OnboardPage(
      emoji: '🏆', title: 'Track Your\nProgress',
      subtitle: 'Watch your scores improve over time. Earn streaks, unlock grades, see your stats grow.',
      accent: AppTheme.accentBlue,
    ),
    _OnboardPage(
      emoji: '💡', title: 'Learn As\nYou Play',
      subtitle: 'Every question comes with a clear explanation — so you always walk away smarter.',
      accent: AppTheme.accentWarm,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Always land on the auth-choice screen on launch — onboarding is for new users only
    _step = _AuthStep.authChoice;

    // Float + pulse animations drive the onboarding illustration
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -10, end: 10)
        .animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light),
    );
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
    for (final c in _secAnswerCtrls) { c.dispose(); }
    _forgotEmailCtrl.dispose();
    _challengeAnswerCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmNewPasswordCtrl.dispose();
    super.dispose();
  }

  // ── Navigation helpers ───────────────────────────────────────────────────

  // Clear the error and change the visible step in one setState call
  void _goToStep(_AuthStep step) => setState(() { _error = null; _step = step; });

  // Advance the onboarding carousel, or finish it and enter the main app
  void _nextOnboardPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Last slide — onboarding complete, enter the app
      _markOnboardingDone();
      _navigateToApp();
    }
  }

  // Write a flag so we never show the onboarding again on future app opens
  Future<void> _markOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', true);
  }

  // Replace this screen with MainShell using a fade transition
  void _navigateToApp() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      // AnimatedSwitcher cross-fades between steps instead of hard-cutting
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _buildCurrentStep(),
      ),
    );
  }

  // Returns the widget for the currently active authentication step
  Widget _buildCurrentStep() {
    return switch (_step) {
      _AuthStep.onboarding => _OnboardingStep(
          pages: _pages, currentPage: _currentPage,
          floatAnimation: _floatAnimation, pulseAnimation: _pulseAnimation,
          pageController: _pageController,
          onPageChanged: (i) => setState(() => _currentPage = i),
          onNext: _nextOnboardPage,
          // Skip → go straight into the app, same as completing the last slide
          onSkip: () { _markOnboardingDone(); _navigateToApp(); },
        ),
      _AuthStep.authChoice => _AuthChoiceStep(
          onRegister: () => _goToStep(_AuthStep.register),
          onLogin:    () => _goToStep(_AuthStep.login),
        ),
      _AuthStep.login => _LoginStep(
          emailCtrl: _loginEmailCtrl, passwordCtrl: _loginPasswordCtrl,
          obscurePassword: _obscureLoginPassword,
          onToggleObscure: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
          error: _error, isLoading: _isLoading,
          onLogin: _login,
          onGoToRegister:   () => _goToStep(_AuthStep.register),
          onForgotPassword: () => _goToStep(_AuthStep.forgotEmail),
          onBack:           () => _goToStep(_AuthStep.authChoice),
        ),
      _AuthStep.register => _RegisterStep(
          nameCtrl: _nameCtrl, usernameCtrl: _usernameCtrl,
          emailCtrl: _emailCtrl, passwordCtrl: _passwordCtrl,
          obscurePassword: _obscurePassword,
          onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
          error: _error, isLoading: _isLoading,
          onSubmit:    _submitRegister,
          onGoToLogin: () => _goToStep(_AuthStep.login),
          onBack:      () => _goToStep(_AuthStep.authChoice),
        ),
      _AuthStep.iconSelection => _IconSelectionStep(
          selectedIconIndex: _selectedIconIndex,
          onSelectIcon: (i) => setState(() => _selectedIconIndex = i),
          error: _error, isLoading: _isLoading,
          onFinish: _finishRegister,
          onBack: () => _goToStep(_AuthStep.register),
        ),
      _AuthStep.securityQuestions => _SecurityQuestionsStep(
          selectedQuestions: _selectedQuestions,
          answerCtrls: _secAnswerCtrls,
          onQuestionChanged: (i, q) => setState(() => _selectedQuestions[i] = q),
          error: _error, isLoading: _isLoading,
          onSubmit: _completeRegistration,
          onBack: () => _goToStep(_AuthStep.iconSelection),
        ),
      _AuthStep.forgotEmail => _ForgotEmailStep(
          emailCtrl: _forgotEmailCtrl,
          error: _error, isLoading: _isLoading,
          onSubmit: _forgotPasswordEmailSubmit,
          onBack: () => _goToStep(_AuthStep.login),
        ),
      _AuthStep.securityChallenge => _SecurityChallengeStep(
          question: _challengeQuestion,
          answerCtrl: _challengeAnswerCtrl,
          attempts: _challengeAttempts,
          isLocked: _isLocked,
          error: _error, isLoading: _isLoading,
          onSubmit: _verifyChallengeAnswer,
          onBackToLogin: () {
            setState(() { _challengeAttempts = 0; _isLocked = false; });
            _goToStep(_AuthStep.login);
          },
        ),
      _AuthStep.newPassword => _NewPasswordStep(
          passwordCtrl: _newPasswordCtrl,
          confirmCtrl:  _confirmNewPasswordCtrl,
          obscurePassword: _obscureNewPassword,
          obscureConfirm:  _obscureConfirmPassword,
          onToggleObscure:        () => setState(() => _obscureNewPassword = !_obscureNewPassword),
          onToggleObscureConfirm: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          error: _error, isLoading: _isLoading,
          onSubmit: _resetPassword,
        ),
    };
  }
}
