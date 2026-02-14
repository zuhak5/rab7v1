import '../../domain/entities/driver_location.dart';
import '../../domain/entities/ride.dart';
import '../../domain/entities/ride_request.dart';
import '../../domain/repositories/rides_repository.dart';
import '../datasources/rides_supabase_datasource.dart';
import '../mappers/ride_mapper.dart';
import '../mappers/ride_request_mapper.dart';

class RidesRepositoryImpl implements RidesRepository {
  RidesRepositoryImpl({
    required RidesSupabaseDataSource dataSource,
    required RideRequestMapper rideRequestMapper,
    required RideMapper rideMapper,
  }) : _dataSource = dataSource,
       _rideRequestMapper = rideRequestMapper,
       _rideMapper = rideMapper;

  final RidesSupabaseDataSource _dataSource;
  final RideRequestMapper _rideRequestMapper;
  final RideMapper _rideMapper;

  @override
  Future<void> cancelRideRequest(String requestId) {
    return _dataSource.cancelRideRequest(requestId);
  }

  @override
  Future<RideRequestEntity> createRideRequest(
    CreateRideRequestInput input,
  ) async {
    final response = await _dataSource.createRideRequest(
      pickupLat: input.pickupLat,
      pickupLng: input.pickupLng,
      dropoffLat: input.dropoffLat,
      dropoffLng: input.dropoffLng,
      pickupAddress: input.pickupAddress,
      dropoffAddress: input.dropoffAddress,
      productCode: input.productCode,
      paymentMethod: input.paymentMethod,
    );

    return _rideRequestMapper.fromMap(response);
  }

  @override
  Future<List<RideRequestEntity>> listRideRequests() async {
    final response = await _dataSource.listRideRequests();
    return response.map(_rideRequestMapper.fromMap).toList(growable: false);
  }

  @override
  Future<void> triggerMatchRide(String requestId) {
    return _dataSource.triggerMatchRide(requestId);
  }

  @override
  Stream<DriverLocationEntity?> watchDriverLocation(String driverId) {
    return _dataSource
        .watchDriverLocation(driverId)
        .map(
          (payload) => payload == null
              ? null
              : _rideRequestMapper.driverLocationFromMap(payload),
        );
  }

  @override
  Stream<RideEntity?> watchRideByRequest(String requestId) {
    return _dataSource
        .watchRideByRequest(requestId)
        .map(
          (payload) => payload == null ? null : _rideMapper.fromMap(payload),
        );
  }

  @override
  Stream<RideRequestEntity?> watchRideRequest(String requestId) {
    return _dataSource
        .watchRideRequest(requestId)
        .map(
          (payload) =>
              payload == null ? null : _rideRequestMapper.fromMap(payload),
        );
  }
}
