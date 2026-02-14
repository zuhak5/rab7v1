import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../domain/entities/ride_request.dart';

class RidesListController
    extends AutoDisposeAsyncNotifier<List<RideRequestEntity>> {
  @override
  Future<List<RideRequestEntity>> build() {
    final useCase = ref.read(getMyRideRequestsUseCaseProvider);
    return useCase();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getMyRideRequestsUseCaseProvider);
      return useCase();
    });
  }

  Future<void> cancelRequest(String requestId) async {
    await ref.read(cancelRideRequestUseCaseProvider)(requestId);
    await refresh();
  }

  Future<void> triggerMatch(String requestId) async {
    await ref.read(triggerMatchRideUseCaseProvider)(requestId);
    await refresh();
  }
}

final ridesListControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      RidesListController,
      List<RideRequestEntity>
    >(RidesListController.new);
