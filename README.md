# همرسان | Hamresan

همرسان یک برنامهٔ Flutter برای انتقال مستقیم فایل میان دستگاه‌های یک شبکهٔ محلی است. انتقال به سرور یا اینترنت وابسته نیست؛ فرستنده دستگاه مقصد را پیدا می‌کند، گیرنده درخواست را تأیید می‌کند و فایل‌ها به‌صورت جریانی منتقل می‌شوند.

> وضعیت: توسعهٔ نسخهٔ 1.0. پروتکل شبکه قابل استفاده است، اما رمزنگاری سرتاسری و Resume هنوز در نقشهٔ راه امنیتی قرار دارند. رابط کاربری نباید تا پیش از تکمیل و تست آن‌ها ادعای این قابلیت‌ها را نمایش دهد.

## قابلیت‌های فعلی

- کشف دستگاه‌ها با اعلان UDP و شناسهٔ پایدار نصب
- درخواست، قبول یا رد انتقال پیش از برقراری جریان داده
- ارسال واقعی چند فایل با TCP و پیشرفت مبتنی بر بایت
- بررسی SHA-256 هر فایل و تأیید نهایی گیرنده
- نام‌گذاری امن فایل مقصد و جلوگیری از Path Traversal
- جلوگیری از بازنویسی فایل‌های موجود
- انتخاب فایل و پوشه با File Picker بومی سیستم‌عامل
- رابط فارسی، پوستهٔ روشن/تیره و تاریخچهٔ محلی

## پلتفرم‌ها

| پلتفرم | وضعیت |
| --- | --- |
| Android | هدف اصلی نسخهٔ 1.0 |
| Windows | هدف اصلی نسخهٔ 1.0 |
| macOS | هدف اصلی نسخهٔ 1.0 |
| Linux | هدف اصلی نسخهٔ 1.0 |
| iOS | انتقال Foreground؛ نیازمند تست روی دستگاه واقعی |
| Web | پشتیبانی نمی‌شود؛ مرورگر به UDP/TCP خام دسترسی ندارد |

## اجرای پروژه

```bash
cd app
flutter pub get
flutter analyze
flutter test
flutter run
```

نسخهٔ پیشنهادی توسعه Flutter Stable و Dart مطابق محدودیت ثبت‌شده در `app/pubspec.yaml` است.

## ساختار

```text
app/
  lib/core/                 زیرساخت مشترک، Router، Theme و Providerها
  lib/features/discovery/   هویت دستگاه و کشف شبکه
  lib/features/transfer/    انتخاب محتوا، پروتکل و جریان انتقال
  lib/features/history/     تاریخچهٔ انتقال‌ها
  lib/features/settings/    تنظیمات دستگاه و محل ذخیره
docs/                       معماری، پروتکل، امنیت و تست
```

مستندات اصلی:

- [معماری](docs/ARCHITECTURE.md)
- [پروتکل انتقال](docs/PROTOCOL.md)
- [مدل امنیتی](docs/SECURITY.md)
- [راهنمای تست](docs/TESTING.md)
- [نقشه راه](docs/ROADMAP.md)

## Android Release Signing

فایل `app/android/key.properties.example` را با نام `key.properties` کپی و مسیر Keystore خصوصی را تنظیم کنید. فایل کلید و `key.properties` نباید Commit شوند. Build نوع Release دیگر از کلید Debug استفاده نمی‌کند.

## English summary

Hamresan is a Flutter application for direct, local-network file transfer. It discovers peers over UDP, requires receiver approval, streams real file bytes over TCP, verifies every file with SHA-256, and stores received files using sanitized collision-safe paths. See the documents under `docs/` before changing the wire protocol or security-sensitive code.

## License

No open-source license has been selected yet. All rights are reserved until a `LICENSE` file is added.
