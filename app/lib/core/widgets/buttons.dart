/// Buttons — همرسان.
///
/// Recreates the `.btn` family from `styles.css`:
/// `.btn-primary`, `.btn-ghost`, `.btn-grad`, `.btn-block`, `.btn-lg`, `.fab`.
import 'package:flutter/material.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';

/// Base button matching `.btn`: pill-shaped, bold, with press-scale.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.block = false,
    this.large = false,
    this.icon,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool block;
  final bool large;
  final AppIconName? icon;

  @override
  State<AppButton> createState() => _AppButtonState();
}

enum AppButtonVariant { primary, ghost, grad }

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final large = widget.large;
    final padH = large ? 24.0 : 22.0;
    final padV = large ? 17.0 : 15.0;
    final disabled = widget.onPressed == null;

    final (bg, fg, shadow) = switch (widget.variant) {
      AppButtonVariant.primary => (c.primary, c.primaryInk, AppShadows.fab(c)),
      AppButtonVariant.grad => (
          Colors.transparent,
          Colors.white,
          AppShadows.fab(c),
        ),
      AppButtonVariant.ghost => (c.surface2, c.text, <BoxShadow>[]),
    };

    final content = DefaultTextStyle.merge(
      style: (large ? AppTextStyles.btnLg : AppTextStyles.btn).copyWith(color: fg),
      child: widget.child,
    );

    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onPressed == null
          ? null
          : () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: disabled ? 0.5 : 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
            constraints: BoxConstraints(minWidth: widget.block ? double.infinity : 0),
            decoration: BoxDecoration(
              gradient: widget.variant == AppButtonVariant.grad
                  ? AppGradients.brand(c)
                  : null,
              color: widget.variant == AppButtonVariant.grad ? null : bg,
              borderRadius: BorderRadius.circular(100),
              border: widget.variant == AppButtonVariant.ghost
                  ? Border.all(color: c.border)
                  : null,
              boxShadow: disabled ? null : shadow,
            ),
            child: Row(
              mainAxisSize: widget.block ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  AppIcon(widget.icon!, size: large ? 20 : 19, stroke: 2.4, color: fg),
                  const SizedBox(width: 9),
                ],
                content,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating action button (`.fab`): centered, gradient, pill.
class AppFab extends StatelessWidget {
  const AppFab({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final AppIconName icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
        decoration: BoxDecoration(
          gradient: AppGradients.brand(c),
          borderRadius: BorderRadius.circular(100),
          boxShadow: AppShadows.fab(c),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(icon, size: 20, stroke: 2.4, color: Colors.white),
            const SizedBox(width: 9),
            Text(
              label,
              style: AppTextStyles.btn.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular icon button (`.iconbtn`).
class IconButtonCircle extends StatefulWidget {
  const IconButtonCircle({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 42,
    this.badge = false,
  });

  final AppIconName icon;
  final VoidCallback? onPressed;
  final double size;
  final bool badge;

  @override
  State<IconButtonCircle> createState() => _IconButtonCircleState();
}

class _IconButtonCircleState extends State<IconButtonCircle> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onPressed == null ? null : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onPressed == null ? null : () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: c.surface2,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.border),
                ),
                child: Center(
                  child: AppIcon(widget.icon, size: 20, color: c.text),
                ),
              ),
              if (widget.badge)
                Positioned(
                  top: widget.size * 0.16,
                  left: widget.size * 0.21,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: c.rose,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
