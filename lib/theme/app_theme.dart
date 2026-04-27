import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Core Palette — dark-mode constants used only where a static const is needed
  // (e.g. as a fallback or in a non-widget context).
  // In widgets prefer AppTheme.palette(context).* instead.
  static const Color primary = Color(0xFF0A0A0A);
  static const Color accent = Color(0xFF00E5A0);
  static const Color accentWarm = Color(0xFFFFB800);
  static const Color accentBlue = Color(0xFF4C6EF5);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceLight = Color(0xFF1E1E1E);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color border = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textMuted = Color(0xFF4A4A4A);
  static const Color success = Color(0xFF00E5A0);
  static const Color danger = Color(0xFFFF4757);
  static const Color warning = Color(0xFFFFB800);

  // Quiz Category Colors (brand — same in both themes)
  static const Color catBudgeting = Color(0xFF4C6EF5);
  static const Color catInvesting = Color(0xFF00E5A0);
  static const Color catCrypto = Color(0xFFFF6B35);
  static const Color catSavings = Color(0xFFFFB800);
  static const Color catTaxes = Color(0xFFB47FFF);
  static const Color catDebt = Color(0xFFFF4757);

  /// Returns the context-aware color palette for the current theme.
  static AppPalette palette(BuildContext context) => AppPalette.of(context);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primary,
      extensions: const [AppColors.dark],
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentBlue,
        surface: surfaceLight,
        error: danger,
        onPrimary: primary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textSecondary),
      ),
    );
  }

  static ThemeData get lightTheme {
    const Color lightBg = Color(0xFFF7F8FA);
    const Color lightCard = Color(0xFFFFFFFF);
    const Color lightBorder = Color(0xFFE2E4E9);
    const Color lightText = Color(0xFF1A1A1A);
    const Color lightTextSub = Color(0xFF6B7280);
    const Color lightTextMuted = Color(0xFF9CA3AF);
    const Color lightSurface = Color(0xFFFFFFFF);

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      extensions: const [AppColors.light],
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1F7AE0),
        secondary: Color(0xFF5C6BC0),
        surface: lightSurface,
        error: Color(0xFFD32F2F),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightText,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: lightText,
        displayColor: lightText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightCard,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: lightText),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: lightText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightCard,
        selectedItemColor: accent,
        unselectedItemColor: lightTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        fillColor: lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: lightTextMuted),
        labelStyle: const TextStyle(color: lightTextSub),
      ),
    );
  }

  // ─── Text styles (color-free — inherit from the current theme's DefaultTextStyle)

  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.1,
      );

  static TextStyle get headlineLarge => GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
      );

  static TextStyle get headlineMedium => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get titleLarge => GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      );

  static TextStyle get monoLarge => GoogleFonts.jetBrainsMono(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: accent,
        letterSpacing: -1,
      );
}

// ─── AppPalette ────────────────────────────────────────────────────────────────
// Context-aware color set. Use AppTheme.palette(context).* in widgets instead
// of AppTheme.primary / AppTheme.cardBg / etc.
class AppPalette {
  final Color bg;
  final Color surface;
  final Color card;
  final Color border;
  final Color text;
  final Color textSub;
  final Color textMuted;

  const AppPalette._({
    required this.bg,
    required this.surface,
    required this.card,
    required this.border,
    required this.text,
    required this.textSub,
    required this.textMuted,
  });

  static const dark = AppPalette._(
    bg: Color(0xFF0A0A0A),
    surface: Color(0xFF141414),
    card: Color(0xFF1A1A1A),
    border: Color(0xFF2A2A2A),
    text: Color(0xFFF5F5F5),
    textSub: Color(0xFF8A8A8A),
    textMuted: Color(0xFF4A4A4A),
  );

  static const light = AppPalette._(
    bg: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE2E4E9),
    text: Color(0xFF1A1A1A),
    textSub: Color(0xFF6B7280),
    textMuted: Color(0xFF9CA3AF),
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
