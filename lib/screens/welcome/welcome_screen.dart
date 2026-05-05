// Host screen for the entire authentication flow.
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/welcome_provider.dart';
import '../../theme/app_theme.dart';
import '../../navigation/app_routes.dart';
import 'welcome_onboarding.dart';
import 'welcome_auth_choice.dart';
import 'welcome_auth_forms.dart';
import 'welcome_register_form.dart';
import 'welcome_icon_selection.dart';
import 'welcome_security_questions.dart';
import 'welcome_forgot_password.dart';
import 'welcome_reset_password.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  // ── Onboarding carousel ──────────────────────────────────────────────────
  final PageController _pageController = PageController();

  // ── Registration form controllers ────────────────────────────────────────
  final _nameCtrl          = TextEditingController();
  final _usernameCtrl      = TextEditingController();
  final _emailCtrl         = TextEditingController();
  final _passwordCtrl      = TextEditingController();

  // ── Login form controllers ───────────────────────────────────────────────
  final _loginEmailCtrl    = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  // ── Security Q&A controllers (3 answer fields, one per question slot) ───
  final List<TextEditingController> _secAnswerCtrls =
      List.generate(3, (_) => TextEditingController());

  // ── Forgot-password / reset flow ─────────────────────────────────────────
  final _forgotEmailCtrl        = TextEditingController();
  final _challengeAnswerCtrl    = TextEditingController();
  final _newPasswordCtrl        = TextEditingController();
  final _confirmNewPasswordCtrl = TextEditingController();

  // ── Onboarding animation controllers ────────────────────────────────────
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double>   _floatAnimation;
  late Animation<double>   _pulseAnimation;

  // Static content for the three onboarding slides
  final List<WelcomeOnboardPage> _pages = const [
    WelcomeOnboardPage(
      emoji: '📊', title: 'Financial\nIntelligence',
      subtitle: 'Test and build your money knowledge with curated quizzes across 6 key areas.',
      accent: AppTheme.accent,
    ),
    WelcomeOnboardPage(
      emoji: '🏆', title: 'Track Your\nProgress',
      subtitle: 'Watch your scores improve over time. Earn streaks, unlock grades, see your stats grow.',
      accent: AppTheme.accentBlue,
    ),
    WelcomeOnboardPage(
      emoji: '💡', title: 'Learn As\nYou Play',
      subtitle: 'Every question comes with a clear explanation — so you always walk away smarter.',
      accent: AppTheme.accentWarm,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Float + pulse animations drive the onboarding illustration.
    // Controllers are created idle — they only start when the onboarding step
    // is shown (after successful registration) so they don't tick uselessly
    // on every other step of the auth flow.
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
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

  // Clear the error and change the visible step in one call.
  // Starts the onboarding animations when entering that step and stops
  // them on exit, so they don't tick while the user is in the auth forms.
  void _goToStep(WelcomeAuthStep step) {
    if (step == WelcomeAuthStep.onboarding) {
      _floatController.repeat(reverse: true);
      _pulseController.repeat(reverse: true);
    } else if (ref.read(welcomeFlowProvider).step == WelcomeAuthStep.onboarding) {
      _floatController.stop();
      _pulseController.stop();
    }
    ref.read(welcomeFlowProvider.notifier).goToStep(step);
  }

  // Advance the onboarding carousel, or finish it and enter the main app
  void _nextOnboardPage() {
    final flow = ref.read(welcomeFlowProvider);
    if (flow.currentPage < _pages.length - 1) {
      ref.read(welcomeFlowProvider.notifier).setCurrentPage(flow.currentPage + 1);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _markOnboardingDone();
      _navigateToApp();
    }
  }

  // Write a flag so we never show the onboarding again on future app opens
  Future<void> _markOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', true);
  }

  void _navigateToApp() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  // ── Auth Actions ─────────────────────────────────────────────────────────
  // Thin wrappers — all logic lives in WelcomeFlowNotifier.

  Future<void> _login() async {
    final ok = await ref.read(welcomeFlowProvider.notifier).login(
      _loginEmailCtrl.text.trim(), _loginPasswordCtrl.text,
    );
    if (ok && mounted) _navigateToApp();
  }

  Future<void> _submitRegister() async {
    await ref.read(welcomeFlowProvider.notifier).submitRegister(
      _nameCtrl.text.trim(), _usernameCtrl.text.trim(),
      _emailCtrl.text.trim(), _passwordCtrl.text,
    );
  }

  void _finishRegister() =>
      ref.read(welcomeFlowProvider.notifier).finishIconSelection();

  Future<void> _completeRegistration() async {
    await ref.read(welcomeFlowProvider.notifier).completeRegistration(_secAnswerCtrls);
    // Navigation to onboarding step is handled by the provider changing state.step.
    // The build method observes the step change and drives the AnimatedSwitcher.
  }

  Future<void> _forgotPasswordEmailSubmit() async {
    await ref.read(welcomeFlowProvider.notifier).forgotPasswordEmailSubmit(
      _forgotEmailCtrl.text.trim(),
    );
  }

  Future<void> _verifyChallengeAnswer() async {
    await ref.read(welcomeFlowProvider.notifier).verifyChallengeAnswer(
      _challengeAnswerCtrl.text.trim(),
    );
    if (!ref.read(welcomeFlowProvider).isLocked) {
      _challengeAnswerCtrl.clear();
    }
  }

  Future<void> _resetPassword() async {
    final ok = await ref.read(welcomeFlowProvider.notifier).resetPassword(
      _newPasswordCtrl.text, _confirmNewPasswordCtrl.text,
    );
    if (ok) {
      _newPasswordCtrl.clear();
      _confirmNewPasswordCtrl.clear();
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(welcomeFlowProvider);
    // Drive the onboarding animations when state changes to onboarding
    if (flow.step == WelcomeAuthStep.onboarding &&
        !_floatController.isAnimating) {
      _floatController.repeat(reverse: true);
      _pulseController.repeat(reverse: true);
    } else if (flow.step != WelcomeAuthStep.onboarding &&
               _floatController.isAnimating) {
      _floatController.stop();
      _pulseController.stop();
    }
    return Scaffold(
      backgroundColor: AppTheme.primary,
      // AnimatedSwitcher cross-fades between steps instead of hard-cutting
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _buildCurrentStep(flow),
      ),
    );
  }

  // Returns the widget for the currently active authentication step
  Widget _buildCurrentStep(WelcomeFlowState flow) {
    final notifier = ref.read(welcomeFlowProvider.notifier);
    return switch (flow.step) {
      WelcomeAuthStep.onboarding => WelcomeOnboardingStep(
          pages: _pages, currentPage: flow.currentPage,
          floatAnimation: _floatAnimation, pulseAnimation: _pulseAnimation,
          pageController: _pageController,
          onPageChanged: (i) => notifier.setCurrentPage(i),
          onNext: _nextOnboardPage,
          // Skip → go straight into the app, same as completing the last slide
          onSkip: () { _markOnboardingDone(); _navigateToApp(); },
        ),
      WelcomeAuthStep.authChoice => WelcomeAuthChoiceStep(
          onRegister: () => _goToStep(WelcomeAuthStep.register),
          onLogin:    () => _goToStep(WelcomeAuthStep.login),
        ),
      WelcomeAuthStep.login => WelcomeLoginStep(
          emailCtrl: _loginEmailCtrl, passwordCtrl: _loginPasswordCtrl,
          obscurePassword: flow.obscureLoginPassword,
          onToggleObscure: notifier.toggleObscureLoginPassword,
          error: flow.error, isLoading: flow.isLoading,
          onLogin: _login,
          onGoToRegister:   () => _goToStep(WelcomeAuthStep.register),
          onForgotPassword: () => _goToStep(WelcomeAuthStep.forgotEmail),
          onBack:           () => _goToStep(WelcomeAuthStep.authChoice),
        ),
      WelcomeAuthStep.register => WelcomeRegisterStep(
          nameCtrl: _nameCtrl, usernameCtrl: _usernameCtrl,
          emailCtrl: _emailCtrl, passwordCtrl: _passwordCtrl,
          obscurePassword: flow.obscurePassword,
          onToggleObscure: notifier.toggleObscurePassword,
          error: flow.error, isLoading: flow.isLoading,
          onSubmit:    _submitRegister,
          onGoToLogin: () => _goToStep(WelcomeAuthStep.login),
          onBack:      () => _goToStep(WelcomeAuthStep.authChoice),
        ),
      WelcomeAuthStep.iconSelection => WelcomeIconSelectionStep(
          selectedIconIndex: flow.selectedIconIndex,
          onSelectIcon: notifier.selectIcon,
          error: flow.error, isLoading: flow.isLoading,
          onFinish: _finishRegister,
          onBack: () => _goToStep(WelcomeAuthStep.register),
        ),
      WelcomeAuthStep.securityQuestions => WelcomeSecurityQuestionsStep(
          securityQuestions: kSecurityQuestions,
          selectedQuestions: flow.selectedQuestions,
          answerCtrls: _secAnswerCtrls,
          onQuestionChanged: (i, q) => notifier.updateQuestion(i, q),
          error: flow.error, isLoading: flow.isLoading,
          onSubmit: _completeRegistration,
          onBack: () => _goToStep(WelcomeAuthStep.iconSelection),
        ),
      WelcomeAuthStep.forgotEmail => WelcomeForgotEmailStep(
          emailCtrl: _forgotEmailCtrl,
          error: flow.error, isLoading: flow.isLoading,
          onSubmit: _forgotPasswordEmailSubmit,
          onBack: () => _goToStep(WelcomeAuthStep.login),
        ),
      WelcomeAuthStep.securityChallenge => WelcomeSecurityChallengeStep(
          question: flow.challengeQuestion,
          answerCtrl: _challengeAnswerCtrl,
          attempts: flow.challengeAttempts,
          isLocked: flow.isLocked,
          error: flow.error, isLoading: flow.isLoading,
          onSubmit: _verifyChallengeAnswer,
          onBackToLogin: () {
            ref.read(welcomeFlowProvider.notifier).goToStep(WelcomeAuthStep.login);
          },
        ),
      WelcomeAuthStep.newPassword => WelcomeNewPasswordStep(
          passwordCtrl: _newPasswordCtrl,
          confirmCtrl:  _confirmNewPasswordCtrl,
          obscurePassword: flow.obscureNewPassword,
          obscureConfirm:  flow.obscureConfirmPassword,
          onToggleObscure:        notifier.toggleObscureNewPassword,
          onToggleObscureConfirm: notifier.toggleObscureConfirmPassword,
          error: flow.error, isLoading: flow.isLoading,
          onSubmit: _resetPassword,
        ),
    };
  }
}
