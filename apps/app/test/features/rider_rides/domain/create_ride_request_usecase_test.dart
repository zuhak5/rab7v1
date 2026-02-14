import 'package:flutter_test/flutter_test.dart';
import 'package:rideiq_app/core/error/app_exception.dart';
import 'package:rideiq_app/features/rider_rides/domain/entities/driver_location.dart';
import 'package:rideiq_app/features/rider_rides/domain/entities/ride.dart';
import 'package:rideiq_app/features/rider_rides/domain/entities/ride_request.dart';
import 'package:rideiq_app/features/rider_rides/domain/repositories/rides_repository.dart';
import 'package:rideiq_app/features/rider_rides/domain/usecases/create_ride_request_usecase.dart';

class _FakeRidesRepository implements RidesRepository {
  _FakeRidesRepository({
    this.failWithQuoteError = false,
    this.failWithGenericError = false,
  });

  final bool failWithQuoteError;
  final bool failWithGenericError;
  CreateRideRequestInput? capturedInput;

  @override
  Future<RideRequestEntity> createRideRequest(
    CreateRideRequestInput input,
  ) async {
    capturedInput = input;
    if (failWithQuoteError) {
      throw StateError('fare-engine response did not include quote_id');
    }
    if (failWithGenericError) {
      throw const FormatException('invalid schema contract mapping');
    }

    return RideRequestEntity(
      id: 'request-1',
      status: 'requested',
      pickupLat: input.pickupLat,
      pickupLng: input.pickupLng,
      dropoffLat: input.dropoffLat,
      dropoffLng: input.dropoffLng,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
      pickupAddress: input.pickupAddress,
      dropoffAddress: input.dropoffAddress,
      productCode: input.productCode,
      fareQuoteId: 'quote-1',
    );
  }

  @override
  Future<void> cancelRideRequest(String requestId) async {}

  @override
  Future<List<RideRequestEntity>> listRideRequests() async {
    return const [];
  }

  @override
  Future<void> triggerMatchRide(String requestId) async {}

  @override
  Stream<DriverLocationEntity?> watchDriverLocation(String driverId) {
    return const Stream<DriverLocationEntity?>.empty();
  }

  @override
  Stream<RideEntity?> watchRideByRequest(String requestId) {
    return const Stream<RideEntity?>.empty();
  }

  @override
  Stream<RideRequestEntity?> watchRideRequest(String requestId) {
    return const Stream<RideRequestEntity?>.empty();
  }
}

void main() {
  group('CreateRideRequestUseCase', () {
    test('returns created ride request and forwards input', () async {
      final repository = _FakeRidesRepository();
      final useCase = CreateRideRequestUseCase(repository);
      const input = CreateRideRequestInput(
        pickupLat: 33.3152,
        pickupLng: 44.3661,
        dropoffLat: 33.2989,
        dropoffLng: 44.3473,
        pickupAddress: 'Baghdad Pickup',
        dropoffAddress: 'Baghdad Dropoff',
      );

      final result = await useCase(input);

      expect(result.id, 'request-1');
      expect(repository.capturedInput, input);
    });

    test(
      'maps fare quote errors into deterministic domain exception',
      () async {
        final repository = _FakeRidesRepository(failWithQuoteError: true);
        final useCase = CreateRideRequestUseCase(repository);

        const input = CreateRideRequestInput(
          pickupLat: 33.3152,
          pickupLng: 44.3661,
          dropoffLat: 33.2989,
          dropoffLng: 44.3473,
        );

        expect(
          () => useCase(input),
          throwsA(
            isA<AppException>().having(
              (e) => e.code,
              'code',
              'FARE_QUOTE_FAILED',
            ),
          ),
        );
      },
    );

    test('maps non-quote failures into CREATE_RIDE_REQUEST_FAILED', () async {
      final repository = _FakeRidesRepository(failWithGenericError: true);
      final useCase = CreateRideRequestUseCase(repository);

      const input = CreateRideRequestInput(
        pickupLat: 33.3152,
        pickupLng: 44.3661,
        dropoffLat: 33.2989,
        dropoffLng: 44.3473,
      );

      expect(
        () => useCase(input),
        throwsA(
          isA<AppException>().having(
            (e) => e.code,
            'code',
            'CREATE_RIDE_REQUEST_FAILED',
          ),
        ),
      );
    });
  });
}
