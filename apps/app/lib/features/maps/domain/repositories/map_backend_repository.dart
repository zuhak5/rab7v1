import '../entities/map_provider_code.dart';
import '../entities/map_render_config.dart';

abstract class MapBackendRepository {
  Future<MapRenderConfig> resolveRenderConfig({
    required List<MapProviderCode> supportedProviders,
    List<MapProviderCode> excludeProviders = const <MapProviderCode>[],
  });

  Future<void> reportRenderSuccess({
    required MapRenderConfig config,
    int? latencyMs,
    int attemptNumber = 1,
    List<MapProviderCode> triedProviders = const <MapProviderCode>[],
  });

  Future<void> reportRenderFailure({
    required MapRenderConfig config,
    String? errorDetail,
    int? latencyMs,
    int attemptNumber = 1,
    List<MapProviderCode> triedProviders = const <MapProviderCode>[],
  });
}
