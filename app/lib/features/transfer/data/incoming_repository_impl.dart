import 'dart:async';
import '../domain/entities/incoming_request.dart';
import '../domain/repositories/incoming_repository.dart';
import '../../discovery/data/lan_service.dart';

class IncomingRepositoryImpl implements IncomingRepository {
  IncomingRepositoryImpl(this._lan);

  final LanService _lan;

  @override
  Stream<IncomingRequest?> watch() => _lan.incomingStream;
}
