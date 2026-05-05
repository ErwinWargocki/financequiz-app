import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

// ─── Shared Base Card ─────────────────────────────────────────────────────────
class HomeFeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const HomeFeaturedCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
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
                      colors: [color.withValues(alpha: 0.68), color.withValues(alpha: 0.25)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: color.withValues(alpha: 0.28), width: 1.5),
                  ),
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
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
                    ),
                    AppSpacing.mdH,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          AppSpacing.xs,
                          Text(
                            subtitle,
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
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

// ─── Test Time Card ───────────────────────────────────────────────────────────
class HomeTestTimeCard extends StatelessWidget {
  final VoidCallback onTap;
  const HomeTestTimeCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return HomeFeaturedCard(
      title: 'Test Time',
      subtitle: 'Time to turn notes into quiz questions.',
      emoji: '📝',
      color: c.danger,
      onTap: onTap,
    );
  }
}

// ─── Study Time Card ──────────────────────────────────────────────────────────
class HomeStudyTimeCard extends StatelessWidget {
  final VoidCallback onTap;
  const HomeStudyTimeCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HomeFeaturedCard(
      title: 'Study Topics',
      subtitle: 'Learn before you quiz',
      emoji: '📖',
      color: AppTheme.accent,
      onTap: onTap,
    );
  }
}
