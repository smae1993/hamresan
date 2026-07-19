import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/device.dart';

final discoveryProvider = StreamProvider.autoDispose<List<Device>>((
  ref,
) async* {
  final repo = ref.watch(deviceRepositoryProvider);
  yield* repo.watchNearbyDevices();
});
