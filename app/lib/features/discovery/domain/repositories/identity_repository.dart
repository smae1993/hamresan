/// Identity repository contract — همرسان.
///
/// Persists "this device" identity. Abstract so the storage backend can be
/// swapped (SharedPreferences today).
import '../entities/identity.dart';

abstract class IdentityRepository {
  Future<Identity> get();
  Future<void> save(Identity identity);
}
