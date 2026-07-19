import '../../../transfer/domain/enums.dart';
import '../../../../core/utils/fa_digits.dart';

class TransferRecord {
  const TransferRecord({
    required this.id,
    required this.direction,
    required this.peer,
    required this.hue,
    required this.summary,
    required this.size,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final TransferDirection direction;
  final String peer;
  final double hue;
  final String summary;
  final String size;
  final DateTime createdAt;
  final TransferStatus status;

  String get when {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'هم‌اکنون';
    if (difference.inHours < 1)
      return '${toFa(difference.inMinutes)} دقیقه پیش';
    if (difference.inDays < 1) return '${toFa(difference.inHours)} ساعت پیش';
    if (difference.inDays < 7) return '${toFa(difference.inDays)} روز پیش';
    return '${toFa(createdAt.year)}/${toFa(createdAt.month.toString().padLeft(2, '0'))}/${toFa(createdAt.day.toString().padLeft(2, '0'))}';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'direction': direction.name,
    'peer': peer,
    'hue': hue,
    'summary': summary,
    'size': size,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'status': status.name,
  };

  static TransferRecord fromJson(Map<String, dynamic> json) => TransferRecord(
    id: json['id'] as String,
    direction: TransferDirection.values.byName(json['direction'] as String),
    peer: json['peer'] as String,
    hue: (json['hue'] as num).toDouble(),
    summary: json['summary'] as String,
    size: json['size'] as String,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
        DateTime.now(),
    status: TransferStatus.values.byName(json['status'] as String),
  );
}
