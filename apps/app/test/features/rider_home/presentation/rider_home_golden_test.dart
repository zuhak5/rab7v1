import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rideiq_app/app/di/providers.dart';
import 'package:rideiq_app/app/theme/app_theme.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/destination_resolution.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/rider_profile.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/saved_place.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/wallet_account.dart';
import 'package:rideiq_app/features/rider_home/domain/repositories/rider_home_repository.dart';
import 'package:rideiq_app/features/rider_home/presentation/pages/finding_driver_page.dart';
import 'package:rideiq_app/features/rider_home/presentation/pages/rider_home_page.dart';
import 'package:rideiq_app/features/rider_home/presentation/pages/trip_options_page.dart';
import 'package:rideiq_app/features/rider_home/presentation/viewmodels/rider_home_controller.dart';
import 'package:rideiq_app/features/rider_home/presentation/viewmodels/rider_home_state.dart';
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
      id: 'req-1',
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
    return const RiderProfileEntity(id: 'user-1');
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
      label: 'Baghdad Mall',
      latitude: 33.3152,
      longitude: 44.3661,
    );
  }
}

Widget _wrap(Widget child, {ThemeMode themeMode = ThemeMode.light}) {
  return ProviderScope(
    overrides: <Override>[
      ridesRepositoryProvider.overrideWithValue(_FakeRidesRepository()),
      riderHomeRepositoryProvider.overrideWithValue(_FakeRiderHomeRepository()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: child,
    ),
  );
}

Future<void> _setTestScreenSize(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpHome(
  WidgetTester tester, {
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await _setTestScreenSize(tester);
  await tester.pumpWidget(_wrap(const RiderHomePage(), themeMode: themeMode));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('golden home default light 390x844', (tester) async {
    await _pumpHome(tester);
    await expectLater(
      find.byType(RiderHomePage),
      matchesGoldenFile('goldens/rider_home_default_light.png'),
    );
  });

  testWidgets('golden home default dark 390x844', (tester) async {
    await _pumpHome(tester, themeMode: ThemeMode.dark);
    await expectLater(
      find.byType(RiderHomePage),
      matchesGoldenFile('goldens/rider_home_default_dark.png'),
    );
  });

  testWidgets('golden home account sheet open 390x844', (tester) async {
    await _pumpHome(tester);
    final context = tester.element(find.byType(RiderHomePage));
    final container = ProviderScope.containerOf(context);
    container.read(riderHomeControllerProvider.notifier).openAccountSheet();
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(RiderHomePage),
      matchesGoldenFile('goldens/rider_home_account_sheet_open.png'),
    );
  });

  testWidgets('golden home pickup sheet search mode 390x844', (tester) async {
    await _pumpHome(tester);
    final context = tester.element(find.byType(RiderHomePage));
    final container = ProviderScope.containerOf(context);
    final notifier = container.read(riderHomeControllerProvider.notifier);
    notifier.openPickupSheet();
    notifier.setPickupMode(PickupSheetMode.search);
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(RiderHomePage),
      matchesGoldenFile('goldens/rider_home_pickup_sheet_search.png'),
    );
  });

  testWidgets('golden home schedule panel open 390x844', (tester) async {
    await _pumpHome(tester);
    final context = tester.element(find.byType(RiderHomePage));
    final container = ProviderScope.containerOf(context);
    container
        .read(riderHomeControllerProvider.notifier)
        .setSchedulePanelOpen(true);
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(RiderHomePage),
      matchesGoldenFile('goldens/rider_home_schedule_panel_open.png'),
    );
  });

  testWidgets('golden home place edit open 390x844', (tester) async {
    await _pumpHome(tester);
    final context = tester.element(find.byType(RiderHomePage));
    final container = ProviderScope.containerOf(context);
    container.read(riderHomeControllerProvider.notifier).openPlaceEdit('home');
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(RiderHomePage),
      matchesGoldenFile('goldens/rider_home_place_edit_open.png'),
    );
  });

  testWidgets('golden trip options default 390x844', (tester) async {
    await _setTestScreenSize(tester);
    await tester.pumpWidget(_wrap(const TripOptionsPage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TripOptionsPage),
      matchesGoldenFile('goldens/trip_options_default.png'),
    );
  });

  testWidgets('golden finding driver default 390x844', (tester) async {
    await _setTestScreenSize(tester);
    await tester.pumpWidget(_wrap(const FindingDriverPage(requestId: 'req-1')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(FindingDriverPage),
      matchesGoldenFile('goldens/finding_driver_default.png'),
    );
  });
}
