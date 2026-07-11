import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/buttons.dart';

/// Shows a directory picker dialog. Returns the selected path or null.
Future<String?> showDirectoryPicker(BuildContext context, {String? initial}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DirectoryPicker(initial: initial),
  );
}

class _DirectoryPicker extends StatefulWidget {
  const _DirectoryPicker({this.initial});
  final String? initial;

  @override
  State<_DirectoryPicker> createState() => _DirectoryPickerState();
}

class _DirectoryPickerState extends State<_DirectoryPicker> {
  late String _currentPath;
  List<FileSystemEntity> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.initial ?? '/';
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final dir = Directory(_currentPath);
      final entities = await dir.list().toList();
      entities.sort((a, b) {
        if (a is Directory && b is! Directory) return -1;
        if (a is! Directory && b is Directory) return 1;
        return a.path.compareTo(b.path);
      });
      if (mounted) setState(() { _entries = entities; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _navigateTo(String path) {
    setState(() { _currentPath = path; });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: AppIcon(AppIconName.back, size: 22, color: c.text),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'انتخاب محل ذخیره',
                    style: AppTextStyles.obTitle.copyWith(fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
          // Current path
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _currentPath,
                      style: AppTextStyles.fileSub.copyWith(color: c.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _navigateTo('/'),
                    child: AppIcon(AppIconName.folder, size: 16, color: c.muted),
                  ),
                ],
              ),
            ),
          ),
          // Directory list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    itemCount: _entries.length + 1,
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        if (_currentPath != '/') {
                          return _DirTile(
                            icon: AppIconName.forward,
                            name: '...',
                            onTap: () {
                              final parent = Directory(_currentPath).parent.path;
                              _navigateTo(parent);
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      }
                      final entity = _entries[i - 1];
                      if (entity is! Directory) return const SizedBox.shrink();
                      final segs = entity.path.split('/');
                      final name = segs.lastWhere((s) => s.isNotEmpty, orElse: () => entity.path);
                      return _DirTile(
                        icon: AppIconName.folder,
                        name: name,
                        onTap: () => _navigateTo(entity.path),
                      );
                    },
                  ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      variant: AppButtonVariant.ghost,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('انصراف'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      variant: AppButtonVariant.primary,
                      onPressed: () => Navigator.of(context).pop(_currentPath),
                      child: const Text('انتخاب این پوشه'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirTile extends StatelessWidget {
  const _DirTile({required this.icon, required this.name, required this.onTap});
  final AppIconName icon;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              AppIcon(icon, size: 18, color: c.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name, style: AppTextStyles.setLabel.copyWith(fontSize: 14, color: c.text)),
              ),
              AppIcon(AppIconName.back, size: 16, color: c.faint),
            ],
          ),
        ),
      ),
    );
  }
}
