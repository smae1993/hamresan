import 'dart:math' show max;
/// Transfer screen — همرسان.
///
/// Recreates `TransferView` from `screens_send.jsx` (used for both send &
/// receive): a full-screen page with a top bar, a progress ring, peer info,
/// speed/ETA stats, and a per-file progress list. When the transfer is done
/// it shows [TransferSuccessView].

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/fa_digits.dart';
import '../../../core/utils/size_format.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/progress_ring.dart';
import '../domain/entities/content_item.dart';
import '../domain/entities/transfer_session.dart';
import '../domain/enums.dart';
import 'transfer_success.dart';

class TransferScreen extends ConsumerWidget {
  const TransferScreen({
    super.key,
    required this.session,
    required this.progress,
    required this.done,
    required this.onCancel,
    required this.onFinish,
  });

  final TransferSession session;
  final double progress; // 0..1
  final bool done;
  final VoidCallback onCancel;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (done) {
      return TransferSuccessView(
        session: session,
        onFinish: onFinish,
      );
    }
    return _TransferInProgress(
      session: session,
      progress: progress,
      onCancel: onCancel,
    );
  }
}

class _TransferInProgress extends StatelessWidget {
  const _TransferInProgress({
    required this.session,
    required this.progress,
    required this.onCancel,
  });

  final TransferSession session;
  final double progress;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pct = (progress * 100).round();
    final items = session.items;
    final totalMb = items.fold(0.0, (a, it) => a + parseMB(it.size));
    final sentMb = totalMb * progress;
    // Speed: simplified mock, mirrors the prototype formula.
    final speed = totalMb / 100 * 12;
    final etaSec = max(0, ((100 - pct) / 14).ceil());

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: close + status
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: IconButtonCircle(
                      icon: AppIconName.close,
                      onPressed: onCancel,
                    ),
                  ),
                  const Spacer(),
                  Text('${session.direction.verb} در حال انجام',
                      style: AppTextStyles.scanning.copyWith(fontSize: 12.5, color: c.muted)),
                  const Spacer(),
                  const SizedBox(width: 42),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
                child: Column(
                  children: [
                    // Ring
                    SizedBox(
                      width: 188,
                      height: 188,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ProgressRing(progress: progress),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: toFa(pct),
                                      style: AppTextStyles.pctNumber.copyWith(color: c.text),
                                    ),
                                    TextSpan(
                                      text: '٪',
                                      style: AppTextStyles.pctNumber.copyWith(color: c.text, fontSize: 22),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('${fmtMB(sentMb)} از ${fmtMB(totalMb)}',
                                  style: AppTextStyles.pctLabel.copyWith(color: c.muted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Peer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Avatar(hue: session.peerHue, type: session.peerType, size: 34),
                        const SizedBox(width: 10),
                        Text(
                          '${session.direction.isSent ? "به" : "از"} ${session.peerName}',
                          style: AppTextStyles.fileName.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Stat(
                          value: toFa(speed.toStringAsFixed(1)),
                          label: 'MB/s',
                          valueColor: c.primary,
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          margin: const EdgeInsets.symmetric(horizontal: 22),
                          color: c.border,
                        ),
                        _Stat(
                          value: '${toFa(etaSec)} ث',
                          label: 'باقی‌مانده',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Per-file list
                    for (var i = 0; i < items.length; i++)
                      _FileProgress(
                        item: items[i],
                        progress: session.fileProgress(progress * 100)[i],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.valueColor});
  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.statNumber.copyWith(color: valueColor ?? c.text)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.statLabel.copyWith(color: c.muted)),
      ],
    );
  }
}

class _FileProgress extends StatelessWidget {
  const _FileProgress({required this.item, required this.progress});

  final ContentItem item;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fp = progress.round();
    final done = fp >= 100;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppGradients.hue(item.hue),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: AppIcon(item.icon, size: 20, stroke: 2, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTextStyles.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      done ? '✓' : '${toFa(fp)}٪',
                      style: AppTextStyles.fileSub.copyWith(
                        color: done ? c.green : c.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 6,
                    backgroundColor: c.surface3,
                    valueColor: AlwaysStoppedAnimation(c.gradStart),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
