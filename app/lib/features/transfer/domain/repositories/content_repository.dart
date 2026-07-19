import '../entities/content_item.dart';
import '../enums.dart';

abstract class ContentRepository {
  Future<List<ContentItem>> getByKind(ContentKind kind);
  Future<List<ContentItem>> getAll();
  Future<List<ContentItem>> pickByKind(ContentKind kind);
}
