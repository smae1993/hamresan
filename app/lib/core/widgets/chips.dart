// Filter chips — همرسان.
//
// Recreates `.chip`/`.chip.active` from `styles.css`.
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: active ? c.primary : c.surface2,
          borderRadius: BorderRadius.circular(100),
          border: active ? null : Border.all(color: c.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.chip.copyWith(
            color: active ? c.primaryInk : c.muted,
          ),
        ),
      ),
    );
  }
}
