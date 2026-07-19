/// Striped media placeholder — همرسان.
///
/// Recreates `StripePlaceholder` from `icons.jsx`: a 135deg repeating stripe
/// used for photo/video thumbnails in the picker and transfer lists.
import 'package:flutter/material.dart';
import '../theme/app_gradients.dart';

class StripePlaceholder extends StatelessWidget {
  const StripePlaceholder({
    super.key,
    this.hue = 281,
    this.label,
    this.mono = true,
  });

  final double hue;
  final String? label;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final pair = AppGradients.stripePair(hue);
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _StripePainter(pair[0], pair[1])),
        if (label != null)
          Center(
            child: Text(
              label!,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xEBFFFFFF),
                fontFamily: mono ? null : 'Vazirmatn',
                height: 1,
              ),
            ),
          ),
      ],
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter(this.a, this.b);
  final Color a;
  final Color b;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width + size.height; // cover diagonal
    const stripe = 18.0; // 0..9 and 9..18 in CSS
    final paintA = Paint()..color = a;
    final paintB = Paint()..color = b;
    // 135deg stripes → step along the diagonal. Draw rectangles rotated.
    canvas.save();
    canvas.translate(size.width, 0);
    canvas.rotate(45 * 3.14159265 / 180);
    for (var x = -w; x < w; x += stripe) {
      canvas.drawRect(
        Rect.fromLTWH(x, -size.height, stripe / 2, size.height * 3),
        paintA,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          x + stripe / 2,
          -size.height,
          stripe / 2,
          size.height * 3,
        ),
        paintB,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StripePainter old) => old.a != a || old.b != b;
}
