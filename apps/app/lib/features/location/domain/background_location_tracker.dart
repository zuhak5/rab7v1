abstract class BackgroundLocationTracker {
  Stream<BackgroundLocationSample> locationUpdates();

  Future<void> start();

  Future<void> stop();
}

class BackgroundLocationSample {
  const BackgroundLocationSample({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;
}
