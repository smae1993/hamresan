import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../domain/repositories/network_repository.dart';

final networkInfoProvider = FutureProvider<NetworkInfo>((ref) async {
  return ref.watch(networkRepositoryProvider).getInfo();
});
