// Identity card — همرسان.
//
// Recreates the `.id-card` from `Home`: a gradient card showing "this device"
// with an avatar, name, platform, a "visible" status pill, the pairing code,
// and an animated radar sweep behind it.
import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/live_dot.dart';
import '../../domain/entities/identity.dart';

class IdentityCard extends StatefulWidget {
  const IdentityCard({super.key, required this.identity});

  final Identity identity;

  @override
  State<IdentityCard> createState() => _IdentityCardState();
}

class _IdentityCardState extends State<IdentityCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radar;

  @override
  void initState() {
    super.initState();
    _radar = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _radar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final me = widget.identity;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: AppGradients.brand(c),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: AppShadows.fab(c),
      ),
      child: Stack(
        children: [
          // Radar sweep rings (absolute, centered, behind content)
          Positioned.fill(child: _RadarSweep(controller: _radar)),
          // Foreground content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar squircle
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        me.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          me.name,
                          style: AppTextStyles.idName.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const AppIcon(
                              AppIconName.phone,
                              size: 14,
                              stroke: 2,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'این دستگاه · ${me.platform}',
                              style: AppTextStyles.idMeta.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        const LiveDot(color: Colors.white),
                        const SizedBox(width: 7),
                        Text(
                          'قابل مشاهده برای اطراف',
                          style: AppTextStyles.pillStatus.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '#${me.code}',
                    style: AppTextStyles.idMeta.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      fontFamily: null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The expanding radar rings (`.radar span` keyframe `radar`).
class _RadarSweep extends StatelessWidget {
  const _RadarSweep({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < 3; i++)
              _Ring(controller: controller, phase: i / 3),
          ],
        );
      },
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.controller, required this.phase});
  final AnimationController controller;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final t = (controller.value + phase) % 1.0;
    // radar: 60px → 360px, opacity 0.7 → 0
    final size = 60 + (360 - 60) * t;
    final opacity = 0.7 * (1 - t);
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppGradients.radarRing, width: 1.5),
        ),
      ),
    );
  }
}
