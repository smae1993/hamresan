/// Live status dot — همرسان.
///
/// Recreates `.live-dot` from `styles.css`: a small green dot with a pulsing
/// glow (keyframe `livepulse`).
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LiveDot extends StatefulWidget {
  const LiveDot({super.key, this.color, this.size = 8});

  final Color? color;
  final double size;

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.color ?? AppColors.liveDot;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        // livepulse: box-shadow grows to 8px and fades, 0→70%→100%
        double glowOpacity;
        double glowRadius;
        if (t < 0.7) {
          final k = t / 0.7;
          glowOpacity = 0.6 * (1 - k);
          glowRadius = 0 + 8 * k;
        } else {
          glowOpacity = 0;
          glowRadius = 8;
        }
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: base,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: base.withValues(alpha: glowOpacity),
                blurRadius: glowRadius,
                spreadRadius: glowRadius / 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
