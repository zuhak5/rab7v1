import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../domain/entities/ride_request.dart';
import '../../domain/repositories/rides_repository.dart';

class RideRequestCreateController
    extends AutoDisposeNotifier<AsyncValue<RideRequestEntity?>> {
  @override
  AsyncValue<RideRequestEntity?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> create(CreateRideRequestInput input) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(createRideRequestUseCaseProvider)(input);
    });
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final rideRequestCreateControllerProvider =
    AutoDisposeNotifierProvider<
      RideRequestCreateController,
      AsyncValue<RideRequestEntity?>
    >(RideRequestCreateController.new);
