/// Transfer repository implementation (stub) — همرسان.
///
/// Simulates transfer progress with random increments (mirrors the mock
/// `TransferView` timer from `screens_send.jsx`).
import 'dart:async';
import 'dart:math';
import '../domain/entities/incoming_request.dart';
import '../domain/entities/transfer_session.dart';
import '../domain/repositories/transfer_repository.dart';

class TransferRepositoryImpl implements TransferRepository {
  @override
  Stream<double> send(TransferSession session) =>
      _simulateProgress();

  @override
  Stream<double> receive(TransferSession session) =>
      _simulateProgress();

  @override
  Future<IncomingRequest?> pollIncoming() async {
    // Returns null — the demo triggers it manually from settings.
    return null;
  }

  /// Emits progress 0→1 with random 3-10% increments every 130ms,
  /// matching the prototype's `TransferView` timer.
  Stream<double> _simulateProgress() async* {
    var p = 0.0;
    final rng = Random();
    while (p < 100) {
      await Future.delayed(const Duration(milliseconds: 130));
      p += rng.nextDouble() * 7 + 3;
      if (p > 100) p = 100;
      yield p / 100;
    }
  }
}
