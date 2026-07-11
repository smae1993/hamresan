/// Preferences provider — همرسان.
///
/// Loads and persists [AppPreferences]. Exposes theme/visible/autoAccept
/// mutations that write-through to the repository.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/app_preferences.dart';
import '../../domain/repositories/preferences_repository.dart';

class PreferencesNotifier extends StateNotifier<AppPreferences> {
  PreferencesNotifier(this._repo) : super(const AppPreferences()) {
    _load();
  }

  final PreferencesRepository _repo;

  Future<void> _load() async {
    state = await _repo.get();
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = state.copyWith(theme: mode);
    await _repo.save(state);
  }

  Future<void> toggleTheme() async {
    await setTheme(
      state.theme == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark,
    );
  }

  Future<void> setVisible(bool v) async {
    state = state.copyWith(visible: v);
    await _repo.save(state);
  }

  Future<void> setAutoAccept(bool v) async {
    state = state.copyWith(autoAccept: v);
    await _repo.save(state);
  }

  Future<void> setSavePath(String path) async {
    state = state.copyWith(savePath: path);
    await _repo.save(state);
  }
}

final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, AppPreferences>((ref) {
  return PreferencesNotifier(ref.watch(preferencesRepositoryProvider));
});
