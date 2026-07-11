import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> defaultSavePath() async {
  if (Platform.isAndroid || Platform.isIOS) {
    return 'دریافتی‌های همرسان';
  }
  try {
    final dir = await getDownloadsDirectory();
    if (dir != null) {
      final path = '${dir.path}/همرسان';
      await Directory(path).create(recursive: true);
      return path;
    }
  } catch (_) {}
  return 'دریافتی‌های همرسان';
}
