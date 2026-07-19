// Segmented control — همرسان.
//
// Recreates `.seg` from `styles.css`: a pill container holding equal-width
// segments; the active one lifts onto the surface with a small shadow.
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';

class SegmentedItem {
  const SegmentedItem({required this.label, this.icon});
  final String label;
  final AppIconName? icon;
}

class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  final List<SegmentedItem> items;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface3,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _Seg(
                item: items[i],
                active: i == selected,
                colors: c,
                onTap: () => onChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.item,
    required this.active,
    required this.colors,
    required this.onTap,
  });

  final SegmentedItem item;
  final bool active;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active ? AppShadows.sm(colors) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.icon != null) ...[
              AppIcon(
                item.icon!,
                size: 16,
                stroke: 2.1,
                color: active ? colors.text : colors.muted,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              item.label,
              style: AppTextStyles.seg.copyWith(
                color: active ? colors.text : colors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
