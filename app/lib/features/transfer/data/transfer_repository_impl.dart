import '../domain/entities/incoming_request.dart';
import '../domain/entities/transfer_progress.dart';
import '../domain/entities/transfer_session.dart';
import '../domain/repositories/transfer_repository.dart';
import '../../discovery/data/lan_service.dart';

class TransferRepositoryImpl implements TransferRepository {
  TransferRepositoryImpl(this._lan);

  final LanService _lan;

  @override
  Stream<TransferProgress> send(TransferSession session) async* {
    yield TransferProgress.waiting(totalBytes: session.totalBytes);
    final authorization = await _lan.requestTransfer(session);
    yield* _lan.sendTransfer(session, authorization);
  }

  @override
  Stream<TransferProgress> receive(TransferSession session) async* {
    yield TransferProgress.waiting(totalBytes: session.totalBytes);
    final progress = await _lan.acceptTransfer(session);
    yield* progress;
  }

  @override
  Future<void> decline(IncomingRequest request) =>
      _lan.declineTransfer(request);

  @override
  Future<void> cancel(String transferId) => _lan.cancelTransfer(transferId);
}
