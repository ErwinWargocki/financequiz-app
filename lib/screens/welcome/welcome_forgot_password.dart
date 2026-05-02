part of 'welcome_screen.dart';

// ─── Forgot Email Step ─────────────────────────────────────────────────────────
// Step 1 of the password-reset flow: the user enters their registered email.
// On submit, _forgotPasswordEmailSubmit() picks a random saved security
// question and advances to the security-challenge screen.
// _SecurityChallengeStep and _NewPasswordStep live in welcome_reset_password.dart.
class _ForgotEmailStep extends StatelessWidget {
  final TextEditingController emailCtrl;
  final String? error;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _ForgotEmailStep({
    required this.emailCtrl,
    required this.error,
    required this.isLoading,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const ValueKey('forgotEmail'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.md,
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
              padding: EdgeInsets.zero,
            ),
            AppSpacing.md,
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.2)),
              ),
              child: const Text('🔑', style: TextStyle(fontSize: 28)),
            ),
            AppSpacing.h20,
            Text('Reset Password', style: AppTheme.displayLarge),
            AppSpacing.h6,
            Text(
              'Enter your registered email address to verify your identity.',
              style: AppTheme.bodyMedium,
            ),
            AppSpacing.h36,
            Text(
              'EMAIL',
              style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary, letterSpacing: 1.5),
            ),
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
            if (error != null) ...[
              AppSpacing.h12,
              Text(error!, style: AppTheme.bodyMedium.copyWith(color: AppTheme.danger)),
            ],
            AppSpacing.h36,
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                child: isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primary))
                    : const Text('Continue →'),
              ),
            ),
            AppSpacing.xl,
          ],
        ),
      ),
    );
  }
}
// _SecurityChallengeStep and _NewPasswordStep live in welcome_reset_password.dart
