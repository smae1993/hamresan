# راهنمای تست

## بررسی‌های خودکار

```bash
cd app
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

GitHub Actions همین بررسی‌ها را برای هر Push و Pull Request اجرا می‌کند.

## ماتریس تست دستی انتقال

حداقل ترکیب‌های زیر پیش از Release بررسی شوند:

- Android → Android
- Android → Windows
- Windows → Android
- Android → macOS
- Linux → Android
- iOS → macOS روی دستگاه واقعی

سناریوهای الزامی:

- یک فایل کوچک و فایل صفر بایت
- چند فایل با نام فارسی
- فایل بزرگ‌تر از 4 GiB
- نام تکراری در مقصد
- قطع Wi-Fi وسط انتقال
- لغو از فرستنده و گیرنده
- رد درخواست و Timeout
- تغییر یا حذف فایل پس از انتخاب
- Metadata با `../`, Separator، نام بسیار بلند و حجم غیرمجاز
- دو انتقال پشت سر هم و حضور چند دستگاه هم‌نام

موفقیت فقط وقتی ثبت می‌شود که گیرنده SHA-256 را تأیید و ACK نهایی ارسال کرده باشد.
