import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import '../domain/entities/content_item.dart';
import '../domain/enums.dart';

class ContentScanner {
  Future<List<ContentItem>> scanByKind(ContentKind kind) async {
    try {
      final dirs = await _directoriesForKind(kind);
      final results = <ContentItem>[];
      final seen = <String>{};
      final rng = Random();

      for (final dir in dirs) {
        final d = Directory(dir);
        if (!await d.exists()) continue;

        await for (final entity in d.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is! File) continue;
          final path = entity.path;
          final segs = path.split('/');
          final name = segs.lastWhere((s) => s.isNotEmpty, orElse: () => path);
          if (seen.contains(name)) continue;
          if (!_matchesKind(kind, name)) continue;
          seen.add(name);

          final stat = await entity.stat();
          results.add(
            ContentItem(
              key: path,
              name: name,
              kind: kind,
              byteSize: stat.size,
              hue: rng.nextDouble() * 360,
            ),
          );

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

  Future<List<String>> _directoriesForKind(ContentKind kind) async {
    final home = _homeDir();
    final docs = await _tryDir(getApplicationDocumentsDirectory);
    final downloads = await _tryDir(getDownloadsDirectory);

    final paths = <String>[
      ..._homePaths(home, kind),
      if (docs != null) docs,
      if (downloads != null) downloads,
      ..._fallbackPaths(kind),
    ];
    return paths;
  }

  List<String> _homePaths(String home, ContentKind kind) {
    switch (kind) {
      case ContentKind.image:
        return [
          '$home/Pictures',
          '$home/Photos',
          '$home/DCIM/Camera',
          '$home/DCIM',
        ];
      case ContentKind.video:
        return [
          '$home/Videos',
          '$home/Movies',
          '$home/DCIM/Camera',
          '$home/DCIM',
        ];
      case ContentKind.doc:
        return ['$home/Documents', '$home/Download', '$home/Downloads'];
      case ContentKind.music:
        return ['$home/Music', '$home/Audio'];
      case ContentKind.archive:
        return ['$home/Download', '$home/Downloads'];
      case ContentKind.contact:
        return ['$home/Documents'];
      case ContentKind.app:
        return ['$home/Applications'];
    }
  }

  List<String> _fallbackPaths(ContentKind kind) {
    switch (kind) {
      case ContentKind.image:
        return [
          '/sdcard/DCIM/Camera',
          '/sdcard/Pictures',
          '/storage/emulated/0/DCIM/Camera',
        ];
      case ContentKind.video:
        return ['/sdcard/DCIM/Camera', '/sdcard/Movies'];
      case ContentKind.doc:
        return ['/sdcard/Documents', '/sdcard/Download'];
      case ContentKind.music:
        return ['/sdcard/Music'];
      case ContentKind.archive:
        return ['/sdcard/Download'];
      case ContentKind.contact:
        return ['/sdcard/Documents'];
      case ContentKind.app:
        return ['/sdcard/Apps'];
    }
  }

  Future<String?> _tryDir(Future<Directory?> Function() provider) async {
    try {
      final dir = await provider();
      if (dir != null && await dir.exists()) return dir.path;
    } catch (_) {}
    return null;
  }

  bool _matchesKind(ContentKind kind, String name) {
    final lower = name.toLowerCase();
    return switch (kind) {
      ContentKind.image => _anyExt(lower, [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'bmp',
        'heic',
        'heif',
      ]),
      ContentKind.video => _anyExt(lower, [
        'mp4',
        'mkv',
        'avi',
        'mov',
        'wmv',
        'flv',
        'webm',
      ]),
      ContentKind.doc => _anyExt(lower, [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'txt',
        'csv',
      ]),
      ContentKind.music => _anyExt(lower, [
        'mp3',
        'wav',
        'aac',
        'flac',
        'ogg',
        'wma',
      ]),
      ContentKind.archive => _anyExt(lower, [
        'zip',
        'rar',
        '7z',
        'tar',
        'gz',
        'bz2',
      ]),
      ContentKind.contact => _anyExt(lower, ['vcf', 'csv']),
      ContentKind.app => _anyExt(lower, [
        'apk',
        'app',
        'exe',
        'appimage',
        'app',
        'dmg',
      ]),
    };
  }

  bool _anyExt(String name, List<String> exts) =>
      exts.any((e) => name.endsWith('.$e'));

  String _homeDir() {
    try {
      return Platform.environment['HOME'] ??
          Platform.environment['USERPROFILE'] ??
          '/sdcard';
    } catch (_) {
      return '/sdcard';
    }
  }
}
