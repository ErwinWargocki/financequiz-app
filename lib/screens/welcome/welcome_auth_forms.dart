part of 'welcome_screen.dart';

Widget _authLabel(String text) => Text(
  text,
  style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary, letterSpacing: 1.5),
);

// ─── Login Step ───────────────────────────────────────────────────────────────
class _LoginStep extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final String? error;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onGoToRegister;
  final VoidCallback onBack;

  const _LoginStep({
    required this.emailCtrl, required this.passwordCtrl,
    required this.obscurePassword, required this.onToggleObscure,
    required this.error, required this.isLoading,
    required this.onLogin, required this.onGoToRegister, required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const ValueKey('login'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary), padding: EdgeInsets.zero),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.accent.withOpacity(0.2))),
              child: const Text('👋', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: 20),
            Text('Welcome back', style: AppTheme.displayLarge),
            const SizedBox(height: 6),
            Text('Log in to continue your learning streak.', style: AppTheme.bodyMedium),
            const SizedBox(height: 36),
            _authLabel('EMAIL'),
            const SizedBox(height: 8),
            TextField(
              controller: emailCtrl, style: AppTheme.bodyLarge, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'you@example.com', prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 20)),
            ),
            const SizedBox(height: 20),
            _authLabel('PASSWORD'),
            const SizedBox(height: 8),
            TextField(
              controller: passwordCtrl, style: AppTheme.bodyLarge, obscureText: obscurePassword,
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 20),
                suffixIcon: GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textMuted, size: 20),
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: AppTheme.bodyMedium.copyWith(color: AppTheme.danger)),
            ],
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : onLogin,
                child: isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primary))
                    : const Text('Log In →'),
              ),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Don't have an account? ", style: AppTheme.bodyMedium),
              GestureDetector(
                onTap: onGoToRegister,
                child: Text('Sign Up', style: AppTheme.bodyMedium.copyWith(color: AppTheme.accent, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Register Step ────────────────────────────────────────────────────────────
class _RegisterStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController usernameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final String? error;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onGoToLogin;
  final VoidCallback onBack;

  const _RegisterStep({
    required this.nameCtrl, required this.usernameCtrl,
    required this.emailCtrl, required this.passwordCtrl,
    required this.obscurePassword, required this.onToggleObscure,
    required this.error, required this.isLoading,
    required this.onSubmit, required this.onGoToLogin, required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const ValueKey('register'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary), padding: EdgeInsets.zero),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.accentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.accentBlue.withOpacity(0.2))),
              child: const Text('🚀', style: TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: 20),
            Text('Create account', style: AppTheme.displayLarge),
            const SizedBox(height: 6),
            Text('Join and start levelling up your financial IQ.', style: AppTheme.bodyMedium),
            const SizedBox(height: 36),
            _authLabel('YOUR NAME'),
            const SizedBox(height: 8),
            TextField(controller: nameCtrl, style: AppTheme.bodyLarge, textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'e.g. Alex Johnson', prefixIcon: Icon(Icons.person_outline, color: AppTheme.textMuted, size: 20))),
            const SizedBox(height: 16),
            _authLabel('USERNAME'),
            const SizedBox(height: 8),
            TextField(controller: usernameCtrl, style: AppTheme.bodyLarge,
              decoration: const InputDecoration(hintText: 'e.g. alex_fin', prefixIcon: Icon(Icons.alternate_email, color: AppTheme.textMuted, size: 20))),
            const SizedBox(height: 16),
            _authLabel('EMAIL'),
            const SizedBox(height: 8),
            TextField(controller: emailCtrl, style: AppTheme.bodyLarge, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'you@example.com', prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 20))),
            const SizedBox(height: 16),
            _authLabel('PASSWORD'),
            const SizedBox(height: 8),
            TextField(
              controller: passwordCtrl, style: AppTheme.bodyLarge, obscureText: obscurePassword,
              decoration: InputDecoration(
                hintText: 'Min. 6 characters',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 20),
                suffixIcon: GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textMuted, size: 20),
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: AppTheme.bodyMedium.copyWith(color: AppTheme.danger)),
            ],
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                child: isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primary))
                    : const Text('Continue →'),
              ),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Already have an account? ', style: AppTheme.bodyMedium),
              GestureDetector(
                onTap: onGoToLogin,
                child: Text('Log In', style: AppTheme.bodyMedium.copyWith(color: AppTheme.accent, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
