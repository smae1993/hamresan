/// Preferences repository implementation (SharedPreferences) — همرسان.
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/default_save_path.dart';
import '../domain/entities/app_preferences.dart';
import '../domain/repositories/preferences_repository.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  PreferencesRepositoryImpl({required SharedPreferences prefs})
    : _prefs = prefs;
  final SharedPreferences _prefs;

  static const _kTheme = 'hamresan_theme';
  static const _kVisible = 'hamresan_visible';
  static const _kAutoAccept = 'hamresan_autoAccept';
  static const _kSavePath = 'hamresan_save_path';

  @override
  Future<AppPreferences> get() async {
    final themeStr = _prefs.getString(_kTheme);
    final theme = themeStr == 'dark' ? AppThemeMode.dark : AppThemeMode.light;
    final visible = _prefs.getBool(_kVisible) ?? true;
    final autoAccept = _prefs.getBool(_kAutoAccept) ?? false;
    final saved = _prefs.getString(_kSavePath);
    final savePath = saved ?? await defaultSavePath();
    return AppPreferences(
      theme: theme,
      visible: visible,
      autoAccept: autoAccept,
      savePath: savePath,
    );
  }

  @override
  Future<void> save(AppPreferences prefs) async {
    await Future.wait([
      _prefs.setString(
        _kTheme,
        prefs.theme == AppThemeMode.dark ? 'dark' : 'light',
      ),
      _prefs.setBool(_kVisible, prefs.visible),
      _prefs.setBool(_kAutoAccept, prefs.autoAccept),
      _prefs.setString(_kSavePath, prefs.savePath),
    ]);
  }
}
