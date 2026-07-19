// History repository contract — همرسان.
//
// Abstract interface for the transfer history log.
import '../entities/transfer_record.dart';

abstract class HistoryRepository {
  Future<List<TransferRecord>> getAll();
  Future<void> add(TransferRecord record);
  Future<void> clear();
}
