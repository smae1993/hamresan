import '../../../core/widgets/app_icon.dart';
import '../domain/entities/content_item.dart';
import '../domain/enums.dart';

extension ContentItemIcon on ContentItem {
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
