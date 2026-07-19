/// History screen — همرسان.
///
/// Recreates `History` from `screens_misc.jsx`: filter chips (همه / ارسالی /
/// دریافتی) and a list of transfer records. Empty state when filtered to none.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../core/widgets/chips.dart';
import '../domain/entities/transfer_record.dart';
import '../presentation/providers/history_provider.dart';
import '../../../features/transfer/domain/enums.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _filter = 'all'; // all | sent | recv

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(historyProvider);
    final rows = all.where((h) {
      if (_filter == 'all') return true;
      if (_filter == 'sent') return h.direction == TransferDirection.sent;
      return h.direction == TransferDirection.received;
    }).toList();

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: 'تاریخچه',
              subtitle: 'انتقال‌های اخیر تو',
              actions: const [
                // Search button (decorative in this phase)
                // IconButtonCircle(icon: AppIconName.search),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  0,
                ).copyWith(bottom: AppDimensions.navHeight + 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppChip(
                          label: 'همه',
                          active: _filter == 'all',
                          onTap: () => setState(() => _filter = 'all'),
                        ),
                        const SizedBox(width: 8),
                        AppChip(
                          label: 'ارسالی',
                          active: _filter == 'sent',
                          onTap: () => setState(() => _filter = 'sent'),
                        ),
                        const SizedBox(width: 8),
                        AppChip(
                          label: 'دریافتی',
                          active: _filter == 'recv',
                          onTap: () => setState(() => _filter = 'recv'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (rows.isEmpty)
                      const _EmptyState()
                    else
                      for (final h in rows) _HistoryRow(record: h),
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

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.record});
  final TransferRecord record;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isSent = record.direction == TransferDirection.sent;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: c.border),
        boxShadow: AppShadows.sm(c),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSent ? c.primarySoft : c.greenSoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: AppIcon(
                isSent ? AppIconName.send : AppIconName.download,
                size: 20,
                stroke: 2.2,
                color: isSent ? c.primary : c.green,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.peer, style: AppTextStyles.historyTitle),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    style: AppTextStyles.historySub.copyWith(color: c.muted),
                    children: [
                      TextSpan(
                        text:
                            '${isSent ? "ارسال" : "دریافت"} · ${record.summary}',
                      ),
                      if (record.status == TransferStatus.failed)
                        TextSpan(
                          text: ' · ناموفق',
                          style: TextStyle(
                            color: c.rose,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (record.status == TransferStatus.cancelled)
                        TextSpan(
                          text: ' · لغوشده',
                          style: TextStyle(
                            color: c.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.when,
                style: AppTextStyles.historyTime.copyWith(color: c.faint),
              ),
              const SizedBox(height: 3),
              Text(
                record.size,
                style: AppTextStyles.historyTime.copyWith(
                  color: c.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: c.border),
              ),
              child: Center(
                child: AppIcon(AppIconName.history, size: 32, color: c.faint),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'چیزی اینجا نیست',
              style: AppTextStyles.emptyTitle.copyWith(color: c.text),
            ),
            const SizedBox(height: 6),
            Text(
              'هنوز انتقالی در این دسته نداری.',
              style: AppTextStyles.emptyBody.copyWith(color: c.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
