import '../entities/incoming_request.dart';

abstract class IncomingRepository {
  Stream<IncomingRequest?> watch();
}
