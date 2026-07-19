// Design dimension tokens — همرسان.
//
// Values are ported from `styles.css` (radii, nav height, paddings, etc.).
import 'package:flutter/widgets.dart';

class AppDimensions {
  AppDimensions._();

  // Radii (from --r-lg/md/sm)
  static const double radiusLg = 26;
  static const double radiusMd = 18;
  static const double radiusSm = 13;

  // Phone-frame & system chrome
  static const double navHeight = 74;

  // Common paddings
  static const double padScreen = 20; // .pad horizontal
  static const double padTopbarBottom = 14;
  static const double padTopbarTop = 6;

  // Phone frame (for web/desktop presentation only)
  static const double phoneWidth = 390;
  static const double phoneHeight = 844;
  static const double phoneBezel = 12;
  static const double phoneRadius = 54;
  static const double screenRadius = 43;

  // Sheet
  static const double sheetTopRadius = 30;
  static const double dialogRadius = 28;

  // Icon button
  static const double iconBtnSize = 42;

  // Avatars
  static const double avatarDevice = 56;
  static const double avatarRecipient = 46;

  // Progress ring
  static const double ringSize = 188;
  static const double ringStroke = 13;
}

/// Standard screen horizontal padding used across pages.
const EdgeInsets kScreenPadding = EdgeInsets.fromLTRB(
  AppDimensions.padScreen,
  4,
  AppDimensions.padScreen,
  0,
);

/// Bottom padding so content clears the bottom nav.
const EdgeInsets kScreenBottomPadding = EdgeInsets.only(
  bottom: AppDimensions.navHeight + 20,
);
