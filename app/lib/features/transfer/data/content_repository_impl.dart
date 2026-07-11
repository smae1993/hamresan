import '../domain/entities/content_item.dart';
import '../domain/enums.dart';
import '../domain/repositories/content_repository.dart';
import 'content_scanner.dart';

class ContentRepositoryImpl implements ContentRepository {
  final _scanner = ContentScanner();

  @override
  Future<List<ContentItem>> getByKind(ContentKind kind) async {
    return _scanner.scanByKind(kind);
  }

  @override
  Future<List<ContentItem>> getAll() async {
    return _scanner.scanAll();
  }
}
