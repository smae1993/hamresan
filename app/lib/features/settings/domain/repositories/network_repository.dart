class NetworkInfo {
  const NetworkInfo({
    required this.ssid,
    required this.ip,
    required this.encrypted,
  });

  final String ssid;
  final String ip;
  final bool encrypted;
}

abstract class NetworkRepository {
  Future<NetworkInfo> getInfo();
}
