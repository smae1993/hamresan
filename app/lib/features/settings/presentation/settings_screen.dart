/// Settings screen — همرسان.
///
/// Recreates `Settings` from `screens_misc.jsx`: profile card (editable name
/// + hue), appearance (theme segmented), visibility/auto-accept toggles,
/// save location, network info, and a "test receive" action.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_switch.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/segmented_control.dart';
import '../../discovery/presentation/providers/identity_provider.dart';
import '../domain/entities/app_preferences.dart';
import 'providers/network_info_provider.dart';
import 'providers/preferences_provider.dart';
import 'widgets/directory_picker.dart';
import 'widgets/profile_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(identityProvider);
    final prefs = ref.watch(preferencesProvider);
    final netAsync = ref.watch(networkInfoProvider);

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            4,
            20,
            0,
          ).copyWith(bottom: AppDimensions.navHeight + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppTopBar(
                title: 'تنظیمات',
                subtitle: 'دستگاه و ترجیحات تو',
              ),
              ProfileCard(
                identity: me,
                onChanged: (next) =>
                    ref.read(identityProvider.notifier).update(next),
              ),
              _SectionHeader2(title: 'ظاهر'),
              _SettingsGroup(
                children: [
                  _SettingsRow(
                    icon: prefs.theme == AppThemeMode.dark
                        ? AppIconName.moon
                        : AppIconName.sun,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('پوسته', style: AppTextStyles.setLabel),
                          const SizedBox(height: 10),
                          SegmentedControl(
                            items: const [
                              SegmentedItem(
                                label: 'روشن',
                                icon: AppIconName.sun,
                              ),
                              SegmentedItem(
                                label: 'تیره',
                                icon: AppIconName.moon,
                              ),
                            ],
                            selected: prefs.theme == AppThemeMode.dark ? 1 : 0,
                            onChanged: (i) => ref
                                .read(preferencesProvider.notifier)
                                .setTheme(
                                  i == 1
                                      ? AppThemeMode.dark
                                      : AppThemeMode.light,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              _SectionHeader2(title: 'نمایان بودن و انتقال'),
              _SettingsGroup(
                children: [
                  _ToggleRow(
                    icon: AppIconName.eye,
                    label: 'قابل مشاهده برای اطراف',
                    caption: 'دستگاه‌های شبکه می‌توانند تو را ببینند',
                    value: prefs.visible,
                    onChanged: (v) =>
                        ref.read(preferencesProvider.notifier).setVisible(v),
                  ),
                  _NavRow(
                    icon: AppIconName.folder,
                    label: 'محل ذخیره',
                    value: prefs.savePath,
                    onTap: () async {
                      final cur = prefs.savePath;
                      final initial = cur.isNotEmpty && cur.startsWith('/')
                          ? cur
                          : null;
                      final path = await showDirectoryPicker(
                        context,
                        initial: initial,
                      );
                      if (path != null && context.mounted) {
                        await ref
                            .read(preferencesProvider.notifier)
                            .setSavePath(path);
                      }
                    },
                  ),
                ],
              ),
              _SectionHeader2(title: 'شبکه'),
              _SettingsGroup(
                children: [
                  netAsync.when(
                    data: (net) => _InfoRow(
                      icon: AppIconName.wifi,
                      label: 'شبکه',
                      value: net.ssid,
                    ),
                    loading: () => _InfoRow(
                      icon: AppIconName.wifi,
                      label: 'شبکه',
                      value: 'در حال تشخیص...',
                    ),
                    error: (_, __) => _InfoRow(
                      icon: AppIconName.wifi,
                      label: 'شبکه',
                      value: 'خطا در تشخیص',
                    ),
                  ),
                  netAsync.when(
                    data: (net) => _InfoRow(
                      icon: AppIconName.pin,
                      label: 'نشانی IP',
                      value: net.ip,
                    ),
                    loading: () => _InfoRow(
                      icon: AppIconName.pin,
                      label: 'نشانی IP',
                      value: 'در حال تشخیص...',
                    ),
                    error: (_, __) => _InfoRow(
                      icon: AppIconName.pin,
                      label: 'نشانی IP',
                      value: 'خطا در تشخیص',
                    ),
                  ),
                  _InfoRow(
                    icon: AppIconName.shield,
                    label: 'بررسی صحت فایل',
                    valueWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppIcon(
                          AppIconName.check,
                          size: 15,
                          stroke: 2.6,
                          color: context.colors.green,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'SHA-256 فعال',
                          style: AppTextStyles.setVal.copyWith(
                            color: context.colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _SectionHeader2(title: 'بیشتر'),
              _SettingsGroup(
                children: [
                  _InfoRow(
                    icon: AppIconName.info,
                    label: 'نسخه',
                    value: '۱٫۰٫۰',
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Center(
                child: Column(
                  children: [
                    const BrandLogo(size: 34),
                    const SizedBox(height: 8),
                    Text(
                      'همرسان · ساخته‌شده برای اشتراک بی‌دردسر',
                      style: AppTextStyles.setCap.copyWith(
                        color: context.colors.faint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader2 extends StatelessWidget {
  const _SectionHeader2({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 24, 2, 13),
      child: Text(title, style: AppTextStyles.sectionHead),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: c.border),
        boxShadow: AppShadows.sm(c),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: c.border,
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.icon, required this.child});
  final AppIconName icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SetIcon(icon: icon),
          const SizedBox(width: 14),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.caption,
    required this.value,
    required this.onChanged,
  });
  final AppIconName icon;
  final String label;
  final String caption;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          _SetIcon(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.setLabel),
                const SizedBox(height: 2),
                Text(
                  caption,
                  style: AppTextStyles.setCap.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ],
            ),
          ),
          AppSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });
  final AppIconName icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          _SetIcon(icon: icon),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: AppTextStyles.setLabel)),
          if (valueWidget != null)
            valueWidget!
          else if (value != null)
            Text(
              value!,
              style: AppTextStyles.setVal.copyWith(color: context.colors.muted),
            ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.label,
    this.caption,
    this.value,
    required this.onTap,
    this.tintedIcon = false,
  });
  final AppIconName icon;
  final String label;
  final String? caption;
  final String? value;
  final VoidCallback onTap;
  final bool tintedIcon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            _SetIcon(icon: icon, tinted: tintedIcon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.setLabel),
                  if (caption != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      caption!,
                      style: AppTextStyles.setCap.copyWith(color: c.muted),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: AppTextStyles.setVal.copyWith(color: c.muted),
              ),
            const SizedBox(width: 4),
            AppIcon(AppIconName.back, size: 17, color: c.faint),
          ],
        ),
      ),
    );
  }
}

class _SetIcon extends StatelessWidget {
  const _SetIcon({required this.icon, this.tinted = false});
  final AppIconName icon;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: tinted ? c.primarySoft : c.surface2,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Center(
        child: AppIcon(icon, size: 19, color: tinted ? c.primary : c.primary),
      ),
    );
  }
}
