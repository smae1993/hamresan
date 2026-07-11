/// App theme — همرسان.
///
/// Exposes [lightTheme]/[darkTheme] and a BuildContext extension to access
/// the resolved [AppColors] from anywhere in the tree.
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

extension AppColorsX on BuildContext {
  /// The active color set for the current brightness.
  AppColors get colors =>
      Theme.of(this).brightness == Brightness.dark ? AppColors.dark : AppColors.light;

  /// True when the current theme is dark.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.primary,
      brightness: brightness,
      primary: c.primary,
      surface: c.surface,
      onSurface: c.text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      fontFamily: 'Vazirmatn',
      textTheme: const TextTheme().apply(
        fontFamily: 'Vazirmatn',
        bodyColor: c.text,
        displayColor: c.text,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: c.border,
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        foregroundColor: c.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.text,
        contentTextStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          color: c.bg,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Shadows ported from styles.css. Returned as lists for [BoxShadow].
class AppShadows {
  AppShadows._();

  static List<BoxShadow> sm(AppColors c) => [
        BoxShadow(
          color: c.text.withValues(alpha: 0.10),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: -3,
        ),
      ];

  static List<BoxShadow> md(AppColors c) => [
        BoxShadow(
          color: c.text.withValues(alpha: 0.20),
          offset: const Offset(0, 14),
          blurRadius: 34,
          spreadRadius: -16,
        ),
      ];

  static List<BoxShadow> lg(AppColors c) => [
        BoxShadow(
          color: c.text.withValues(alpha: 0.24),
          offset: const Offset(0, 26),
          blurRadius: 60,
          spreadRadius: -22,
        ),
      ];

  /// FAB / brand-button shadow (tinted with primary).
  static List<BoxShadow> fab(AppColors c) => [
        BoxShadow(
          color: c.primary.withValues(alpha: 0.50),
          offset: const Offset(0, 12),
          blurRadius: 26,
          spreadRadius: -8,
        ),
      ];
}

/// The standard screen corner radius (used by sheets/dialogs).
final BorderRadius kRadiusLg =
    BorderRadius.circular(AppDimensions.radiusLg);
final BorderRadius kRadiusMd =
    BorderRadius.circular(AppDimensions.radiusMd);
final BorderRadius kRadiusSm =
    BorderRadius.circular(AppDimensions.radiusSm);
