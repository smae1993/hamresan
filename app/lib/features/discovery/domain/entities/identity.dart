/// Identity entity — همرسان.
///
/// Represents "this device" (me): name, platform, color hue, pairing code.
class Identity {
  const Identity({
    required this.name,
    required this.platform,
    required this.hue,
    required this.code,
  });

  final String name;
  final String platform;
  final double hue;
  final String code;

  /// First non-whitespace character of the name, used as avatar initial.
  String get label => name.trim().isNotEmpty ? name.trim().substring(0, 1) : 'م';

  Identity copyWith({
    String? name,
    String? platform,
    double? hue,
    String? code,
  }) =>
      Identity(
        name: name ?? this.name,
        platform: platform ?? this.platform,
        hue: hue ?? this.hue,
        code: code ?? this.code,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'platform': platform,
        'hue': hue,
        'code': code,
      };

  factory Identity.fromJson(Map<String, dynamic> json) => Identity(
        name: json['name'] as String? ?? 'گوشی من',
        platform: json['platform'] as String? ?? 'Android',
        hue: (json['hue'] as num?)?.toDouble() ?? 281,
        code: json['code'] as String? ?? 'آبی-۲۷',
      );
}
