import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'auth_provider.dart';

enum WelcomeAuthStep {
  onboarding, authChoice, login, register,
  iconSelection, securityQuestions, forgotEmail,
  securityChallenge, newPassword,
}

// The shared security questions list (owned here since it's part of the auth domain).
const kSecurityQuestions = [
  'What was the name of your first pet?',
  'What was your first car?',
  'What is your favourite city?',
  'What was the name of your childhood best friend?',
  'What street did you grow up on?',
  "What is your mother's maiden name?",
  'What was the name of your primary school?',
];

class WelcomeFlowState {
  final WelcomeAuthStep step;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int selectedIconIndex;
  final List<int?> selectedQuestions;
  final String? pendingName;
  final String? pendingUsername;
  final String? pendingEmail;
  final String? pendingPasswordHash;
  final int forgotUserId;
  final int challengeAttempts;
  final bool isLocked;
  final String challengeQuestion;
  final int challengeQuestionIndex;
  final bool obscurePassword;
  final bool obscureLoginPassword;
  final bool obscureNewPassword;
  final bool obscureConfirmPassword;

  const WelcomeFlowState({
    this.step = WelcomeAuthStep.authChoice,
    this.isLoading = false,
    this.error,
    this.currentPage = 0,
    this.selectedIconIndex = 0,
    this.selectedQuestions = const [null, null, null],
    this.pendingName,
    this.pendingUsername,
    this.pendingEmail,
    this.pendingPasswordHash,
    this.forgotUserId = -1,
    this.challengeAttempts = 0,
    this.isLocked = false,
    this.challengeQuestion = '',
    this.challengeQuestionIndex = -1,
    this.obscurePassword = true,
    this.obscureLoginPassword = true,
    this.obscureNewPassword = true,
    this.obscureConfirmPassword = true,
  });

  WelcomeFlowState copyWith({
    WelcomeAuthStep? step,
    bool? isLoading,
    Object? error = _sentinel,
    int? currentPage,
    int? selectedIconIndex,
    List<int?>? selectedQuestions,
    Object? pendingName = _sentinel,
    Object? pendingUsername = _sentinel,
    Object? pendingEmail = _sentinel,
    Object? pendingPasswordHash = _sentinel,
    int? forgotUserId,
    int? challengeAttempts,
    bool? isLocked,
    String? challengeQuestion,
    int? challengeQuestionIndex,
    bool? obscurePassword,
    bool? obscureLoginPassword,
    bool? obscureNewPassword,
    bool? obscureConfirmPassword,
  }) => WelcomeFlowState(
    step: step ?? this.step,
    isLoading: isLoading ?? this.isLoading,
    error: error == _sentinel ? this.error : error as String?,
    currentPage: currentPage ?? this.currentPage,
    selectedIconIndex: selectedIconIndex ?? this.selectedIconIndex,
    selectedQuestions: selectedQuestions ?? this.selectedQuestions,
    pendingName: pendingName == _sentinel ? this.pendingName : pendingName as String?,
    pendingUsername: pendingUsername == _sentinel ? this.pendingUsername : pendingUsername as String?,
    pendingEmail: pendingEmail == _sentinel ? this.pendingEmail : pendingEmail as String?,
    pendingPasswordHash: pendingPasswordHash == _sentinel ? this.pendingPasswordHash : pendingPasswordHash as String?,
    forgotUserId: forgotUserId ?? this.forgotUserId,
    challengeAttempts: challengeAttempts ?? this.challengeAttempts,
    isLocked: isLocked ?? this.isLocked,
    challengeQuestion: challengeQuestion ?? this.challengeQuestion,
    challengeQuestionIndex: challengeQuestionIndex ?? this.challengeQuestionIndex,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    obscureLoginPassword: obscureLoginPassword ?? this.obscureLoginPassword,
    obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
    obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
  );
}

const _sentinel = Object();

String _hashPassword(String plainText) {
  final bytes = utf8.encode(plainText.trim().toLowerCase());
  return sha256.convert(bytes).toString();
}

class WelcomeFlowNotifier extends Notifier<WelcomeFlowState> {
  @override
  WelcomeFlowState build() => const WelcomeFlowState();

  void goToStep(WelcomeAuthStep step) =>
      state = state.copyWith(step: step, error: null);

  void setCurrentPage(int page) => state = state.copyWith(currentPage: page);

  void selectIcon(int index) => state = state.copyWith(selectedIconIndex: index);

  void updateQuestion(int slot, int? questionIndex) {
    final updated = List<int?>.from(state.selectedQuestions);
    updated[slot] = questionIndex;
    state = state.copyWith(selectedQuestions: updated);
  }

  void toggleObscurePassword() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void toggleObscureLoginPassword() =>
      state = state.copyWith(obscureLoginPassword: !state.obscureLoginPassword);

  void toggleObscureNewPassword() =>
      state = state.copyWith(obscureNewPassword: !state.obscureNewPassword);

  void toggleObscureConfirmPassword() =>
      state = state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword);

  // ── Auth actions — receive text values from the widget ────────────────────

  /// Returns true if login succeeded (widget handles navigation).
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(error: 'Please enter your email and password.');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final auth = ref.read(authProvider.notifier);
      final user = await auth.getUserByEmail(email);
      if (user == null) {
        state = state.copyWith(isLoading: false, error: 'No account found with that email.');
        return false;
      }
      if (user.passwordHash != _hashPassword(password)) {
        state = state.copyWith(isLoading: false, error: 'Incorrect password. Please try again.');
        return false;
      }
      await auth.login(user.id!);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong. Please try again.');
      return false;
    }
  }

  /// Returns true if validation passed and icon selection step should be shown.
  Future<bool> submitRegister(String name, String username, String email, String password) async {
    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      state = state.copyWith(error: 'Please fill in all fields.');
      return false;
    }
    if (password.length < 6) {
      state = state.copyWith(error: 'Password must be at least 6 characters.');
      return false;
    }
    if (!email.contains('@')) {
      state = state.copyWith(error: 'Please enter a valid email address.');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final auth = ref.read(authProvider.notifier);
      if (await auth.getUserByUsername(username) != null) {
        state = state.copyWith(isLoading: false, error: 'That username is already taken.');
        return false;
      }
      if (await auth.getUserByEmail(email) != null) {
        state = state.copyWith(isLoading: false, error: 'An account with that email already exists.');
        return false;
      }
      state = state.copyWith(
        isLoading: false,
        pendingName: name,
        pendingUsername: username,
        pendingEmail: email,
        pendingPasswordHash: _hashPassword(password),
        step: WelcomeAuthStep.iconSelection,
        error: null,
      );
      return true;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong. Please try again.');
      return false;
    }
  }

  void finishIconSelection() =>
      state = state.copyWith(step: WelcomeAuthStep.securityQuestions, error: null);

  /// Returns true if registration completed (widget triggers onboarding).
  Future<bool> completeRegistration(List<TextEditingController> answerCtrls) async {
    for (int i = 0; i < 3; i++) {
      if (state.selectedQuestions[i] == null) {
        state = state.copyWith(error: 'Please select all three security questions.');
        return false;
      }
      if (answerCtrls[i].text.trim().isEmpty) {
        state = state.copyWith(error: 'Please answer all three security questions.');
        return false;
      }
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newUser = UserModel(
        name: state.pendingName!,
        username: state.pendingUsername!,
        avatarInitial: state.pendingName!.isNotEmpty ? state.pendingName![0].toUpperCase() : '?',
        email: state.pendingEmail,
        passwordHash: state.pendingPasswordHash,
        profileIconIndex: state.selectedIconIndex,
        totalScore: 0, quizzesCompleted: 0, currentStreak: 0, longestStreak: 0,
      );
      final indices = state.selectedQuestions.map((q) => q!).toList();
      final hashes = answerCtrls.map((c) => _hashPassword(c.text)).toList();
      await ref.read(authProvider.notifier).registerUser(newUser, indices, hashes);
      state = state.copyWith(isLoading: false, currentPage: 0, step: WelcomeAuthStep.onboarding);
      return true;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Could not create account. Please try again.');
      return false;
    }
  }

  Future<void> forgotPasswordEmailSubmit(String email) async {
    if (email.isEmpty) {
      state = state.copyWith(error: 'Please enter your email address.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final auth = ref.read(authProvider.notifier);
      final user = await auth.getUserByEmail(email);
      if (user == null) {
        state = state.copyWith(isLoading: false, error: 'No account found with that email.');
        return;
      }
      final answers = await auth.getSecurityAnswers(user.id!);
      if (answers.isEmpty) {
        state = state.copyWith(isLoading: false, error: 'No security questions set up for this account.');
        return;
      }
      final pick = answers[Random().nextInt(answers.length)];
      final qIndex = pick['questionIndex'] as int;
      state = state.copyWith(
        isLoading: false,
        forgotUserId: user.id!,
        challengeQuestionIndex: qIndex,
        challengeQuestion: kSecurityQuestions[qIndex],
        challengeAttempts: 0,
        isLocked: false,
        step: WelcomeAuthStep.securityChallenge,
        error: null,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong. Please try again.');
    }
  }

  Future<void> verifyChallengeAnswer(String answer) async {
    if (state.isLocked) return;
    if (answer.isEmpty) {
      state = state.copyWith(error: 'Please enter your answer.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final answers = await ref.read(authProvider.notifier).getSecurityAnswers(state.forgotUserId);
      final record = answers.firstWhere(
        (a) => a['questionIndex'] == state.challengeQuestionIndex,
        orElse: () => {},
      );
      if (record.isEmpty) {
        state = state.copyWith(isLoading: false, error: 'Could not verify answer. Please try again.');
        return;
      }
      if (_hashPassword(answer) != record['answerHash'] as String) {
        final newAttempts = state.challengeAttempts + 1;
        final lock = newAttempts >= 4;
        state = state.copyWith(
          isLoading: false,
          challengeAttempts: newAttempts,
          isLocked: lock,
          error: lock ? null : 'Incorrect answer. ${4 - newAttempts} attempt(s) remaining.',
        );
        return;
      }
      state = state.copyWith(isLoading: false, step: WelcomeAuthStep.newPassword, error: null);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Something went wrong. Please try again.');
    }
  }

  /// Returns true if password reset succeeded (widget returns to login step).
  Future<bool> resetPassword(String password, String confirm) async {
    if (password.isEmpty || confirm.isEmpty) {
      state = state.copyWith(error: 'Please fill in both password fields.');
      return false;
    }
    if (password.length < 6) {
      state = state.copyWith(error: 'Password must be at least 6 characters.');
      return false;
    }
    if (password != confirm) {
      state = state.copyWith(error: 'Passwords do not match.');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authProvider.notifier).updatePassword(state.forgotUserId, _hashPassword(password));
      state = state.copyWith(isLoading: false, forgotUserId: -1, step: WelcomeAuthStep.login, error: null);
      return true;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Could not reset password. Please try again.');
      return false;
    }
  }
}

final welcomeFlowProvider =
    NotifierProvider<WelcomeFlowNotifier, WelcomeFlowState>(WelcomeFlowNotifier.new);
