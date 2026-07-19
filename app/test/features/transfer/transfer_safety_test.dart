import 'package:flutter_test/flutter_test.dart';
import 'package:hamresan/features/transfer/data/transfer_safety.dart';

void main() {
  group('sanitizeFileName', () {
    test('removes path traversal and separators', () {
      expect(
        TransferSafety.sanitizeFileName('../../secret\\file.txt'),
        'secret_file.txt',
      );
    });

    test('never returns dot paths or an empty name', () {
      expect(TransferSafety.sanitizeFileName('..'), 'file');
      expect(TransferSafety.sanitizeFileName('///'), 'file');
    });

    test('bounds file-name length', () {
      final longName = List.filled(300, 'a').join();
      expect(TransferSafety.sanitizeFileName(longName).length, 180);
    });

    test('guards Windows reserved device names', () {
      expect(TransferSafety.sanitizeFileName('CON.txt'), '_CON.txt');
      expect(TransferSafety.sanitizeFileName('file. '), 'file');
    });
  });

  test('constant time equality compares complete digest values', () {
    expect(TransferSafety.constantTimeEquals([1, 2, 3], [1, 2, 3]), isTrue);
    expect(TransferSafety.constantTimeEquals([1, 2, 3], [1, 2, 4]), isFalse);
    expect(TransferSafety.constantTimeEquals([1], [1, 0]), isFalse);
  });
}
