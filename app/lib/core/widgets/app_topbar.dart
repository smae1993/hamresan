/// App top bar — همرسان.
///
/// Recreates `.topbar` from `styles.css`: a title + subtitle on the leading
/// side, with optional trailing actions. Leading widget (e.g. logo) optional.
import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.padScreen,
        AppDimensions.padTopbarTop,
        AppDimensions.padScreen,
        AppDimensions.padTopbarBottom,
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.screenTitle),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(subtitle!, style: AppTextStyles.screenSub),
                  ),
              ],
            ),
          ),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}
