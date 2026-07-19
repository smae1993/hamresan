// Onboarding provider — همرسان.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._repo) : super(false) {
    _load();
  }

  final OnboardingRepository _repo;

  Future<void> _load() async {
    state = await _repo.isCompleted();
  }

  Future<void> complete() async {
    await _repo.setCompleted(value: true);
    state = true;
  }

  Future<void> reset() async {
    await _repo.setCompleted(value: false);
    state = false;
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((
  ref,
) {
  return OnboardingNotifier(ref.watch(onboardingRepositoryProvider));
});
