import '../repositories/rides_repository.dart';

class TriggerMatchRideUseCase {
  const TriggerMatchRideUseCase(this._repository);

  final RidesRepository _repository;

  Future<void> call(String requestId) {
    return _repository.triggerMatchRide(requestId);
  }
}
