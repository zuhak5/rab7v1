import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rideiq_app/app/di/providers.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/destination_resolution.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/rider_profile.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/saved_place.dart';
import 'package:rideiq_app/features/rider_home/domain/entities/wallet_account.dart';
import 'package:rideiq_app/features/rider_home/domain/repositories/rider_home_repository.dart';
import 'package:rideiq_app/features/rider_home/presentation/pages/rider_home_page.dart';

import '../../../test_utils/golden_harness.dart';

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

class _GoldenMapBackdrop extends StatelessWidget {
  const _GoldenMapBackdrop();

  @override
  Widget build(BuildContext context) {
    // Deterministic backdrop (maps are ignored for this reference golden).
    return const ColoredBox(color: Color(0xFFE9EDF2));
  }
}

Future<void> _setReferenceScreenSize(WidgetTester tester) async {
  tester.view.physicalSize = const Size(591, 1146);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  // This reference test is intentionally opt-in. It will fail until the UI is
  // pixel-identical to the 1.jpg-derived reference overlay.
  //
  // Run it explicitly with:
  //   flutter test --dart-define=RUN_1JPG_REFERENCE_GOLDEN=true \
  //     test/features/rider_home/presentation/rider_home_reference_1jpg_golden_test.dart
  const bool runReferenceGolden = bool.fromEnvironment(
    'RUN_1JPG_REFERENCE_GOLDEN',
    defaultValue: false,
  );

  testWidgets(
    'reference golden derived from 1.jpg (masked map) 591x1146',
    (tester) async {
      await _setReferenceScreenSize(tester);

      await tester.pumpWidget(
        wrapForGolden(
          RiderHomePage(
            mapBuilderOverride: (_) => const _GoldenMapBackdrop(),
            skipMapInit: true,
          ),
          overrides: <Override>[
            riderHomeRepositoryProvider.overrideWithValue(
              _FakeRiderHomeRepository(),
            ),
          ],
          viewPadding: EdgeInsets.zero,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(RiderHomePage),
        matchesGoldenFile('goldens/rider_home_reference_1jpg_overlay.png'),
      );
    },
    // Opt-in until parity is reached.
    skip: !runReferenceGolden,
  );
}
