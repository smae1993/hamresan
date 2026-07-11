import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import '../../discovery/domain/entities/device.dart';
import '../../transfer/domain/entities/content_item.dart';
import '../../transfer/domain/entities/incoming_request.dart';
import '../../transfer/domain/entities/transfer_session.dart';
import '../../transfer/domain/enums.dart';

const _discoveryPort = 41829;
const _transferPort = 41830;
const _broadcastInterval = Duration(seconds: 5);
const _deviceTimeout = Duration(seconds: 25);

class LanService {
  RawDatagramSocket? _udp;
  ServerSocket? _tcp;
  Timer? _broadcastTimer;
  bool _running = false;

  final _peers = <String, _PeerEntry>{};
  final _peerCtrl = StreamController<List<Device>>.broadcast();
  final _incomingCtrl = StreamController<IncomingRequest?>.broadcast();

  Stream<List<Device>> get peersStream => _peerCtrl.stream;
  Stream<IncomingRequest?> get incomingStream => _incomingCtrl.stream;

  String _myId = '';
  String _myName = '';
  String _myPlatform = '';
  double _myHue = 281;

  void init({required String id, required String name, required String platform, required double hue}) {
    _myId = id;
    _myName = name;
    _myPlatform = platform;
    _myHue = hue;
  }

  Future<void> start() async {
    if (_running) return;
    _running = true;

    try {
      _udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _discoveryPort, reusePort: true);
      _udp!.broadcastEnabled = true;
      _udp!.listen(_onUdp);
    } catch (_) {}

    try {
      _tcp = await ServerSocket.bind(InternetAddress.anyIPv4, _transferPort, shared: true);
      _tcp!.listen(_onTcp);
    } catch (_) {}

    _broadcastTimer = Timer.periodic(_broadcastInterval, (_) => _announce());
    _announce();
    _startCleanup();
    _emitPeers();
  }

  void _startCleanup() {
    Timer.periodic(const Duration(seconds: 10), (_) {
      final now = DateTime.now();
      var changed = false;
      _peers.removeWhere((_, e) {
        if (now.difference(e.lastSeen) > _deviceTimeout) {
          changed = true;
          return true;
        }
        return false;
      });
      if (changed) _emitPeers();
    });
  }

  void _announce() {
    if (_udp == null) return;
    final msg = json.encode({
      'type': 'announce',
      'id': _myId,
      'name': _myName,
      'platform': _myPlatform,
      'hue': _myHue,
      'code': '${_randomAnimal()}-${_randomNum()}',
      'port': _transferPort,
    });
    final data = utf8.encode(msg);
    try {
      _udp!.send(data, InternetAddress('255.255.255.255'), _discoveryPort);
    } catch (_) {}
  }

  void _onUdp(event) {
    if (event != RawSocketEvent.read) return;
    final dg = _udp!.receive();
    if (dg == null) return;
    try {
      final map = jsonDecode(utf8.decode(dg.data)) as Map<String, dynamic>;
      final type = map['type'] as String?;
      if (type == 'announce') _onAnnounce(map, dg.address);
      if (type == 'transfer_request') _onTransferReq(map);
    } catch (_) {}
  }

  void _onAnnounce(Map<String, dynamic> map, InternetAddress addr) {
    final id = map['id'] as String?;
    if (id == null || id == _myId) return;
    _peers[id] = _PeerEntry(
      device: Device(
        id: id,
        name: map['name'] as String? ?? '',
        type: _inferType(map['platform'] as String? ?? ''),
        platform: map['platform'] as String? ?? '',
        hue: (map['hue'] as num?)?.toDouble() ?? 0,
        code: map['code'] as String? ?? '',
      ),
      addr: addr,
      port: (map['port'] as num?)?.toInt() ?? _transferPort,
      lastSeen: DateTime.now(),
    );
    _emitPeers();
  }

  void _onTransferReq(Map<String, dynamic> map) {
    final fromId = map['from'] as String?;
    if (fromId == null || fromId == _myId) return;
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((it) {
      final m = it as Map<String, dynamic>;
      return ContentItem(
        key: m['name'] as String? ?? '',
        name: m['name'] as String? ?? '',
        kind: contentKindFromString(m['kind'] as String?),
        size: _fmtBytes((m['size'] as num?)?.toInt() ?? 0),
        hue: (m['hue'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
    _incomingCtrl.add(IncomingRequest(
      peer: map['fromName'] as String? ?? '',
      hue: (map['fromHue'] as num?)?.toDouble() ?? 0,
      type: map['fromType'] as String? ?? 'phone',
      platform: map['fromPlatform'] as String? ?? '',
      code: map['fromCode'] as String? ?? '',
      items: items,
      total: _fmtBytes((map['total'] as num?)?.toInt() ?? 0),
    ));
  }

  String _savePath = '';

  void setSavePath(String path) { _savePath = path; }

  void _onTcp(Socket socket) {
    _receiveAndSave(socket).then((_) => socket.close()).catchError((_) => socket.close());
  }

  Future<void> _receiveAndSave(Socket socket) async {
    final reader = _SocketReader(socket);

    final metaLenB = await reader.read(4);
    final metaSize = ByteData.sublistView(metaLenB).getUint32(0, Endian.little);
    final metaB = await reader.read(metaSize);
    final meta = jsonDecode(utf8.decode(metaB)) as Map<String, dynamic>;
    final count = meta['count'] as int;
    final peerName = meta['peerName'] as String? ?? 'unknown';

    final baseDir = _savePath.isNotEmpty ? _savePath : '.';
    final sessionDir = '$baseDir/$peerName';
    await Directory(sessionDir).create(recursive: true);

    for (var i = 0; i < count; i++) {
      final nameLenB = await reader.read(4);
      final nameLen = ByteData.sublistView(nameLenB).getUint32(0, Endian.little);
      final nameB = await reader.read(nameLen);
      final fileName = utf8.decode(nameB);

      final sizeB = await reader.read(8);
      final fileSize = ByteData.sublistView(sizeB).getUint64(0, Endian.little);

      final file = File('$sessionDir/$fileName');
      await file.create(recursive: true);
      final sink = file.openWrite();
      var remaining = fileSize;
      while (remaining > 0) {
        final chunk = await reader.read(remaining < 65536 ? remaining.toInt() : 65536);
        sink.add(chunk);
        remaining -= chunk.length;
      }
      await sink.flush();
      await sink.close();
    }
    reader.dispose();
  }

  Future<Stream<double>> sendTransfer(TransferSession session, InternetAddress addr, int port) async {
    final socket = await Socket.connect(addr, port, timeout: const Duration(seconds: 10));
    final ctrl = StreamController<double>();
    final totalBytes = session.items.fold<int>(0, (a, it) => a + _parseBytes(it.size));

    _doSend(socket, session, totalBytes, ctrl);
    return ctrl.stream;
  }

  Future<void> _doSend(Socket socket, TransferSession session, int totalBytes, StreamController<double> ctrl) async {
    try {
      final meta = json.encode({'count': session.items.length, 'totalSize': totalBytes, 'peerName': session.peerName});
      final metaBytes = utf8.encode(meta);
      final hdr = Uint8List(4)..buffer.asByteData().setUint32(0, metaBytes.length, Endian.little);
      socket.add(hdr);
      socket.add(metaBytes);

      var sent = 0;
      for (final item in session.items) {
        final nameB = utf8.encode(item.name);
        final nl = Uint8List(4)..buffer.asByteData().setUint32(0, nameB.length, Endian.little);
        socket.add(nl);
        socket.add(nameB);
        final sz = _parseBytes(item.size);
        final sd = Uint8List(8)..buffer.asByteData().setUint64(0, sz, Endian.little);
        socket.add(sd);
        sent += sz;
        ctrl.add(sent / totalBytes);
      }
      await socket.flush();
      ctrl.add(1.0);
    } catch (e) {
      ctrl.addError(e);
    } finally {
      await socket.close();
      await ctrl.close();
    }
  }

  void triggerIncoming(IncomingRequest request) {
    _incomingCtrl.add(request);
  }

  void requestTransfer(Device device, List<ContentItem> items) {
    final peer = _peers[device.id];
    if (peer == null) return;
    final total = items.fold<int>(0, (a, it) => a + _parseBytes(it.size));
    final msg = json.encode({
      'type': 'transfer_request',
      'from': _myId, 'fromName': _myName, 'fromHue': _myHue,
      'fromType': _inferType(_myPlatform),
      'fromPlatform': _myPlatform, 'fromCode': '',
      'items': items.map((it) => {
        'name': it.name, 'size': _parseBytes(it.size), 'hue': it.hue, 'kind': it.kind.name,
      }).toList(),
      'total': total,
    });
    try {
      _udp!.send(utf8.encode(msg), peer.addr, _discoveryPort);
    } catch (_) {}
  }

  InternetAddress? peerAddress(String deviceId) => _peers[deviceId]?.addr;
  int peerPort(String deviceId) => _peers[deviceId]?.port ?? _transferPort;

  void _emitPeers() => _peerCtrl.add(_peers.values.map((e) => e.device).toList());

  void stop() {
    _running = false;
    _broadcastTimer?.cancel();
    _udp?.close();
    _tcp?.close();
  }

  void dispose() { stop(); _peerCtrl.close(); _incomingCtrl.close(); }

  String _inferType(String p) {
    final l = p.toLowerCase();
    if (l.contains('android') || l.contains('ios')) return 'phone';
    if (l.contains('mac')) return 'laptop';
    if (l.contains('windows')) return 'desktop';
    if (l.contains('linux')) return 'desktop';
    return 'phone';
  }

  String _randomAnimal() => ['آبی', 'ققنوس', 'کوه', 'مروارید', 'ستاره', 'ریشه', 'بادبادک'][Random().nextInt(7)];
  String _randomNum() => '${Random().nextInt(99) + 1}';

  String _fmtBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  int _parseBytes(String s) {
    final e = s.replaceAll('۰', '0').replaceAll('۱', '1').replaceAll('۲', '2')
        .replaceAll('۳', '3').replaceAll('۴', '4').replaceAll('۵', '5')
        .replaceAll('۶', '6').replaceAll('۷', '7').replaceAll('۸', '8')
        .replaceAll('۹', '9').replaceAll('٫', '.').trim().split(' ');
    if (e.length != 2) return 0;
    final v = double.tryParse(e[0]) ?? 0;
    return switch (e[1].toLowerCase()) {
      'kb' => (v * 1024).toInt(), 'mb' => (v * 1024 * 1024).toInt(),
      'gb' => (v * 1024 * 1024 * 1024).toInt(), _ => v.toInt(),
    };
  }
}

class _PeerEntry {
  _PeerEntry({required this.device, required this.addr, required this.port, required this.lastSeen});
  final Device device;
  final InternetAddress addr;
  final int port;
  DateTime lastSeen;
}

class _SocketReader {
  _SocketReader(Socket socket)
      : _queue = <Uint8List>[],
        _done = false {
    _sub = socket.listen(
      (data) { _queue.add(data); _completer?.complete(); },
      onError: (e) { _error = e; _completer?.completeError(e); },
      onDone: () { _done = true; _completer?.complete(); },
      cancelOnError: false,
    );
  }

  late final StreamSubscription<Uint8List> _sub;
  final List<Uint8List> _queue;
  Completer<void>? _completer;
  Object? _error;
  bool _done;

  Future<Uint8List> read(int len) async {
    final parts = <Uint8List>[];
    var remaining = len;
    while (remaining > 0) {
      if (_queue.isEmpty) {
        if (_done) return Uint8List(0);
        if (_error != null) throw _error!;
        _completer = Completer<void>();
        await _completer!.future;
        _completer = null;
        if (_error != null) throw _error!;
      }
      final data = _queue.removeAt(0);
      if (data.length <= remaining) {
        parts.add(data);
        remaining -= data.length;
      } else {
        parts.add(data.sublist(0, remaining));
        _queue.insert(0, data.sublist(remaining));
        remaining = 0;
      }
    }
    final total = Uint8List(len);
    var off = 0;
    for (final p in parts) {
      total.setRange(off, off + p.length, p);
      off += p.length;
    }
    return total;
  }

  void dispose() { _sub.cancel(); }
}
