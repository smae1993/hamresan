/// Design color tokens — همرسان.
///
/// Ported from `styles.css`. The prototype uses OKLCH; these are the
/// equivalent sRGB hex values (computed from the same OKLCH coordinates so
/// they match the design output on standard displays).
import 'package:flutter/material.dart';

@immutable
class AppColors {
  const AppColors({
    required this.stage,
    required this.stage2,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.surfaceInset,
    required this.text,
    required this.muted,
    required this.faint,
    required this.border,
    required this.borderStrong,
    required this.primary,
    required this.primaryPress,
    required this.primaryInk,
    required this.primarySoft,
    required this.primarySoftBd,
    required this.gradStart,
    required this.gradEnd,
    required this.green,
    required this.greenSoft,
    required this.amber,
    required this.rose,
  });

  // --- Light theme ---
  static const light = AppColors(
    stage: Color(0xFFEAEAF3),
    stage2: Color(0xFFF4F4FA),
    bg: Color(0xFFFAFAFD),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF6F6FC),
    surface3: Color(0xFFEFEFF8),
    surfaceInset: Color(0xFFF2F3FA),
    text: Color(0xFF202131),
    muted: Color(0xFF6C6D7F),
    faint: Color(0xFF9091A0),
    border: Color(0xFFE4E4EA),
    borderStrong: Color(0xFFD0D0D9),
    primary: Color(0xFF5B51D1),
    primaryPress: Color(0xFF4C3EBD),
    primaryInk: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFEEEDFF),
    primarySoftBd: Color(0xFFDBD9FF),
    gradStart: Color(0xFF6064E4),
    gradEnd: Color(0xFF9245C9),
    green: Color(0xFF1A9951),
    greenSoft: Color(0xFFD7F9DE),
    amber: Color(0xFFD48E00),
    rose: Color(0xFFE54056),
  );

  // --- Dark theme ---
  static const dark = AppColors(
    stage: Color(0xFF06070D),
    stage2: Color(0xFF0C0C15),
    bg: Color(0xFF0D0D16),
    surface: Color(0xFF161621),
    surface2: Color(0xFF1C1D29),
    surface3: Color(0xFF262635),
    surfaceInset: Color(0xFF12131D),
    text: Color(0xFFF1F1F7),
    muted: Color(0xFFA3A3B2),
    faint: Color(0xFF797987),
    border: Color(0xFF2E2F3D),
    borderStrong: Color(0xFF454658),
    primary: Color(0xFF9386F5),
    primaryPress: Color(0xFF8271E6),
    primaryInk: Color(0xFF0D0D16),
    primarySoft: Color(0xFF2C284A),
    primarySoftBd: Color(0xFF454070),
    gradStart: Color(0xFF7474EF),
    gradEnd: Color(0xFFA058D5),
    green: Color(0xFF4DBF74),
    greenSoft: Color(0xFF183B23),
    amber: Color(0xFFD48E00),
    rose: Color(0xFFE54056),
  );

  // Live indicator dot (same across themes, from keyframes livepulse)
  static const liveDot = Color(0xFF6EE7B7);

  final Color stage;
  final Color stage2;
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color surfaceInset;
  final Color text;
  final Color muted;
  final Color faint;
  final Color border;
  final Color borderStrong;
  final Color primary;
  final Color primaryPress;
  final Color primaryInk;
  final Color primarySoft;
  final Color primarySoftBd;
  final Color gradStart;
  final Color gradEnd;
  final Color green;
  final Color greenSoft;
  final Color amber;
  final Color rose;
}
