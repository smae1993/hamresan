/// Device card — همرسان.
///
/// Recreates `DeviceCard` from `screens_home.jsx`: a surface card with a
/// platform tag, a ringed avatar, device name, and an online indicator.
import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/fa_digits.dart';
import '../../../../core/widgets/avatar.dart';
import '../../../../core/widgets/live_dot.dart';
import '../../domain/entities/device.dart';

class DeviceCard extends StatefulWidget {
  const DeviceCard({
    super.key,
    required this.device,
    required this.index,
    required this.onTap,
  });

  final Device device;
  final int index;
  final VoidCallback onTap;

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 0,
    );
    Future.delayed(Duration(milliseconds: widget.index * 70), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final d = widget.device;

    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _c, curve: Curves.easeOutCubic),
        child: FadeTransition(
          opacity: _c,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 15),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: c.border),
              boxShadow: AppShadows.sm(c),
            ),
            child: Column(
              children: [
                // Platform tag (absolute in CSS; here placed above avatar)
                Align(
                  alignment: Alignment.topRight,
                  child: Transform.translate(
                    offset: const Offset(6, -8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.surface2,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: c.border),
                      ),
                      child: Text(
                        toFa(d.platform),
                        style: AppTextStyles.platformTag.copyWith(color: c.muted),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -6),
                  child: Avatar(hue: d.hue, type: d.type, size: 56, ring: true),
                ),
                const SizedBox(height: 4),
                Text(d.name, style: AppTextStyles.deviceName, textAlign: TextAlign.center),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LiveDot(color: c.green, size: 6),
                    const SizedBox(width: 4),
                    Text('آنلاین', style: AppTextStyles.deviceMeta.copyWith(color: c.muted)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
