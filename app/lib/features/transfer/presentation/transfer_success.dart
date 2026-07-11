/// Transfer success view — همرسان.
///
/// Recreates the "done" branch of `TransferView` from `screens_send.jsx`:
/// a success burst icon, a summary line, and a "تمام" button. For receives,
/// shows the save location.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/fa_digits.dart';
import '../../../core/utils/size_format.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/buttons.dart';
import '../domain/entities/transfer_session.dart';
import '../domain/enums.dart';

class TransferSuccessView extends ConsumerStatefulWidget {
  const TransferSuccessView({
    super.key,
    required this.session,
    required this.onFinish,
  });

  final TransferSession session;
  final VoidCallback onFinish;

  @override
  ConsumerState<TransferSuccessView> createState() => _TransferSuccessViewState();
}

class _TransferSuccessViewState extends ConsumerState<TransferSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burst;

  @override
  void initState() {
    super.initState();
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = widget.session;
    final totalMb = s.items.fold(0.0, (a, it) => a + parseMB(it.size));
    final isSent = s.direction.isSent;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: ScaleTransition(
                  scale: Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _burst,
                      curve: const _PopCurve(),
                    ),
                  ),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: c.greenSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppIcon(AppIconName.check, size: 56, stroke: 2.6, color: c.green),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                isSent ? 'ارسال شد!' : 'دریافت شد!',
                textAlign: TextAlign.center,
                style: AppTextStyles.obTitle.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: AppTextStyles.obDesc.copyWith(color: c.muted, height: 1.8),
                  children: [
                    TextSpan(text: '${toFa(s.items.length)} مورد (${fmtMB(totalMb)}) با موفقیت ${isSent ? "به" : "از"} '),
                    TextSpan(
                      text: s.peerName,
                      style: TextStyle(color: c.text, fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' ${isSent ? "فرستاده شد" : "ذخیره شد"}.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              if (!isSent) ...[
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: c.surface2,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(AppIconName.folder, size: 15, color: c.muted),
                        const SizedBox(width: 7),
                        Text('ذخیره در «دریافتی‌های همرسان»',
                            style: AppTextStyles.fileSub.copyWith(color: c.muted)),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              AppButton(
                variant: AppButtonVariant.primary,
                block: true,
                large: true,
                onPressed: widget.onFinish,
                child: const Text('تمام'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Matches `@keyframes pop`: 0 → 1.12 (60%) → 1 (100%).
class _PopCurve extends Curve {
  const _PopCurve();
  @override
  double transformInternal(double t) {
    if (t < 0.6) return (t / 0.6) * 1.12;
    return 1.12 - 0.12 * ((t - 0.6) / 0.4);
  }
}
