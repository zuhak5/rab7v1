import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../domain/entities/ride.dart';

class ActiveRideRealtimeController
    extends AutoDisposeFamilyAsyncNotifier<RideEntity?, String> {
  StreamSubscription<RideEntity?>? _rideSubscription;

  @override
  Future<RideEntity?> build(String arg) async {
    final useCase = ref.watch(watchActiveRideUseCaseProvider);
    _rideSubscription = useCase(arg).listen((ride) {
      if (ride != null) {
        state = AsyncValue.data(ride);
      }
    });

    ref.onDispose(() async {
      await _rideSubscription?.cancel();
    });

    return null;
  }
}

final activeRideRealtimeControllerProvider =
    AutoDisposeAsyncNotifierProviderFamily<
      ActiveRideRealtimeController,
      RideEntity?,
      String
    >(ActiveRideRealtimeController.new);
