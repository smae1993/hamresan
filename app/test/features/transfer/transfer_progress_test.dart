import 'package:flutter_test/flutter_test.dart';
import 'package:hamresan/features/transfer/domain/entities/transfer_progress.dart';

void main() {
  test('overall ratio is weighted by bytes', () {
    const progress = TransferProgress(
      phase: TransferPhase.transferring,
      transferredBytes: 25,
      totalBytes: 100,
    );
    expect(progress.ratio, 0.25);
  });

  test('per-file ratio tracks completed, current and future files', () {
    const progress = TransferProgress(
      phase: TransferPhase.transferring,
      transferredBytes: 150,
      totalBytes: 300,
      currentFileIndex: 1,
      currentFileBytes: 50,
      currentFileTotalBytes: 100,
    );
    expect(progress.fileRatio(0), 1);
    expect(progress.fileRatio(1), 0.5);
    expect(progress.fileRatio(2), 0);
  });

  test('completed state reports full ratio for zero-byte transfers', () {
    const progress = TransferProgress(
      phase: TransferPhase.completed,
      transferredBytes: 0,
      totalBytes: 0,
    );
    expect(progress.ratio, 1);
  });
}
