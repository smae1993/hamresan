# پروتکل شبکهٔ همرسان

## نسخه

نسخهٔ فعلی Wire Protocol برابر `1` و Magic هدر TCP برابر `HAMRESAN` است. تمام Integerهای فریم باینری با Big Endian نوشته می‌شوند.

## Discovery

- UDP port: `41829`
- Announce interval: 4 seconds
- Peer timeout: 18 seconds
- TCP port: ابتدا `41830` و در صورت اشغال یک پورت آزاد سیستم

پیام Announce شامل نوع پیام، نسخه، شناسه، نام، پلتفرم، رنگ، کد نمایش و پورت TCP است. Datagramهای نامعتبر بدون تغییر State نادیده گرفته می‌شوند.

## Transfer request

فرستنده پیام `transfer_request` شامل موارد زیر می‌فرستد:

- `protocol`
- `transferId`
- مشخصات دستگاه فرستنده
- آرایهٔ فایل‌ها شامل `name`, `size`, `kind`, `hue`

محدودیت‌ها:

- حداکثر 500 فایل در هر نشست
- حداکثر مجموع 2 TiB
- نام و رشته‌های Metadata حداکثر 255 نویسه
- Timeout تأیید 60 ثانیه

گیرنده با `transfer_response` پاسخ می‌دهد. پاسخ قبول شامل Token تصادفی حداقل 128 بیت و پورت TCP است. پاسخ فقط وقتی معتبر است که از IP دستگاه مورد انتظار آمده باشد.

## TCP framing

```text
[4-byte header length]
[UTF-8 JSON header]
[file 0 bytes]
[file 0 SHA-256: 32 bytes]
[file 1 bytes]
[file 1 SHA-256: 32 bytes]
...
[receiver ACK: 1 byte]
```

Header حداکثر 256 KiB است و شامل Magic، نسخه، `transferId`، Token، `senderId` و فهرست فایل‌ها می‌شود. گیرنده Header را با درخواست قبلی تطبیق می‌دهد؛ تغییر نام، اندازه، تعداد، فرستنده یا Token انتقال را متوقف می‌کند.

ACK برابر `1` به‌معنی ثبت و تأیید تمام فایل‌ها است. هر مقدار دیگر یا قطع Socket شکست انتقال محسوب می‌شود. فرستنده قبل از دریافت ACK نباید موفقیت نمایش دهد.

## Compatibility

نسخه‌های ناسازگار نباید انتقال را آغاز کنند. هر تغییر در ترتیب فریم، الگوریتم Integrity یا الزامات Header باید با افزایش `protocolVersion` و سند Migration همراه باشد.
