import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_spacing.dart';

// ─── Security Challenge Step ───────────────────────────────────────────────────
// Shows a randomly selected security question from the user's saved answers.
// The user has 4 attempts before the screen locks. A row of 4 dots tracks
// how many attempts have been used (red dot = used attempt).
class WelcomeSecurityChallengeStep extends StatelessWidget {
  final String question;
  final TextEditingController answerCtrl;
  final int attempts;
  final bool isLocked;
  final String? error;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onBackToLogin;

  const WelcomeSecurityChallengeStep({
    super.key,
    required this.question,
    required this.answerCtrl,
    required this.attempts,
    required this.isLocked,
    required this.error,
    required this.isLoading,
    required this.onSubmit,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    // The accent colour and icon flip to red/lock when the screen is locked
    final accent = isLocked ? AppTheme.danger : AppTheme.accentWarm;

    return SafeArea(
      key: const ValueKey('securityChallenge'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.md,
            // Back arrow is hidden while locked — the user must use the button
            if (!isLocked)
              IconButton(
                onPressed: onBackToLogin,
                icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                padding: EdgeInsets.zero,
              ),
            AppSpacing.md,
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              child: Text(isLocked ? '🔒' : '🛡️', style: const TextStyle(fontSize: 28)),
            ),
            AppSpacing.h20,
            Text(
              isLocked ? 'Account Locked' : 'Security Question',
              style: AppTheme.displayLarge,
            ),
            AppSpacing.h6,

            // ── Locked state — show message and a back button only ────────────
            if (isLocked) ...[
              Text(
                'Too many incorrect attempts. Please go back and try again.',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.danger),
              ),
              AppSpacing.h36,
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: onBackToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceLight,
                    foregroundColor: AppTheme.textPrimary,
                  ),
                  child: const Text('← Back to Login'),
                ),
              ),
            ]

            // ── Active challenge ──────────────────────────────────────────────
            else ...[
              Text(
                'Answer the question below to verify your identity.',
                style: AppTheme.bodyMedium,
              ),
              AppSpacing.sm,
              // 4 dots — each one fills red as an attempt is used
              Row(
                children: List.generate(4, (i) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < attempts ? AppTheme.danger : AppTheme.border,
                    ),
                  ),
                )),
              ),
              AppSpacing.h28,
              // The question is displayed in a card so it stands out visually
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(question, style: AppTheme.bodyLarge),
              ),
              AppSpacing.h20,
              Text(
                'YOUR ANSWER',
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.textSecondary, letterSpacing: 1.5,
                ),
              ),
              AppSpacing.sm,
              TextField(
                controller: answerCtrl,
                style: AppTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Enter your answer',
                  prefixIcon: Icon(Icons.lock_open_outlined, color: AppTheme.textMuted, size: 20),
                ),
              ),
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
                      : const Text('Verify →'),
                ),
              ),
            ],
            AppSpacing.xl,
          ],
        ),
      ),
    );
  }
}

// ─── New Password Step ─────────────────────────────────────────────────────────
/* Shown after the security challenge is passed. The user enters their new
 password twice for confirmation. The form validates length and match before
 calling onSubmit, which writes the hashed password to the database.*/
class WelcomeNewPasswordStep extends StatelessWidget {
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onToggleObscure;
  final VoidCallback onToggleObscureConfirm;
  final String? error;
  final bool isLoading;
  final VoidCallback onSubmit;

  const WelcomeNewPasswordStep({
    super.key,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onToggleObscure,
    required this.onToggleObscureConfirm,
    required this.error,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const ValueKey('newPassword'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.md,
            // Green checkmark badge signals that identity was verified
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
              ),
              child: const Text('✅', style: TextStyle(fontSize: 28)),
            ),
            AppSpacing.h20,
            Text('New Password', style: AppTheme.displayLarge),
            AppSpacing.h6,
            Text(
              'Identity verified. Set your new password below.',
              style: AppTheme.bodyMedium,
            ),
            AppSpacing.h36,
            Text(
              'NEW PASSWORD',
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.textSecondary, letterSpacing: 1.5,
              ),
            ),
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
            AppSpacing.md,
            Text(
              'CONFIRM PASSWORD',
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.textSecondary, letterSpacing: 1.5,
              ),
            ),
            AppSpacing.sm,
            TextField(
              controller: confirmCtrl,
              style: AppTheme.bodyLarge,
              obscureText: obscureConfirm,
              decoration: InputDecoration(
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 20),
                suffixIcon: GestureDetector(
                  onTap: onToggleObscureConfirm,
                  child: Icon(
                    obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppTheme.textMuted, size: 20,
                  ),
                ),
              ),
            ),
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
                    : const Text('Reset Password →'),
              ),
            ),
            AppSpacing.xl,
          ],
        ),
      ),
    );
  }
}
