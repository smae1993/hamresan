/// Section header — همرسان.
///
/// Recreates `.sec-head` from `styles.css`: a section title with an optional
/// count badge, a flexible spacer, and optional trailing widget (e.g. the
/// "در حال جستجو" scanning indicator).
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.count,
    this.trailing,
    this.padding,
  });

  final String title;
  final int? count;
  final Widget? trailing;

  /// Outer margin. Defaults to the CSS margin (24px 2px 13px).
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(2, 24, 2, 13),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.sectionHead),
          if (count != null) ...[
            const SizedBox(width: 9),
            _CountBadge(c: c, count: count!),
          ],
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.c, required this.count});
  final AppColors c;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: c.primarySoft,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: c.primarySoftBd),
      ),
      child: Text(
        '${count}', // digit conversion applied by callers via toFa()
        style: AppTextStyles.countBadge.copyWith(color: c.primary),
      ),
    );
  }
}

/// The animated "scanning" dots indicator (`.scanning`).
class ScanningIndicator extends StatefulWidget {
  const ScanningIndicator({super.key, this.text = 'در حال جستجو'});
  final String text;

  @override
  State<ScanningIndicator> createState() => _ScanningIndicatorState();
}

class _ScanningIndicatorState extends State<ScanningIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.text,
          style: AppTextStyles.scanning.copyWith(color: c.muted),
        ),
        const SizedBox(width: 5),
        for (var i = 0; i < 3; i++) _Dot(controller: _c, delay: i * 0.2, color: c.primary),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.controller, required this.delay, required this.color});
  final AnimationController controller;
  final double delay;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = (controller.value + delay) % 1.0;
          // scanbob: 0/1 opacity .25 at y0 → 0.5 opacity 1 at y-3 → 1 back to .25
          final double opacity;
          final double dy;
          if (t < 0.5) {
            opacity = 0.25 + (1 - 0.25) * (t / 0.5);
            dy = -3 * (t / 0.5);
          } else {
            opacity = 1 - (1 - 0.25) * ((t - 0.5) / 0.5);
            dy = -3 + 3 * ((t - 0.5) / 0.5);
          }
          return Transform.translate(
            offset: Offset(0, dy),
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          );
        },
      ),
    );
  }
}
