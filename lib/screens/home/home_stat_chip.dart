part of 'home_screen.dart';

// ─── Stat Chip ────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatChip(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return StatDisplay(
      icon: icon,
      value: value,
      label: label,
      color: color,
    );
  }
}
