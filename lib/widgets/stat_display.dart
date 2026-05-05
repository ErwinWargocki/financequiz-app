import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';

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
    final padding = isLarge
        ? const EdgeInsets.all(14)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
    final radius = isLarge ? 14.0 : 12.0;
    final bgAlpha = isLarge ? 0.08 : 0.1;
    final iconSize = isLarge ? 22.0 : 18.0;
    final gap = isLarge ? AppSpacing.sm : AppSpacing.xs;
    final valueFontSize = isLarge ? 22.0 : 16.0;
    final valueFontWeight = isLarge ? FontWeight.w800 : FontWeight.w700;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: bgAlpha),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: TextStyle(fontSize: iconSize)),
          gap,
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              color: color,
              fontSize: valueFontSize,
              fontWeight: valueFontWeight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(color: color.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}
