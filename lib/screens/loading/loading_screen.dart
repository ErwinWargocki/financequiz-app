/*import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_shell.dart';
import '../welcome/welcome_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // Phase timing (controller value 0 → 1, total 2400 ms)
  static const double _slideEnd    = 0.48; // slide-in ends
  static const double _holdEnd     = 0.62; // hold ends
  static const double _convergeEnd = 0.95; // converge ends
  static const double _fadeStart   = 0.78; // fade begins

  // Cached text metrics (measured once after first layout)
  double? _finW, _quizW, _textH;

  static const double _fontSize = 64;

  TextStyle get _finStyle => GoogleFonts.spaceGrotesk(
        fontSize: _fontSize,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        color: const Color(0xFF059669),
        height: 1,
      );

  TextStyle get _quizStyle => GoogleFonts.spaceGrotesk(
        fontSize: _fontSize,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        color: const Color(0xFF047857),
        height: 1,
      );

  void _measureText() {
    if (_finW != null) return;
    final fp = TextPainter(
      text: TextSpan(text: 'FIN', style: _finStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final qp = TextPainter(
      text: TextSpan(text: 'QUIZ', style: _quizStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    _finW   = fp.width;
    _quizW  = qp.width;
    _textH  = fp.height;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _ctrl.forward().then((_) => _navigate());
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            userId != null ? const MainShell() : const WelcomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Offset helpers ──────────────────────────────────────────────────────────

  double _finX(double t, double sw) {
    if (t <= _slideEnd) {
      final p = Curves.easeOutCubic.transform((t / _slideEnd).clamp(0.0, 1.0));
      return lerpDouble(-sw, 0, p)!;
    } else if (t <= _holdEnd) {
      return 0;
    } else {
      final p = Curves.easeInCubic.transform(
          ((t - _holdEnd) / (_convergeEnd - _holdEnd)).clamp(0.0, 1.0));
      return lerpDouble(0, sw * 0.28, p)!;
    }
  }

  double _quizX(double t, double sw) {
    if (t <= _slideEnd) {
      final p = Curves.easeOutCubic.transform((t / _slideEnd).clamp(0.0, 1.0));
      return lerpDouble(sw, 0, p)!;
    } else if (t <= _holdEnd) {
      return 0;
    } else {
      final p = Curves.easeInCubic.transform(
          ((t - _holdEnd) / (_convergeEnd - _holdEnd)).clamp(0.0, 1.0));
      return lerpDouble(0, -sw * 0.28, p)!;
    }
  }

  double _opacity(double t) {
    if (t <= _fadeStart) return 1.0;
    return lerpDouble(1.0, 0.0, (t - _fadeStart) / (1.0 - _fadeStart))!
        .clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    _measureText();

    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    // Natural positions when offset = 0:
    // both parts are horizontally adjacent and the pair is centered.
    final totalW = (_finW ?? 0) + (_quizW ?? 0);
    final pairLeft = (sw - totalW) / 2; // left edge of FIN at rest
    final midY = (sh - (_textH ?? _fontSize)) / 2; // same Y for both

    return Scaffold(
      backgroundColor: const Color(0xFFDCFCE7),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t      = _ctrl.value;
          final alpha  = _opacity(t);
          final dxFin  = _finX(t, sw);
          final dxQuiz = _quizX(t, sw);

          return Opacity(
            opacity: alpha,
            child: Stack(
              children: [
                // FIN — anchored to left half of the word, same Y as QUIZ
                Positioned(
                  left: pairLeft + dxFin,
                  top:  midY,
                  child: Text('FIN', style: _finStyle),
                ),
                // QUIZ — anchored immediately after FIN, same Y
                Positioned(
                  left: pairLeft + (_finW ?? 0) + dxQuiz,
                  top:  midY,
                  child: Text('QUIZ', style: _quizStyle),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}*/