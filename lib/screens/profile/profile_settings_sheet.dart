part of 'profile_screen.dart';

// ─── Settings Tile ────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppTheme.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.5))),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label, style: AppTheme.bodyLarge.copyWith(color: color)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Mode Switcher Tile ───────────────────────────────────────────────────────
class _ModeSwitcherTile extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _ModeSwitcherTile({required this.isDarkMode, required this.onPrevious, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.5))),
      child: Row(
        children: [
          const Icon(Icons.brightness_6_outlined, color: AppTheme.textPrimary, size: 20),
          const SizedBox(width: 12),
          Text('Theme Mode', style: AppTheme.bodyLarge),
          const Spacer(),
          IconButton(onPressed: onPrevious, icon: const Icon(Icons.chevron_left_rounded), color: AppTheme.textSecondary, visualDensity: VisualDensity.compact),
          Text(isDarkMode ? 'Dark' : 'Light', style: AppTheme.bodyLarge.copyWith(color: AppTheme.accent)),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right_rounded), color: AppTheme.textSecondary, visualDensity: VisualDensity.compact),
        ],
      ),
    );
  }
}
