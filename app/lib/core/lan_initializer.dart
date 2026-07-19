import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/discovery/presentation/providers/identity_provider.dart';
import '../features/settings/presentation/providers/preferences_provider.dart';
import 'providers/repository_providers.dart';

/// Keeps the LAN service synchronized with persisted identity and settings.
class LanInitializer extends ConsumerStatefulWidget {
  const LanInitializer({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<LanInitializer> createState() => _LanInitializerState();
}

class _LanInitializerState extends ConsumerState<LanInitializer> {
  String _lastConfiguration = '';

  @override
  Widget build(BuildContext context) {
    final identity = ref.watch(identityProvider);
    final preferences = ref.watch(preferencesProvider);
    final configuration = [
      identity.id,
      identity.name,
      identity.platform,
      identity.code,
      identity.hue,
      preferences.visible,
      preferences.savePath,
    ].join('|');

    if (configuration != _lastConfiguration) {
      _lastConfiguration = configuration;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || identity.id.isEmpty) return;
        final lan = ref.read(lanServiceProvider);
        lan.configure(
          id: identity.id,
          name: identity.name,
          platform: identity.platform,
          code: identity.code,
          hue: identity.hue,
          visible: preferences.visible,
          savePath: preferences.savePath,
        );
        unawaited(lan.start().catchError((_) {}));
      });
    }
    return widget.child;
  }
}
