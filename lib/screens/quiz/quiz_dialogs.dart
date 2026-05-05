import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

// ─── Exit Dialog ──────────────────────────────────────────────────────────────
void showQuizExitDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) {
      final p = AppTheme.palette(ctx);
      final c = AppColors.of(ctx);
      return Dialog(
        backgroundColor: p.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: p.border)),
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
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: p.border),
                        foregroundColor: p.text,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Stay'),
                    ),
                  ),
                  AppSpacing.w12,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () { Navigator.pop(ctx); Navigator.pop(ctx); },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.danger,
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
      );
    },
  );
}
