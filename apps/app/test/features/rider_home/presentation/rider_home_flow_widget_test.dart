import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rideiq_app/app/di/providers.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/destination_resolution.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/rider_profile.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/saved_place.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/wallet_account.dart';
import 'package:rideiq_app/features/rider_home/domain/repositories/rider_home_repository.dart';
import 'package:rideiq_app/features/rider_home/presentation/pages/rider_home_page.dart';
import 'package:rideiq_app/features/rider_home/presentation/pages/trip_options_page.dart';
import 'package:rideiq_app/features/rider_rides/domain/entities/driver_location.dart';
import 'package:rideiq_app/features/rider_rides/domain/entities/ride.dart';
import 'package:rideiq_app/features/rider_rides/domain/entities/ride_request.dart';
import 'package:rideiq_app/features/rider_rides/domain/repositories/rides_repository.dart';

class _FakeRidesRepository implements RidesRepository {
  @override
  Future<void> cancelRideRequest(String requestId) async {}

  @override
  Future<RideRequestEntity> createRideRequest(
    CreateRideRequestInput input,
  ) async {
    return RideRequestEntity(
      id: 'req-test',
      status: 'requested',
      pickupLat: input.pickupLat,
      pickupLng: input.pickupLng,
      dropoffLat: input.dropoffLat,
      dropoffLng: input.dropoffLng,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
  }

  @override
  Future<List<RideRequestEntity>> listRideRequests() async {
    return const <RideRequestEntity>[];
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

class _FakeRiderHomeRepository implements RiderHomeRepository {
  @override
  Future<RiderProfileEntity?> getProfile() async {
    return const RiderProfileEntity(
      id: 'user-1',
      displayName: 'Tester',
      phoneE164: '+9647000000000',
    );
  }

  @override
  Future<List<SavedPlaceEntity>> getSavedPlaces() async {
    return const <SavedPlaceEntity>[];
  }

  @override
  Future<WalletAccountEntity> getWalletAccount() async {
    return WalletAccountEntity(
      balanceIqd: 12000,
      currency: 'IQD',
      updatedAt: DateTime.utc(2026, 1, 1),
    );
  }

  @override
  Future<void> savePlace(SavedPlaceEntity place) async {}

  @override
  Future<DestinationResolutionEntity?> resolveDestination(String query) async {
    return const DestinationResolutionEntity(
      label: 'Mansour Mall',
      latitude: 33.3012,
      longitude: 44.3781,
    );
  }
}

void main() {
  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: <Override>[
        ridesRepositoryProvider.overrideWithValue(_FakeRidesRepository()),
        riderHomeRepositoryProvider.overrideWithValue(
          _FakeRiderHomeRepository(),
        ),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('home trip button is gated by destination input', (tester) async {
    await tester.pumpWidget(wrap(const RiderHomePage()));
    await tester.pumpAndSettle();

    final finder = find.byKey(
      const ValueKey<String>('home_trip_options_button'),
    );
    FilledButton button = tester.widget<FilledButton>(finder);
    expect(button.onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey<String>('home_destination_input')),
      'Mansour Mall',
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    button = tester.widget<FilledButton>(finder);
    expect(button.onPressed, isNotNull);
  });

  testWidgets('trip options updates CTA price on offer selection', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const TripOptionsPage()));
    await tester.pumpAndSettle();

    var priceText = tester.widget<Text>(
      find.byKey(const ValueKey<String>('trip_cta_price_text')),
    );
    expect(priceText.data, contains('5,000'));

    await tester.tap(find.byKey(const ValueKey<String>('trip_offer_comfort')));
    await tester.pumpAndSettle();

    priceText = tester.widget<Text>(
      find.byKey(const ValueKey<String>('trip_cta_price_text')),
    );
    expect(priceText.data, contains('8,000'));
  });

  testWidgets('home navigates to trip options route', (tester) async {
    final router = GoRouter(
      routes: <RouteBase>[
        GoRoute(path: '/', builder: (_, _) => const RiderHomePage()),
        GoRoute(
          path: '/trip-options',
          builder: (_, _) => const Scaffold(body: Text('trip-screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          ridesRepositoryProvider.overrideWithValue(_FakeRidesRepository()),
          riderHomeRepositoryProvider.overrideWithValue(
            _FakeRiderHomeRepository(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('home_destination_input')),
      'Mutanabbi Street',
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('home_trip_options_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('trip-screen'), findsOneWidget);
  });
}
