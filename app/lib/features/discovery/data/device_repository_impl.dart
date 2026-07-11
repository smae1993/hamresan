import 'dart:async';
import '../domain/entities/device.dart';
import '../domain/repositories/device_repository.dart';
import 'lan_service.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl(this._lan);

  final LanService _lan;

  @override
  Future<List<Device>> getNearbyDevices() async {
    final ctrl = StreamController<List<Device>>();
    final sub = _lan.peersStream.listen((d) {
      if (!ctrl.isClosed) ctrl.add(d);
    });
    await Future.delayed(const Duration(milliseconds: 500));
    final devices = await ctrl.stream.first;
    await sub.cancel();
    await ctrl.close();
    return devices;
  }

  @override
  Stream<List<Device>> watchNearbyDevices() => _lan.peersStream;
}
