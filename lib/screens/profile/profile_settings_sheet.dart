part of 'profile_screen.dart';

// ─── Settings Tile ────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette(context);
    final tileColor = color ?? p.text;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: tileColor, size: 20),
            const SizedBox(width: 12),
            Text(label, style: AppTheme.bodyLarge.copyWith(color: tileColor)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: p.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Mode Switcher Theme Tile ───────────────────────────────────────────────────────
class _ModeSwitcherTile extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _ModeSwitcherTile({required this.isDarkMode, required this.onPrevious, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.brightness_6_outlined, color: p.text, size: 20),
          const SizedBox(width: 12),
          Text('Theme Mode', style: AppTheme.bodyLarge),
          const Spacer(),
          IconButton(
            onPressed: onPrevious,
            icon: Icon(Icons.chevron_left_rounded, color: p.textSub),
            visualDensity: VisualDensity.compact,
          ),
          Text(isDarkMode ? 'Dark' : 'Light',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.accent)),
          IconButton(
            onPressed: onNext,
            icon: Icon(Icons.chevron_right_rounded, color: p.textSub),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
