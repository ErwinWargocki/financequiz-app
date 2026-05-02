part of 'quiz_screen.dart';

// ─── Exit Dialog ──────────────────────────────────────────────────────────────
void _showQuizExitDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppTheme.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppTheme.border)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 40)),
            AppSpacing.h12,
            Text('Quit Quiz?', style: AppTheme.headlineMedium),
            AppSpacing.sm,
            Text('Your progress will be lost.', style: AppTheme.bodyMedium, textAlign: TextAlign.center),
            AppSpacing.lg,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.border),
                      foregroundColor: AppTheme.textPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Stay'),
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () { Navigator.pop(context); Navigator.pop(context); },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Quit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
