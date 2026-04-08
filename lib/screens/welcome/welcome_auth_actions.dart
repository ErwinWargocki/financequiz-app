part of 'welcome_screen.dart';

// ignore_for_file: invalid_use_of_protected_member
// ^ setState is @protected on State<T>. Extension methods don't satisfy
//   the "must be inside a subclass" check even when declared in the same
//   library via 'part of'. The ignore is safe here because this extension
//   targets _WelcomeScreenState exclusively and lives in the same library.

// ─── Auth Actions ─────────────────────────────────────────────────────────────
// All business-logic methods that live on _WelcomeScreenState.
// Widgets in the other part files call these via callbacks — they stay thin
// and presentational while this file owns all async/DB work.

// Hash a plain-text password (or security answer) to a hex SHA-256 digest.
// We never store plain text — only the hash goes into the database.
String _hashPassword(String plainText) {
  final bytes  = utf8.encode(plainText.trim().toLowerCase());
  final digest = sha256.convert(bytes);
  return digest.toString();
}

// ─── Login ────────────────────────────────────────────────────────────────────
extension _AuthActions on _WelcomeScreenState {

  // Validate the login form, look up the user by email, verify the hashed
  // password, then persist the userId and navigate into the app.
  Future<void> _login() async {
    final email    = _loginEmailCtrl.text.trim();
    final password = _loginPasswordCtrl.text;

    // Basic presence checks — show an inline error instead of a dialog
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final db   = DatabaseHelper.instance;
      final user = await db.getUserByEmail(email);

      // No account found with that email
      if (user == null) {
        setState(() { _isLoading = false; _error = 'No account found with that email.'; });
        return;
      }

      // Compare the stored hash against what the user typed
      final hash = _hashPassword(password);
      if (user.passwordHash != hash) {
        setState(() { _isLoading = false; _error = 'Incorrect password. Please try again.'; });
        return;
      }

      // Persist the userId so SplashScreen can detect the logged-in state on
      // future app opens and skip the welcome flow entirely.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id!);

      _navigateToApp();
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Something went wrong. Please try again.'; });
    }
  }

  // ─── Register (step 1 of 3) ───────────────────────────────────────────────
  // Validates the registration form, checks for duplicate username/email,
  // hashes the password, then holds the data in memory while the user
  // completes icon selection and security questions.
  Future<void> _submitRegister() async {
    final name     = _nameCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final db = DatabaseHelper.instance;

      // Reject duplicate usernames (case-insensitive handled by SQLite UNIQUE)
      final existingUsername = await db.getUserByUsername(username);
      if (existingUsername != null) {
        setState(() { _isLoading = false; _error = 'That username is already taken.'; });
        return;
      }

      // Reject duplicate emails — one account per address
      final existingEmail = await db.getUserByEmail(email);
      if (existingEmail != null) {
        setState(() { _isLoading = false; _error = 'An account with that email already exists.'; });
        return;
      }

      // Hold the validated data in memory — the user object isn't created
      // in the database until _completeRegistration (after security Qs)
      _pendingName         = name;
      _pendingUsername     = username;
      _pendingEmail        = email;
      _pendingPasswordHash = _hashPassword(password);

      setState(() => _isLoading = false);
      _goToStep(_AuthStep.iconSelection);
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Something went wrong. Please try again.'; });
    }
  }

  // ─── Register (step 2 of 3) — icon confirmed ─────────────────────────────
  // The user has picked their profile icon; advance to security questions.
  // No async work here — the selected icon index is already stored in state.
  void _finishRegister() {
    _goToStep(_AuthStep.securityQuestions);
  }

  // ─── Register (step 3 of 3) — complete ───────────────────────────────────
  // Validate the three Q&A slots, write the user to the DB, persist the
  // security answer hashes, then launch the onboarding carousel.
  // The carousel is shown exactly once — right after first registration.
  Future<void> _completeRegistration() async {
    // Every slot must have a question selected and an answer typed
    for (int i = 0; i < 3; i++) {
      if (_selectedQuestions[i] == null) {
        setState(() => _error = 'Please select all three security questions.');
        return;
      }
      if (_secAnswerCtrls[i].text.trim().isEmpty) {
        setState(() => _error = 'Please answer all three security questions.');
        return;
      }
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final db = DatabaseHelper.instance;

      // Create the user row — the icon index chosen on the previous step is
      // embedded in the model so it is persisted immediately.
      final newUser = UserModel(
        name:             _pendingName!,
        username:         _pendingUsername!,
        avatarInitial:    _pendingName!.isNotEmpty ? _pendingName![0].toUpperCase() : '?',
        email:            _pendingEmail,
        passwordHash:     _pendingPasswordHash,
        profileIconIndex: _selectedIconIndex,
        totalScore:       0,
        quizzesCompleted: 0,
        currentStreak:    0,
        longestStreak:    0,
      );

      final userId = await db.insertUser(newUser);

      // Hash each answer before saving — answers are never stored as plain text
      final indices = _selectedQuestions.map((q) => q!).toList();
      final hashes  = _secAnswerCtrls.map((c) => _hashPassword(c.text)).toList();
      await db.saveSecurityAnswers(userId, indices, hashes);

      // Persist the userId so the app knows the user is logged in on future
      // opens. From here on SplashScreen will jump straight to MainShell.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userId);

      setState(() { _isLoading = false; _currentPage = 0; });

      // Show the "how it works" onboarding — new users only.
      // Completing or skipping it calls _navigateToApp() directly.
      _goToStep(_AuthStep.onboarding);
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Could not create account. Please try again.'; });
    }
  }

  // ─── Forgot password (step 1) — email lookup ─────────────────────────────
  // Looks up the account by email, picks a random one of the saved security
  // questions, stores the challenge context, then shows the challenge screen.
  Future<void> _forgotPasswordEmailSubmit() async {
    final email = _forgotEmailCtrl.text.trim();

    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final db   = DatabaseHelper.instance;
      final user = await db.getUserByEmail(email);

      if (user == null) {
        setState(() { _isLoading = false; _error = 'No account found with that email.'; });
        return;
      }

      // Load the saved security Q&A slots for this account
      final answers = await db.getSecurityAnswers(user.id!);
      if (answers.isEmpty) {
        setState(() { _isLoading = false; _error = 'No security questions set up for this account.'; });
        return;
      }

      // Pick a random slot to challenge the user — they only need to answer one
      final pick   = answers[Random().nextInt(answers.length)];
      final qIndex = pick['questionIndex'] as int;

      _forgotUserId           = user.id!;
      _challengeQuestionIndex = qIndex;
      _challengeQuestion      = _kSecurityQuestions[qIndex];
      _challengeAttempts      = 0;
      _isLocked               = false;

      setState(() => _isLoading = false);
      _goToStep(_AuthStep.securityChallenge);
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Something went wrong. Please try again.'; });
    }
  }

  // ─── Forgot password (step 2) — verify challenge answer ──────────────────
  // Hashes the user's answer and compares it to the stored hash.
  // After 4 wrong attempts the screen locks and the user must go back.
  Future<void> _verifyChallengeAnswer() async {
    if (_isLocked) return;

    final answer = _challengeAnswerCtrl.text.trim();
    if (answer.isEmpty) {
      setState(() => _error = 'Please enter your answer.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final db      = DatabaseHelper.instance;
      final answers = await db.getSecurityAnswers(_forgotUserId);

      // Find the specific answer record for the presented question
      final record = answers.firstWhere(
        (a) => a['questionIndex'] == _challengeQuestionIndex,
        orElse: () => {},
      );

      if (record.isEmpty) {
        setState(() { _isLoading = false; _error = 'Could not verify answer. Please try again.'; });
        return;
      }

      final storedHash = record['answerHash'] as String;
      final inputHash  = _hashPassword(answer);

      if (inputHash != storedHash) {
        // Wrong answer — increment the attempt counter and possibly lock
        final newAttempts = _challengeAttempts + 1;
        final lock        = newAttempts >= 4;

        setState(() {
          _isLoading         = false;
          _challengeAttempts = newAttempts;
          _isLocked          = lock;
          _error = lock ? null : 'Incorrect answer. ${4 - newAttempts} attempt(s) remaining.';
        });
        return;
      }

      // Correct — clear the answer field and advance to the new-password screen
      _challengeAnswerCtrl.clear();
      setState(() => _isLoading = false);
      _goToStep(_AuthStep.newPassword);
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Something went wrong. Please try again.'; });
    }
  }

  // ─── Forgot password (step 3) — set new password ─────────────────────────
  // Validates the two password fields then writes the new hash to the DB.
  // On success, takes the user back to the login screen.
  Future<void> _resetPassword() async {
    final password = _newPasswordCtrl.text;
    final confirm  = _confirmNewPasswordCtrl.text;

    if (password.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Please fill in both password fields.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final db   = DatabaseHelper.instance;
      final hash = _hashPassword(password);
      await db.updateUserPassword(_forgotUserId, hash);

      // Clear the reset flow state so it cannot be replayed
      _newPasswordCtrl.clear();
      _confirmNewPasswordCtrl.clear();
      _forgotUserId = -1;

      setState(() => _isLoading = false);

      // Return to the login screen — the user can now log in with the new password
      _goToStep(_AuthStep.login);
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Could not reset password. Please try again.'; });
    }
  }
}
