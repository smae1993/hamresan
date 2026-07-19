/// Gradient helpers — همرسان.
///
/// The prototype builds per-hue gradients in JS (`Avatar`, file icons, etc.)
/// as `linear-gradient(135deg, oklch(0.66 0.15 H), oklch(0.55 0.17 H+22))`.
/// Here we reproduce the same OKLCH→sRGB conversion at build time.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  /// Brand gradient (`--grad`): 135deg gradStart → gradEnd.
  static LinearGradient brand(AppColors c) => LinearGradient(
    begin: const Alignment(-1, -1),
    end: const Alignment(1, 1),
    colors: [c.gradStart, c.gradEnd],
  );

  /// Soft brand gradient (`--grad-soft`).
  static LinearGradient brandSoft(AppColors c) => LinearGradient(
    begin: const Alignment(-1, -1),
    end: const Alignment(1, 1),
    colors: [
      Color.lerp(c.primarySoft, c.bg, 0.0)!,
      Color.lerp(c.primarySoftBd, c.bg, 0.4)!,
    ],
  );

  /// Radar ring color used on the identity card (semi-transparent white).
  static const Color radarRing = Color(0x80FFFFFF);

  /// Hue-based avatar/file-icon gradient.
  ///
  /// Reproduces `oklch(0.66 0.15 h) → oklch(0.55 0.17 h+22)`.
  /// Conversion is done via OKLCH→OKLab→linearRGB→sRGB.
  static LinearGradient hue(double hue) {
    final start = _oklchToColor(0.66, 0.15, hue);
    final end = _oklchToColor(0.55, 0.17, hue + 22);
    return LinearGradient(
      begin: const Alignment(-1, -1),
      end: const Alignment(1, 1),
      colors: [start, end],
    );
  }

  /// Solid color at the avatar "start" lightness for a given hue.
  static Color hueStart(double hue) => _oklchToColor(0.66, 0.15, hue);
  static Color hueEnd(double hue) => _oklchToColor(0.55, 0.17, hue + 22);

  /// Striped placeholder colors (`StripePlaceholder`).
  static List<Color> stripePair(double hue) => [
    _oklchToColor(0.7, 0.1, hue),
    _oklchToColor(0.62, 0.12, hue),
  ];
}

// --- OKLCH → sRGB ---

Color _oklchToColor(double l, double c, double h) {
  final hRad = h * math.pi / 180;
  final a = c * math.cos(hRad);
  final b = c * math.sin(hRad);
  return _oklabToColor(l, a, b);
}

Color _oklabToColor(double l, double a, double b) {
  final l_ = l + 0.3963377774 * a + 0.2158037573 * b;
  final m_ = l - 0.1055613458 * a - 0.0638541728 * b;
  final s_ = l - 0.0894841775 * a - 1.2914855480 * b;
  final l3 = l_ * l_ * l_;
  final m3 = m_ * m_ * m_;
  final s3 = s_ * s_ * s_;
  var r = 4.0767416621 * l3 - 3.3077115913 * m3 + 0.2309699292 * s3;
  var g = -1.2684380046 * l3 + 2.6097574011 * m3 - 0.3413193965 * s3;
  var bl = -0.0041960863 * l3 - 0.7034186147 * m3 + 1.7076147010 * s3;
  r = _linearToSrgb(r < 0 ? 0 : r);
  g = _linearToSrgb(g < 0 ? 0 : g);
  bl = _linearToSrgb(bl < 0 ? 0 : bl);
  return Color.fromARGB(
    255,
    (r * 255).round().clamp(0, 255),
    (g * 255).round().clamp(0, 255),
    (bl * 255).round().clamp(0, 255),
  );
}

double _linearToSrgb(double x) {
  if (x <= 0.0031308) return 12.92 * x;
  return 1.055 * math.pow(x, 1 / 2.4) - 0.055;
}
