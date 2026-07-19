// Typography — همرسان.
//
// Font family is Vazirmatn (declared in pubspec). Sizes/weights are ported
// from the prototype's inline styles + `styles.css`.
import 'package:flutter/material.dart';

const String _kFont = 'Vazirmatn';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle screenTitle = TextStyle(
    fontFamily: _kFont,
    fontSize: 21,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.01,
    height: 1.2,
  );

  static const TextStyle screenSub = TextStyle(
    fontFamily: _kFont,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle sheetTitle = TextStyle(
    fontFamily: _kFont,
    fontSize: 17,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  static const TextStyle sheetSub = TextStyle(
    fontFamily: _kFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle sectionHead = TextStyle(
    fontFamily: _kFont,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle countBadge = TextStyle(
    fontFamily: _kFont,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle idName = TextStyle(
    fontFamily: _kFont,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  static const TextStyle idMeta = TextStyle(
    fontFamily: _kFont,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle pillStatus = TextStyle(
    fontFamily: _kFont,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle deviceName = TextStyle(
    fontFamily: _kFont,
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle deviceMeta = TextStyle(
    fontFamily: _kFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle platformTag = TextStyle(
    fontFamily: _kFont,
    fontSize: 9.5,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle chip = TextStyle(
    fontFamily: _kFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle seg = TextStyle(
    fontFamily: _kFont,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle fileName = TextStyle(
    fontFamily: _kFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle fileSub = TextStyle(
    fontFamily: _kFont,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle btn = TextStyle(
    fontFamily: _kFont,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle btnLg = TextStyle(
    fontFamily: _kFont,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle navLabel = TextStyle(
    fontFamily: _kFont,
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle pctNumber = TextStyle(
    fontFamily: _kFont,
    fontSize: 44,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.02,
    height: 1.0,
  );

  static const TextStyle pctLabel = TextStyle(
    fontFamily: _kFont,
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle statNumber = TextStyle(
    fontFamily: _kFont,
    fontSize: 17,
    fontWeight: FontWeight.w800,
    height: 1.2,
  );

  static const TextStyle statLabel = TextStyle(
    fontFamily: _kFont,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle historyTitle = TextStyle(
    fontFamily: _kFont,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle historySub = TextStyle(
    fontFamily: _kFont,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle historyTime = TextStyle(
    fontFamily: _kFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle setLabel = TextStyle(
    fontFamily: _kFont,
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle setVal = TextStyle(
    fontFamily: _kFont,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle setCap = TextStyle(
    fontFamily: _kFont,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle obTitle = TextStyle(
    fontFamily: _kFont,
    fontSize: 25,
    fontWeight: FontWeight.w800,
    height: 1.35,
    letterSpacing: -0.01,
  );

  static const TextStyle obDesc = TextStyle(
    fontFamily: _kFont,
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    height: 1.85,
  );

  static const TextStyle scanning = TextStyle(
    fontFamily: _kFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle emptyTitle = TextStyle(
    fontFamily: _kFont,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle emptyBody = TextStyle(
    fontFamily: _kFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
}
