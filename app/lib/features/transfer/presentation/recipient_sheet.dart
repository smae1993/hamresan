/// Recipient picker sheet — همرسان.
///
/// Recreates `RecipientSheet` from `screens_send.jsx`: shown after content is
/// picked with no preselected device. Lists nearby devices as rows; tapping
/// one begins the transfer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/fa_digits.dart';
import '../../../core/utils/size_format.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/live_dot.dart';
import '../../discovery/domain/entities/device.dart';
import '../../discovery/presentation/providers/discovery_provider.dart';
import '../domain/entities/content_item.dart';

/// Shows the recipient sheet and awaits the chosen [Device].
Future<Device?> showRecipientSheet(
  BuildContext context, {
  required List<ContentItem> items,
}) {
  final totalMb = items.fold(0.0, (a, it) => a + parseMB(it.size));
  return showAppSheet<Device>(
    context: context,
    title: 'انتخاب گیرنده',
    subtitle: '${toFa(items.length)} مورد · ${fmtMB(totalMb)} آماده‌ی ارسال',
    body: RecipientSheetBody(items: items),
  );
}

class RecipientSheetBody extends ConsumerWidget {
  const RecipientSheetBody({super.key, required this.items, this.onPick, this.onCancel});
  final List<ContentItem> items;
  final ValueChanged<Device>? onPick;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final devicesAsync = ref.watch(discoveryProvider);
    final devices = devicesAsync.maybeWhen(
      data: (d) => d,
      orElse: () => <Device>[],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final d in devices)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (onPick != null) {
                  onPick!(d);
                } else {
                  Navigator.of(context).pop(d);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Avatar(hue: d.hue, type: d.type, size: 46, ring: true),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.name, style: AppTextStyles.fileName),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              LiveDot(color: c.green, size: 6),
                              const SizedBox(width: 5),
                              Text('آنلاین · ${d.platform}',
                                  style: AppTextStyles.fileSub.copyWith(color: c.muted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AppIcon(AppIconName.back, size: 18, color: c.faint),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
