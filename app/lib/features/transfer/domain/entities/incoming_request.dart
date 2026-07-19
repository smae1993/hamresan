// Incoming transfer request entity — همرسان.
//
// Mirrors `INCOMING_REQ` from `data.jsx`: a peer that wants to send content.
import 'content_item.dart';

class IncomingRequest {
  const IncomingRequest({
    required this.transferId,
    required this.peerId,
    required this.peer,
    required this.hue,
    required this.type,
    required this.platform,
    required this.code,
    required this.items,
    required this.totalBytes,
  });

  final String transferId;
  final String peerId;
  final String peer;
  final double hue;
  final String type;
  final String platform;
  final String code;
  final List<ContentItem> items;

  final int totalBytes;
}
