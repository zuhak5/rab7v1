import '../repositories/rides_repository.dart';

class CancelRideRequestUseCase {
  const CancelRideRequestUseCase(this._repository);

  final RidesRepository _repository;

  Future<void> call(String requestId) {
    return _repository.cancelRideRequest(requestId);
  }
}
