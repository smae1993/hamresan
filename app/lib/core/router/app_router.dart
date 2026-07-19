/// Application router — همرسان.
///
/// Uses a [StatefulShellRoute] for the bottom-nav tabs (home / history /
/// settings) and a redirect that gates the whole app behind onboarding.
/// The transfer overlay (sheets, incoming dialog, full-screen transfer) is
/// driven by [transferFlowProvider] and rendered above the shell, mirroring
/// the prototype's overlay-on-current-screen approach.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/discovery/presentation/home_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/transfer_flow_overlay.dart';
import 'routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<bool>(ref.read(onboardingProvider));
  ref.listen<bool>(onboardingProvider, (_, next) => refresh.value = next);
  ref.onDispose(refresh.dispose);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final onboarded = ref.read(onboardingProvider);
      final goingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!onboarded && !goingToOnboarding) return AppRoutes.onboarding;
      if (onboarded && goingToOnboarding) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _ScaffoldWithNav(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _ScaffoldWithNav extends StatelessWidget {
  const _ScaffoldWithNav({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: navigationShell),
              BottomNavBar(
                active: navigationShell.currentIndex,
                onChanged: (i) => navigationShell.goBranch(
                  i,
                  initialLocation: i == navigationShell.currentIndex,
                ),
              ),
            ],
          ),
          const TransferFlowOverlay(),
        ],
      ),
    );
  }
}
