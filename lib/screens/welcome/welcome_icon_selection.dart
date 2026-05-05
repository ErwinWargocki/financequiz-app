import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';

// ─── Icon Selection Step ──────────────────────────────────────────────────────
class WelcomeIconSelectionStep extends StatelessWidget {
  final int selectedIconIndex;
  final ValueChanged<int> onSelectIcon;
  final String? error;
  final bool isLoading;
  final VoidCallback onFinish;
  final VoidCallback onBack;

  const WelcomeIconSelectionStep({
    super.key,
    required this.selectedIconIndex, required this.onSelectIcon,
    required this.error, required this.isLoading,
    required this.onFinish, required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const ValueKey('iconSelection'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.md,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary), padding: EdgeInsets.zero),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose your\nprofile icon', style: AppTheme.displayLarge.copyWith(fontSize: 30)),
                AppSpacing.sm,
                Text('Pick the one that represents you best.', style: AppTheme.bodyMedium),
              ],
            ),
          ),
          AppSpacing.lg,
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 1,
              ),
              itemCount: ProfileIcons.all.length,
              itemBuilder: (_, i) {
                final selected = selectedIconIndex == i;
                return GestureDetector(
                  onTap: () => onSelectIcon(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.accent.withValues(alpha:0.15) : AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? AppTheme.accent : AppTheme.border, width: selected ? 2 : 1),
                      boxShadow: selected ? [BoxShadow(color: AppTheme.accent.withValues(alpha:0.25), blurRadius: 12, spreadRadius: 2)] : [],
                    ),
                    child: Center(child: Text(ProfileIcons.all[i], style: const TextStyle(fontSize: 30))),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                if (error != null) ...[
                  Text(error!, style: AppTheme.bodyMedium.copyWith(color: AppTheme.danger)),
                  AppSpacing.sm,
                ],
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onFinish,
                    child: isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primary))
                        : Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(ProfileIcons.all[selectedIconIndex], style: const TextStyle(fontSize: 20)),
                            AppSpacing.w10,
                            const Text('Continue →'),
                          ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
