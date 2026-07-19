/// Content item entity — همرسان.
///
/// A single selectable piece of content (photo, video, file, app) in the
/// picker, and a single item being transferred.
import '../../../../core/utils/size_format.dart';
import '../enums.dart';

class ContentItem {
  const ContentItem({
    required this.key,
    required this.name,
    required this.kind,
    required this.byteSize,
    required this.hue,
    this.label,
    this.version,
    this.duration,
  });

  /// Stable id. For local files this is the absolute source path.
  final String key;

  /// Display name including extension (e.g. "غروب ساحل.jpg").
  final String name;
  final ContentKind kind;

  /// Exact size used by the transfer protocol.
  final int byteSize;

  /// Localized value used only by the presentation layer.
  String get size => formatBytes(byteSize);
  final double hue;

  /// Optional short label used on thumbnails (e.g. "غروب ساحل").
  final String? label;

  /// App version (only for apps).
  final String? version;

  /// Video duration (only for videos).
  final String? duration;
}
