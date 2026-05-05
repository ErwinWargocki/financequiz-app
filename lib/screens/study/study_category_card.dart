import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_spacing.dart';
import '../../data/study_category_info.dart';

// ─── Category Card ────────────────────────────────────────────────────────────
class StudyCategoryCard extends StatelessWidget {
  final StudyCategoryInfo info;
  final int topicCount;
  final VoidCallback onTap;

  const StudyCategoryCard({
    super.key,
    required this.info,
    required this.topicCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = info.color;
    final p = AppTheme.palette(context);
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
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
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(info.icon, style: const TextStyle(fontSize: 44))),
            ),
            AppSpacing.h12,
            Text(
              info.label,
              style: GoogleFonts.spaceGrotesk(color: p.text, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(info.subtitle, style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$topicCount ${topicCount == 1 ? 'topic' : 'topics'}',
                style: AppTheme.labelSmall.copyWith(color: color, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            AppSpacing.h10,
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
                child: Text('Explore →', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
