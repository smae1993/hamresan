/// Content item entity — همرسان.
///
/// A single selectable piece of content (photo, video, file, app) in the
/// picker, and a single item being transferred.
import '../../../../core/widgets/app_icon.dart';
import '../enums.dart';

class ContentItem {
  const ContentItem({
    required this.key,
    required this.name,
    required this.kind,
    required this.size,
    required this.hue,
    this.label,
    this.version,
    this.duration,
  });

  /// Stable id (from the source mock entry, e.g. "p1").
  final String key;

  /// Display name including extension (e.g. "غروب ساحل.jpg").
  final String name;
  final ContentKind kind;

  /// Human-readable size string (Persian digits), e.g. "۴٫۲ MB".
  final String size;
  final double hue;

  /// Optional short label used on thumbnails (e.g. "غروب ساحل").
  final String? label;

  /// App version (only for apps).
  final String? version;

  /// Video duration (only for videos).
  final String? duration;

  AppIconName get icon => switch (kind) {
        ContentKind.image => AppIconName.image,
        ContentKind.video => AppIconName.video,
        ContentKind.doc => AppIconName.doc,
        ContentKind.music => AppIconName.music,
        ContentKind.archive => AppIconName.archive,
        ContentKind.contact => AppIconName.contact,
        ContentKind.app => AppIconName.apps,
      };
}
