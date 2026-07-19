enum TransferPhase {
  waitingForApproval,
  connecting,
  transferring,
  verifying,
  completed,
}

class TransferProgress {
  const TransferProgress({
    required this.phase,
    required this.transferredBytes,
    required this.totalBytes,
    this.currentFileIndex = 0,
    this.currentFileBytes = 0,
    this.currentFileTotalBytes = 0,
    this.bytesPerSecond = 0,
  });

  const TransferProgress.waiting({required int totalBytes})
    : this(
        phase: TransferPhase.waitingForApproval,
        transferredBytes: 0,
        totalBytes: totalBytes,
      );

  final TransferPhase phase;
  final int transferredBytes;
  final int totalBytes;
  final int currentFileIndex;
  final int currentFileBytes;
  final int currentFileTotalBytes;
  final double bytesPerSecond;

  double get ratio {
    if (phase == TransferPhase.completed) return 1;
    if (totalBytes <= 0) return 0;
    return (transferredBytes / totalBytes).clamp(0.0, 1.0);
  }

  Duration? get eta {
    if (bytesPerSecond <= 0 || transferredBytes >= totalBytes) return null;
    return Duration(
      seconds: ((totalBytes - transferredBytes) / bytesPerSecond).ceil(),
    );
  }

  double fileRatio(int index) {
    if (index < currentFileIndex) return 1;
    if (index > currentFileIndex || currentFileTotalBytes <= 0) return 0;
    return (currentFileBytes / currentFileTotalBytes).clamp(0.0, 1.0);
  }
}
