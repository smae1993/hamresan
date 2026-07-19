import '../domain/entities/content_item.dart';
import '../domain/enums.dart';
import '../domain/repositories/content_repository.dart';
import 'content_scanner.dart';
import 'native_content_picker.dart';

class ContentRepositoryImpl implements ContentRepository {
  final _scanner = ContentScanner();
  final _picker = NativeContentPicker();

  @override
  Future<List<ContentItem>> getByKind(ContentKind kind) async {
    return _scanner.scanByKind(kind);
  }

  @override
  Future<List<ContentItem>> getAll() async {
    return _scanner.scanAll();
  }

  @override
  Future<List<ContentItem>> pickByKind(ContentKind kind) => _picker.pick(kind);
}
