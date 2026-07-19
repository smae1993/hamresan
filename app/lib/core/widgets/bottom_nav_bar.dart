/// Bottom navigation bar — همرسان.
///
/// Recreates `.nav` from `styles.css`: a blurred bar with three items
/// (اطراف / تاریخچه / تنظیمات), active item tinted with the brand color.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' show ImageFilter;
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';

class NavItemData {
  const NavItemData({
    required this.icon,
    required this.label,
    required this.index,
  });
  final AppIconName icon;
  final String label;
  final int index;
}

const kNavItems = <NavItemData>[
  NavItemData(icon: AppIconName.wifi, label: 'اطراف', index: 0),
  NavItemData(icon: AppIconName.history, label: 'تاریخچه', index: 1),
  NavItemData(icon: AppIconName.settings, label: 'تنظیمات', index: 2),
];

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.active,
    required this.onChanged,
  });

  final int active;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: AppDimensions.navHeight,
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.82),
            border: Border(top: BorderSide(color: c.border)),
          ),
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
          child: Row(
            children: [
              for (final item in kNavItems)
                Expanded(
                  child: _NavButton(
                    item: item,
                    active: item.index == active,
                    colors: c,
                    onTap: () => onChanged(item.index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.colors,
    required this.onTap,
  });

  final NavItemData item;
  final bool active;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? colors.primary : colors.faint;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Light haptic to match native feel.
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSlide(
              offset: active ? const Offset(0, -0.06) : Offset.zero,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: AppIcon(
                item.icon,
                size: 23,
                stroke: active ? 2.4 : 2,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: AppTextStyles.navLabel.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
