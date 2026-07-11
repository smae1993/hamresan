/// Transfer session entity — همرسان.
///
/// Describes an active transfer (send or receive): the peer, the items, and
/// progress state. Mirrors the props of the prototype's `TransferView`.
import '../enums.dart';
import 'content_item.dart';

class TransferSession {
  const TransferSession({
    required this.direction,
    required this.peerName,
    required this.peerHue,
    this.peerType,
    required this.items,
  });

  final TransferDirection direction;
  final String peerName;
  final double peerHue;

  /// Peer device-type string (e.g. "phone"), used for the avatar icon.
  final String? peerType;
  final List<ContentItem> items;

  /// Per-item file progress (0..100), indexed parallel to [items].
  List<double> fileProgress(double overallPct) {
    final n = items.length;
    return List.generate(n, (i) {
      final start = (i / n) * 100;
      final fp = (overallPct - start) / (100 / n) * 100;
      return fp.clamp(0, 100);
    });
  }
}
