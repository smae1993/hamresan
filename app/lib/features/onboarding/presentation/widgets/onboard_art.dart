/// Onboarding art — همرسان.
///
/// Recreates `OnboardArt` from `screens_home.jsx`: three animated illustrations
/// shown behind each onboarding step (radar sweep / content type cards / shield).
import 'package:flutter/material.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/avatar.dart';
import '../../../../core/widgets/brand_logo.dart';

enum OnboardArtKind { radar, types, shield }

class OnboardArt extends StatelessWidget {
  const OnboardArt({super.key, required this.kind});

  final OnboardArtKind kind;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case OnboardArtKind.radar:
        return const _RadarArt();
      case OnboardArtKind.types:
        return const _TypesArt();
      case OnboardArtKind.shield:
        return const _ShieldArt();
    }
  }
}

// --- Radar: pulsing rings + peer avatars around the logo ---
class _RadarArt extends StatefulWidget {
  const _RadarArt();

  @override
  State<_RadarArt> createState() => _RadarArtState();
}

class _RadarArtState extends State<_RadarArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const size = 260.0;
    final peers = <_Peer>[
      _Peer(hue: 200, dx: -96, dy: -54, type: 'phone'),
      _Peer(hue: 152, dx: 92, dy: -70, type: 'laptop'),
      _Peer(hue: 24, dx: 104, dy: 56, type: 'tablet'),
      _Peer(hue: 330, dx: -86, dy: 70, type: 'phone'),
    ];
    final ringSizes = [120.0, 200.0, 270.0];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing rings (staggered by phase)
          for (var i = 0; i < ringSizes.length; i++)
            AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final t = (_c.value + i * 0.2) % 1.0;
                final scale = 0.6 + 0.7 * t;
                final opacity = (1 - t) * 0.5;
                return Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: ringSizes[i],
                      height: ringSizes[i],
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: c.primarySoftBd, width: 1.5),
                      ),
                    ),
                  ),
                );
              },
            ),
          // Peer avatars
          for (final p in peers)
            Transform.translate(
              offset: Offset(p.dx, p.dy),
              child: Avatar(hue: p.hue, type: p.type, size: 50),
            ),
          // Center logo
          const BrandLogo(size: 86, radius: 28),
        ],
      ),
    );
  }
}

class _Peer {
  const _Peer({
    required this.hue,
    required this.dx,
    required this.dy,
    required this.type,
  });
  final double hue;
  final double dx;
  final double dy;
  final String type;
}

// --- Types: four gradient cards for عکس/فیلم/فایل/برنامه ---
class _TypesArt extends StatelessWidget {
  const _TypesArt();

  @override
  Widget build(BuildContext context) {
    const cards = <_TypeCard>[
      _TypeCard(icon: AppIconName.image, hue: 24, label: 'عکس'),
      _TypeCard(icon: AppIconName.video, hue: 200, label: 'فیلم'),
      _TypeCard(icon: AppIconName.file, hue: 152, label: 'فایل'),
      _TypeCard(icon: AppIconName.apps, hue: 281, label: 'برنامه'),
    ];
    return SizedBox(
      width: 232,
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1,
        children: [for (var i = 0; i < cards.length; i++) cards[i]],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.icon, required this.hue, required this.label});
  final AppIconName icon;
  final double hue;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.hue(hue),
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppShadows.md(context.colors),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(icon, size: 36, stroke: 2, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Shield: a big gradient squircle with the shield icon ---
class _ShieldArt extends StatelessWidget {
  const _ShieldArt();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        gradient: AppGradients.brand(c),
        borderRadius: BorderRadius.circular(48),
        boxShadow: AppShadows.lg(c),
      ),
      child: Center(
        child: AppIcon(
          AppIconName.shield,
          size: 74,
          stroke: 1.7,
          color: Colors.white,
        ),
      ),
    );
  }
}
