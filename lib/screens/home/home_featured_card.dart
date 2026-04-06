part of 'home_screen.dart';

// ─── Test Time Card ───────────────────────────────────────────────────────────
class _TestTimeCard extends StatelessWidget {
  final VoidCallback onTap;
  const _TestTimeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const redBase = Color.fromARGB(255, 255, 0, 21);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color.fromARGB(196, 255, 58, 75).withValues(alpha:0.68), const Color.fromARGB(159, 255, 24, 43).withValues(alpha:0.25)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: redBase.withValues(alpha: 0.28), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Positioned(
                right: -20, top: -20,
                child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, color: redBase.withValues(alpha: 0.06))),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(color: redBase.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                      child: const Center(child: Text('📝', style: TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Test Time', style: GoogleFonts.spaceGrotesk(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          const Text('Time to turn notes into quiz questions.', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: redBase.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFFFF4757), size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Study Time Card ──────────────────────────────────────────────────────────
class _StudyTimeCard extends StatelessWidget {
  final VoidCallback onTap;
  const _StudyTimeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color.fromARGB(85, 76, 245, 130).withValues(alpha: 0.68), const Color.fromARGB(159, 60, 243, 81).withValues(alpha: 0.25)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -20, top: -20,
                child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05))),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
                      child: const Center(child: Text('📖', style: TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Study Topics', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text('Learn before you quiz', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
