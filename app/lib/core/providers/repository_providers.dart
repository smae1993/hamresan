import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/discovery/domain/repositories/device_repository.dart';
import '../../features/discovery/domain/repositories/identity_repository.dart';
import '../../features/discovery/data/device_repository_impl.dart';
import '../../features/discovery/data/identity_repository_impl.dart';
import '../../features/discovery/data/lan_service.dart';
import '../../features/transfer/domain/entities/incoming_request.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/data/history_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/data/onboarding_repository_impl.dart';
import '../../features/settings/domain/repositories/network_repository.dart';
import '../../features/settings/domain/repositories/preferences_repository.dart';
import '../../features/settings/data/network_repository_impl.dart';
import '../../features/settings/data/preferences_repository_impl.dart';
import '../../features/transfer/domain/repositories/content_repository.dart';
import '../../features/transfer/domain/repositories/incoming_repository.dart';
import '../../features/transfer/domain/repositories/transfer_repository.dart';
import '../../features/transfer/data/content_repository_impl.dart';
import '../../features/transfer/data/incoming_repository_impl.dart';
import '../../features/transfer/data/transfer_repository_impl.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final lanServiceProvider = Provider<LanService>((ref) {
  final service = LanService();
  ref.onDispose(() => service.dispose());
  return service;
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepositoryImpl(ref.watch(lanServiceProvider));
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

final networkRepositoryProvider = Provider<NetworkRepository>((ref) {
  return NetworkRepositoryImpl();
});

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepositoryImpl();
});

final incomingRepositoryProvider = Provider<IncomingRepository>((ref) {
  return IncomingRepositoryImpl(ref.watch(lanServiceProvider));
});

final incomingStreamProvider = StreamProvider<IncomingRequest?>((ref) {
  return ref.watch(incomingRepositoryProvider).watch();
});

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepositoryImpl(ref.watch(lanServiceProvider));
});
