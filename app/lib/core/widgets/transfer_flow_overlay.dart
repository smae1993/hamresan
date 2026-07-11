import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/transfer/domain/entities/content_item.dart';
import '../../features/transfer/domain/entities/incoming_request.dart';
import '../../features/transfer/presentation/content_picker_sheet.dart';

import '../../features/transfer/presentation/providers/transfer_provider.dart';
import '../../features/transfer/presentation/recipient_sheet.dart';
import '../../features/transfer/presentation/transfer_screen.dart';
import '../providers/repository_providers.dart';
import '../utils/fa_digits.dart';
import '../utils/size_format.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';
import 'avatar.dart';
import 'buttons.dart';

class TransferFlowOverlay extends ConsumerStatefulWidget {
  const TransferFlowOverlay({super.key});

  @override
  ConsumerState<TransferFlowOverlay> createState() =>
      _TransferFlowOverlayState();
}

class _TransferFlowOverlayState extends ConsumerState<TransferFlowOverlay> {
  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(transferFlowProvider);

    ref.listen<AsyncValue<IncomingRequest?>>(incomingStreamProvider, (_, next) {
      next.whenData((req) {
        if (req != null && flow is TransferIdle) {
          ref.read(transferFlowProvider.notifier).showIncoming(req);
        }
      });
    });

    return switch (flow) {
      TransferTransferring(
        :final session,
        :final progress,
        :final done,
      ) =>
        TransferScreen(
          session: session,
          progress: progress,
          done: done,
          onCancel: () => ref.read(transferFlowProvider.notifier).cancel(),
          onFinish: () => ref.read(transferFlowProvider.notifier).finish(),
        ),
      TransferPicker(:final device) => _SheetOverlay(
          title: device != null ? 'ارسال به ${device.name}' : 'انتخاب محتوا',
          subtitle: device != null
              ? '${device.platform} · #${device.code}'
              : 'موارد دلخواهت را انتخاب کن',
          leading: device != null
              ? Avatar(hue: device.hue, type: device.type, size: 42)
              : null,
          body: PickerSheetBody(
            device: device,
            onConfirm: (result) =>
                ref.read(transferFlowProvider.notifier).confirmPicker(
                      result.items,
                      result.device,
                    ),
          ),
          onClose: () => ref.read(transferFlowProvider.notifier).cancel(),
        ),
      TransferRecipient(:final items) => _SheetOverlay(
          title: 'انتخاب گیرنده',
          subtitle:
              '${toFa(items.length)} مورد · ${fmtMB(_totalMb(items))} آماده‌ی ارسال',
          body: RecipientSheetBody(
            items: items,
            onPick: (device) =>
                ref.read(transferFlowProvider.notifier).pickRecipient(
                      device,
                      items,
                    ),
          ),
          onClose: () => ref.read(transferFlowProvider.notifier).cancel(),
        ),
      TransferIncoming(:final request) => _DialogOverlay(
          request: request,
          onAccept: () =>
              ref.read(transferFlowProvider.notifier).acceptIncoming(request),
          onDecline: () =>
              ref.read(transferFlowProvider.notifier).declineIncoming(),
        ),
      TransferIdle() => const SizedBox.shrink(),
    };
  }

  double _totalMb(List<ContentItem> items) =>
      items.fold(0.0, (a, it) => a + parseMB(it.size));
}

// ────────────────────────────────────────────────────────────────────
// Shared bottom-sheet overlay  (slide-up, scrim, grip, header, footer)
// ────────────────────────────────────────────────────────────────────

class _SheetOverlay extends StatefulWidget {
  const _SheetOverlay({
    required this.title,
    this.subtitle,
    this.leading,
    required this.body,
    required this.onClose,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget body;

  final VoidCallback onClose;

  @override
  State<_SheetOverlay> createState() => _SheetOverlayState();
}

class _SheetOverlayState extends State<_SheetOverlay> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  void _close() {
    setState(() => _visible = false);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          child: GestureDetector(
            onTap: _close,
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
        ),
        AnimatedPositioned(
          left: 0,
          right: 0,
          bottom: _visible ? 0 : -screenHeight,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          child: _sheetCard(c),
        ),
      ],
    );
  }

  Widget _sheetCard(AppColors c) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.sheetTopRadius),
        ),
        boxShadow: AppShadows.lg(c),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 11, 0, 4),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: c.borderStrong,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: AppTextStyles.sheetTitle),
                      if (widget.subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            widget.subtitle!,
                            style: AppTextStyles.sheetSub
                                .copyWith(color: c.muted),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButtonCircle(
                    icon: AppIconName.close,
                    size: 36,
                    onPressed: _close,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: widget.body,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────
// Centered dialog overlay  (fade-in, incoming request)
// ────────────────────────────────────────────────────────────────────

class _DialogOverlay extends StatefulWidget {
  const _DialogOverlay({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  final IncomingRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  State<_DialogOverlay> createState() => _DialogOverlayState();
}

class _DialogOverlayState extends State<_DialogOverlay> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  void _close([VoidCallback? after]) {
    setState(() => _visible = false);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) after?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final r = widget.request;
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: () => _close(widget.onDecline),
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Center(
            child: AnimatedScale(
              scale: _visible ? 1.0 : 0.8,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: Dialog(
                backgroundColor: c.bg,
                insetPadding: const EdgeInsets.all(24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                      decoration: BoxDecoration(
                        gradient: AppGradients.brand(c),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Avatar(
                              hue: r.hue,
                              type: r.type,
                              size: 64,
                              radius: 22,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              r.peer,
                              style: AppTextStyles.idName.copyWith(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'می‌خواهد برایت محتوا بفرستد',
                              style: AppTextStyles.idMeta.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                        children: [
                          for (final it in r.items)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.hue(it.hue),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Center(
                                      child: AppIcon(
                                        it.icon,
                                        size: 19,
                                        stroke: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          it.name,
                                          style: AppTextStyles.fileName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          it.size,
                                          style: AppTextStyles.fileSub
                                              .copyWith(color: c.muted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: c.border)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'مجموع',
                            style: AppTextStyles.setLabel.copyWith(
                              color: c.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${toFa(r.items.length)} مورد · ${r.total}',
                            style: AppTextStyles.fileName.copyWith(
                              color: c.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: AppButton(
                              variant: AppButtonVariant.ghost,
                              onPressed: () => _close(widget.onDecline),
                              child: const Text('رد'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: AppButton(
                              variant: AppButtonVariant.primary,
                              icon: AppIconName.download,
                              onPressed: () => _close(widget.onAccept),
                              child: const Text('دریافت'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
