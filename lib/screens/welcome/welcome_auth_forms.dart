part of 'welcome_screen.dart';

// ─── Shared Helpers ───────────────────────────────────────────────────────────

// Renders a small all-caps field label (EMAIL, PASSWORD, etc.) used by
// every form across the auth flow. Kept here so all form files can use it
// without any extra import — they are all part of the same library.
Widget _authLabel(String text) => Text(
  text,
  style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary, letterSpacing: 1.5),
);

// ─── Login Step ───────────────────────────────────────────────────────────────
// Collects email + password and provides links to register and forgot-password.
class _LoginStep extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final String? error;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onGoToRegister;
  final VoidCallback onForgotPassword;
  final VoidCallback onBack;

  const _LoginStep({
    required this.emailCtrl, required this.passwordCtrl,
    required this.obscurePassword, required this.onToggleObscure,
    required this.error, required this.isLoading,
    required this.onLogin, required this.onGoToRegister,
    required this.onForgotPassword, required this.onBack,
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
            AppSpacing.md,
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary), padding: EdgeInsets.zero),
            AppSpacing.md,
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha:0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.accent.withValues(alpha:0.2))),
              child: const Text('👋', style: TextStyle(fontSize: 28)),
            ),
            AppSpacing.h20,
            Text('Welcome back', style: AppTheme.displayLarge),
            AppSpacing.h6,
            Text('Log in to continue your learning streak.', style: AppTheme.bodyMedium),
            AppSpacing.h36,
            _authLabel('EMAIL'),
            AppSpacing.sm,
            TextField(
              controller: emailCtrl, style: AppTheme.bodyLarge, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'you@example.com', prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 20)),
            ),
            AppSpacing.h20,
            _authLabel('PASSWORD'),
            AppSpacing.sm,
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
              AppSpacing.h12,
              Text(error!, style: AppTheme.bodyMedium.copyWith(color: AppTheme.danger)),
            ],
            AppSpacing.h12,
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onForgotPassword,
                child: Text('Forgot Password?', style: AppTheme.bodyMedium.copyWith(color: AppTheme.accentBlue)),
              ),
            ),
            AppSpacing.lg,
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : onLogin,
                child: isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primary))
                      : Text('Log In →', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
            AppSpacing.h20,
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Don't have an account? ", style: AppTheme.bodyMedium),
              GestureDetector(
                onTap: onGoToRegister,
                child: Text('Sign Up', style: AppTheme.bodyMedium.copyWith(color: AppTheme.accent, fontWeight: FontWeight.w600)),
              ),
            ]),
            AppSpacing.xl,
          ],
        ),
      ),
    );
  }
}
// _RegisterStep has moved to welcome_register_form.dart
