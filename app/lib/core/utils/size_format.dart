/// Size string parsing/formatting — همرسان.
///
/// Mirrors `parseMB`/`fmtMB` from `screens_send.jsx`. Sizes in the mock data
/// are Persian-digit strings like "۴٫۲ MB"; these helpers round-trip them
/// to numeric MB for arithmetic.
import 'fa_digits.dart';

/// Parses a size string (e.g. "۴٫۲ MB", "۱۴۸ MB", "۸۴۰ KB", "۲ GB") into MB.
double parseMB(String s) {
  final en = faToEn(s);
  final n = double.tryParse(RegExp(r'[\d.]+').firstMatch(en)?.group(0) ?? '0') ?? 0;
  if (RegExp(r'GB', caseSensitive: false).hasMatch(s)) return n * 1024;
  if (RegExp(r'KB', caseSensitive: false).hasMatch(s)) return n / 1024;
  return n;
}

/// Formats an MB count back to a Persian-digit size string.
String fmtMB(double mb) {
  if (mb >= 1024) return toFa((mb / 1024).toStringAsFixed(1)) + ' GB';
  if (mb < 1) return toFa((mb * 1024).round()) + ' KB';
  return toFa(mb.toStringAsFixed(1)) + ' MB';
}
