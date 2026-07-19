// File-size formatting helpers — همرسان.
import 'fa_digits.dart';

/// Parses a size string (e.g. "۴٫۲ MB", "۱۴۸ MB", "۸۴۰ KB", "۲ GB") into MB.
double parseMB(String s) {
  final en = faToEn(s);
  final n =
      double.tryParse(RegExp(r'[\d.]+').firstMatch(en)?.group(0) ?? '0') ?? 0;
  if (RegExp(r'GB', caseSensitive: false).hasMatch(s)) return n * 1024;
  if (RegExp(r'KB', caseSensitive: false).hasMatch(s)) return n / 1024;
  return n;
}

/// Formats an MB count back to a Persian-digit size string.
String fmtMB(double mb) {
  if (mb >= 1024) return '${toFa((mb / 1024).toStringAsFixed(1))} GB';
  if (mb < 1) return '${toFa((mb * 1024).round())} KB';
  return '${toFa(mb.toStringAsFixed(1))} MB';
}

/// Formats an exact byte count for display without using the formatted value
/// as application state.
String formatBytes(int bytes) {
  if (bytes < 0) return '۰ B';
  if (bytes < 1024) return '${toFa(bytes)} B';
  if (bytes < 1024 * 1024) {
    return '${toFa((bytes / 1024).toStringAsFixed(1))} KB';
  }
  if (bytes < 1024 * 1024 * 1024) {
    return '${toFa((bytes / (1024 * 1024)).toStringAsFixed(1))} MB';
  }
  return '${toFa((bytes / (1024 * 1024 * 1024)).toStringAsFixed(2))} GB';
}

double bytesToMb(int bytes) => bytes / (1024 * 1024);
