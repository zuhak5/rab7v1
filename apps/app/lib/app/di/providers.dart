import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/logging/app_logger.dart';
import '../../core/network/connectivity_service.dart';
import '../../data/edge/edge_functions_client.dart';
import '../../data/storage/storage_repository_impl.dart';
import '../../data/supabase/realtime_subscription_manager.dart';
import '../../data/supabase/supabase_client_provider.dart';
import '../../features/auth/data/datasources/auth_supabase_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/request_phone_otp_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/verify_phone_otp_usecase.dart';
import '../../features/maps/data/datasources/maps_supabase_datasource.dart';
import '../../features/maps/data/repositories/map_backend_repository_impl.dart';
import '../../features/maps/domain/repositories/map_backend_repository.dart';
import '../../features/realtime/data/realtime_driver_location_adapter.dart';
import '../../features/realtime/data/realtime_ride_status_adapter.dart';
import '../../features/rider_home/data/datasources/rider_home_supabase_datasource.dart';
import '../../features/rider_home/data/repositories/rider_home_repository_impl.dart';
import '../../features/rider_home/domain/repositories/rider_home_repository.dart';
import '../../features/rider_rides/data/datasources/rides_supabase_datasource.dart';
import '../../features/rider_rides/data/mappers/ride_mapper.dart';
import '../../features/rider_rides/data/mappers/ride_request_mapper.dart';
import '../../features/rider_rides/data/repositories/rides_repository_impl.dart';
import '../../features/rider_rides/domain/repositories/rides_repository.dart';
import '../../features/rider_rides/domain/usecases/cancel_ride_request_usecase.dart';
import '../../features/rider_rides/domain/usecases/create_ride_request_usecase.dart';
import '../../features/rider_rides/domain/usecases/get_my_ride_requests_usecase.dart';
import '../../features/rider_rides/domain/usecases/trigger_match_ride_usecase.dart';
import '../../features/rider_rides/domain/usecases/watch_active_ride_usecase.dart';

final appLoggerProvider = Provider<AppLogger>((ref) {
  return AppLogger(ref.watch(appConfigProvider).logLevel);
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(Connectivity());
});

final realtimeSubscriptionManagerProvider =
    Provider<RealtimeSubscriptionManager>((ref) {
      final manager = RealtimeSubscriptionManager(
        ref.watch(supabaseClientProvider),
      );
      ref.onDispose(manager.dispose);
      return manager;
    });

final edgeFunctionsClientProvider = Provider<EdgeFunctionsClient>((ref) {
  return EdgeFunctionsClient(ref.watch(supabaseClientProvider));
});

final mapsSupabaseDataSourceProvider = Provider<MapsSupabaseDataSource>((ref) {
  return MapsSupabaseDataSource(ref.watch(edgeFunctionsClientProvider));
});

final mapBackendRepositoryProvider = Provider<MapBackendRepository>((ref) {
  return MapBackendRepositoryImpl(ref.watch(mapsSupabaseDataSourceProvider));
});

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepositoryImpl(ref.watch(supabaseClientProvider));
});

final authSupabaseDataSourceProvider = Provider<AuthSupabaseDataSource>((ref) {
  return AuthSupabaseDataSource(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authSupabaseDataSourceProvider));
});

final requestPhoneOtpUseCaseProvider = Provider<RequestPhoneOtpUseCase>((ref) {
  return RequestPhoneOtpUseCase(ref.watch(authRepositoryProvider));
});

final verifyPhoneOtpUseCaseProvider = Provider<VerifyPhoneOtpUseCase>((ref) {
  return VerifyPhoneOtpUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final realtimeRideStatusAdapterProvider = Provider<RealtimeRideStatusAdapter>((
  ref,
) {
  return RealtimeRideStatusAdapter(
    ref.watch(realtimeSubscriptionManagerProvider),
  );
});

final realtimeDriverLocationAdapterProvider =
    Provider<RealtimeDriverLocationAdapter>((ref) {
      return RealtimeDriverLocationAdapter(
        ref.watch(realtimeSubscriptionManagerProvider),
      );
    });

final rideRequestMapperProvider = Provider<RideRequestMapper>((ref) {
  return RideRequestMapper();
});

final rideMapperProvider = Provider<RideMapper>((ref) {
  return RideMapper();
});

final ridesSupabaseDataSourceProvider = Provider<RidesSupabaseDataSource>((
  ref,
) {
  return RidesSupabaseDataSource(
    client: ref.watch(supabaseClientProvider),
    edgeFunctionsClient: ref.watch(edgeFunctionsClientProvider),
    rideStatusAdapter: ref.watch(realtimeRideStatusAdapterProvider),
    driverLocationAdapter: ref.watch(realtimeDriverLocationAdapterProvider),
  );
});

final ridesRepositoryProvider = Provider<RidesRepository>((ref) {
  return RidesRepositoryImpl(
    dataSource: ref.watch(ridesSupabaseDataSourceProvider),
    rideRequestMapper: ref.watch(rideRequestMapperProvider),
    rideMapper: ref.watch(rideMapperProvider),
  );
});

final getMyRideRequestsUseCaseProvider = Provider<GetMyRideRequestsUseCase>((
  ref,
) {
  return GetMyRideRequestsUseCase(ref.watch(ridesRepositoryProvider));
});

final createRideRequestUseCaseProvider = Provider<CreateRideRequestUseCase>((
  ref,
) {
  return CreateRideRequestUseCase(ref.watch(ridesRepositoryProvider));
});

final cancelRideRequestUseCaseProvider = Provider<CancelRideRequestUseCase>((
  ref,
) {
  return CancelRideRequestUseCase(ref.watch(ridesRepositoryProvider));
});

final triggerMatchRideUseCaseProvider = Provider<TriggerMatchRideUseCase>((
  ref,
) {
  return TriggerMatchRideUseCase(ref.watch(ridesRepositoryProvider));
});

final watchActiveRideUseCaseProvider = Provider<WatchActiveRideUseCase>((ref) {
  return WatchActiveRideUseCase(ref.watch(ridesRepositoryProvider));
});

final riderHomeSupabaseDataSourceProvider =
    Provider<RiderHomeSupabaseDataSource>((ref) {
      return RiderHomeSupabaseDataSource(
        client: ref.watch(supabaseClientProvider),
        edgeFunctionsClient: ref.watch(edgeFunctionsClientProvider),
      );
    });

final riderHomeRepositoryProvider = Provider<RiderHomeRepository>((ref) {
  return RiderHomeRepositoryImpl(
    ref.watch(riderHomeSupabaseDataSourceProvider),
  );
});
