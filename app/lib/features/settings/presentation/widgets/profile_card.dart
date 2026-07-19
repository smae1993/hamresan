/// Profile card (settings) — همرسان.
///
/// Recreates the profile `.id-card` from `Settings` in `screens_misc.jsx`:
/// gradient card with editable name, code, and a hue swatch picker.
import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/avatar.dart';
import '../../../discovery/domain/entities/identity.dart';

const _hueSwatches = [281.0, 200.0, 152.0, 24.0, 330.0, 95.0];

class ProfileCard extends StatefulWidget {
  const ProfileCard({
    super.key,
    required this.identity,
    required this.onChanged,
  });

  final Identity identity;
  final ValueChanged<Identity> onChanged;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  bool _editing = false;
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.identity.name);
  }

  @override
  void didUpdateWidget(covariant ProfileCard old) {
    super.didUpdateWidget(old);
    if (old.identity.name != widget.identity.name && !_editing) {
      _ctrl.text = widget.identity.name;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _ctrl.text.trim();
    if (name.isNotEmpty) {
      widget.onChanged(widget.identity.copyWith(name: name));
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final me = widget.identity;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.brand(c),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(hue: me.hue, size: 56, label: me.label, radius: 20),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_editing)
                      TextField(
                        controller: _ctrl,
                        autofocus: true,
                        style: AppTextStyles.idName.copyWith(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _save(),
                      )
                    else
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              me.name,
                              style: AppTextStyles.idName.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() {
                              _ctrl.text = me.name;
                              _editing = true;
                            }),
                            child: AppIcon(
                              AppIconName.edit,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 3),
                    Text(
                      '#${me.code}',
                      style: AppTextStyles.idMeta.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Hue swatches
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              for (final h in _hueSwatches)
                GestureDetector(
                  onTap: () =>
                      widget.onChanged(widget.identity.copyWith(hue: h)),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.hue(h),
                      border: Border.all(
                        color: me.hue == h ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: me.hue == h
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.4),
                                blurRadius: 2,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
