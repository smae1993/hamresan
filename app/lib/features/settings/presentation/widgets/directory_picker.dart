import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Uses the operating system's directory picker so scoped-storage and sandbox
/// permissions are respected on every supported platform.
Future<String?> showDirectoryPicker(
  BuildContext context, {
  String? initial,
}) async {
  try {
    return await FilePicker.getDirectoryPath(
      dialogTitle: 'انتخاب محل ذخیرهٔ فایل‌های همرسان',
      initialDirectory: initial,
    );
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('انتخاب پوشه در این دستگاه پشتیبانی نمی‌شود: $error'),
        ),
      );
    }
    return null;
  }
}
