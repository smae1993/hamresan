/// Onboarding screen — همرسان.
///
/// Recreates `Onboarding` from `screens_home.jsx`: a 3-step intro
/// (radar / types / shield) with animated art, dots, and a CTA.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/buttons.dart';
import 'providers/onboarding_provider.dart';
import 'widgets/onboard_art.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _index = 0;

  static const _steps = <_ObStep>[
    _ObStep(
      title: 'همه‌چیز را در یک لحظه بفرست',
      desc:
          'عکس، فیلم، فایل و حتی برنامه‌ها را مستقیم بین دستگاه‌های نزدیک رد و بدل کن — بدون اینترنت، بدون ابر.',
      art: OnboardArtKind.radar,
    ),
    _ObStep(
      title: 'سریع، روی شبکه‌ی محلی',
      desc:
          'همرسان دستگاه‌های روی همان وای‌فای را خودش پیدا می‌کند. کافی است یکی را انتخاب کنی.',
      art: OnboardArtKind.types,
    ),
    _ObStep(
      title: 'خصوصی و امن',
      desc:
          'فایل‌ها فقط پس از تأیید تو روی شبکه‌ی محلی جابه‌جا می‌شوند و صحت آن‌ها در مقصد بررسی می‌شود.',
      art: OnboardArtKind.shield,
    ),
  ];

  void _next() {
    if (_index == _steps.length - 1) {
      ref.read(onboardingProvider.notifier).complete();
      context.go(AppRoutes.home);
    } else {
      setState(() => _index++);
    }
  }

  void _skip() {
    ref.read(onboardingProvider.notifier).complete();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final step = _steps[_index];
    final isLast = _index == _steps.length - 1;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: logo + skip
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              child: Row(
                children: [
                  const BrandLogo(size: 30),
                  const SizedBox(width: 9),
                  Text(
                    'همرسان',
                    style: AppTextStyles.idName.copyWith(fontSize: 17),
                  ),
                  const Spacer(),
                  if (!isLast)
                    AppButton(
                      variant: AppButtonVariant.ghost,
                      onPressed: _skip,
                      child: const Text('رد کردن'),
                    ),
                ],
              ),
            ),
            // Art
            Expanded(
              child: Center(
                child: OnboardArt(key: ValueKey(_index), kind: step.art),
              ),
            ),
            // Bottom content
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_steps.length, (i) {
                      final on = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3.5),
                        width: on ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: on ? c.primary : c.borderStrong,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 22),
                  _FadeText(
                    text: step.title,
                    style: AppTextStyles.obTitle,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  _FadeText(
                    text: step.desc,
                    style: AppTextStyles.obDesc.copyWith(color: c.muted),
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 26),
                  AppButton(
                    variant: AppButtonVariant.grad,
                    block: true,
                    large: true,
                    icon: AppIconName.forward,
                    onPressed: _next,
                    child: Text(isLast ? 'بزن بریم' : 'بعدی'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObStep {
  const _ObStep({required this.title, required this.desc, required this.art});
  final String title;
  final String desc;
  final OnboardArtKind art;
}

/// A text that fades up when first inserted (matches `.fade-up`).
class _FadeText extends StatefulWidget {
  const _FadeText({required this.text, required this.style, this.align});
  final String text;
  final TextStyle style;
  final TextAlign? align;

  @override
  State<_FadeText> createState() => _FadeTextState();
}

class _FadeTextState extends State<_FadeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: Text(widget.text, style: widget.style, textAlign: widget.align),
      ),
    );
  }
}
