/// Brand logo — همرسان.
///
/// Recreates `Logo` from `icons.jsx`: a gradient squircle containing the
/// broadcast-arcs mark (a node + two arcs).
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_gradients.dart';
import '../theme/app_theme.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 38, this.radius});

  final double size;

  /// Override corner radius. Defaults to `size * 0.3` (matches prototype).
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final r = radius ?? size * 0.3;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppGradients.brand(colors),
        borderRadius: BorderRadius.circular(r),
        boxShadow: AppShadows.fab(colors),
      ),
      child: Center(
        child: SvgPicture.string(
          _markSvg,
          width: size * 0.62,
          height: size * 0.62,
        ),
      ),
    );
  }
}

const _markSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
  fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round">
  <circle cx="7" cy="17" r="2.3" fill="#fff" stroke="none" />
  <path d="M7 12.5a6.5 6.5 0 016.5 6.5" />
  <path d="M7 7a12 12 0 0112 12" opacity="0.85" />
</svg>''';
