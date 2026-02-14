import '../entities/ride.dart';
import '../repositories/rides_repository.dart';

class WatchActiveRideUseCase {
  const WatchActiveRideUseCase(this._repository);

  final RidesRepository _repository;

  Stream<RideEntity?> call(String requestId) {
    return _repository.watchRideByRequest(requestId);
  }
}
