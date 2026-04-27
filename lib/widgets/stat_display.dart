import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum StatDisplaySize { small, large }

class StatDisplay extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;
  final StatDisplaySize size;

  const StatDisplay({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.size = StatDisplaySize.small,
  });

  @override
  Widget build(BuildContext context) {
    final isLarge = size == StatDisplaySize.large;
    return Expanded(
      child: Container(
        padding: isLarge
            ? const EdgeInsets.all(14)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isLarge ? 0.08 : 0.1),
          borderRadius: BorderRadius.circular(isLarge ? 14 : 12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: TextStyle(fontSize: isLarge ? 22 : 18)),
            SizedBox(height: isLarge ? 8 : 4),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                color: color,
                fontSize: isLarge ? 22 : 16,
                fontWeight: isLarge ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
            Text(label,
                style: AppTheme.labelSmall
                    .copyWith(color: color.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}
