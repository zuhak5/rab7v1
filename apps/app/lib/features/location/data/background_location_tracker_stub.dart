import 'dart:async';

import '../domain/background_location_tracker.dart';

class BackgroundLocationTrackerStub implements BackgroundLocationTracker {
  final _controller = StreamController<BackgroundLocationSample>.broadcast();

  @override
  Stream<BackgroundLocationSample> locationUpdates() => _controller.stream;

  @override
  Future<void> start() async {
    // Stub implementation: plug in platform tracking service in production.
  }

  @override
  Future<void> stop() async {
    await _controller.close();
  }
}
