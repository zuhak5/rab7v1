import '../../domain/entities/map_provider_code.dart';
import '../../domain/entities/map_render_config.dart';
import '../../domain/repositories/map_backend_repository.dart';
import '../datasources/maps_supabase_datasource.dart';

class MapBackendRepositoryImpl implements MapBackendRepository {
  MapBackendRepositoryImpl(this._dataSource);

  final MapsSupabaseDataSource _dataSource;

  @override
  Future<MapRenderConfig> resolveRenderConfig({
    required List<MapProviderCode> supportedProviders,
    List<MapProviderCode> excludeProviders = const <MapProviderCode>[],
  }) {
    return _dataSource.loadRenderConfig(
      supportedProviders: supportedProviders,
      excludeProviders: excludeProviders,
    );
  }

  @override
  Future<void> reportRenderSuccess({
    required MapRenderConfig config,
    int? latencyMs,
    int attemptNumber = 1,
    List<MapProviderCode> triedProviders = const <MapProviderCode>[],
  }) {
    return _dataSource.trackRenderEvent(
      config: config,
      success: true,
      latencyMs: latencyMs,
      attemptNumber: attemptNumber,
      triedProviders: triedProviders,
    );
  }

  @override
  Future<void> reportRenderFailure({
    required MapRenderConfig config,
    String? errorDetail,
    int? latencyMs,
    int attemptNumber = 1,
    List<MapProviderCode> triedProviders = const <MapProviderCode>[],
  }) {
    return _dataSource.trackRenderEvent(
      config: config,
      success: false,
      errorDetail: errorDetail,
      latencyMs: latencyMs,
      attemptNumber: attemptNumber,
      triedProviders: triedProviders,
    );
  }
}
