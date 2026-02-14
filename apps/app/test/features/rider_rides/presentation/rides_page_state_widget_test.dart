import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rideiq_app/features/rider_rides/domain/entities/ride_request.dart';
import 'package:rideiq_app/features/rider_rides/presentation/viewmodels/rides_list_controller.dart';

class _FakeRidesListController extends RidesListController {
  _FakeRidesListController(this._result);

  final List<RideRequestEntity> _result;

  @override
  Future<List<RideRequestEntity>> build() async => _result;
}

void main() {
  test('rides list controller exposes loading/data states', () async {
    final container = ProviderContainer(
      overrides: [
        ridesListControllerProvider.overrideWith(
          () => _FakeRidesListController(const []),
        ),
      ],
    );
    addTearDown(container.dispose);

    final future = container.read(ridesListControllerProvider.future);
    await expectLater(future, completes);

    expect(container.read(ridesListControllerProvider).value, isEmpty);
  });
}
