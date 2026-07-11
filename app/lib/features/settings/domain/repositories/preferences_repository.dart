/// Preferences repository contract — همرسان.
import '../entities/app_preferences.dart';

abstract class PreferencesRepository {
  Future<AppPreferences> get();
  Future<void> save(AppPreferences prefs);
}
