/// Bottom sheet scaffold — همرسان.
///
/// Recreates the `.scrim`/`.sheet` pattern from `styles.css`: a dark blurred
/// scrim with a rounded sheet sliding up from the bottom, a drag grip, an
/// optional header (icon + title + subtitle + close) and a sticky footer.
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';
import 'buttons.dart';

/// Shows an [AppSheet] as a modal route. Matches the prototype overlay style.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  Widget? leading,
  required Widget body,
  Widget? footer,
  bool dismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierColor: Colors.transparent,
    useSafeArea: false,
    builder: (_) => AppSheet(
      title: title,
      subtitle: subtitle,
      leading: leading,
      body: body,
      footer: footer,
      dismissible: dismissible,
    ),
  );
}

class AppSheet extends StatefulWidget {
  const AppSheet({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.body,
    this.footer,
    this.dismissible = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget body;
  final Widget? footer;
  final bool dismissible;

  @override
  State<AppSheet> createState() => _AppSheetState();
}

class _AppSheetState extends State<AppSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _sheet;
  late final Animation<double> _scrim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scrim = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _sheet = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _c.value = 1; // start hidden, then animate in
    _c.reverse();
  }

  void _close([result]) {
    _c.forward().then((_) {
      if (mounted) Navigator.of(context).pop(result);
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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                // Scrim
                GestureDetector(
                  onTap: widget.dismissible ? _close : null,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.45 * _scrim.value),
                  ),
                ),
                // Sheet
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: bottomInset,
                  child: FractionalTranslation(
                    translation: Offset(0, _sheet.value),
                    child: _sheetCard(c),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sheetCard(AppColors c) {
    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    return Container(
      constraints: BoxConstraints(
        maxHeight: (mq.size.height - bottomInset) * 0.9,
      ),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.sheetTopRadius),
        ),
        boxShadow: AppShadows.lg(c),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grip
          Container(
            margin: const EdgeInsets.fromLTRB(0, 11, 0, 4),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: c.borderStrong,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: AppTextStyles.sheetTitle),
                      if (widget.subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            widget.subtitle!,
                            style: AppTextStyles.sheetSub.copyWith(
                              color: c.muted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButtonCircle(
                    icon: AppIconName.close,
                    size: 36,
                    onPressed: _close,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: widget.footer == null ? 16 : 0),
              child: widget.body,
            ),
          ),
          if (widget.footer != null)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.border)),
              ),
              child: SafeArea(top: false, child: widget.footer!),
            ),
        ],
      ),
    );
  }
}
