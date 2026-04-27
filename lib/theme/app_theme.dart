import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ─── Brand / accent colors (theme-independent) ───────────────────────────
  static const Color accent      = Color(0xFF00E5A0);
  static const Color accentWarm  = Color(0xFFFFB800);
  static const Color accentBlue  = Color(0xFF4C6EF5);

  // ─── Semantic status colors (dark-mode constants) ────────────────────────
  // Use AppColors.of(context).* in widgets for theme-aware variants.
  static const Color success = Color(0xFF00E5A0);
  static const Color danger  = Color(0xFFFF4757);
  static const Color warning = Color(0xFFFFB800);

  // ─── Dark-mode surface constants (backward-compat for out-of-scope screens)
  // Prefer AppTheme.palette(context).* → LayerTheme in new / migrated code.
  static const Color primary       = Color(0xFF0A0A0A);
  static const Color surface       = Color(0xFF141414);
  static const Color surfaceLight  = Color(0xFF1E1E1E);
  static const Color cardBg        = Color(0xFF1A1A1A);
  static const Color border        = Color(0xFF2A2A2A);
  static const Color textPrimary   = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textMuted     = Color(0xFF4A4A4A);

  // ─── Quiz category colors (brand — same in both themes) ─────────────────
  static const Color catBudgeting = Color(0xFF4C6EF5);
  static const Color catInvesting = Color(0xFF00E5A0);
  static const Color catCrypto    = Color(0xFFFF6B35);
  static const Color catSavings   = Color(0xFFFFB800);
  static const Color catTaxes     = Color(0xFFB47FFF);
  static const Color catDebt      = Color(0xFFFF4757);

  // ─── Study difficulty colors ─────────────────────────────────────────────
  static const Color diffAll          = Color(0xFF78909C); // blue-grey / "All"
  static const Color diffBeginner     = Color(0xFF4ADE80); // green
  static const Color diffIntermediate = Color(0xFFFB923C); // orange
  static const Color diffAdvanced     = Color(0xFFFF4757); // red (= danger)

  // ─── Loading / splash screen brand colors ────────────────────────────────
  static const Color loadingBg          = Color(0xFFDCFCE7); // light-green scaffold
  static const Color loadingAccent      = Color(0xFF059669); // emerald-600 "FIN"
  static const Color loadingAccentDark  = Color(0xFF047857); // emerald-700 "QUIZ"

  /// Convenience alias for [LayerTheme.of(context)].
  /// All widgets should use this instead of any hardcoded color constant.
  static LayerTheme palette(BuildContext context) => LayerTheme.of(context);

  // ─── Dark theme ──────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const layer  = LayerTheme.dark;
    const colors = AppColors.dark;

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: layer.bg,
      extensions: const [colors, layer],
      colorScheme: ColorScheme.dark(
        primary:     accent,
        secondary:   accentBlue,
        surface:     layer.card,
        error:       colors.danger,
        onPrimary:   layer.bg,
        onSecondary: layer.text,
        onSurface:   layer.text,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor:    layer.text,
        displayColor: layer.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: layer.bg,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: layer.text),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: layer.text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: layer.surface,
        selectedItemColor: accent,
        unselectedItemColor: layer.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: layer.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: layer.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: layer.bg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: layer.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: layer.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: layer.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: TextStyle(color: layer.textMuted),
        labelStyle: TextStyle(color: layer.textSub),
      ),
    );
  }

  // ─── Light theme ─────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const layer  = LayerTheme.light;
    const colors = AppColors.light;

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: layer.bg,
      extensions: const [colors, layer],
      colorScheme: ColorScheme.light(
        primary:     const Color(0xFF1F7AE0),
        secondary:   const Color(0xFF5C6BC0),
        surface:     layer.surface,
        error:       colors.danger,
        onPrimary:   Colors.white,
        onSecondary: Colors.white,
        onSurface:   layer.text,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor:    layer.text,
        displayColor: layer.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: layer.card,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: layer.text),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: layer.text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: layer.card,
        selectedItemColor: accent,
        unselectedItemColor: layer.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: layer.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: layer.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: layer.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: layer.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: layer.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: TextStyle(color: layer.textMuted),
        labelStyle: TextStyle(color: layer.textSub),
      ),
    );
  }

  // ─── Text styles (color-free — inherit from DefaultTextStyle / textTheme) ─

  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
        fontSize: 40, fontWeight: FontWeight.w800,
        letterSpacing: -1.5, height: 1.1,
      );

  static TextStyle get headlineLarge => GoogleFonts.spaceGrotesk(
        fontSize: 28, fontWeight: FontWeight.w700,
        letterSpacing: -0.8, height: 1.2,
      );

  static TextStyle get headlineMedium => GoogleFonts.spaceGrotesk(
        fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5,
      );

  static TextStyle get titleLarge => GoogleFonts.spaceGrotesk(
        fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, height: 1.5,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8,
      );

  static TextStyle get monoLarge => GoogleFonts.jetBrainsMono(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: accent, letterSpacing: -1,
      );
}
