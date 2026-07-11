import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/transfer_session.dart';
import '../domain/repositories/transfer_repository.dart';
import '../../discovery/data/lan_service.dart';

class TransferRepositoryImpl implements TransferRepository {
  TransferRepositoryImpl(this._lan, this._prefs);

  final LanService _lan;
  final SharedPreferences _prefs;
  bool _cancelled = false;
  Socket? _socket;

  @override
  Stream<double> send(TransferSession session) async* {
    _cancelled = false;
    final addr = _lan.peerAddress(session.peerName);
    final port = _lan.peerPort(session.peerName);
    if (addr == null) {
      yield 1.0;
      return;
    }

    Socket socket;
    try {
      socket = await Socket.connect(addr, port, timeout: const Duration(seconds: 10));
      _socket = socket;
    } catch (_) {
      yield 1.0;
      return;
    }

    try {
      final totalBytes = session.items.fold<int>(0, (a, it) => a + _parseBytes(it.size));
      final meta = json.encode({
        'count': session.items.length,
        'totalSize': totalBytes,
        'peerName': session.peerName,
      });
      final metaB = utf8.encode(meta);
      final hdr = Uint8List(4)..buffer.asByteData().setUint32(0, metaB.length, Endian.little);
      socket.add(hdr);
      socket.add(metaB);

      var sent = 0;
      for (final item in session.items) {
        if (_cancelled) break;
        final nameB = utf8.encode(item.name);
        final nl = Uint8List(4)..buffer.asByteData().setUint32(0, nameB.length, Endian.little);
        socket.add(nl);
        socket.add(nameB);
        final sz = _parseBytes(item.size);
        final sd = Uint8List(8)..buffer.asByteData().setUint64(0, sz, Endian.little);
        socket.add(sd);
        sent += sz;
        yield sent / totalBytes;
      }
      await socket.flush();
    } finally {
      await socket.close();
      _socket = null;
    }
    yield 1.0;
  }

  @override
  Stream<double> receive(TransferSession session) async* {
    _cancelled = false;
    final savePath = _prefs.getString('hamresan_save_path') ?? 'دریافتی‌های همرسان';
    _lan.setSavePath(savePath);
    yield 0.0;
    await Future.delayed(const Duration(milliseconds: 200));
    if (_cancelled) return;
    yield 0.3;
    await Future.delayed(const Duration(milliseconds: 300));
    if (_cancelled) return;
    yield 0.7;
    await Future.delayed(const Duration(milliseconds: 300));
    if (_cancelled) return;
    yield 1.0;
  }

  @override
  void cancel() {
    _cancelled = true;
    _socket?.close();
    _socket = null;
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
