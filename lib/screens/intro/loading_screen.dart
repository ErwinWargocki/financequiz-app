// Intro animation — 7 000 ms total, six phases:
//
//   0.00 – 0.14  slide-in   : FIN from left, QUIZ from right
//   0.14 – 0.24  hold       : full FINQUIZ centred
//   0.24 – 0.36  converge   : I N Q U I Z drift to centre and fade out; F moves to centre
//   0.36 – 0.79  F pause    : only F visible, centred (~3 000 ms)
//   0.79 – 0.96  scale      : F enlarges from centre until it fills the screen
//   0.83 – 1.00  fade-out   : F (now full-screen) fades to transparent → navigate

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../main_shell.dart';
import '../welcome/welcome_screen.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});
  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  static const double _slideEnd    = 0.14; //  980 ms
  static const double _holdEnd     = 0.24; // 1680 ms
  static const double _convergeEnd = 0.36; // 2520 ms
  // 0.36 – 0.79  F sits alone (~3 000 ms pause)
  static const double _scaleEnd    = 0.96; // 6720 ms
  static const double _fadeStart   = 0.83; // 5810 ms
  static const double _fontSize    = 95;

  // Measured once on first build
  double? _wF, _wI, _wN, _wQ, _wU, _wI2, _wZ, _textH;

  TextStyle get _finStyle => GoogleFonts.spaceGrotesk(
        fontSize: _fontSize, fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic, color: const Color(0xFF059669), height: 1);

  TextStyle get _quizStyle => GoogleFonts.spaceGrotesk(
        fontSize: _fontSize, fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic, color: const Color(0xFF047857), height: 1);

  double _mw(String ch, TextStyle s) =>
      (TextPainter(text: TextSpan(text: ch, style: s), textDirection: TextDirection.ltr)
        ..layout())
          .width;

  void _measureText() {
    if (_wF != null) return;
    _wF  = _mw('F', _finStyle);
    _wI  = _mw('I', _finStyle);
    _wN  = _mw('N', _finStyle);
    _wQ  = _mw('Q', _quizStyle);
    _wU  = _mw('U', _quizStyle);
    _wI2 = _mw('I', _quizStyle);
    _wZ  = _mw('Z', _quizStyle);
    _textH = (TextPainter(
            text: TextSpan(text: 'F', style: _finStyle ),
            textDirection: TextDirection.ltr)
          ..layout())
        .height;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 5000));
    _ctrl.forward().then((_) => _navigate());
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final user = await ref.read(authProvider.future);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            user != null ? const MainShell() : const WelcomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  // Normalised phase progress, clamped to [0, 1]
  double _p(double t, double start, double end) =>
      ((t - start) / (end - start)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    _measureText();
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    final totalW = _wF! + _wI! + _wN! + _wQ! + _wU! + _wI2! + _wZ!;
    final left0  = (sw - totalW) / 2; // F's x at rest
    final midY   = (sh - _textH!) / 2;

    // Natural (resting) left-edge x of each letter
    final xF  = left0;
    final xI  = xF  + _wF!;
    final xN  = xI  + _wI!;
    final xQ  = xN  + _wN!;
    final xU  = xQ  + _wQ!;
    final xI2 = xU  + _wU!;
    final xZ  = xI2 + _wI2!;

    // x so that F is perfectly screen-centred
    final xFc = sw / 2 - _wF! / 2;

    // Scale factor that makes F cover the whole screen (larger axis wins)
    final targetScale =
        (sw / _wF! > sh / _textH! ? sw / _wF! : sh / _textH!) * 1.2;

    return Scaffold(
      backgroundColor: const Color(0xFFDCFCE7),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _ctrl.value;

          // ── 1. Slide-in ───────────────────────────────────────────────────
          final slideP = Curves.easeOutCubic.transform(_p(t, 0, _slideEnd));
          final dxFin  = lerpDouble(-sw, 0, slideP)!;
          final dxQuiz = lerpDouble( sw, 0, slideP)!;

          // ── 2. Converge ───────────────────────────────────────────────────
          final convP    = Curves.easeInCubic.transform(_p(t, _holdEnd, _convergeEnd));
          final sideAlpha = (1.0 - convP).clamp(0.0, 1.0);

          // Returns the current x for a side letter.
          // During slide: natural + group offset.
          // During hold: natural.
          // During converge: lerps toward sw/2 (letters collapse to centre).
          double lx(double natX, double dx) {
            if (t <= _slideEnd) return natX + dx;
            if (t <= _holdEnd) return natX;
            return lerpDouble(natX, sw / 2, convP)!;
          }

          // ── 3. F position (slide → hold → move to centre) ─────────────
          double fLeft;
          if (t <= _slideEnd) {
            fLeft = xF + dxFin;
          } else if (t <= _holdEnd) {
            fLeft = xF;
          } else if (t <= _convergeEnd) {
            fLeft = lerpDouble(xF, xFc,
                Curves.easeInOut.transform(_p(t, _holdEnd, _convergeEnd)))!;
          } else {
            fLeft = xFc;
          }

          // ── 4. Scale (begins after the 3-second F pause at t = 0.79) ───────
          const double _scaleStart = 0.79;
          final fScale = t > _scaleStart
              ? lerpDouble(1.0, targetScale,
                  Curves.easeInCubic.transform(_p(t, _scaleStart, _scaleEnd)))!
              : 1.0;

          // ── 5. Fade ───────────────────────────────────────────────────────
          final alpha = t > _fadeStart
              ? (1.0 - Curves.easeIn.transform(_p(t, _fadeStart, 1.0)))
                  .clamp(0.0, 1.0)
              : 1.0;

          // ── Build ─────────────────────────────────────────────────────────
          final hideSide = t >= _convergeEnd;

          return Opacity(
            opacity: alpha,
            child: Stack(
              children: [
                // Side letters — collapse to centre and fade
                if (!hideSide) ...[
                  _lt('I',  _finStyle,  lx(xI,  dxFin),  midY, sideAlpha),
                  _lt('N',  _finStyle,  lx(xN,  dxFin),  midY, sideAlpha),
                  _lt('Q',  _quizStyle, lx(xQ,  dxQuiz), midY, sideAlpha),
                  _lt('U',  _quizStyle, lx(xU,  dxQuiz), midY, sideAlpha),
                  _lt('I',  _quizStyle, lx(xI2, dxQuiz), midY, sideAlpha),
                  _lt('Z',  _quizStyle, lx(xZ,  dxQuiz), midY, sideAlpha),
                ],
                // F — survives, moves to centre, then fills the screen
                Positioned(
                  left: fLeft,
                  top:  midY,
                  child: Transform.scale(
                    scale: fScale,
                    alignment: Alignment.center,
                    child: Text('F', style: _finStyle),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _lt(String ch, TextStyle style, double x, double y, double opacity) =>
      Positioned(
        left: x,
        top:  y,
        child: Opacity(opacity: opacity, child: Text(ch, style: style)),
      );
}
