import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/lan_initializer.dart';
import 'core/router/app_router.dart' show routerProvider;
import 'core/theme/app_theme.dart';
import 'features/settings/domain/entities/app_preferences.dart';
import 'features/settings/presentation/providers/preferences_provider.dart';

class HamresanApp extends ConsumerStatefulWidget {
  const HamresanApp({super.key});

  @override
  ConsumerState<HamresanApp> createState() => _HamresanAppState();
}

class _HamresanAppState extends ConsumerState<HamresanApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final prefs = ref.watch(preferencesProvider);

    return MaterialApp.router(
      title: 'همرسان',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: prefs.theme == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        return LanInitializer(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fa', 'IR')],
      locale: const Locale('fa', 'IR'),
    );
  }
}
