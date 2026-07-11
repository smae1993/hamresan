import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/transfer_record.dart';
import '../domain/repositories/history_repository.dart';
import '../../discovery/data/mock_devices.dart' show seedHistory;

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({required SharedPreferences prefs}) : _prefs = prefs {
    _migrateSeed();
  }

  final SharedPreferences _prefs;
  static const _key = 'hamresan_history';

  void _migrateSeed() {
    if (!_prefs.containsKey(_key)) {
      final encoded = json.encode(seedHistory.map((r) => r.toJson()).toList());
      _prefs.setString(_key, encoded);
    }
  }

  @override
  Future<List<TransferRecord>> getAll() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => TransferRecord.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> add(TransferRecord record) async {
    final records = await getAll();
    records.insert(0, record);
    final encoded = json.encode(records.map((r) => r.toJson()).toList());
    await _prefs.setString(_key, encoded);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
