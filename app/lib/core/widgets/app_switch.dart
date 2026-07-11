/// Toggle switch — همرسان.
///
/// Recreates `.switch` from `styles.css`: 50×30 pill, knob slides 20px.
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppSwitch extends StatefulWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.value ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant AppSwitch old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _c.animateTo(widget.value ? 1 : 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const w = 50.0, h = 30.0;
    // In LTR the knob slides left when on; the app is RTL but the switch
    // visuals match the CSS (translateX(-20px) when on).
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: Color.lerp(c.borderStrong, c.primary, _c.value),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 3,
                  right: 3 + 20 * _c.value, // knob slides left as value→1
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          offset: const Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
