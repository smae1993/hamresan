import 'dart:io';
import '../domain/repositories/network_repository.dart';

class NetworkRepositoryImpl implements NetworkRepository {
  @override
  Future<NetworkInfo> getInfo() async {
    var ip = '۱۹۲٫۱۶۸٫۱٫۲۴';
    try {
      final interfaces = await NetworkInterface.list();
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              addr.address.startsWith('192.') ||
              addr.address.startsWith('10.') ||
              addr.address.startsWith('172.')) {
            ip = _toFa(addr.address);
          }
        }
      }
    } catch (_) {}

    return NetworkInfo(
      ssid: 'Home-WiFi-5G',
      ip: ip,
      encrypted: true,
    );
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
