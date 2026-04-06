part of 'welcome_screen.dart';

// ─── Auth Choice Step ─────────────────────────────────────────────────────────
class _AuthChoiceStep extends StatelessWidget {
  final VoidCallback onRegister;
  final VoidCallback onLogin;
  const _AuthChoiceStep({required this.onRegister, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const ValueKey('authChoice'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Text.rich(TextSpan(children: [
              TextSpan(text: 'FIN', style: GoogleFonts.spaceGrotesk(color: AppTheme.accent, fontSize: 28, fontWeight: FontWeight.w800)),
              TextSpan(text: 'QUIZ', style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w800)),
            ])),
            const SizedBox(height: 16),
            Text('Your financial\nlearning journey\nstarts here.', style: AppTheme.displayLarge.copyWith(fontSize: 32)),
            const SizedBox(height: 8),
            Text('Quiz-based learning for real-world money skills.', style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary)),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: onRegister,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent, foregroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text('Create Account', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 56,
              child: OutlinedButton(
                onPressed: onLogin,
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.border, width: 1.5), foregroundColor: AppTheme.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text('Log In', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 56,
              child: OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Google Sign-In requires backend setup.'), duration: Duration(seconds: 2)),
                ),
                icon: const Text('G', style: TextStyle(color: AppTheme.accentBlue, fontWeight: FontWeight.w800, fontSize: 18)),
                label: Text('Continue with Google', style: GoogleFonts.spaceGrotesk(color: AppTheme.textSecondary, fontWeight: FontWeight.w500, fontSize: 15)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
