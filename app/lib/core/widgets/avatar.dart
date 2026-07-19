/// Avatar widget — همرسان.
///
/// Recreates `Avatar` from `icons.jsx`: a hue-based gradient circle/squircle
/// containing either a device-type icon or an initial letter, optionally with
/// a pulsing green "online" ring (`.avatar-ring`).
import 'package:flutter/material.dart';
import '../theme/app_gradients.dart';
import 'app_icon.dart';

/// Maps a device type string (from mock data) to its icon.
AppIconName deviceIcon(String? type) {
  switch (type) {
    case 'phone':
      return AppIconName.phone;
    case 'laptop':
      return AppIconName.laptop;
    case 'desktop':
      return AppIconName.desktop;
    case 'tablet':
      return AppIconName.tablet;
    case 'server':
      return AppIconName.server;
    default:
      return AppIconName.phone;
  }
}

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.hue = 281,
    this.size = 46,
    this.type,
    this.label,
    this.ring = false,
    this.radius,
  });

  final double hue;
  final double size;
  final String? type;
  final String? label;
  final bool ring;

  /// Override corner radius. Defaults to a circle (size/2).
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final avatar = DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.hue(hue),
        borderRadius: BorderRadius.circular(radius ?? size / 2),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: type != null
              ? AppIcon(
                  deviceIcon(type),
                  size: size * 0.46,
                  stroke: 2.1,
                  color: Colors.white,
                )
              : Text(
                  label ?? 'م',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );

    if (!ring) return avatar;

    // The ring sits behind, scaled up with a fade-out loop.
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _AvatarRing(size: size),
          avatar,
        ],
      ),
    );
  }
}

/// Pulsing green ring (`.avatar-ring::after` from `styles.css`).
class _AvatarRing extends StatefulWidget {
  const _AvatarRing({required this.size});
  final double size;

  @override
  State<_AvatarRing> createState() => _AvatarRingState();
}

class _AvatarRingState extends State<_AvatarRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The ring is drawn ~10px larger than the avatar (inset: -5px in CSS),
    // then scaled 0.92→1.12 while fading 0.7→0.
    const ringMargin = 5.0;
    final ringSize = widget.size + ringMargin * 2;

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        double scale;
        double opacity;
        if (t < 0.7) {
          final k = t / 0.7;
          scale = 0.92 + (1.12 - 0.92) * k;
          opacity = 0.7 * (1 - k);
        } else {
          scale = 1.12;
          opacity = 0;
        }
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: ringSize,
              height: ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1A9951), width: 2),
              ),
            ),
          ),
        );
      },
    );
  }
}
