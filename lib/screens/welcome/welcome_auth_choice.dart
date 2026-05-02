part of 'welcome_screen.dart';

// ─── Auth Choice Step ─────────────────────────────────────────────────────────
class _AuthChoiceStep extends StatefulWidget {
  final VoidCallback onRegister;
  final VoidCallback onLogin;
  const _AuthChoiceStep({required this.onRegister, required this.onLogin});

  @override
  State<_AuthChoiceStep> createState() => _AuthChoiceStepState();
}

class _AuthChoiceStepState extends State<_AuthChoiceStep> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -7, end: 7)
        .animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const ValueKey('authChoice'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              ),
              child: Text.rich(TextSpan(children: [
                TextSpan(text: 'FIN', style: GoogleFonts.spaceGrotesk(color: AppTheme.accent, fontSize: 42, fontWeight: FontWeight.w800)),
                TextSpan(text: 'QUIZ', style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary, fontSize: 42, fontWeight: FontWeight.w800)),
              ])),
            ),
            AppSpacing.h20,
            Text(
              'Your financial\nlearning journey\nstarts here.',
              textAlign: TextAlign.center,
              style: AppTheme.displayLarge.copyWith(fontSize: 32, height: 1.15),
            ),
            AppSpacing.h28,
            Text(
              'Quiz-based learning for real-world money skills.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: widget.onRegister,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent, foregroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text('Create Account', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            AppSpacing.h12,
            SizedBox(
              width: double.infinity, height: 56,
              child: OutlinedButton(
                onPressed: widget.onLogin,
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.border, width: 1.5), foregroundColor: AppTheme.textPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text('Log In', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
            AppSpacing.h12,
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
            AppSpacing.xl,
          ],
        ),
      ),
    );
  }
}
