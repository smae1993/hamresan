import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/transfer_record.dart';
import '../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({required SharedPreferences prefs}) : _prefs = prefs {
    _migrate();
  }

  final SharedPreferences _prefs;
  static const _key = 'hamresan_history';
  static const _verKey = 'hamresan_version';

  void _migrate() {
    final ver = _prefs.getInt(_verKey) ?? 0;
    if (ver < 3) {
      // Version 3 adds `createdAt`. Older records are read with a safe
      // fallback instead of deleting the user's history.
      _prefs.setInt(_verKey, 3);
    }
  }

  @override
  Future<List<TransferRecord>> getAll() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((e) => TransferRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> add(TransferRecord record) async {
    final records = await getAll();
    records.insert(0, record);
    if (records.length > 500) records.removeRange(500, records.length);
    final encoded = json.encode(records.map((r) => r.toJson()).toList());
    await _prefs.setString(_key, encoded);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
