part of 'welcome_screen.dart';

// ─── Register Step ────────────────────────────────────────────────────────────
// Collects name, username, email, and password for a new account.
// This is the first of three registration steps; submitting it leads to
// icon selection, then security questions, then the onboarding carousel.
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
            AppSpacing.md,
            // Back arrow returns to the auth-choice landing page
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
              padding: EdgeInsets.zero,
            ),
            AppSpacing.md,
            // Coloured icon badge — gives each step a distinct visual identity
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.2)),
              ),
              child: const Text('🚀', style: TextStyle(fontSize: 28)),
            ),
            AppSpacing.h20,
            Text('Create account', style: AppTheme.displayLarge),
            AppSpacing.h6,
            Text(
              'Join and start levelling up your financial IQ.',
              style: AppTheme.bodyMedium,
            ),
            AppSpacing.h36,
            _authLabel('YOUR NAME'),
            AppSpacing.sm,
            TextField(
              controller: nameCtrl,
              style: AppTheme.bodyLarge,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g. Alex Johnson',
                prefixIcon: Icon(Icons.person_outline, color: AppTheme.textMuted, size: 20),
              ),
            ),
            AppSpacing.md,
            _authLabel('USERNAME'),
            AppSpacing.sm,
            TextField(
              controller: usernameCtrl,
              style: AppTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'e.g. alex_fin',
                prefixIcon: Icon(Icons.alternate_email, color: AppTheme.textMuted, size: 20),
              ),
            ),
            AppSpacing.md,
            _authLabel('EMAIL'),
            AppSpacing.sm,
            TextField(
              controller: emailCtrl,
              style: AppTheme.bodyLarge,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 20),
              ),
            ),
            AppSpacing.md,
            _authLabel('PASSWORD'),
            AppSpacing.sm,
            TextField(
              controller: passwordCtrl,
              style: AppTheme.bodyLarge,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                hintText: 'Min. 6 characters',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 20),
                suffixIcon: GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(
                    obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppTheme.textMuted, size: 20,
                  ),
                ),
              ),
            ),
            // Inline validation error — shown below the last field
            if (error != null) ...[
              AppSpacing.h12,
              Text(error!, style: AppTheme.bodyMedium.copyWith(color: AppTheme.danger)),
            ],
            AppSpacing.h36,
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                child: isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primary))
                    : const Text('Continue →'),
              ),
            ),
            AppSpacing.h20,
            // Shortcut for users who accidentally landed on the wrong screen
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Already have an account? ', style: AppTheme.bodyMedium),
              GestureDetector(
                onTap: onGoToLogin,
                child: Text(
                  'Log In',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.accent, fontWeight: FontWeight.w600),
                ),
              ),
            ]),
            AppSpacing.xl,
          ],
        ),
      ),
    );
  }
}
