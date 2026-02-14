import 'package:flutter_test/flutter_test.dart';
import 'package:rideiq_app/features/rider_home/presentation/viewmodels/ride_status_presentation.dart';

void main() {
  group('mapRideStatusPresentation', () {
    test('maps active lifecycle statuses to non-terminal stages', () {
      final requested = mapRideStatusPresentation('requested');
      final assigned = mapRideStatusPresentation('assigned');

      expect(requested.isTerminal, isFalse);
      expect(requested.stage, 2);
      expect(assigned.isTerminal, isFalse);
      expect(assigned.stage, 3);
    });

    test('maps terminal statuses correctly', () {
      final canceled = mapRideStatusPresentation('canceled');
      final completed = mapRideStatusPresentation('completed');
      final expired = mapRideStatusPresentation('expired');

      expect(canceled.isTerminal, isTrue);
      expect(canceled.stage, 1);
      expect(completed.isTerminal, isTrue);
      expect(completed.stage, 3);
      expect(expired.isTerminal, isTrue);
      expect(expired.stage, 2);
    });

    test('falls back safely for unknown statuses', () {
      final unknown = mapRideStatusPresentation('unexpected_status');
      expect(unknown.isTerminal, isFalse);
      expect(unknown.stage, 2);
    });
  });
}
