import 'package:flutter_test/flutter_test.dart';
import 'package:rideiq_app/features/rider_home/presentation/viewmodels/rider_home_state.dart';

void main() {
  group('TripDraft.canRequestTrip', () {
    test('requires resolved destination coordinates', () {
      const draft = TripDraft(
        pickupLabel: 'Pickup',
        pickupSecondary: 'GPS',
        pickupLat: 33.3152,
        pickupLng: 44.3661,
        destinationLabel: 'Destination',
        destinationSecondary: null,
        dropoffLat: 33.2989,
        dropoffLng: 44.3473,
        scheduleType: ScheduleType.now,
        scheduledAt: null,
        selectedOfferId: 'economy',
        paymentMethod: 'cash',
        destinationResolutionStatus: DestinationResolutionStatus.unresolved,
        destinationResolutionError: null,
      );

      expect(draft.canRequestTrip, isFalse);
      expect(
        draft
            .copyWith(
              destinationResolutionStatus: DestinationResolutionStatus.resolved,
            )
            .canRequestTrip,
        isTrue,
      );
    });
  });
}
