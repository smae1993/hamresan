/// Onboarding repository implementation (SharedPreferences) — همرسان.
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({required SharedPreferences prefs}) : _prefs = prefs;
  final SharedPreferences _prefs;

  static const _key = 'hamresan_onboarded';

  @override
  Future<bool> isCompleted() async => _prefs.getBool(_key) ?? false;

  @override
  Future<void> setCompleted({required bool value}) =>
      _prefs.setBool(_key, value);
}
