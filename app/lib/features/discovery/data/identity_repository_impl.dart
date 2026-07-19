/// Identity repository implementation (SharedPreferences) — همرسان.
import 'dart:convert';
import 'dart:io';
import 'dart:math';
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
    if (raw == null) {
      final created = _newIdentity();
      await save(created);
      return created;
    }
    try {
      final current = Identity.fromJson(
        json.decode(raw) as Map<String, dynamic>,
      );
      if (current.id.isNotEmpty) return current;
      final migrated = current.copyWith(id: _randomId());
      await save(migrated);
      return migrated;
    } catch (_) {
      final created = _newIdentity();
      await save(created);
      return created;
    }
  }

  @override
  Future<void> save(Identity identity) =>
      _prefs.setString(_key, json.encode(identity.toJson()));

  Identity _newIdentity() {
    final id = _randomId();
    return Identity(
      id: id,
      name: 'دستگاه من',
      platform: _platformName(),
      hue: 281,
      code: _pairingCode(id),
    );
  }

  String _randomId() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  String _pairingCode(String id) {
    const words = [
      'آبی',
      'ققنوس',
      'کوه',
      'مروارید',
      'ستاره',
      'ریشه',
      'بادبادک',
    ];
    final value = id.codeUnits.fold<int>(0, (sum, char) => sum + char);
    return '${words[value % words.length]}-${(value % 90) + 10}';
  }

  String _platformName() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return Platform.operatingSystem;
  }
}
