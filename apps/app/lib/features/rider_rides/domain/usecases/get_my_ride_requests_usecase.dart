import '../entities/ride_request.dart';
import '../repositories/rides_repository.dart';

class GetMyRideRequestsUseCase {
  const GetMyRideRequestsUseCase(this._repository);

  final RidesRepository _repository;

  Future<List<RideRequestEntity>> call() {
    return _repository.listRideRequests();
  }
}
