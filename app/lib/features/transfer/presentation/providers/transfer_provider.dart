// Transfer flow provider — همرسان.
//
// State machine mirroring the React `flow` state in `app.jsx`:
//   idle → picker → recipient → sending → success → idle
//   idle → incoming → receiving → success → idle
//
// Drives the modal sheets, the incoming dialog, and the full-screen
// transfer screen. Persists nothing itself; it records completed transfers
// into [HistoryNotifier].
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/utils/fa_digits.dart';
import '../../../../core/utils/size_format.dart';
import '../../../discovery/domain/entities/device.dart';
import '../../../history/domain/entities/transfer_record.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../domain/entities/content_item.dart';
import '../../domain/entities/incoming_request.dart';
import '../../domain/entities/transfer_session.dart';
import '../../domain/entities/transfer_progress.dart';
import '../../domain/enums.dart';
import '../../domain/repositories/transfer_repository.dart';

/// Which step of the transfer flow is active.
sealed class TransferFlowState {
  const TransferFlowState();
}

class TransferIdle extends TransferFlowState {
  const TransferIdle();
}

/// Content picker sheet open. [device] is non-null when launched from a
/// device card (send directly); null when launched from the FAB (then a
/// recipient sheet follows).
class TransferPicker extends TransferFlowState {
  const TransferPicker({this.device});
  final Device? device;
}

/// Recipient selection sheet open (after picking content with no device).
class TransferRecipient extends TransferFlowState {
  const TransferRecipient({required this.items});
  final List<ContentItem> items;
}

/// Incoming request dialog open.
class TransferIncoming extends TransferFlowState {
  const TransferIncoming({required this.request});
  final IncomingRequest request;
}

/// Full-screen transfer in progress.
class TransferTransferring extends TransferFlowState {
  const TransferTransferring({
    required this.session,
    required this.progress,
    this.done = false,
  });

  final TransferSession session;
  final TransferProgress progress;
  final bool done;

  TransferTransferring copyWith({TransferProgress? progress, bool? done}) =>
      TransferTransferring(
        session: session,
        progress: progress ?? this.progress,
        done: done ?? this.done,
      );
}

class TransferFailed extends TransferFlowState {
  const TransferFailed({required this.session, required this.message});
  final TransferSession session;
  final String message;
}

class TransferFlowNotifier extends StateNotifier<TransferFlowState> {
  TransferFlowNotifier(this._transferRepo, this._history)
    : super(const TransferIdle());

  final TransferRepository _transferRepo;
  final HistoryNotifier _history;

  // ---- Flow entry points ----

  /// Started from a device card: open picker with a preselected device.
  void startSendToDevice(Device device) =>
      state = TransferPicker(device: device);

  /// Started from the FAB: open picker with no device; recipient sheet later.
  void startSendFlow() => state = const TransferPicker(device: null);

  /// Presents an incoming request emitted by the LAN service.
  void showIncoming(IncomingRequest req) =>
      state = TransferIncoming(request: req);

  // ---- Picker / recipient transitions ----

  /// Content confirmed in the picker.
  /// If a device was preselected → go straight to transfer.
  /// Otherwise → open recipient sheet.
  void confirmPicker(List<ContentItem> items, Device? device) {
    if (device != null) {
      _beginSend(device, items);
    } else {
      state = TransferRecipient(items: items);
    }
  }

  /// Recipient chosen in the recipient sheet.
  void pickRecipient(Device device, List<ContentItem> items) =>
      _beginSend(device, items);

  // ---- Incoming transitions ----

  void acceptIncoming(IncomingRequest req) => _beginReceive(req);
  void declineIncoming(IncomingRequest request) {
    unawaited(_transferRepo.decline(request));
    state = const TransferIdle();
  }

  // ---- Cancel / done ----

  void cancel() {
    final current = state;
    if (current is TransferTransferring) {
      unawaited(_transferRepo.cancel(current.session.id));
      _recordHistory(current.session, TransferStatus.cancelled);
    }
    _sub?.cancel();
    state = const TransferIdle();
  }

  /// Called from the success screen's "تمام" button.
  void finish() => state = const TransferIdle();

  // ---- Internals ----

  StreamSubscription<TransferProgress>? _sub;

  void _beginSend(Device device, List<ContentItem> items) {
    final session = TransferSession(
      id: _newTransferId(),
      direction: TransferDirection.sent,
      peerId: device.id,
      peerName: device.name,
      peerHue: device.hue,
      peerType: device.type,
      items: items,
    );
    _run(session);
  }

  void _beginReceive(IncomingRequest req) {
    final session = TransferSession(
      id: req.transferId,
      direction: TransferDirection.received,
      peerId: req.peerId,
      peerName: req.peer,
      peerHue: req.hue,
      peerType: req.type,
      items: req.items,
    );
    _run(session);
  }

  void _run(TransferSession session) {
    _sub?.cancel();
    state = TransferTransferring(
      session: session,
      progress: TransferProgress.waiting(totalBytes: session.totalBytes),
      done: false,
    );

    final stream = session.direction.isSent
        ? _transferRepo.send(session)
        : _transferRepo.receive(session);

    _sub = stream.listen(
      (progress) {
        if (state is! TransferTransferring) return;
        final cur = state as TransferTransferring;
        if (progress.phase == TransferPhase.completed) {
          state = cur.copyWith(progress: progress, done: true);
          _recordHistory(session, TransferStatus.done);
        } else {
          state = cur.copyWith(progress: progress);
        }
      },
      onError: (Object error) {
        state = TransferFailed(session: session, message: error.toString());
        _recordHistory(session, TransferStatus.failed);
      },
      onDone: () {
        if (state is TransferTransferring) {
          final cur = state as TransferTransferring;
          if (!cur.done) {
            state = TransferFailed(
              session: session,
              message: 'ارتباط پیش از تأیید نهایی پایان یافت.',
            );
            _recordHistory(session, TransferStatus.failed);
          }
        }
      },
    );
  }

  void _recordHistory(TransferSession session, TransferStatus status) {
    final items = session.items;
    final totalBytes = items.fold<int>(0, (sum, item) => sum + item.byteSize);
    final summary = items.length == 1
        ? items.first.name
        : '${toFa(items.length)} مورد';
    _history.add(
      TransferRecord(
        id: 'n${DateTime.now().millisecondsSinceEpoch}',
        direction: session.direction,
        peer: session.peerName,
        hue: session.peerHue,
        summary: summary,
        size: formatBytes(totalBytes),
        createdAt: DateTime.now(),
        status: status,
      ),
    );
  }

  String _newTransferId() {
    final random = Random.secure();
    final bytes = List.generate(18, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final transferFlowProvider =
    StateNotifierProvider<TransferFlowNotifier, TransferFlowState>((ref) {
      return TransferFlowNotifier(
        ref.watch(transferRepositoryProvider),
        ref.watch(historyProvider.notifier),
      );
    });
