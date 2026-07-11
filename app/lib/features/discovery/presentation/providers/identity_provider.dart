/// Identity provider — همرسان.
///
/// Loads and persists "this device" identity.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/identity.dart';
import '../../domain/repositories/identity_repository.dart';

class IdentityNotifier extends StateNotifier<Identity> {
  IdentityNotifier(this._repo) : super(const Identity(name: 'گوشی من', platform: 'Android', hue: 281, code: 'آبی-۲۷')) {
    _load();
  }

  final IdentityRepository _repo;

  Future<void> _load() async {
    state = await _repo.get();
  }

  Future<void> update(Identity next) async {
    state = next;
    await _repo.save(next);
  }

  Future<void> setName(String name) async =>
      update(state.copyWith(name: name));

  Future<void> setHue(double hue) async =>
      update(state.copyWith(hue: hue));
}

final identityProvider =
    StateNotifierProvider<IdentityNotifier, Identity>((ref) {
  return IdentityNotifier(ref.watch(identityRepositoryProvider));
});
