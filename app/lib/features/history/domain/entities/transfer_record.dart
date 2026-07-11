import '../../../transfer/domain/enums.dart';

class TransferRecord {
  const TransferRecord({
    required this.id,
    required this.direction,
    required this.peer,
    required this.hue,
    required this.summary,
    required this.size,
    required this.when,
    required this.status,
  });

  final String id;
  final TransferDirection direction;
  final String peer;
  final double hue;
  final String summary;
  final String size;
  final String when;
  final TransferStatus status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'direction': direction.name,
        'peer': peer,
        'hue': hue,
        'summary': summary,
        'size': size,
        'when': when,
        'status': status.name,
      };

  static TransferRecord fromJson(Map<String, dynamic> json) => TransferRecord(
        id: json['id'] as String,
        direction: TransferDirection.values.byName(json['direction'] as String),
        peer: json['peer'] as String,
        hue: (json['hue'] as num).toDouble(),
        summary: json['summary'] as String,
        size: json['size'] as String,
        when: json['when'] as String,
        status: TransferStatus.values.byName(json['status'] as String),
      );
}
