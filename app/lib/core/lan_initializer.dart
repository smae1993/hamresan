import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/discovery/presentation/providers/identity_provider.dart';
import 'providers/repository_providers.dart';

class LanInitializer extends ConsumerStatefulWidget {
  const LanInitializer({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<LanInitializer> createState() => _LanInitializerState();
}

class _LanInitializerState extends ConsumerState<LanInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final identity = ref.read(identityProvider);
    final lan = ref.read(lanServiceProvider);
    lan.init(
      id: identity.code.isNotEmpty ? identity.code : identity.name,
      name: identity.name,
      platform: identity.platform,
      hue: identity.hue,
    );
    await lan.start();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
