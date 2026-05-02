part of 'quiz_screen.dart';

// ─── Quiz Header ──────────────────────────────────────────────────────────────
class _QuizHeader extends StatelessWidget {
  final QuizCategory category;
  final int currentIndex;
  final int totalCount;
  final int score;
  final Color catColor;
  final double progress;
  final VoidCallback onExit;

  const _QuizHeader({
    required this.category, required this.currentIndex, required this.totalCount,
    required this.score, required this.catColor, required this.progress, required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border, width: 0.5))),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onExit,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: p.border)),
                  child: Icon(Icons.close_rounded, color: p.textSub, size: 18),
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(category.icon, style: const TextStyle(fontSize: 16)),
                      AppSpacing.w6,
                      Text(category.name, style: AppTheme.titleLarge.copyWith(fontSize: 15)),
                    ]),
                    Text('${currentIndex + 1} of $totalCount', style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: catColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Text('⭐ $score', style: GoogleFonts.spaceGrotesk(color: catColor, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ],
          ),
          AppSpacing.h10,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: progress, backgroundColor: p.border, valueColor: AlwaysStoppedAnimation(catColor), minHeight: 4),
          ),
        ],
      ),
    );
  }
}

// ─── Timer Bar ────────────────────────────────────────────────────────────────
class _TimerBar extends StatelessWidget {
  final int timeLeft;
  final int timePerQuestion;
  final Color catColor;

  const _TimerBar({required this.timeLeft, required this.timePerQuestion, required this.catColor});

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette(context);
    final c = AppColors.of(context);
    final timerColor = timeLeft > 10 ? catColor : timeLeft > 5 ? AppTheme.accentWarm : c.danger;
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: timerColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: timerColor.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Icon(Icons.timer_outlined, size: 15, color: timerColor),
            const SizedBox(width: 5),
            Text('$timeLeft s', style: GoogleFonts.jetBrainsMono(color: timerColor, fontWeight: FontWeight.w700, fontSize: 14)),
          ]),
        ),
        AppSpacing.w10,
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: timeLeft / timePerQuestion, backgroundColor: p.border, valueColor: AlwaysStoppedAnimation(timerColor), minHeight: 6),
          ),
        ),
      ],
    );
  }
}

// ─── Question Card ────────────────────────────────────────────────────────────
class _QuestionCard extends StatelessWidget {
  final QuizQuestion question;
  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette(context);
    final c = AppColors.of(context);
    final diffColor = question.difficulty == 'easy' ? c.success : question.difficulty == 'medium' ? AppTheme.accentWarm : c.danger;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: diffColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(question.difficulty.toUpperCase(), style: AppTheme.labelSmall.copyWith(color: diffColor, fontSize: 10)),
          ),
          AppSpacing.h12,
          Text(question.question, style: AppTheme.titleLarge.copyWith(fontSize: 17, height: 1.4)),
        ],
      ),
    );
  }
}

// ─── Option Tile ──────────────────────────────────────────────────────────────
class _OptionTile extends StatelessWidget {
  final QuizQuestion question;
  final int index;
  final Color catColor;
  final int? selectedOption;
  final int? firstAttemptSelection;
  final bool answered;
  final Animation<double> shakeAnimation;
  final ValueChanged<int> onSelect;

  const _OptionTile({
    required this.question, required this.index, required this.catColor,
    required this.selectedOption, required this.firstAttemptSelection,
    required this.answered, required this.shakeAnimation, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette(context);
    final c = AppColors.of(context);
    final isSelected = selectedOption == index;
    final isCorrect = index == question.correctIndex;
    final isWrongAttempt = firstAttemptSelection == index;
    final optionLetters = ['A', 'B', 'C', 'D'];

    Color borderColor = p.border;
    Color bgColor = p.card;
    Color textColor = p.text;
    IconData? trailingIcon;
    var textDecoration = TextDecoration.none;

    if (answered) {
      if (selectedOption != -1 && isCorrect) {
        borderColor = c.success; bgColor = c.success.withValues(alpha: 0.1);
        trailingIcon = Icons.check_circle_rounded; textColor = c.success;
      } else if (isSelected && !isCorrect) {
        borderColor = c.danger; bgColor = c.danger.withValues(alpha: 0.1);
        trailingIcon = Icons.cancel_rounded; textColor = c.danger;
        textDecoration = TextDecoration.lineThrough;
      } else if (isWrongAttempt && !isSelected) {
        borderColor = c.danger.withValues(alpha: 0.35);
        bgColor = c.danger.withValues(alpha: 0.06);
        textColor = p.textMuted;
        textDecoration = TextDecoration.lineThrough;
      }
    } else {
      if (isWrongAttempt) {
        borderColor = c.danger.withValues(alpha: 0.4);
        bgColor = c.danger.withValues(alpha: 0.07);
        textColor = p.textMuted;
        textDecoration = TextDecoration.lineThrough;
      } else if (isSelected) {
        borderColor = catColor; bgColor = catColor.withValues(alpha: 0.1);
      }
    }

    return AnimatedBuilder(
      animation: shakeAnimation,
      builder: (context, child) => Transform.translate(
        offset: (isSelected && answered && !isCorrect) ? Offset(shakeAnimation.value, 0) : Offset.zero,
        child: child,
      ),
      child: GestureDetector(
        onTap: () => onSelect(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor, width: 1.5)),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: answered && isCorrect ? c.success
                      : (answered && isSelected && !isCorrect) || isWrongAttempt ? c.danger.withValues(alpha: isWrongAttempt && !isSelected ? 0.5 : 1.0)
                      : isSelected ? catColor : p.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(optionLetters[index], style: GoogleFonts.spaceGrotesk(
                    color: isSelected || (answered && isCorrect) || isWrongAttempt ? Colors.white : p.textSub,
                    fontWeight: FontWeight.w700, fontSize: 13,
                    decoration: textDecoration,
                    decorationColor: Colors.white,
                  )),
                ),
              ),
              AppSpacing.w12,
              Expanded(child: Text(
                question.options[index],
                style: AppTheme.bodyLarge.copyWith(
                  color: textColor, fontSize: 15, height: 1.3,
                  decoration: textDecoration,
                  decorationColor: textColor,
                  decorationThickness: 2.0,
                ),
              )),
              if (trailingIcon != null) ...[AppSpacing.smH, Icon(trailingIcon, color: textColor, size: 20)],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Explanation Card ─────────────────────────────────────────────────────────
class _ExplanationCard extends StatelessWidget {
  final QuizQuestion question;
  final int? selectedOption;
  const _ExplanationCard({required this.question, required this.selectedOption});

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette(context);
    final c = AppColors.of(context);
    final isCorrect = selectedOption == question.correctIndex;
    final color = isCorrect ? c.success : c.danger;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(isCorrect ? '✅' : '❌', style: const TextStyle(fontSize: 18)),
            AppSpacing.smH,
            Text(isCorrect ? 'Correct!' : 'Not quite!', style: GoogleFonts.spaceGrotesk(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
          ]),
          AppSpacing.sm,
          Text(question.explanation, style: AppTheme.bodyMedium.copyWith(color: p.text, height: 1.5)),
        ],
      ),
    );
  }
}

// ─── Next Button ──────────────────────────────────────────────────────────────
class _NextButton extends StatelessWidget {
  final bool isLast;
  final Color catColor;
  final VoidCallback onNext;
  const _NextButton({required this.isLast, required this.catColor, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(color: p.bg, border: Border(top: BorderSide(color: p.border, width: 0.5))),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(backgroundColor: catColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: Text(isLast ? 'See Results 🏁' : 'Next Question →', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ),
    );
  }
}
