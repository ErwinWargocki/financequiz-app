import 'package:flutter/material.dart';
import '../../widgets/stat_display.dart';

// ─── Stat Chip ────────────────────────────────────────────────────────────────
class HomeStatChip extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const HomeStatChip({super.key, required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StatDisplay(icon: icon, value: value, label: label, color: color),
    );
  }
}
