import '../domain/entities/device.dart';
import '../domain/repositories/device_repository.dart';
import 'lan_service.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl(this._lan);

  final LanService _lan;

  @override
  Future<List<Device>> getNearbyDevices() async => _lan.currentPeers;

  @override
  Stream<List<Device>> watchNearbyDevices() async* {
    yield _lan.currentPeers;
    yield* _lan.peersStream;
  }
}
