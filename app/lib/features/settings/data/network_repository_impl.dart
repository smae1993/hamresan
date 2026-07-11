import 'dart:io';
import '../domain/repositories/network_repository.dart';

class NetworkRepositoryImpl implements NetworkRepository {
  @override
  Future<NetworkInfo> getInfo() async {
    var ip = '';
    var ifaceName = '';

    try {
      final interfaces = await NetworkInterface.list();
      for (final iface in interfaces) {
        if (ifaceName.isEmpty) ifaceName = iface.name;
        for (final addr in iface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              _isPrivate(addr.address)) {
            if (ip.isEmpty) ip = _toFa(addr.address);
          }
        }
      }
    } catch (_) {}

    var ssid = await _detectSsid() ?? ifaceName;
    if (ip.isEmpty) ip = '۱۹۲٫۱۶۸٫۱٫۲۴';
    if (ssid.isEmpty) ssid = 'Home-WiFi-5G';

    return NetworkInfo(ssid: ssid, ip: ip, encrypted: true);
  }

  bool _isPrivate(String addr) =>
      addr.startsWith('192.') ||
      addr.startsWith('10.') ||
      addr.startsWith('172.') ||
      addr.startsWith('169.254.');

  Future<String?> _detectSsid() async {
    try {
      final result = await Process.run(
        'sh',
        ['-c', 'iwgetid -r 2>/dev/null || nmcli -t -f active,ssid dev wifi 2>/dev/null | grep "^yes:" | cut -d: -f2 || echo ""'],
      );
      final out = (result.stdout as String).trim();
      if (out.isNotEmpty) return out;
    } catch (_) {}
    return null;
  }

  String _toFa(String eng) => eng
      .split('.')
      .map((octet) => octet
          .replaceAll('0', '۰')
          .replaceAll('1', '۱')
          .replaceAll('2', '۲')
          .replaceAll('3', '۳')
          .replaceAll('4', '۴')
          .replaceAll('5', '۵')
          .replaceAll('6', '۶')
          .replaceAll('7', '۷')
          .replaceAll('8', '۸')
          .replaceAll('9', '۹'))
      .join('٫');
}
