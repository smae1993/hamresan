/// Incoming transfer request entity — همرسان.
///
/// Mirrors `INCOMING_REQ` from `data.jsx`: a peer that wants to send content.
import 'content_item.dart';

class IncomingRequest {
  const IncomingRequest({
    required this.peer,
    required this.hue,
    required this.type,
    required this.platform,
    required this.code,
    required this.items,
    required this.total,
  });

  final String peer;
  final double hue;
  final String type;
  final String platform;
  final String code;
  final List<ContentItem> items;

  /// Total size display string, e.g. "۹۵٫۳ MB".
  final String total;
}
