part of 'study_screen.dart';

// ─── Category Card ────────────────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final _CategoryInfo info;
  final int topicCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.info,
    required this.topicCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = info.color;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 72,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(info.icon, style: const TextStyle(fontSize: 44))),
            ),
            const SizedBox(height: 12),
            Text(
              info.label,
              style: GoogleFonts.spaceGrotesk(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(info.subtitle, style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$topicCount ${topicCount == 1 ? 'topic' : 'topics'}',
                style: AppTheme.labelSmall.copyWith(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Explore →',
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
