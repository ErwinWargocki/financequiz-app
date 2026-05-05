import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_spacing.dart';

// ─── Security Questions Step (Sign-Up) ────────────────────────────────────────
class WelcomeSecurityQuestionsStep extends StatelessWidget {
  final List<String> securityQuestions;
  final List<int?> selectedQuestions;
  final List<TextEditingController> answerCtrls;
  final void Function(int slotIndex, int? questionIndex) onQuestionChanged;
  final String? error;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const WelcomeSecurityQuestionsStep({
    super.key,
    required this.securityQuestions,
    required this.selectedQuestions,
    required this.answerCtrls,
    required this.onQuestionChanged,
    required this.error,
    required this.isLoading,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const ValueKey('securityQuestions'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.md,
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
              padding: EdgeInsets.zero,
            ),
            AppSpacing.md,
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accentWarm.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.accentWarm.withValues(alpha: 0.2)),
              ),
              child: const Text('🔐', style: TextStyle(fontSize: 28)),
            ),
            AppSpacing.h20,
            Text('Security Questions', style: AppTheme.displayLarge),
            AppSpacing.h6,
            Text(
              'Choose 3 questions and set your personal answers. These will be used to verify your identity if you forget your password.',
              style: AppTheme.bodyMedium,
            ),
            AppSpacing.xl,
            for (int i = 0; i < 3; i++) ...[
              _QuestionSlot(
                slotNumber: i + 1,
                selectedIndex: selectedQuestions[i],
                securityQuestions: securityQuestions,
                otherSelected: [
                  for (int j = 0; j < 3; j++) if (j != i) selectedQuestions[j],
                ],
                answerCtrl: answerCtrls[i],
                onQuestionChanged: (q) => onQuestionChanged(i, q),
              ),
              AppSpacing.h20,
            ],
            if (error != null) ...[
              Text(error!, style: AppTheme.bodyMedium.copyWith(color: AppTheme.danger)),
              AppSpacing.h12,
            ],
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                child: isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primary))
                    : const Text('Complete Sign Up →'),
              ),
            ),
            AppSpacing.xl,
          ],
        ),
      ),
    );
  }
}

class _QuestionSlot extends StatelessWidget {
  final int slotNumber;
  final int? selectedIndex;
  final List<String> securityQuestions;
  final List<int?> otherSelected;
  final TextEditingController answerCtrl;
  final ValueChanged<int?> onQuestionChanged;

  const _QuestionSlot({
    required this.slotNumber,
    required this.selectedIndex,
    required this.securityQuestions,
    required this.otherSelected,
    required this.answerCtrl,
    required this.onQuestionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question $slotNumber',
            style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary, letterSpacing: 1.5),
          ),
          AppSpacing.h10,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButton<int>(
              value: selectedIndex,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              dropdownColor: AppTheme.surfaceLight,
              hint: Text('Select a question', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted)),
              style: AppTheme.bodyMedium,
              iconEnabledColor: AppTheme.textSecondary,
              items: List.generate(securityQuestions.length, (idx) {
                final isUsedElsewhere = otherSelected.contains(idx);
                return DropdownMenuItem<int>(
                  value: idx,
                  enabled: !isUsedElsewhere,
                  child: Text(
                    securityQuestions[idx],
                    style: AppTheme.bodyMedium.copyWith(
                      color: isUsedElsewhere ? AppTheme.textMuted : AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
              onChanged: onQuestionChanged,
            ),
          ),
          if (selectedIndex != null) ...[
            AppSpacing.h12,
            TextField(
              controller: answerCtrl,
              style: AppTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Your answer',
                prefixIcon: Icon(Icons.edit_outlined, color: AppTheme.textMuted, size: 20),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
