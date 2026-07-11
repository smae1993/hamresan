import 'dart:io';
import 'dart:math';
import '../domain/entities/content_item.dart';
import '../domain/enums.dart';

class ContentScanner {
  Future<List<ContentItem>> scanByKind(ContentKind kind) async {
    try {
      final dirs = _directoriesForKind(kind);
      final results = <ContentItem>[];
      final seen = <String>{};
      final rng = Random();

      for (final dir in dirs) {
        final d = Directory(dir);
        if (!await d.exists()) continue;

        await for (final entity in d.list(recursive: true, followLinks: false)) {
          if (entity is! File) continue;
          final path = entity.path;
          final name = entity.uri.pathSegments.last;
          if (seen.contains(name)) continue;
          if (!_matchesKind(kind, name)) continue;
          seen.add(name);

          final stat = await entity.stat();
          results.add(ContentItem(
            key: path,
            name: name,
            kind: kind,
            size: _fmtBytes(stat.size),
            hue: rng.nextDouble() * 360,
          ));

          if (results.length >= 50) break;
        }
        if (results.length >= 50) break;
      }

      return results;
    } catch (_) {
      return [];
    }
  }

  Future<List<ContentItem>> scanAll() async {
    final all = <ContentItem>[];
    for (final kind in ContentKind.values) {
      all.addAll(await scanByKind(kind));
    }
    return all;
  }

  List<String> _directoriesForKind(ContentKind kind) {
    final home = _homeDir();
    return switch (kind) {
      ContentKind.image => [
        '$home/DCIM/Camera',
        '$home/DCIM',
        '$home/Pictures',
        '$home/Photos',
        '/sdcard/DCIM/Camera',
        '/sdcard/Pictures',
        '/storage/emulated/0/DCIM/Camera',
      ],
      ContentKind.video => [
        '$home/DCIM/Camera',
        '$home/DCIM',
        '$home/Movies',
        '$home/Videos',
        '/sdcard/DCIM/Camera',
        '/sdcard/Movies',
      ],
      ContentKind.doc => [
        '$home/Documents',
        '$home/Download',
        '$home/Downloads',
        '/sdcard/Documents',
        '/sdcard/Download',
      ],
      ContentKind.music => [
        '$home/Music',
        '$home/Audio',
        '/sdcard/Music',
      ],
      ContentKind.archive => [
        '$home/Download',
        '$home/Downloads',
        '/sdcard/Download',
      ],
      ContentKind.contact => [
        '$home/Documents',
        '/sdcard/Documents',
      ],
      ContentKind.app => [
        '$home/Applications',
        '/sdcard/Apps',
      ],
    };
  }

  bool _matchesKind(ContentKind kind, String name) {
    final lower = name.toLowerCase();
    return switch (kind) {
      ContentKind.image => _anyExt(lower, ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic', 'heif']),
      ContentKind.video => _anyExt(lower, ['mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm']),
      ContentKind.doc => _anyExt(lower, ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'csv']),
      ContentKind.music => _anyExt(lower, ['mp3', 'wav', 'aac', 'flac', 'ogg', 'wma']),
      ContentKind.archive => _anyExt(lower, ['zip', 'rar', '7z', 'tar', 'gz', 'bz2']),
      ContentKind.contact => _anyExt(lower, ['vcf', 'csv']),
      ContentKind.app => _anyExt(lower, ['apk', 'app', 'exe', 'AppImage', 'App', 'dmg']),
    };
  }

  bool _anyExt(String name, List<String> exts) => exts.any((e) => name.endsWith('.$e'));

  String _homeDir() {
    try {
      return Platform.environment['HOME'] ??
             Platform.environment['USERPROFILE'] ??
             '/sdcard';
    } catch (_) {
      return '/sdcard';
    }
  }

  String _fmtBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
