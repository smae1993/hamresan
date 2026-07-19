import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../transfer/domain/entities/content_item.dart';
import '../../transfer/domain/entities/incoming_request.dart';
import '../../transfer/domain/entities/transfer_progress.dart';
import '../../transfer/domain/entities/transfer_session.dart';
import '../../transfer/domain/enums.dart';
import '../../transfer/data/transfer_safety.dart';
import '../domain/entities/device.dart';

const _protocolMagic = 'HAMRESAN';
const _protocolVersion = 1;
const _discoveryPort = 41829;
const _preferredTransferPort = 41830;
const _broadcastInterval = Duration(seconds: 4);
const _deviceTimeout = Duration(seconds: 18);
const _requestTimeout = Duration(seconds: 60);
const _socketTimeout = Duration(seconds: 30);
const _maxHeaderBytes = 256 * 1024;
const _maxFilesPerTransfer = 500;
const _maxTransferBytes = 2 * 1024 * 1024 * 1024 * 1024;

class TransferRejectedException implements Exception {
  const TransferRejectedException(this.message);
  final String message;

  @override
  String toString() => message;
}

class TransferProtocolException implements Exception {
  const TransferProtocolException(this.message);
  final String message;

  @override
  String toString() => message;
}

class TransferAuthorization {
  const TransferAuthorization({
    required this.address,
    required this.port,
    required this.token,
  });

  final InternetAddress address;
  final int port;
  final String token;
}

enum LanStatus { stopped, starting, ready, failed }

class LanService {
  RawDatagramSocket? _udp;
  ServerSocket? _tcp;
  Timer? _broadcastTimer;
  Timer? _cleanupTimer;
  Future<void>? _starting;
  bool _running = false;

  final _peers = <String, _PeerEntry>{};
  final _pendingDecisions = <String, _PendingDecision>{};
  final _pendingIncoming = <String, _PendingIncoming>{};
  final _acceptedIncoming = <String, _AcceptedIncoming>{};
  final _activeSockets = <String, Socket>{};
  final _peerCtrl = StreamController<List<Device>>.broadcast();
  final _incomingCtrl = StreamController<IncomingRequest?>.broadcast();
  final _statusCtrl = StreamController<LanStatus>.broadcast();

  Stream<List<Device>> get peersStream => _peerCtrl.stream;
  Stream<IncomingRequest?> get incomingStream => _incomingCtrl.stream;
  Stream<LanStatus> get statusStream async* {
    yield _status;
    yield* _statusCtrl.stream;
  }

  LanStatus get status => _status;
  Object? get lastError => _lastError;
  List<Device> get currentPeers =>
      List.unmodifiable(_peers.values.map((entry) => entry.device));

  String _myId = '';
  String _myName = '';
  String _myPlatform = '';
  String _myCode = '';
  double _myHue = 281;
  bool _visible = true;
  String _savePath = '';
  LanStatus _status = LanStatus.stopped;
  Object? _lastError;

  void configure({
    required String id,
    required String name,
    required String platform,
    required String code,
    required double hue,
    required bool visible,
    required String savePath,
  }) {
    final identityChanged =
        _myId != id ||
        _myName != name ||
        _myPlatform != platform ||
        _myCode != code ||
        _myHue != hue;
    _myId = id;
    _myName = name;
    _myPlatform = platform;
    _myCode = code;
    _myHue = hue;
    _visible = visible;
    _savePath = savePath;
    if (_running && identityChanged) _announce();
  }

  Future<void> start() {
    if (_running) return Future.value();
    return _starting ??= _startWithStatus().whenComplete(
      () => _starting = null,
    );
  }

  Future<void> _startWithStatus() async {
    _setStatus(LanStatus.starting);
    try {
      await _start();
      _lastError = null;
      _setStatus(LanStatus.ready);
    } catch (error) {
      _lastError = error;
      _setStatus(LanStatus.failed);
      rethrow;
    }
  }

  Future<void> _start() async {
    if (_running) return;
    if (_myId.isEmpty) {
      throw const TransferProtocolException('هویت دستگاه هنوز آماده نیست.');
    }

    final udp = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      _discoveryPort,
      reuseAddress: true,
      reusePort: true,
    );
    udp.broadcastEnabled = true;

    ServerSocket tcp;
    try {
      tcp = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        _preferredTransferPort,
      );
    } on SocketException {
      tcp = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    }

    _udp = udp;
    _tcp = tcp;
    _running = true;
    udp.listen(_onUdp, onError: _onNetworkError);
    tcp.listen(_onTcp, onError: _onNetworkError);
    _broadcastTimer = Timer.periodic(_broadcastInterval, (_) => _announce());
    _cleanupTimer = Timer.periodic(
      const Duration(seconds: 6),
      (_) => _removeExpiredPeers(),
    );
    _announce();
    _emitPeers();
  }

  void _onNetworkError(Object error, [StackTrace? stackTrace]) {
    _lastError = error;
    _setStatus(LanStatus.failed);
    for (final pending in _pendingDecisions.values) {
      if (!pending.completer.isCompleted) {
        pending.completer.completeError(error, stackTrace);
      }
    }
    _pendingDecisions.clear();
  }

  void _removeExpiredPeers() {
    final now = DateTime.now();
    final before = _peers.length;
    _peers.removeWhere(
      (_, entry) => now.difference(entry.lastSeen) > _deviceTimeout,
    );
    if (_peers.length != before) _emitPeers();
    _pendingIncoming.removeWhere(
      (_, pending) => now.difference(pending.receivedAt) > _requestTimeout,
    );
    final expiredAccepted = _acceptedIncoming.entries
        .where(
          (entry) => now.difference(entry.value.acceptedAt) > _requestTimeout,
        )
        .map((entry) => entry.key)
        .toList();
    for (final transferId in expiredAccepted) {
      final accepted = _acceptedIncoming.remove(transferId);
      if (accepted != null && !accepted.controller.isClosed) {
        accepted.controller.addError(
          const TransferRejectedException('فرستنده اتصال را آغاز نکرد.'),
        );
        unawaited(accepted.controller.close());
      }
    }
  }

  void _announce() {
    final udp = _udp;
    final tcp = _tcp;
    if (!_visible || udp == null || tcp == null || _myId.isEmpty) return;
    final message = jsonEncode({
      'type': 'announce',
      'protocol': _protocolVersion,
      'id': _myId,
      'name': _myName,
      'platform': _myPlatform,
      'hue': _myHue,
      'code': _myCode,
      'port': tcp.port,
    });
    udp.send(
      utf8.encode(message),
      InternetAddress('255.255.255.255'),
      _discoveryPort,
    );
  }

  void _onUdp(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final datagram = _udp?.receive();
    if (datagram == null) return;
    try {
      final decoded = jsonDecode(utf8.decode(datagram.data));
      if (decoded is! Map<String, dynamic>) return;
      switch (decoded['type']) {
        case 'announce':
          _onAnnounce(decoded, datagram.address);
        case 'transfer_request':
          _onTransferRequest(decoded, datagram.address);
        case 'transfer_response':
          _onTransferResponse(decoded, datagram.address);
      }
    } catch (_) {
      // Invalid LAN datagrams are intentionally ignored.
    }
  }

  void _onAnnounce(Map<String, dynamic> map, InternetAddress address) {
    final id = map['id'] as String?;
    final protocol = (map['protocol'] as num?)?.toInt() ?? 0;
    if (id == null || id.isEmpty || id == _myId || protocol <= 0) return;
    final port = (map['port'] as num?)?.toInt() ?? 0;
    if (port < 1 || port > 65535) return;

    _peers[id] = _PeerEntry(
      device: Device(
        id: id,
        name: _limitedString(map['name'], fallback: 'دستگاه ناشناس'),
        type: _inferType(_limitedString(map['platform'])),
        platform: _limitedString(map['platform'], fallback: 'Unknown'),
        hue: (map['hue'] as num?)?.toDouble() ?? 0,
        code: _limitedString(map['code']),
        protocolVersion: protocol,
      ),
      address: address,
      port: port,
      lastSeen: DateTime.now(),
    );
    _emitPeers();
  }

  void _onTransferRequest(Map<String, dynamic> map, InternetAddress address) {
    if (!_visible) return;
    final protocol = (map['protocol'] as num?)?.toInt() ?? 0;
    final transferId = map['transferId'] as String? ?? '';
    final peerId = map['fromId'] as String? ?? '';
    if (protocol != _protocolVersion ||
        transferId.isEmpty ||
        transferId.length > 96 ||
        peerId.isEmpty ||
        peerId == _myId) {
      return;
    }
    if (_pendingIncoming.containsKey(transferId) ||
        _acceptedIncoming.containsKey(transferId)) {
      return;
    }

    final rawItems = map['items'];
    if (rawItems is! List ||
        rawItems.isEmpty ||
        rawItems.length > _maxFilesPerTransfer) {
      return;
    }

    final items = <ContentItem>[];
    var totalBytes = 0;
    for (var i = 0; i < rawItems.length; i++) {
      final raw = rawItems[i];
      if (raw is! Map) return;
      final item = Map<String, dynamic>.from(raw);
      final byteSize = (item['size'] as num?)?.toInt() ?? -1;
      if (byteSize < 0 || byteSize > _maxTransferBytes) return;
      totalBytes += byteSize;
      if (totalBytes > _maxTransferBytes) return;
      items.add(
        ContentItem(
          key: 'remote:$transferId:$i',
          name: TransferSafety.sanitizeFileName(
            _limitedString(item['name'], fallback: 'file'),
          ),
          kind: contentKindFromString(item['kind'] as String?),
          byteSize: byteSize,
          hue: (item['hue'] as num?)?.toDouble() ?? 0,
        ),
      );
    }

    final request = IncomingRequest(
      transferId: transferId,
      peerId: peerId,
      peer: _limitedString(map['fromName'], fallback: 'دستگاه ناشناس'),
      hue: (map['fromHue'] as num?)?.toDouble() ?? 0,
      type: _limitedString(map['fromType'], fallback: 'phone'),
      platform: _limitedString(map['fromPlatform'], fallback: 'Unknown'),
      code: _limitedString(map['fromCode']),
      items: List.unmodifiable(items),
      totalBytes: totalBytes,
    );
    _pendingIncoming[transferId] = _PendingIncoming(
      request: request,
      address: address,
      receivedAt: DateTime.now(),
    );
    _incomingCtrl.add(request);
  }

  void _onTransferResponse(Map<String, dynamic> map, InternetAddress address) {
    final transferId = map['transferId'] as String? ?? '';
    final pending = _pendingDecisions[transferId];
    if (pending == null || pending.completer.isCompleted) return;
    if (pending.expectedAddress.address != address.address) return;
    final completer = pending.completer;
    if (map['accepted'] != true) {
      completer.completeError(
        TransferRejectedException(
          _limitedString(map['reason'], fallback: 'درخواست انتقال رد شد.'),
        ),
      );
      return;
    }
    final port = (map['port'] as num?)?.toInt() ?? 0;
    final token = map['token'] as String? ?? '';
    if (port < 1 || port > 65535 || token.length < 16) {
      completer.completeError(
        const TransferProtocolException('پاسخ گیرنده معتبر نیست.'),
      );
      return;
    }
    completer.complete(
      TransferAuthorization(address: address, port: port, token: token),
    );
  }

  Future<TransferAuthorization> requestTransfer(TransferSession session) async {
    final udp = _udp;
    final peer = _peers[session.peerId];
    if (udp == null || peer == null) {
      throw const TransferProtocolException('دستگاه مقصد دیگر در دسترس نیست.');
    }
    if (peer.device.protocolVersion != _protocolVersion) {
      throw const TransferProtocolException(
        'نسخهٔ دو دستگاه با هم سازگار نیست.',
      );
    }
    if (session.items.isEmpty || session.items.length > _maxFilesPerTransfer) {
      throw const TransferProtocolException('فهرست فایل‌ها معتبر نیست.');
    }

    final items = <Map<String, Object>>[];
    var totalBytes = 0;
    for (final item in session.items) {
      final file = File(item.key);
      if (!await file.exists()) {
        throw TransferProtocolException('فایل ${item.name} پیدا نشد.');
      }
      final size = await file.length();
      totalBytes += size;
      if (totalBytes > _maxTransferBytes) {
        throw const TransferProtocolException('حجم انتقال بیش از حد مجاز است.');
      }
      items.add({
        'name': TransferSafety.sanitizeFileName(item.name),
        'size': size,
        'kind': item.kind.name,
        'hue': item.hue,
      });
    }

    final completer = Completer<TransferAuthorization>();
    _pendingDecisions[session.id] = _PendingDecision(
      completer: completer,
      expectedAddress: peer.address,
    );
    final message = jsonEncode({
      'type': 'transfer_request',
      'protocol': _protocolVersion,
      'transferId': session.id,
      'fromId': _myId,
      'fromName': _myName,
      'fromHue': _myHue,
      'fromType': _inferType(_myPlatform),
      'fromPlatform': _myPlatform,
      'fromCode': _myCode,
      'items': items,
      'total': totalBytes,
    });
    udp.send(utf8.encode(message), peer.address, _discoveryPort);

    try {
      return await completer.future.timeout(
        _requestTimeout,
        onTimeout: () => throw const TransferRejectedException(
          'گیرنده در زمان تعیین‌شده پاسخی نداد.',
        ),
      );
    } finally {
      _pendingDecisions.remove(session.id);
    }
  }

  Future<Stream<TransferProgress>> acceptTransfer(
    TransferSession session,
  ) async {
    final pending = _pendingIncoming.remove(session.id);
    final tcp = _tcp;
    if (pending == null || tcp == null) {
      throw const TransferProtocolException('درخواست انتقال منقضی شده است.');
    }
    final token = _randomToken();
    final controller = StreamController<TransferProgress>();
    _acceptedIncoming[session.id] = _AcceptedIncoming(
      pending: pending,
      token: token,
      controller: controller,
      acceptedAt: DateTime.now(),
    );
    _sendTransferResponse(
      pending,
      accepted: true,
      token: token,
      port: tcp.port,
    );
    return controller.stream;
  }

  Future<void> declineTransfer(IncomingRequest request) async {
    final pending = _pendingIncoming.remove(request.transferId);
    if (pending == null) return;
    _sendTransferResponse(
      pending,
      accepted: false,
      reason: 'گیرنده درخواست را رد کرد.',
    );
  }

  void _sendTransferResponse(
    _PendingIncoming pending, {
    required bool accepted,
    String token = '',
    int port = 0,
    String reason = '',
  }) {
    final udp = _udp;
    if (udp == null) return;
    final response = jsonEncode({
      'type': 'transfer_response',
      'protocol': _protocolVersion,
      'transferId': pending.request.transferId,
      'accepted': accepted,
      'token': token,
      'port': port,
      'reason': reason,
    });
    udp.send(utf8.encode(response), pending.address, _discoveryPort);
  }

  Stream<TransferProgress> sendTransfer(
    TransferSession session,
    TransferAuthorization authorization,
  ) async* {
    final files = <File>[];
    final sizes = <int>[];
    var totalBytes = 0;
    for (final item in session.items) {
      final file = File(item.key);
      if (!await file.exists()) {
        throw TransferProtocolException('فایل ${item.name} پیدا نشد.');
      }
      final size = await file.length();
      files.add(file);
      sizes.add(size);
      totalBytes += size;
    }

    yield TransferProgress(
      phase: TransferPhase.connecting,
      transferredBytes: 0,
      totalBytes: totalBytes,
    );

    final socket = await Socket.connect(
      authorization.address,
      authorization.port,
      timeout: const Duration(seconds: 10),
    );
    _activeSockets[session.id] = socket;
    final speed = _SpeedMeter();
    var transferred = 0;
    try {
      final metadata = jsonEncode({
        'magic': _protocolMagic,
        'protocol': _protocolVersion,
        'transferId': session.id,
        'token': authorization.token,
        'senderId': _myId,
        'files': [
          for (var i = 0; i < session.items.length; i++)
            {
              'name': TransferSafety.sanitizeFileName(session.items[i].name),
              'size': sizes[i],
              'kind': session.items[i].kind.name,
            },
        ],
      });
      final metadataBytes = utf8.encode(metadata);
      if (metadataBytes.length > _maxHeaderBytes) {
        throw const TransferProtocolException(
          'اطلاعات انتقال بیش از حد بزرگ است.',
        );
      }
      socket.add(_uint32(metadataBytes.length));
      socket.add(metadataBytes);
      await socket.flush();

      for (var index = 0; index < files.length; index++) {
        Digest? digest;
        final output = ChunkedConversionSink<Digest>.withCallback(
          (values) => digest = values.single,
        );
        final hashInput = sha256.startChunkedConversion(output);
        var fileBytes = 0;
        await for (final chunk in files[index].openRead()) {
          hashInput.add(chunk);
          socket.add(chunk);
          await socket.flush();
          fileBytes += chunk.length;
          transferred += chunk.length;
          yield TransferProgress(
            phase: TransferPhase.transferring,
            transferredBytes: transferred,
            totalBytes: totalBytes,
            currentFileIndex: index,
            currentFileBytes: fileBytes,
            currentFileTotalBytes: sizes[index],
            bytesPerSecond: speed.bytesPerSecond(transferred),
          );
        }
        hashInput.close();
        final checksum = digest;
        if (checksum == null) {
          throw const TransferProtocolException('محاسبهٔ صحت فایل ناموفق بود.');
        }
        socket.add(checksum.bytes);
        await socket.flush();
      }

      yield TransferProgress(
        phase: TransferPhase.verifying,
        transferredBytes: transferred,
        totalBytes: totalBytes,
        currentFileIndex: max(0, files.length - 1),
        currentFileBytes: files.isEmpty ? 0 : sizes.last,
        currentFileTotalBytes: files.isEmpty ? 0 : sizes.last,
        bytesPerSecond: speed.bytesPerSecond(transferred),
      );
      final acknowledgement = await socket.first.timeout(_socketTimeout);
      if (acknowledgement.isEmpty || acknowledgement.first != 1) {
        throw const TransferProtocolException(
          'گیرنده صحت فایل‌ها را تأیید نکرد.',
        );
      }
      yield TransferProgress(
        phase: TransferPhase.completed,
        transferredBytes: totalBytes,
        totalBytes: totalBytes,
        currentFileIndex: max(0, files.length - 1),
        currentFileBytes: files.isEmpty ? 0 : sizes.last,
        currentFileTotalBytes: files.isEmpty ? 0 : sizes.last,
        bytesPerSecond: speed.bytesPerSecond(transferred),
      );
    } finally {
      _activeSockets.remove(session.id);
      socket.destroy();
    }
  }

  void _onTcp(Socket socket) {
    unawaited(_receiveAndSave(socket));
  }

  Future<void> _receiveAndSave(Socket socket) async {
    _SocketReader? reader;
    _AcceptedIncoming? accepted;
    String? transferId;
    File? partialFile;
    try {
      reader = _SocketReader(socket);
      final headerSize = _readUint32(await reader.readExact(4));
      if (headerSize <= 0 || headerSize > _maxHeaderBytes) {
        throw const TransferProtocolException('هدر انتقال معتبر نیست.');
      }
      final decoded = jsonDecode(
        utf8.decode(await reader.readExact(headerSize)),
      );
      if (decoded is! Map<String, dynamic> ||
          decoded['magic'] != _protocolMagic ||
          decoded['protocol'] != _protocolVersion) {
        throw const TransferProtocolException('پروتکل انتقال معتبر نیست.');
      }

      transferId = decoded['transferId'] as String? ?? '';
      accepted = _acceptedIncoming.remove(transferId);
      if (accepted == null ||
          decoded['token'] != accepted.token ||
          decoded['senderId'] != accepted.pending.request.peerId ||
          socket.remoteAddress.address != accepted.pending.address.address) {
        throw const TransferProtocolException('این انتقال مجاز نیست.');
      }
      _activeSockets[transferId] = socket;

      final rawFiles = decoded['files'];
      final offered = accepted.pending.request.items;
      if (rawFiles is! List || rawFiles.length != offered.length) {
        throw const TransferProtocolException('فهرست فایل‌ها تغییر کرده است.');
      }

      final saveRoot = _savePath.trim();
      if (saveRoot.isEmpty) {
        throw const TransferProtocolException('محل ذخیره مشخص نشده است.');
      }
      final senderFolder = TransferSafety.sanitizeFileName(
        accepted.pending.request.peer,
      );
      final sessionDirectory = Directory(_join(saveRoot, senderFolder));
      await sessionDirectory.create(recursive: true);

      final speed = _SpeedMeter();
      var transferred = 0;
      final totalBytes = accepted.pending.request.totalBytes;
      for (var index = 0; index < rawFiles.length; index++) {
        final raw = rawFiles[index];
        if (raw is! Map) {
          throw const TransferProtocolException('اطلاعات فایل معتبر نیست.');
        }
        final metadata = Map<String, dynamic>.from(raw);
        final name = TransferSafety.sanitizeFileName(
          _limitedString(metadata['name'], fallback: 'file'),
        );
        final size = (metadata['size'] as num?)?.toInt() ?? -1;
        if (name != offered[index].name || size != offered[index].byteSize) {
          throw const TransferProtocolException(
            'اطلاعات فایل با درخواست یکسان نیست.',
          );
        }

        final destination = await _uniqueDestination(sessionDirectory, name);
        partialFile = File('${destination.path}.hamresan-$transferId.part');
        final sink = partialFile.openWrite();
        Digest? digest;
        final digestOutput = ChunkedConversionSink<Digest>.withCallback(
          (values) => digest = values.single,
        );
        final hashInput = sha256.startChunkedConversion(digestOutput);
        var remaining = size;
        var fileBytes = 0;
        try {
          while (remaining > 0) {
            final length = min(64 * 1024, remaining);
            final chunk = await reader.readExact(length);
            sink.add(chunk);
            hashInput.add(chunk);
            remaining -= chunk.length;
            fileBytes += chunk.length;
            transferred += chunk.length;
            accepted.controller.add(
              TransferProgress(
                phase: TransferPhase.transferring,
                transferredBytes: transferred,
                totalBytes: totalBytes,
                currentFileIndex: index,
                currentFileBytes: fileBytes,
                currentFileTotalBytes: size,
                bytesPerSecond: speed.bytesPerSecond(transferred),
              ),
            );
          }
          await sink.flush();
        } finally {
          await sink.close();
          hashInput.close();
        }

        final sentDigest = await reader.readExact(32);
        if (digest == null ||
            !TransferSafety.constantTimeEquals(digest!.bytes, sentDigest)) {
          if (await partialFile.exists()) await partialFile.delete();
          throw TransferProtocolException('صحت فایل $name تأیید نشد.');
        }
        await partialFile.rename(destination.path);
        partialFile = null;
      }

      accepted.controller.add(
        TransferProgress(
          phase: TransferPhase.verifying,
          transferredBytes: transferred,
          totalBytes: totalBytes,
          currentFileIndex: max(0, offered.length - 1),
          currentFileBytes: offered.isEmpty ? 0 : offered.last.byteSize,
          currentFileTotalBytes: offered.isEmpty ? 0 : offered.last.byteSize,
          bytesPerSecond: speed.bytesPerSecond(transferred),
        ),
      );
      socket.add(const [1]);
      await socket.flush();
      accepted.controller.add(
        TransferProgress(
          phase: TransferPhase.completed,
          transferredBytes: totalBytes,
          totalBytes: totalBytes,
          currentFileIndex: max(0, offered.length - 1),
          currentFileBytes: offered.isEmpty ? 0 : offered.last.byteSize,
          currentFileTotalBytes: offered.isEmpty ? 0 : offered.last.byteSize,
          bytesPerSecond: speed.bytesPerSecond(transferred),
        ),
      );
      await accepted.controller.close();
    } catch (error, stackTrace) {
      socket.add(const [0]);
      if (partialFile != null && await partialFile.exists()) {
        await partialFile.delete();
      }
      if (accepted != null && !accepted.controller.isClosed) {
        accepted.controller.addError(error, stackTrace);
        await accepted.controller.close();
      }
    } finally {
      if (transferId != null) _activeSockets.remove(transferId);
      reader?.dispose();
      socket.destroy();
    }
  }

  Future<void> cancelTransfer(String transferId) async {
    _activeSockets.remove(transferId)?.destroy();
    final decision = _pendingDecisions.remove(transferId);
    if (decision != null && !decision.completer.isCompleted) {
      decision.completer.completeError(
        const TransferRejectedException('انتقال توسط کاربر لغو شد.'),
      );
    }
    final pending = _pendingIncoming.remove(transferId);
    if (pending != null) {
      _sendTransferResponse(
        pending,
        accepted: false,
        reason: 'انتقال توسط گیرنده لغو شد.',
      );
    }
    final accepted = _acceptedIncoming.remove(transferId);
    if (accepted != null && !accepted.controller.isClosed) {
      await accepted.controller.close();
    }
  }

  void _emitPeers() {
    if (!_peerCtrl.isClosed) _peerCtrl.add(currentPeers);
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    _broadcastTimer?.cancel();
    _cleanupTimer?.cancel();
    _broadcastTimer = null;
    _cleanupTimer = null;
    _udp?.close();
    _udp = null;
    await _tcp?.close();
    _tcp = null;
    for (final socket in _activeSockets.values) {
      socket.destroy();
    }
    _activeSockets.clear();
    _setStatus(LanStatus.stopped);
  }

  void dispose() {
    unawaited(stop());
    _peerCtrl.close();
    _incomingCtrl.close();
    _statusCtrl.close();
  }

  void _setStatus(LanStatus next) {
    _status = next;
    if (!_statusCtrl.isClosed) _statusCtrl.add(next);
  }

  String _inferType(String platform) {
    final value = platform.toLowerCase();
    if (value.contains('ipad')) return 'tablet';
    if (value.contains('android') || value.contains('ios')) return 'phone';
    if (value.contains('mac')) return 'laptop';
    if (value.contains('windows') || value.contains('linux')) return 'desktop';
    return 'phone';
  }

  String _randomToken() {
    final random = Random.secure();
    return base64UrlEncode(List.generate(32, (_) => random.nextInt(256)));
  }

  String _limitedString(Object? value, {String fallback = ''}) {
    final text = value is String ? value.trim() : '';
    if (text.isEmpty) return fallback;
    return text.length <= 255 ? text : text.substring(0, 255);
  }

  String _join(String parent, String child) {
    final separator = Platform.pathSeparator;
    return parent.endsWith(separator)
        ? '$parent$child'
        : '$parent$separator$child';
  }

  Future<File> _uniqueDestination(Directory directory, String name) async {
    var candidate = File(_join(directory.path, name));
    if (!await candidate.exists()) return candidate;
    final dot = name.lastIndexOf('.');
    final base = dot > 0 ? name.substring(0, dot) : name;
    final extension = dot > 0 ? name.substring(dot) : '';
    for (var index = 1; index < 10000; index++) {
      candidate = File(_join(directory.path, '$base ($index)$extension'));
      if (!await candidate.exists()) return candidate;
    }
    throw const TransferProtocolException(
      'نام مناسبی برای ذخیرهٔ فایل پیدا نشد.',
    );
  }

  Uint8List _uint32(int value) {
    final bytes = Uint8List(4);
    ByteData.sublistView(bytes).setUint32(0, value, Endian.big);
    return bytes;
  }

  int _readUint32(Uint8List bytes) =>
      ByteData.sublistView(bytes).getUint32(0, Endian.big);
}

class _PeerEntry {
  _PeerEntry({
    required this.device,
    required this.address,
    required this.port,
    required this.lastSeen,
  });

  final Device device;
  final InternetAddress address;
  final int port;
  DateTime lastSeen;
}

class _PendingIncoming {
  const _PendingIncoming({
    required this.request,
    required this.address,
    required this.receivedAt,
  });

  final IncomingRequest request;
  final InternetAddress address;
  final DateTime receivedAt;
}

class _PendingDecision {
  const _PendingDecision({
    required this.completer,
    required this.expectedAddress,
  });

  final Completer<TransferAuthorization> completer;
  final InternetAddress expectedAddress;
}

class _AcceptedIncoming {
  const _AcceptedIncoming({
    required this.pending,
    required this.token,
    required this.controller,
    required this.acceptedAt,
  });

  final _PendingIncoming pending;
  final String token;
  final StreamController<TransferProgress> controller;
  final DateTime acceptedAt;
}

class _SpeedMeter {
  _SpeedMeter() : _startedAt = DateTime.now();
  final DateTime _startedAt;

  double bytesPerSecond(int bytes) {
    final seconds = DateTime.now().difference(_startedAt).inMilliseconds / 1000;
    return seconds <= 0 ? 0 : bytes / seconds;
  }
}

class _SocketReader {
  _SocketReader(Socket socket) {
    _subscription = socket.listen(
      (data) {
        _queue.add(Uint8List.fromList(data));
        _waiting?.complete();
      },
      onError: (Object error, StackTrace stackTrace) {
        _error = error;
        _stackTrace = stackTrace;
        _waiting?.complete();
      },
      onDone: () {
        _done = true;
        _waiting?.complete();
      },
      cancelOnError: false,
    );
  }

  late final StreamSubscription<Uint8List> _subscription;
  final List<Uint8List> _queue = [];
  Completer<void>? _waiting;
  Object? _error;
  StackTrace? _stackTrace;
  bool _done = false;

  Future<Uint8List> readExact(int length) async {
    if (length < 0) {
      throw const TransferProtocolException('طول فریم معتبر نیست.');
    }
    final result = Uint8List(length);
    var offset = 0;
    while (offset < length) {
      while (_queue.isEmpty) {
        if (_error != null) Error.throwWithStackTrace(_error!, _stackTrace!);
        if (_done) {
          throw const TransferProtocolException(
            'ارتباط پیش از تکمیل فایل قطع شد.',
          );
        }
        _waiting = Completer<void>();
        await _waiting!.future.timeout(_socketTimeout);
        _waiting = null;
      }
      final data = _queue.removeAt(0);
      final count = min(data.length, length - offset);
      result.setRange(offset, offset + count, data);
      offset += count;
      if (count < data.length) {
        _queue.insert(0, Uint8List.sublistView(data, count));
      }
    }
    return result;
  }

  void dispose() {
    unawaited(_subscription.cancel());
  }
}
