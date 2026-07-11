/// Domain enums — همرسان.
///
/// Shared enumerations used across features (device types, content kinds,
/// transfer direction, history status).
import 'package:flutter/material.dart';
import '../../../core/widgets/app_icon.dart';

/// Kind of a remote device.
enum DeviceType { phone, laptop, desktop, tablet, server }

DeviceType deviceTypeFromString(String? s) {
  switch (s) {
    case 'phone':
      return DeviceType.phone;
    case 'laptop':
      return DeviceType.laptop;
    case 'desktop':
      return DeviceType.desktop;
    case 'tablet':
      return DeviceType.tablet;
    case 'server':
      return DeviceType.server;
    default:
      return DeviceType.phone;
  }
}

/// Icon name for a device type string.
AppIconName deviceIcon(String type) {
  switch (type) {
    case 'phone':
      return AppIconName.phone;
    case 'laptop':
      return AppIconName.laptop;
    case 'desktop':
      return AppIconName.desktop;
    case 'tablet':
      return AppIconName.tablet;
    case 'server':
      return AppIconName.server;
    default:
      return AppIconName.phone;
  }
}

/// Kind of transferable content.
enum ContentKind { image, video, doc, music, archive, contact, app }

ContentKind contentKindFromString(String? s) {
  switch (s) {
    case 'image':
      return ContentKind.image;
    case 'video':
      return ContentKind.video;
    case 'doc':
      return ContentKind.doc;
    case 'music':
      return ContentKind.music;
    case 'archive':
      return ContentKind.archive;
    case 'contact':
      return ContentKind.contact;
    case 'app':
      return ContentKind.app;
    default:
      return ContentKind.doc;
  }
}

/// Direction of a transfer.
enum TransferDirection { sent, received }

extension TransferDirectionX on TransferDirection {
  bool get isSent => this == TransferDirection.sent;

  /// Persian verb used in the transfer UI ("ارسال"/"دریافت").
  String get verb => isSent ? 'ارسال' : 'دریافت';
}

/// Lifecycle status of a completed/failed transfer record.
enum TransferStatus { done, failed, cancelled }

extension TransferStatusX on TransferStatus {
  bool get isFailed => this == TransferStatus.failed;
  bool get isCancelled => this == TransferStatus.cancelled;
}

/// Semantic color for a content kind (used by icons in lists).
Color kindTint(ContentKind kind) => switch (kind) {
      ContentKind.image => const Color(0xFFE07A3C),
      ContentKind.video => const Color(0xFF0083B7),
      ContentKind.doc => const Color(0xFFE07A3C),
      ContentKind.music => const Color(0xFF8752C1),
      ContentKind.archive => const Color(0xFFA16200),
      ContentKind.contact => const Color(0xFF0083B7),
      ContentKind.app => const Color(0xFF8752C1),
    };
