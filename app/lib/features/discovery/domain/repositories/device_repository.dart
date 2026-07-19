// Device discovery repository contract — همرسان.
//
// Abstract interface so the discovery implementation (mock today, real mDNS
// / NSD later) can be swapped without touching the presentation layer.
import '../entities/device.dart';

abstract class DeviceRepository {
  /// Currently visible nearby devices.
  Future<List<Device>> getNearbyDevices();

  /// Emits the live list of nearby devices as they come and go.
  /// Stub implementations can emit once and complete.
  Stream<List<Device>> watchNearbyDevices();
}
