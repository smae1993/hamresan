/// Mock data — همرسان.
///
/// Seed content ported verbatim from `data.jsx` (DEVICES, PHOTOS, VIDEOS,
/// FILES, APPS, SEED_HISTORY, INCOMING_REQ). The network layer will replace
/// these with real discovery later; for now they drive the UI.
import '../../discovery/domain/entities/device.dart';
import '../../history/domain/entities/transfer_record.dart';
import '../../transfer/domain/entities/content_item.dart';
import '../../transfer/domain/enums.dart';
import '../../transfer/domain/entities/incoming_request.dart';

/// Nearby devices on the LAN.
const mockDevices = <Device>[
  Device(id: 'd1', name: 'لپ‌تاپ سارا', type: 'laptop', platform: 'macOS', hue: 281, code: 'بادبادک-۷۲'),
  Device(id: 'd2', name: 'گوشی علی', type: 'phone', platform: 'Android', hue: 200, code: 'ققنوس-۱۴'),
  Device(id: 'd3', name: 'کامپیوتر دفتر', type: 'desktop', platform: 'Windows', hue: 152, code: 'کوه-۰۹'),
  Device(id: 'd4', name: 'آی‌پد مریم', type: 'tablet', platform: 'iPadOS', hue: 24, code: 'مروارید-۵۱'),
  Device(id: 'd5', name: 'گوشی رضا', type: 'phone', platform: 'iOS', hue: 330, code: 'ستاره-۳۸'),
  Device(id: 'd6', name: 'سرور خانه', type: 'server', platform: 'Linux', hue: 95, code: 'ریشه-۰۲'),
];

const mockPhotos = <ContentItem>[
  ContentItem(key: 'p1', name: 'غروب ساحل.jpg', kind: ContentKind.image, size: '۴٫۲ MB', hue: 24, label: 'غروب ساحل'),
  ContentItem(key: 'p2', name: 'تولد.jpg', kind: ContentKind.image, size: '۳٫۱ MB', hue: 330, label: 'تولد'),
  ContentItem(key: 'p3', name: 'کوهنوردی.jpg', kind: ContentKind.image, size: '۵٫۸ MB', hue: 152, label: 'کوهنوردی'),
  ContentItem(key: 'p4', name: 'کافه.jpg', kind: ContentKind.image, size: '۲٫۴ MB', hue: 60, label: 'کافه'),
  ContentItem(key: 'p5', name: 'خیابان.jpg', kind: ContentKind.image, size: '۳٫۶ MB', hue: 281, label: 'خیابان'),
  ContentItem(key: 'p6', name: 'گل‌ها.jpg', kind: ContentKind.image, size: '۴٫۰ MB', hue: 350, label: 'گل‌ها'),
  ContentItem(key: 'p7', name: 'معماری.jpg', kind: ContentKind.image, size: '۶٫۲ MB', hue: 200, label: 'معماری'),
  ContentItem(key: 'p8', name: 'جنگل.jpg', kind: ContentKind.image, size: '۵٫۱ MB', hue: 140, label: 'جنگل'),
  ContentItem(key: 'p9', name: 'شهر شب.jpg', kind: ContentKind.image, size: '۴٫۷ MB', hue: 270, label: 'شهر شب'),
];

const mockVideos = <ContentItem>[
  ContentItem(key: 'v1', name: 'سفر شمال.mp4', kind: ContentKind.video, size: '۸۸ MB', hue: 200, label: 'سفر شمال', duration: '۰:۴۲'),
  ContentItem(key: 'v2', name: 'کنسرت.mp4', kind: ContentKind.video, size: '۲۴۰ MB', hue: 330, label: 'کنسرت', duration: '۲:۱۵'),
  ContentItem(key: 'v3', name: 'آشپزی.mp4', kind: ContentKind.video, size: '۳۱۰ MB', hue: 24, label: 'آشپزی', duration: '۵:۰۳'),
  ContentItem(key: 'v4', name: 'ورزش.mp4', kind: ContentKind.video, size: '۱۲۰ MB', hue: 152, label: 'ورزش', duration: '۱:۱۲'),
  ContentItem(key: 'v5', name: 'خانوادگی.mp4', kind: ContentKind.video, size: '۴۱۰ MB', hue: 281, label: 'خانوادگی', duration: '۳:۴۸'),
  ContentItem(key: 'v6', name: 'طبیعت.mp4', kind: ContentKind.video, size: '۶۲ MB', hue: 140, label: 'طبیعت', duration: '۰:۲۸'),
];

const mockFiles = <ContentItem>[
  ContentItem(key: 'f1', name: 'قرارداد همکاری.pdf', kind: ContentKind.doc, size: '۱٫۲ MB', hue: 18),
  ContentItem(key: 'f2', name: 'گزارش مالی Q۲.xlsx', kind: ContentKind.doc, size: '۸۴۰ KB', hue: 152),
  ContentItem(key: 'f3', name: 'ارائه محصول.pptx', kind: ContentKind.doc, size: '۵٫۶ MB', hue: 24),
  ContentItem(key: 'f4', name: 'آهنگ مورد علاقه.mp3', kind: ContentKind.music, size: '۹٫۱ MB', hue: 281),
  ContentItem(key: 'f5', name: 'بکاپ پروژه.zip', kind: ContentKind.archive, size: '۱۴۸ MB', hue: 60),
  ContentItem(key: 'f6', name: 'مخاطبین.vcf', kind: ContentKind.contact, size: '۳۲ KB', hue: 200),
];

const mockApps = <ContentItem>[
  ContentItem(key: 'a1', name: 'نقشه‌یاب', kind: ContentKind.app, size: '۶۸ MB', hue: 152, version: '۳٫۴٫۱'),
  ContentItem(key: 'a2', name: 'پخش‌کننده ویدیو', kind: ContentKind.app, size: '۴۲ MB', hue: 281, version: '۲٫۰٫۸'),
  ContentItem(key: 'a3', name: 'ویرایشگر عکس', kind: ContentKind.app, size: '۱۲۴ MB', hue: 330, version: '۵٫۱٫۰'),
  ContentItem(key: 'a4', name: 'یادداشت امن', kind: ContentKind.app, size: '۲۸ MB', hue: 200, version: '۱٫۹٫۳'),
  ContentItem(key: 'a5', name: 'اسکنر سند', kind: ContentKind.app, size: '۵۵ MB', hue: 24, version: '۴٫۲٫۲'),
];

/// Initial history (mirrors `SEED_HISTORY`).
final seedHistory = <TransferRecord>[
  const TransferRecord(id: 'h1', direction: TransferDirection.received, peer: 'گوشی علی', hue: 200, summary: '۳ عکس', size: '۱۱٫۴ MB', when: '۱۰ دقیقه پیش', status: TransferStatus.done),
  const TransferRecord(id: 'h2', direction: TransferDirection.sent, peer: 'لپ‌تاپ سارا', hue: 281, summary: 'ارائه محصول.pptx', size: '۵٫۶ MB', when: 'امروز ۹:۲۰', status: TransferStatus.done),
  const TransferRecord(id: 'h3', direction: TransferDirection.sent, peer: 'کامپیوتر دفتر', hue: 152, summary: 'بکاپ پروژه.zip', size: '۱۴۸ MB', when: 'دیروز ۱۸:۰۲', status: TransferStatus.done),
  const TransferRecord(id: 'h4', direction: TransferDirection.received, peer: 'آی‌پد مریم', hue: 24, summary: 'سفر شمال.mp4', size: '۸۸ MB', when: 'دیروز ۱۴:۴۵', status: TransferStatus.done),
  const TransferRecord(id: 'h5', direction: TransferDirection.sent, peer: 'گوشی رضا', hue: 330, summary: '۲ فایل', size: '۹٫۴ MB', when: '۲ روز پیش', status: TransferStatus.failed),
];

/// Incoming request used by the receive demo (mirrors `INCOMING_REQ`).
final mockIncomingRequest = IncomingRequest(
  peer: 'گوشی علی',
  hue: 200,
  type: 'phone',
  platform: 'Android',
  code: 'ققنوس-۱۴',
  items: const [
    ContentItem(key: 'i1', name: 'غروب ساحل.jpg', kind: ContentKind.image, size: '۴٫۲ MB', hue: 24),
    ContentItem(key: 'i2', name: 'تولد.jpg', kind: ContentKind.image, size: '۳٫۱ MB', hue: 330),
    ContentItem(key: 'i3', name: 'سفر شمال.mp4', kind: ContentKind.video, size: '۸۸ MB', hue: 200),
  ],
  total: '۹۵٫۳ MB',
);
