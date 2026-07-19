import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';

import '../domain/entities/content_item.dart';
import '../domain/enums.dart';

class NativeContentPicker {
  Future<List<ContentItem>> pick(ContentKind kind) async {
    final options = _options(kind);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: options.type,
      allowedExtensions: options.extensions,
      withData: false,
      withReadStream: false,
    );
    if (result == null) return const [];

    final random = Random();
    final items = <ContentItem>[];
    for (final picked in result.files) {
      final path = picked.path;
      if (path == null || path.isEmpty) continue;
      final file = File(path);
      if (!await file.exists()) continue;
      items.add(
        ContentItem(
          key: path,
          name: picked.name,
          kind: _kindFromName(picked.name, fallback: kind),
          byteSize: await file.length(),
          hue: random.nextDouble() * 360,
        ),
      );
    }
    return items;
  }

  _PickerOptions _options(ContentKind kind) => switch (kind) {
    ContentKind.image => const _PickerOptions(FileType.image),
    ContentKind.video => const _PickerOptions(FileType.video),
    ContentKind.music => const _PickerOptions(FileType.audio),
    ContentKind.app => const _PickerOptions(FileType.custom, [
      'apk',
      'aab',
      'ipa',
      'exe',
      'msi',
      'dmg',
      'appimage',
    ]),
    ContentKind.archive => const _PickerOptions(FileType.custom, [
      'zip',
      'rar',
      '7z',
      'tar',
      'gz',
      'bz2',
    ]),
    ContentKind.contact => const _PickerOptions(FileType.custom, [
      'vcf',
      'csv',
    ]),
    ContentKind.doc => const _PickerOptions(FileType.any),
  };

  ContentKind _kindFromName(String name, {required ContentKind fallback}) {
    final extension = name.contains('.')
        ? name.split('.').last.toLowerCase()
        : '';
    if ([
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'heic',
      'heif',
    ].contains(extension)) {
      return ContentKind.image;
    }
    if (['mp4', 'mkv', 'avi', 'mov', 'webm'].contains(extension)) {
      return ContentKind.video;
    }
    if (['mp3', 'wav', 'aac', 'flac', 'ogg'].contains(extension)) {
      return ContentKind.music;
    }
    if (['zip', 'rar', '7z', 'tar', 'gz', 'bz2'].contains(extension)) {
      return ContentKind.archive;
    }
    if (extension == 'vcf') return ContentKind.contact;
    if ([
      'apk',
      'aab',
      'ipa',
      'exe',
      'msi',
      'dmg',
      'appimage',
    ].contains(extension)) {
      return ContentKind.app;
    }
    return fallback;
  }
}

class _PickerOptions {
  const _PickerOptions(this.type, [this.extensions]);
  final FileType type;
  final List<String>? extensions;
}
