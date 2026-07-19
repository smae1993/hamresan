/// Home / Discovery screen — همرسان.
///
/// Recreates `Home` from `screens_home.jsx`: top bar (logo, title, bell, theme),
/// identity card with radar, nearby-device grid, and a FAB to start sending.
/// Drives the transfer flow overlays (picker / recipient / incoming / transfer).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/fa_digits.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/section_header.dart';
import '../../settings/domain/entities/app_preferences.dart';
import '../../settings/presentation/providers/preferences_provider.dart';
import '../../transfer/presentation/providers/transfer_provider.dart';
import '../domain/entities/device.dart';
import '../domain/entities/identity.dart';
import '../data/lan_service.dart';
import '../presentation/providers/discovery_provider.dart';
import '../presentation/providers/identity_provider.dart';
import 'widgets/device_card.dart';
import 'widgets/identity_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(discoveryProvider);
    final me = ref.watch(identityProvider);
    final prefs = ref.watch(preferencesProvider);
    final transferFlow = ref.watch(transferFlowProvider);
    final lanStatus = ref
        .watch(lanStatusProvider)
        .maybeWhen(data: (status) => status, orElse: () => null);

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                AppTopBar(
                  leading: const BrandLogo(size: 40),
                  title: 'همرسان',
                  subtitle: lanStatus == LanStatus.failed
                      ? 'خطا در دسترسی به شبکهٔ محلی'
                      : '${toFa(devicesAsync.maybeWhen(data: (d) => d.length, orElse: () => 0))} دستگاه در شبکه',
                  actions: [
                    IconButtonCircle(
                      icon: prefs.theme == AppThemeMode.dark
                          ? AppIconName.sun
                          : AppIconName.moon,
                      onPressed: () =>
                          ref.read(preferencesProvider.notifier).toggleTheme(),
                    ),
                  ],
                ),
                Expanded(
                  child: _Body(
                    me: me,
                    devices: devicesAsync.maybeWhen(
                      data: (d) => d,
                      orElse: () => const [],
                    ),
                    onPickDevice: (d) => ref
                        .read(transferFlowProvider.notifier)
                        .startSendToDevice(d),
                    onSendFlow: () =>
                        ref.read(transferFlowProvider.notifier).startSendFlow(),
                  ),
                ),
              ],
            ),
            // FAB (positioned above bottom nav)
            Positioned(
              bottom: AppDimensions.navHeight + 16,
              left: 0,
              right: 0,
              child: Center(
                child: AppFab(
                  label: 'ارسال محتوا',
                  icon: AppIconName.send,
                  onPressed: transferFlow is TransferIdle
                      ? () => ref
                            .read(transferFlowProvider.notifier)
                            .startSendFlow()
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.me,
    required this.devices,
    required this.onPickDevice,
    required this.onSendFlow,
  });

  final Identity me;
  final List<Device> devices;
  final ValueChanged<Device> onPickDevice;
  final VoidCallback onSendFlow;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        0,
      ).copyWith(bottom: AppDimensions.navHeight + 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IdentityCard(identity: me),
          SectionHeader(
            title: 'دستگاه‌های اطراف',
            count: devices.length,
            trailing: const _ScanningLabel(),
          ),
          if (devices.isEmpty)
            _EmptyState()
          else
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.92,
              children: [
                for (var i = 0; i < devices.length; i++)
                  DeviceCard(
                    device: devices[i],
                    index: i,
                    onTap: () => onPickDevice(devices[i]),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          AppIcon(AppIconName.wifi, size: 48, color: c.faint),
          const SizedBox(height: 16),
          Text(
            'هیچ دستگاهی پیدا نشد',
            style: AppTextStyles.setLabel.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'مطمئن شو همه دستگاه‌ها به یک شبکه وصل هستند\nو برنامه در آن‌ها باز است.',
            textAlign: TextAlign.center,
            style: AppTextStyles.setCap.copyWith(color: c.muted, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _ScanningLabel extends StatelessWidget {
  const _ScanningLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'در حال جستجو',
          style: AppTextStyles.scanning.copyWith(color: context.colors.muted),
        ),
        const SizedBox(width: 5),
        const _BobDot(delay: 0),
        const SizedBox(width: 2),
        const _BobDot(delay: 0.2),
        const SizedBox(width: 2),
        const _BobDot(delay: 0.4),
      ],
    );
  }
}

class _BobDot extends StatefulWidget {
  const _BobDot({required this.delay});
  final double delay;

  @override
  State<_BobDot> createState() => _BobDotState();
}

class _BobDotState extends State<_BobDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = (_c.value + widget.delay) % 1.0;
        double opacity, dy;
        if (t < 0.5) {
          opacity = 0.25 + 0.75 * (t / 0.5);
          dy = -3 * (t / 0.5);
        } else {
          opacity = 1 - 0.75 * ((t - 0.5) / 0.5);
          dy = -3 + 3 * ((t - 0.5) / 0.5);
        }
        return Transform.translate(
          offset: Offset(0, dy),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
