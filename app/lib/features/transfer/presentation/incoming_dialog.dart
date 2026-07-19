// Incoming request dialog — همرسان.
//
// Recreates `IncomingDialog` from `screens_receive.jsx`: a centered dialog
// with a gradient header (peer avatar + "wants to send"), the item list,
// a total row, and رد / دریافت actions.
import 'package:flutter/material.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/fa_digits.dart';
import '../../../core/utils/size_format.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/buttons.dart';
import '../domain/entities/incoming_request.dart';
import 'content_item_icon.dart';

/// Shows the incoming-request dialog. Returns true if accepted, false/null if declined.
Future<bool?> showIncomingDialog(
  BuildContext context, {
  required IncomingRequest request,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => IncomingDialogContent(request: request),
  );
}

class IncomingDialogContent extends StatelessWidget {
  const IncomingDialogContent({
    super.key,
    required this.request,
    this.onAccept,
    this.onDecline,
  });
  final IncomingRequest request;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Dialog(
      backgroundColor: c.bg,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header band
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
                    hue: request.hue,
                    type: request.type,
                    size: 64,
                    radius: 22,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    request.peer,
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
          // Item list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              children: [
                for (final it in request.items)
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                it.name,
                                style: AppTextStyles.fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                it.size,
                                style: AppTextStyles.fileSub.copyWith(
                                  color: c.muted,
                                ),
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
          // Total
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
                  '${toFa(request.items.length)} مورد · ${formatBytes(request.totalBytes)}',
                  style: AppTextStyles.fileName.copyWith(
                    color: c.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AppButton(
                    variant: AppButtonVariant.ghost,
                    onPressed: () {
                      if (onDecline != null) {
                        onDecline!();
                      } else {
                        Navigator.of(context).pop(false);
                      }
                    },
                    child: const Text('رد'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    variant: AppButtonVariant.primary,
                    icon: AppIconName.download,
                    onPressed: () {
                      if (onAccept != null) {
                        onAccept!();
                      } else {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: const Text('دریافت'),
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
