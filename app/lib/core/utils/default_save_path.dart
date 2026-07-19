import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> defaultSavePath() async {
  try {
    final dir = Platform.isAndroid || Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : await getDownloadsDirectory();
    if (dir != null) {
      final path = '${dir.path}${Platform.pathSeparator}همرسان';
      await Directory(path).create(recursive: true);
      return path;
    }
  } catch (_) {}
  final fallback =
      '${Directory.systemTemp.path}${Platform.pathSeparator}همرسان';
  await Directory(fallback).create(recursive: true);
  return fallback;
}
