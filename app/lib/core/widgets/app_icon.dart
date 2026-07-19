// Custom SVG icon set — همرسان.
//
// Recreates `Icon`/`ICON_PATHS` from `icons.jsx`. The prototype stores each
// icon as one or more SVG path `d` strings (space-separated `M` segments),
// rendered as a 24×24 stroked SVG. Here we keep the exact same path data and
// render it with `SvgPicture.string`.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// All icon names available in the set.
enum AppIconName {
  send,
  paperplane,
  image,
  video,
  file,
  apps,
  history,
  settings,
  check,
  checkbold,
  close,
  back,
  forward,
  search,
  wifi,
  shield,
  download,
  bell,
  moon,
  sun,
  folder,
  plus,
  qr,
  phone,
  laptop,
  desktop,
  tablet,
  server,
  edit,
  link,
  eye,
  info,
  chevron,
  pin,
  zap,
  music,
  archive,
  doc,
  contact,
  refresh,
  trash,
  clock,
  bolt2,
}

/// Raw path data per icon (identical to `icons.jsx` `ICON_PATHS`).
const Map<AppIconName, String> _kPaths = {
  AppIconName.send: 'M12 19V5 M5 12l7-7 7 7',
  AppIconName.paperplane: 'M22 2L11 13 M22 2l-7 20-4-9-9-4 20-7z',
  AppIconName.image:
      'M3 5h18v14H3z M3 16l5-5 4 4 3-3 6 6 M8.5 9.5a1.5 1.5 0 100-3 1.5 1.5 0 000 3z',
  AppIconName.video: 'M15 8.5v7l6-3.5-6-3.5z M3 6h12v12H3z',
  AppIconName.file: 'M14 3H6v18h12V8l-4-5z M14 3v5h4',
  AppIconName.apps: 'M4 4h6v6H4z M14 4h6v6h-6z M4 14h6v6H4z M14 14h6v6h-6z',
  AppIconName.history:
      'M3 12a9 9 0 109-9 9 9 0 00-7.5 4 M3 4v4h4 M12 7v5l3.5 2',
  AppIconName.settings:
      'M12 15a3 3 0 100-6 3 3 0 000 6z M19.4 13a7.8 7.8 0 000-2l2-1.5-2-3.5-2.4 1a7.6 7.6 0 00-1.7-1L13 3h-2l-.3 2.5a7.6 7.6 0 00-1.7 1l-2.4-1-2 3.5L4.6 11a7.8 7.8 0 000 2l-2 1.5 2 3.5 2.4-1a7.6 7.6 0 001.7 1L11 21h2l.3-2.5a7.6 7.6 0 001.7-1l2.4 1 2-3.5-2-1.5z',
  AppIconName.check: 'M5 12.5l5 5 9-11',
  AppIconName.checkbold: 'M5 13l4 4 10-12',
  AppIconName.close: 'M6 6l12 12 M18 6L6 18',
  AppIconName.back: 'M9 6l6 6-6 6',
  AppIconName.forward: 'M15 6l-6 6 6 6',
  AppIconName.search: 'M11 19a8 8 0 100-16 8 8 0 000 16z M21 21l-4.3-4.3',
  AppIconName.wifi: 'M5 12.5a10 10 0 0114 0 M8.5 16a5 5 0 017 0 M12 19.5h.01',
  AppIconName.shield:
      'M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6l8-3z M9 12l2 2 4-4',
  AppIconName.download: 'M12 3v12 M7 11l5 5 5-5 M5 21h14',
  AppIconName.bell:
      'M18 9a6 6 0 10-12 0c0 6-2 8-2 8h16s-2-2-2-8z M10 21a2 2 0 004 0',
  AppIconName.moon: 'M21 12.8A9 9 0 1111.2 3a7 7 0 009.8 9.8z',
  AppIconName.sun:
      'M12 17a5 5 0 100-10 5 5 0 000 10z M12 1v3 M12 20v3 M4 4l2 2 M18 18l2 2 M1 12h3 M20 12h3 M4 20l2-2 M18 6l2-2',
  AppIconName.folder: 'M3 7h6l2 2h10v10H3V7z',
  AppIconName.plus: 'M12 5v14 M5 12h14',
  AppIconName.qr:
      'M4 4h6v6H4z M14 4h6v6h-6z M4 14h6v6H4z M14 14v3 M17 14h3v3 M17 20h3 M14 20v0',
  AppIconName.phone: 'M8 2h8v20H8z M11 18h2',
  AppIconName.laptop: 'M5 5h14v10H5z M3 19h18 M3 19l1-2h16l1 2',
  AppIconName.desktop: 'M4 4h16v11H4z M9 19h6 M10 15v4 M14 15v4',
  AppIconName.tablet: 'M6 3h12v18H6z M11 18h2',
  AppIconName.server: 'M4 4h16v6H4z M4 14h16v6H4z M7 7h.01 M7 17h.01',
  AppIconName.edit: 'M4 20h4L19 9l-4-4L4 16v4z M14 6l4 4',
  AppIconName.link:
      'M9 15l6-6 M10 6l1-1a4 4 0 016 6l-1 1 M14 18l-1 1a4 4 0 01-6-6l1-1',
  AppIconName.eye:
      'M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z M12 15a3 3 0 100-6 3 3 0 000 6z',
  AppIconName.info: 'M12 21a9 9 0 100-18 9 9 0 000 18z M12 11v5 M12 7.5h.01',
  AppIconName.chevron: 'M9 6l6 6-6 6',
  AppIconName.pin:
      'M12 21s7-6 7-11a7 7 0 10-14 0c0 5 7 11 7 11z M12 12a2.5 2.5 0 100-5 2.5 2.5 0 000 5z',
  AppIconName.zap: 'M13 2L4 14h7l-2 8 9-12h-7l2-8z',
  AppIconName.music:
      'M9 18V5l11-2v13 M9 18a3 3 0 11-6 0 3 3 0 016 0z M20 16a3 3 0 11-6 0 3 3 0 016 0z',
  AppIconName.archive: 'M3 6h18v4H3z M5 10v10h14V10 M9 14h6',
  AppIconName.doc: 'M14 3H6v18h12V8l-4-5z M14 3v5h4 M8 13h8 M8 17h5',
  AppIconName.contact: 'M12 12a4 4 0 100-8 4 4 0 000 8z M4 20a8 8 0 0116 0',
  AppIconName.refresh:
      'M3 12a9 9 0 0115-6.7L21 8 M21 3v5h-5 M21 12a9 9 0 01-15 6.7L3 16 M3 21v-5h5',
  AppIconName.trash: 'M4 7h16 M9 7V4h6v3 M6 7l1 13h10l1-13',
  AppIconName.clock: 'M12 21a9 9 0 100-18 9 9 0 000 18z M12 7v5l3 2',
  AppIconName.bolt2: 'M11 21l1-7H7l6-11-1 7h5l-6 11z',
};

/// Icons that should be drawn filled rather than stroked.
const _kFilled = <AppIconName>{AppIconName.check};

/// Builds the inline SVG string for [name].
String iconSvg(AppIconName name, {Color? color, double stroke = 2}) {
  final raw = _kPaths[name] ?? '';
  final filled = _kFilled.contains(name);
  final argb = (color ?? const Color(0xFF000000)).toARGB32();
  final hex =
      '${((argb >> 16) & 0xFF).toRadixString(16).padLeft(2, '0')}'
      '${((argb >> 8) & 0xFF).toRadixString(16).padLeft(2, '0')}'
      '${(argb & 0xFF).toRadixString(16).padLeft(2, '0')}'
      '${((argb >> 24) & 0xFF).toRadixString(16).padLeft(2, '0')}';
  final fillAttr = filled ? '#$hex' : 'none';
  final strokeAttr = filled ? 'none' : '#$hex';
  final paths = raw
      .split(' M')
      .asMap()
      .entries
      .map((e) {
        final d = e.key == 0 ? e.value : 'M${e.value}';
        return '    <path d="$d" />';
      })
      .join('\n');
  return '''
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
  fill="$fillAttr" stroke="$strokeAttr" stroke-width="$stroke"
  stroke-linecap="round" stroke-linejoin="round">
$paths
</svg>''';
}

/// A single custom icon, painted from the inline SVG set.
///
/// Mirrors the prototype's `<Icon name size stroke fill />` component.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.name, {
    super.key,
    this.size = 22,
    this.stroke = 2,
    this.color,
  });

  final AppIconName name;
  final double size;
  final double stroke;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c =
        color ??
        IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color;
    return SvgPicture.string(
      iconSvg(name, color: c, stroke: stroke),
      width: size,
      height: size,
    );
  }
}
