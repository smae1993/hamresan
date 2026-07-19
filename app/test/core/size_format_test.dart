import 'package:flutter_test/flutter_test.dart';
import 'package:hamresan/core/utils/size_format.dart';

void main() {
  test('formats exact byte ranges with Persian digits', () {
    expect(formatBytes(0), '۰ B');
    expect(formatBytes(1024), '۱.۰ KB');
    expect(formatBytes(1024 * 1024), '۱.۰ MB');
    expect(formatBytes(1024 * 1024 * 1024), '۱.۰۰ GB');
  });

  test('converts bytes to megabytes', () {
    expect(bytesToMb(5 * 1024 * 1024), 5);
  });
}
