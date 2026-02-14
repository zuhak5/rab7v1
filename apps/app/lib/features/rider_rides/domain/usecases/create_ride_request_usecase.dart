import '../../../../core/error/app_exception.dart';
import '../entities/ride_request.dart';
import '../repositories/rides_repository.dart';

class CreateRideRequestUseCase {
  const CreateRideRequestUseCase(this._repository);

  final RidesRepository _repository;

  Future<RideRequestEntity> call(CreateRideRequestInput input) async {
    try {
      return await _repository.createRideRequest(input);
    } catch (error) {
      final message = error.toString();
      if (message.contains('quote_id') || message.contains('fare-engine')) {
        throw const AppException(
          'Unable to create ride request because fare quote failed.',
          code: 'FARE_QUOTE_FAILED',
        );
      }
      throw const AppException(
        'Unable to create ride request.',
        code: 'CREATE_RIDE_REQUEST_FAILED',
      );
    }
  }
}
