/// Identity repository implementation (SharedPreferences) — همرسان.
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/identity.dart';
import '../domain/repositories/identity_repository.dart';

class IdentityRepositoryImpl implements IdentityRepository {
  IdentityRepositoryImpl({required SharedPreferences prefs}) : _prefs = prefs;
  final SharedPreferences _prefs;

  static const _key = 'hamresan_me';

  @override
  Future<Identity> get() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return _default;
    try {
      return Identity.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return _default;
    }
  }

  @override
  Future<void> save(Identity identity) =>
      _prefs.setString(_key, json.encode(identity.toJson()));

  static const _default = Identity(
    name: 'گوشی من',
    platform: 'Android',
    hue: 281,
    code: 'آبی-۲۷',
  );
}
