part of 'welcome_screen.dart';

// ─── Onboard Page Data ────────────────────────────────────────────────────────
class _OnboardPage {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;
  const _OnboardPage({required this.emoji, required this.title, required this.subtitle, required this.accent});
}

// ─── Onboarding Step ──────────────────────────────────────────────────────────
class _OnboardingStep extends StatelessWidget {
  final List<_OnboardPage> pages;
  final int currentPage;
  final Animation<double> floatAnimation;
  final Animation<double> pulseAnimation;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _OnboardingStep({
    required this.pages, required this.currentPage,
    required this.floatAnimation, required this.pulseAnimation,
    required this.pageController, required this.onPageChanged,
    required this.onNext, required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final page = pages[currentPage];
    return SafeArea(
      key: const ValueKey('onboarding'),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: page.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: page.accent.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Text('FIN', style: AppTheme.labelSmall.copyWith(color: page.accent, fontWeight: FontWeight.w800, letterSpacing: 2)),
                    Text('QUIZ', style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  ]),
                ),
                const Spacer(),
                if (currentPage < pages.length - 1)
                  TextButton(
                    onPressed: onSkip,
                    child: Text('Skip', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                  ),
              ],
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: floatAnimation,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, floatAnimation.value),
              child: AnimatedBuilder(
                animation: pulseAnimation,
                builder: (_, __) => Transform.scale(
                  scale: pulseAnimation.value,
                  child: Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      color: page.accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: page.accent.withOpacity(0.2), width: 1.5),
                      boxShadow: [BoxShadow(color: page.accent.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)],
                    ),
                    child: Center(child: Text(page.emoji, style: const TextStyle(fontSize: 60))),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                SizedBox(
                  height: 170,
                  child: PageView.builder(
                    controller: pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: onPageChanged,
                    itemCount: pages.length,
                    itemBuilder: (_, i) {
                      final p = pages[i];
                      return Column(children: [
                        Text(p.title, style: AppTheme.displayLarge.copyWith(fontSize: 36), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(p.subtitle, style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary, height: 1.6), textAlign: TextAlign.center),
                      ]);
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pages.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: currentPage == i ? 24 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: currentPage == i ? page.accent : AppTheme.textMuted,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(backgroundColor: page.accent, foregroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text(currentPage < pages.length - 1 ? 'Continue' : 'Get Started',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 17, letterSpacing: 0.2)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
