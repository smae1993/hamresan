/// History provider — همرسان.
///
/// Loads transfer history and supports adding a record after a transfer.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/transfer_record.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryNotifier extends StateNotifier<List<TransferRecord>> {
  HistoryNotifier(this._repo) : super(const []) {
    _load();
  }

  final HistoryRepository _repo;

  Future<void> _load() async {
    state = await _repo.getAll();
  }

  Future<void> add(TransferRecord record) async {
    await _repo.add(record);
    state = [record, ...state];
  }

  Future<void> clear() async {
    await _repo.clear();
    state = const [];
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<TransferRecord>>((ref) {
  return HistoryNotifier(ref.watch(historyRepositoryProvider));
});
