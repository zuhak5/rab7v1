import '../entities/driver_location.dart';
import '../entities/ride.dart';
import '../entities/ride_request.dart';

class CreateRideRequestInput {
  const CreateRideRequestInput({
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    this.pickupAddress,
    this.dropoffAddress,
    this.productCode = 'standard',
    this.paymentMethod = 'wallet',
  });

  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final String? pickupAddress;
  final String? dropoffAddress;
  final String productCode;
  final String paymentMethod;
}

abstract class RidesRepository {
  Future<List<RideRequestEntity>> listRideRequests();

  Future<RideRequestEntity> createRideRequest(CreateRideRequestInput input);

  Future<void> cancelRideRequest(String requestId);

  Future<void> triggerMatchRide(String requestId);

  Stream<RideRequestEntity?> watchRideRequest(String requestId);

  Stream<RideEntity?> watchRideByRequest(String requestId);

  Stream<DriverLocationEntity?> watchDriverLocation(String driverId);
}
