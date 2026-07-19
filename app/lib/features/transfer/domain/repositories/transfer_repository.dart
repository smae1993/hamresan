/// Transfer repository contract — همرسان.
///
/// Abstract interface for performing transfers. The stub implementation
/// simulates progress; a real implementation will open sockets later.
import '../entities/transfer_session.dart';
import '../entities/incoming_request.dart';
import '../entities/transfer_progress.dart';

abstract class TransferRepository {
  /// Streams transfer progress (0..1) until it reaches 1.0, then completes.
  Stream<TransferProgress> send(TransferSession session);

  /// Streams transfer progress (0..1) for a receive session.
  Stream<TransferProgress> receive(TransferSession session);

  Future<void> decline(IncomingRequest request);

  /// Cancels an ongoing transfer.
  Future<void> cancel(String transferId);
}
