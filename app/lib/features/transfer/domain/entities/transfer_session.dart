/// Transfer session entity — همرسان.
///
/// Describes an active transfer (send or receive): the peer, the items, and
/// progress state. Mirrors the props of the prototype's `TransferView`.
import '../enums.dart';
import 'content_item.dart';

class TransferSession {
  const TransferSession({
    required this.id,
    required this.direction,
    required this.peerId,
    required this.peerName,
    required this.peerHue,
    this.peerType,
    required this.items,
  });

  final String id;
  final TransferDirection direction;
  final String peerId;
  final String peerName;
  final double peerHue;

  /// Peer device-type string (e.g. "phone"), used for the avatar icon.
  final String? peerType;
  final List<ContentItem> items;

  int get totalBytes => items.fold(0, (sum, item) => sum + item.byteSize);

  // File progress is emitted by the transfer engine and weighted by bytes.
}
