import 'package:flutter/material.dart';

// ─── AppColors — semantic / status colors ────────────────────────────────────
// Registered in ThemeData.extensions for both dark and light themes.
// Access via AppColors.of(context).danger etc.
class AppColors extends ThemeExtension<AppColors> {
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  const AppColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  static const dark = AppColors(
    success: Color(0xFF00E5A0),
    warning: Color(0xFFFFB800),
    danger: Color(0xFFFF4757),
    info: Color(0xFF4C6EF5),
  );

  static const light = AppColors(
    success: Color(0xFF00B87A),
    warning: Color(0xFFE6A200),
    danger: Color(0xFFD32F2F),
    info: Color(0xFF1F7AE0),
  );

  @override
  AppColors copyWith({Color? success, Color? warning, Color? danger, Color? info}) {
    return AppColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

// ─── LayerTheme — surface / background / text layer colors ───────────────────
// Registered in ThemeData.extensions for both dark and light themes.
// Access via LayerTheme.of(context).bg etc.
// AppTheme.palette(context) is a convenience alias for LayerTheme.of(context).
class LayerTheme extends ThemeExtension<LayerTheme> {
  final Color bg;       // scaffold background
  final Color surface;  // nav bar, bottom bar, drawers
  final Color card;     // cards, sheets, containers
  final Color border;   // dividers, strokes, outlines
  final Color text;     // primary text
  final Color textSub;  // secondary / label text
  final Color textMuted; // hint / disabled / muted text

  const LayerTheme({
    required this.bg,
    required this.surface,
    required this.card,
    required this.border,
    required this.text,
    required this.textSub,
    required this.textMuted,
  });

  static LayerTheme of(BuildContext context) =>
      Theme.of(context).extension<LayerTheme>()!;

  static const dark = LayerTheme(
    bg:        Color(0xFF0A0A0A),
    surface:   Color(0xFF141414),
    card:      Color(0xFF1A1A1A),
    border:    Color(0xFF2A2A2A),
    text:      Color(0xFFF5F5F5),
    textSub:   Color(0xFF8A8A8A),
    textMuted: Color(0xFF4A4A4A),
  );

  static const light = LayerTheme(
    bg:        Color(0xFFF7F8FA),
    surface:   Color(0xFFFFFFFF),
    card:      Color(0xFFFFFFFF),
    border:    Color(0xFFE2E4E9),
    text:      Color(0xFF1A1A1A),
    textSub:   Color(0xFF6B7280),
    textMuted: Color(0xFF9CA3AF),
  );

  @override
  LayerTheme copyWith({
    Color? bg, Color? surface, Color? card, Color? border,
    Color? text, Color? textSub, Color? textMuted,
  }) {
    return LayerTheme(
      bg:        bg        ?? this.bg,
      surface:   surface   ?? this.surface,
      card:      card      ?? this.card,
      border:    border    ?? this.border,
      text:      text      ?? this.text,
      textSub:   textSub   ?? this.textSub,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  LayerTheme lerp(ThemeExtension<LayerTheme>? other, double t) {
    if (other is! LayerTheme) return this;
    return LayerTheme(
      bg:        Color.lerp(bg,        other.bg,        t)!,
      surface:   Color.lerp(surface,   other.surface,   t)!,
      card:      Color.lerp(card,      other.card,      t)!,
      border:    Color.lerp(border,    other.border,    t)!,
      text:      Color.lerp(text,      other.text,      t)!,
      textSub:   Color.lerp(textSub,   other.textSub,   t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}
