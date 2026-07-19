/// Device entity — همرسان.
///
/// Represents a remote device discovered on the local network.
import '../../../transfer/domain/enums.dart';

class Device {
  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.platform,
    required this.hue,
    required this.code,
    this.protocolVersion = 1,
  });

  final String id;
  final String name;

  /// Raw device-type string (e.g. "phone", "laptop"). Kept as string so mock
  /// data round-trips losslessly.
  final String type;
  final String platform;
  final double hue;
  final String code;
  final int protocolVersion;

  DeviceType get deviceType => deviceTypeFromString(type);
  Device copyWith({
    String? id,
    String? name,
    String? type,
    String? platform,
    double? hue,
    String? code,
    int? protocolVersion,
  }) => Device(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    platform: platform ?? this.platform,
    hue: hue ?? this.hue,
    code: code ?? this.code,
    protocolVersion: protocolVersion ?? this.protocolVersion,
  );
}
