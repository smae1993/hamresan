import 'package:flutter/material.dart';

enum AppThemeMode { light, dark }

extension AppThemeModeX on AppThemeMode {
  Brightness get brightness =>
      this == AppThemeMode.dark ? Brightness.dark : Brightness.light;
  String get label => this == AppThemeMode.dark ? 'تیره' : 'روشن';
}

class AppPreferences {
  const AppPreferences({
    this.theme = AppThemeMode.light,
    this.visible = true,
    this.autoAccept = false,
    this.savePath = 'دریافتی‌های همرسان',
  });

  final AppThemeMode theme;
  final bool visible;
  final bool autoAccept;
  final String savePath;

  AppPreferences copyWith({
    AppThemeMode? theme,
    bool? visible,
    bool? autoAccept,
    String? savePath,
  }) =>
      AppPreferences(
        theme: theme ?? this.theme,
        visible: visible ?? this.visible,
        autoAccept: autoAccept ?? this.autoAccept,
        savePath: savePath ?? this.savePath,
      );
}
