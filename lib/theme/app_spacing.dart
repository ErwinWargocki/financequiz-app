import 'package:flutter/material.dart';

/// Spacing constants on a 4 dp grid.
///
/// Vertical: [h4] [h6] [h8] [h10] [h12] [h14] [h16] [h20] [h24] [h32] [h48]
/// Horizontal: [w4] [w6] [w8] [w10] [w12] [w14] [w16] [w24]
/// Semantic aliases: [xs] [sm] [md] [lg] [xl] / [xsH] [smH] [mdH] [lgH]
class AppSpacing {
  // ─── Semantic vertical (REVIEW.md recommendation) ────────────────────────
  static const Widget xs  = SizedBox(height: 4);
  static const Widget sm  = SizedBox(height: 8);
  static const Widget md  = SizedBox(height: 16);
  static const Widget lg  = SizedBox(height: 24);
  static const Widget xl  = SizedBox(height: 32);

  // ─── Semantic horizontal ─────────────────────────────────────────────────
  static const Widget xsH = SizedBox(width: 4);
  static const Widget smH = SizedBox(width: 8);
  static const Widget mdH = SizedBox(width: 16);
  static const Widget lgH = SizedBox(width: 24);

  // ─── Explicit vertical values ─────────────────────────────────────────────
  static const Widget h4  = SizedBox(height: 4);
  static const Widget h6  = SizedBox(height: 6);
  static const Widget h8  = SizedBox(height: 8);
  static const Widget h10 = SizedBox(height: 10);
  static const Widget h12 = SizedBox(height: 12);
  static const Widget h14 = SizedBox(height: 14);
  static const Widget h16 = SizedBox(height: 16);
  static const Widget h20 = SizedBox(height: 20);
  static const Widget h24 = SizedBox(height: 24);
  static const Widget h32 = SizedBox(height: 32);
  static const Widget h48 = SizedBox(height: 48);

  // ─── Explicit horizontal values ───────────────────────────────────────────
  static const Widget w4  = SizedBox(width: 4);
  static const Widget w6  = SizedBox(width: 6);
  static const Widget w8  = SizedBox(width: 8);
  static const Widget w10 = SizedBox(width: 10);
  static const Widget w12 = SizedBox(width: 12);
  static const Widget w14 = SizedBox(width: 14);
  static const Widget w16 = SizedBox(width: 16);
  static const Widget w24 = SizedBox(width: 24);
}
