/// Repository providers — همرسان.
///
/// Wires repository implementations to their abstract contracts via Riverpod,
/// so features depend only on the interfaces. SharedPreferences is provided
/// from `main.dart` via an override.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/discovery/domain/repositories/device_repository.dart';
import '../../features/discovery/domain/repositories/identity_repository.dart';
import '../../features/discovery/data/device_repository_impl.dart';
import '../../features/discovery/data/identity_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/data/history_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/data/onboarding_repository_impl.dart';
import '../../features/settings/domain/repositories/preferences_repository.dart';
import '../../features/settings/data/preferences_repository_impl.dart';
import '../../features/transfer/domain/repositories/transfer_repository.dart';
import '../../features/transfer/data/transfer_repository_impl.dart';

/// SharedPreferences instance, overridden in `main.dart`.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepositoryImpl();
});

final identityRepositoryProvider = Provider<IdentityRepository>((ref) {
  return IdentityRepositoryImpl(prefs: ref.watch(sharedPreferencesProvider));
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(prefs: ref.watch(sharedPreferencesProvider));
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(prefs: ref.watch(sharedPreferencesProvider));
});

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepositoryImpl(prefs: ref.watch(sharedPreferencesProvider));
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepositoryImpl();
});
