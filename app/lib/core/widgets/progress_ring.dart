// Progress ring — همرسان.
//
// Recreates `Ring` from `ui.jsx`: an SVG circular progress with a brand
// gradient stroke and a rounded cap.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_theme.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = AppDimensions.ringSize,
    this.stroke = AppDimensions.ringStroke,
  });

  /// 0.0 – 1.0
  final double progress;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final r = (size - stroke) / 2;
    final circ = 2 * math.pi * r;
    final off = circ * (1 - progress.clamp(0, 1));

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          background: c.surface3,
          start: c.gradStart,
          end: c.gradEnd,
          stroke: stroke,
          radius: r,
          circumference: circ,
          offset: off,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.background,
    required this.start,
    required this.end,
    required this.stroke,
    required this.radius,
    required this.circumference,
    required this.offset,
  });

  final Color background;
  final Color start;
  final Color end;
  final double stroke;
  final double radius;
  final double circumference;
  final double offset;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = background
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    // Progress arc (gradient, rounded cap). Rotated so it starts at top.
    final sweep = circumference - offset;
    if (sweep <= 0) return;

    final shader = SweepGradient(
      center: Alignment.center,
      colors: [start, end],
      // SweepGradient starts at 3 o'clock; we rotate the canvas -90deg below.
      transform: GradientRotation(-math.pi / 2),
    ).createShader(rect);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.offset != offset ||
      old.background != background ||
      old.start != start ||
      old.end != end;
}
