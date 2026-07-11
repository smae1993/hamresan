/// Onboarding repository contract — همرسان.
///
/// Persists whether the user has completed the onboarding flow.
abstract class OnboardingRepository {
  Future<bool> isCompleted();
  Future<void> setCompleted({required bool value});
}
