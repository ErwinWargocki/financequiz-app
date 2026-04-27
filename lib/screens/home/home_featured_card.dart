part of 'home_screen.dart';

// ─── Shared Base Card ─────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.titleColor,
    required this.subtitleColor,
    required this.onTap,
  });

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
                      colors: [
                        color.withValues(alpha: 0.68),
                        color.withValues(alpha: 0.25),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: color.withValues(alpha: 0.28), width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(title,
                              style: GoogleFonts.spaceGrotesk(
                                  color: titleColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(subtitle,
                              style:
                                  TextStyle(color: subtitleColor, fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: color, size: 20),
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

// ─── Test Time Card ───────────────────────────────────────────────────────────
class _TestTimeCard extends StatelessWidget {
  final VoidCallback onTap;
  const _TestTimeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _FeaturedCard(
      title: 'Test Time',
      subtitle: 'Time to turn notes into quiz questions.',
      emoji: '📝',
      color: AppTheme.danger,
      titleColor: AppTheme.textPrimary,
      subtitleColor: const Color.fromARGB(187, 255, 255, 255),
      onTap: onTap,
    );
  }
}

// ─── Study Time Card ──────────────────────────────────────────────────────────
class _StudyTimeCard extends StatelessWidget {
  final VoidCallback onTap;
  const _StudyTimeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _FeaturedCard(
      title: 'Study Topics',
      subtitle: 'Learn before you quiz',
      emoji: '📖',
      color: AppTheme.accent,
      titleColor: Colors.white,
      subtitleColor: Colors.white.withValues(alpha: 0.8),
      onTap: onTap,
    );
  }
}
