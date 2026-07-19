/// Content picker sheet — همرسان.
///
/// Recreates `ContentPicker` from `screens_send.jsx`: a bottom sheet with
/// 4 segmented tabs (عکس / فیلم / فایل / برنامه), a media grid for photos &
/// videos, a file list for files & apps, multi-select, and a footer button
/// showing count + total size.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/fa_digits.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/utils/size_format.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/segmented_control.dart';
import '../../../core/widgets/stripe_placeholder.dart';
import '../../discovery/domain/entities/device.dart';
import '../domain/entities/content_item.dart';
import '../domain/enums.dart';
import 'content_item_icon.dart';

/// Result returned when the picker is confirmed.
class PickerResult {
  const PickerResult({required this.items, this.device});
  final List<ContentItem> items;
  final Device? device;
}

/// Shows the content picker as a modal sheet and awaits the result.
/// Returns null if dismissed.
Future<PickerResult?> showContentPicker(
  BuildContext context, {
  Device? device,
}) {
  return showAppSheet<PickerResult>(
    context: context,
    title: device != null ? 'ارسال به ${device.name}' : 'انتخاب محتوا',
    subtitle: device != null
        ? '${device.platform} · #${device.code}'
        : 'موارد دلخواهت را انتخاب کن',
    leading: device != null
        ? Avatar(hue: device.hue, type: device.type, size: 42)
        : null,
    body: PickerSheetBody(device: device),
  );
}

class PickerSheetBody extends ConsumerStatefulWidget {
  const PickerSheetBody({
    super.key,
    this.device,
    this.onConfirm,
    this.onCancel,
  });

  final Device? device;
  final void Function(PickerResult)? onConfirm;
  final VoidCallback? onCancel;

  @override
  ConsumerState<PickerSheetBody> createState() => _PickerSheetBodyState();
}

class _PickerSheetBodyState extends ConsumerState<PickerSheetBody> {
  int _tab = 0;
  final _selected = <String, ContentItem>{};
  final _contentCache = <ContentKind, List<ContentItem>>{};
  bool _picking = false;

  List<_TabDef> get _tabs {
    final type = widget.device?.type ?? 'phone';
    return _tabDefs(type);
  }

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    final repo = ref.read(contentRepositoryProvider);
    final kinds = _tabs.map((t) => t.kind).toSet();
    for (final kind in kinds) {
      final items = await repo.getByKind(kind);
      _contentCache[kind] = items;
    }
    if (mounted) setState(() {});
  }

  void _toggle(ContentItem item) {
    setState(() {
      if (_selected.containsKey(item.key)) {
        _selected.remove(item.key);
      } else {
        _selected[item.key] = item;
      }
    });
  }

  void _confirm() {
    if (_selected.isEmpty) return;
    final result = PickerResult(
      items: _selected.values.toList(),
      device: widget.device,
    );
    if (widget.onConfirm != null) {
      widget.onConfirm!(result);
    } else {
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _pickFromDevice() async {
    if (_picking || _tab >= _tabs.length) return;
    setState(() => _picking = true);
    try {
      final kind = _tabs[_tab].kind;
      final picked = await ref.read(contentRepositoryProvider).pickByKind(kind);
      if (!mounted || picked.isEmpty) return;
      setState(() {
        final existing = {
          for (final item in _contentCache[kind] ?? const <ContentItem>[])
            item.key: item,
        };
        for (final item in picked) {
          existing[item.key] = item;
          _selected[item.key] = item;
        }
        _contentCache[kind] = existing.values.toList();
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('انتخاب فایل انجام نشد: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _selected.values.toList();
    final totalBytes = items.fold<int>(0, (sum, item) => sum + item.byteSize);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: SegmentedControl(
            items: _tabs.map((t) => t.seg).toList(),
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
        ),
        SizedBox(
          height: 326,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
                child: AppButton(
                  variant: AppButtonVariant.ghost,
                  block: true,
                  icon: AppIconName.folder,
                  onPressed: _picking ? null : _pickFromDevice,
                  child: Text(
                    _picking ? 'در حال باز کردن...' : 'انتخاب از دستگاه',
                  ),
                ),
              ),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
        // Footer
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: SafeArea(
            top: false,
            child: AppButton(
              variant: AppButtonVariant.primary,
              block: true,
              large: true,
              icon: AppIconName.send,
              onPressed: _selected.isEmpty ? null : _confirm,
              child: Text(
                items.isEmpty
                    ? 'موردی انتخاب نشده'
                    : '${widget.device != null ? "ارسال" : "ادامه با"} ${toFa(items.length)} مورد · ${formatBytes(totalBytes)}',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final tabs = _tabs;
    if (_tab >= tabs.length) return const SizedBox.shrink();
    final def = tabs[_tab];
    final items = _contentCache[def.kind];
    if (items == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (def.view == _ViewType.file) {
      return _FileList(
        items: items,
        selected: _selected,
        onToggle: _toggle,
        isApp: def.kind == ContentKind.app,
      );
    }
    return _MediaGrid(
      items: items,
      kind: def.kind,
      selected: _selected,
      onToggle: _toggle,
    );
  }
}

enum _ViewType { media, file }

class _TabDef {
  const _TabDef({required this.kind, required this.view, required this.seg});
  final ContentKind kind;
  final _ViewType view;
  final SegmentedItem seg;
}

List<_TabDef> _tabDefs(String deviceType) {
  final isDesktop = deviceType == 'laptop' || deviceType == 'desktop';
  final isServer = deviceType == 'server';
  final isAndroid = !isDesktop && !isServer && Platform.isAndroid;

  if (isServer) {
    return const [
      _TabDef(
        kind: ContentKind.doc,
        view: _ViewType.file,
        seg: SegmentedItem(label: 'فایل', icon: AppIconName.file),
      ),
      _TabDef(
        kind: ContentKind.archive,
        view: _ViewType.file,
        seg: SegmentedItem(label: 'بایگانی', icon: AppIconName.archive),
      ),
    ];
  }

  if (isDesktop) {
    return const [
      _TabDef(
        kind: ContentKind.doc,
        view: _ViewType.file,
        seg: SegmentedItem(label: 'فایل', icon: AppIconName.file),
      ),
      _TabDef(
        kind: ContentKind.image,
        view: _ViewType.media,
        seg: SegmentedItem(label: 'عکس', icon: AppIconName.image),
      ),
      _TabDef(
        kind: ContentKind.video,
        view: _ViewType.media,
        seg: SegmentedItem(label: 'فیلم', icon: AppIconName.video),
      ),
      _TabDef(
        kind: ContentKind.music,
        view: _ViewType.file,
        seg: SegmentedItem(label: 'موزیک', icon: AppIconName.music),
      ),
    ];
  }

  return [
    const _TabDef(
      kind: ContentKind.image,
      view: _ViewType.media,
      seg: SegmentedItem(label: 'عکس', icon: AppIconName.image),
    ),
    const _TabDef(
      kind: ContentKind.video,
      view: _ViewType.media,
      seg: SegmentedItem(label: 'فیلم', icon: AppIconName.video),
    ),
    const _TabDef(
      kind: ContentKind.doc,
      view: _ViewType.file,
      seg: SegmentedItem(label: 'فایل', icon: AppIconName.file),
    ),
    const _TabDef(
      kind: ContentKind.music,
      view: _ViewType.file,
      seg: SegmentedItem(label: 'موزیک', icon: AppIconName.music),
    ),
    if (isAndroid)
      const _TabDef(
        kind: ContentKind.app,
        view: _ViewType.file,
        seg: SegmentedItem(label: 'برنامه', icon: AppIconName.apps),
      ),
  ];
}

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({
    required this.items,
    required this.kind,
    required this.selected,
    required this.onToggle,
  });

  final List<ContentItem> items;
  final ContentKind kind;
  final Map<String, ContentItem> selected;
  final ValueChanged<ContentItem> onToggle;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      children: [
        for (final m in items)
          _MediaTile(
            item: m,
            kind: kind,
            selected: selected.containsKey(m.key),
            onTap: () => onToggle(m),
          ),
      ],
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.item,
    required this.kind,
    required this.selected,
    required this.onTap,
  });

  final ContentItem item;
  final ContentKind kind;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 0.92 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: selected
                      ? Border.all(color: c.primary, width: 3)
                      : Border.all(color: c.border, width: 1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: _buildPreview(),
              ),
            ),
            if (kind == ContentKind.video)
              const Positioned.fill(
                child: Center(
                  child: AppIcon(
                    AppIconName.video,
                    size: 26,
                    color: Colors.black38,
                  ),
                ),
              ),
            if (kind == ContentKind.video && item.duration != null)
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.duration!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 7,
              right: 7,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected
                      ? c.primary
                      : Colors.black.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: selected
                    ? const Center(
                        child: AppIcon(
                          AppIconName.checkbold,
                          size: 14,
                          stroke: 3,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (kind == ContentKind.image) {
      final file = File(item.key);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              StripePlaceholder(hue: item.hue, label: item.label),
        );
      }
    }
    return StripePlaceholder(hue: item.hue, label: item.label);
  }
}

class _FileList extends StatelessWidget {
  const _FileList({
    required this.items,
    required this.selected,
    required this.onToggle,
    this.isApp = false,
  });

  final List<ContentItem> items;
  final Map<String, ContentItem> selected;
  final ValueChanged<ContentItem> onToggle;
  final bool isApp;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
      children: [
        for (final f in items)
          _FileRow(
            item: f,
            selected: selected.containsKey(f.key),
            isApp: isApp,
            onTap: () => onToggle(f),
          ),
      ],
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.item,
    required this.selected,
    required this.onTap,
    this.isApp = false,
  });

  final ContentItem item;
  final bool selected;
  final VoidCallback onTap;
  final bool isApp;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppGradients.hue(item.hue),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: AppIcon(
                  item.icon,
                  size: 22,
                  stroke: 2,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (isApp && item.version != null) ...[
                        Text(
                          'نسخه ${item.version}',
                          style: AppTextStyles.fileSub.copyWith(color: c.muted),
                        ),
                        const Text(' · ', style: AppTextStyles.fileSub),
                      ],
                      Text(
                        item.size,
                        style: AppTextStyles.fileSub.copyWith(color: c.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? c.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? c.primary : c.borderStrong,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Center(
                      child: AppIcon(
                        AppIconName.checkbold,
                        size: 15,
                        stroke: 3,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
