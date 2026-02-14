import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../rider_rides/domain/entities/ride.dart';
import '../../../rider_rides/domain/entities/ride_request.dart';

final watchRideRequestProvider = StreamProvider.autoDispose
    .family<RideRequestEntity?, String>((ref, requestId) {
      final repository = ref.watch(ridesRepositoryProvider);
      return repository.watchRideRequest(requestId);
    });

final watchRideByRequestProvider = StreamProvider.autoDispose
    .family<RideEntity?, String>((ref, requestId) {
      final repository = ref.watch(ridesRepositoryProvider);
      return repository.watchRideByRequest(requestId);
    });
