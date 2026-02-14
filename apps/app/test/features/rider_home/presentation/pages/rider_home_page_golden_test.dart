import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rideiq_app/app/theme/app_theme.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/rider_profile.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/saved_place.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/wallet_account.dart';
import 'package:rideiq_app/features/rider_home/presentation/pages/rider_home_page.dart';
import 'package:rideiq_app/features/rider_home/presentation/viewmodels/rider_home_controller.dart';
import 'package:rideiq_app/features/rider_home/presentation/viewmodels/rider_home_data_controller.dart';
import 'package:rideiq_app/features/rider_home/presentation/viewmodels/rider_home_state.dart';
import 'package:rideiq_app/features/rider_rides/domain/entities/ride_request.dart';
import 'package:rideiq_app/features/rider_rides/presentation/viewmodels/rides_list_controller.dart';

// ---------------------------------------------------------------------------
// Fake controllers
// ---------------------------------------------------------------------------

class FakeRiderHomeController extends RiderHomeController {
  FakeRiderHomeController(this.initialState);

  final RiderHomeState initialState;

  @override
  Future<RiderHomeState> build() async => initialState;
}

class FakeSavedPlacesController extends SavedPlacesController {
  @override
  Future<Map<String, SavedPlaceEntity>> build() async {
    return {
      'home': const SavedPlaceEntity(
        id: '1',
        label: 'المنزل',
        city: 'Baghdad',
        addressLine1: 'Al-Mansour',
      ),
      'work': const SavedPlaceEntity(
        id: '2',
        label: 'العمل',
        city: 'Baghdad',
        addressLine1: 'Babylon Hotel',
      ),
    };
  }
}

class FakeRidesListController extends RidesListController {
  @override
  Future<List<RideRequestEntity>> build() async => [];
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  setUp(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  group('RiderHomePage Goldens', () {
    testWidgets('RiderHomePage - iPhone 14 (Default)', (tester) async {
      await _pumpRiderHome(tester, size: const Size(390, 844));
      await expectLater(
        find.byType(RiderHomePage),
        matchesGoldenFile('../../goldens/rider_home_page_iphone14.png'),
      );
    });

    testWidgets('RiderHomePage - Android Compact (360x800)', (tester) async {
      await _pumpRiderHome(tester, size: const Size(360, 800));
      await expectLater(
        find.byType(RiderHomePage),
        matchesGoldenFile('../../goldens/rider_home_page_compact.png'),
      );
    });

    testWidgets('RiderHomePage - iPhone SE (320x568)', (tester) async {
      await _pumpRiderHome(tester, size: const Size(320, 568));
      await expectLater(
        find.byType(RiderHomePage),
        matchesGoldenFile('../../goldens/rider_home_page_iphonese.png'),
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Future<void> _pumpRiderHome(
  WidgetTester tester, {
  RiderHomeState? homeState,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size * tester.view.devicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        riderHomeControllerProvider.overrideWith(
          () => FakeRiderHomeController(homeState ?? RiderHomeState.initial()),
        ),
        savedPlacesControllerProvider.overrideWith(
          FakeSavedPlacesController.new,
        ),
        // FutureProvider.overrideWith expects (ref) => FutureOr<T>,
        // NOT AsyncValue<T>.
        walletAccountProvider.overrideWith(
          (ref) => WalletAccountEntity(
            balanceIqd: 25000,
            currency: 'IQD',
            updatedAt: DateTime(2026, 1, 1),
          ),
        ),
        riderProfileProvider.overrideWith(
          (ref) => const RiderProfileEntity(
            id: '123',
            displayName: 'Test User',
            // null avatarUrl to avoid NetworkImage in tests
            phoneE164: '+9647700000000',
          ),
        ),
        ridesListControllerProvider.overrideWith(FakeRidesListController.new),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar')],
        locale: const Locale('ar'),
        theme: AppTheme.light,
        home: const RiderHomePage(),
      ),
    ),
  );

  await tester.pumpAndSettle();
}
