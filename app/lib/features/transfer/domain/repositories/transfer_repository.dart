/// Transfer repository contract — همرسان.
///
/// Abstract interface for performing transfers. The stub implementation
/// simulates progress; a real implementation will open sockets later.
import '../entities/incoming_request.dart';
import '../entities/transfer_session.dart';

abstract class TransferRepository {
  /// Streams transfer progress (0..1) until it reaches 1.0, then completes.
  Stream<double> send(TransferSession session);

  /// Streams transfer progress (0..1) for a receive session.
  Stream<double> receive(TransferSession session);

  /// Returns the current incoming request, if any (stub: a fixed demo).
  Future<IncomingRequest?> pollIncoming();
}
