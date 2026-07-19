/// Persian-digit helpers — همرسان.
///
/// Mirrors `toFa` from `data.jsx`: every ASCII digit is replaced with its
/// Persian counterpart. Used for all numeric display in the app.
const _faDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

/// Converts any ASCII digits in [input] to Persian digits.
String toFa(Object input) {
  return input.toString().replaceAllMapped(
    RegExp(r'[0-9]'),
    (m) => _faDigits[int.parse(m[0]!)],
  );
}

/// Converts Persian/Arabic digits back to ASCII (used by size parsing).
String faToEn(String input) {
  var out = input;
  // Persian digits
  for (var i = 0; i < 10; i++) {
    out = out.replaceAll(_faDigits[i], '$i');
  }
  // Arabic-Indic digits
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (var i = 0; i < 10; i++) {
    out = out.replaceAll(arabic[i], '$i');
  }
  // Persian decimal separator
  out = out.replaceAll('٫', '.');
  return out;
}
