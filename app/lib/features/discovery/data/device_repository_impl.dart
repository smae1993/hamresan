/// Device discovery repository implementation (mock) — همرسان.
///
/// Returns the static device list from `mock_devices.dart`. A future real
/// implementation will use mDNS/NSD to discover peers on the LAN.
import 'dart:async';
import '../domain/entities/device.dart';
import '../domain/repositories/device_repository.dart';
import 'mock_devices.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  @override
  Future<List<Device>> getNearbyDevices() async => mockDevices;

  @override
  Stream<List<Device>> watchNearbyDevices() async* {
    // Simulate a brief "scanning" delay then emit the list once.
    await Future.delayed(const Duration(seconds: 1));
    yield mockDevices;
    // Keep stream open; no more events in mock mode.
    await Completer<void>().future;
  }
}
