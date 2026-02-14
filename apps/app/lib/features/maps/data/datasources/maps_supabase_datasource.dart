import '../../../../data/edge/edge_functions_client.dart';
import '../../domain/entities/map_provider_code.dart';
import '../../domain/entities/map_render_config.dart';

class MapsSupabaseDataSource {
  MapsSupabaseDataSource(this._edgeFunctionsClient);

  final EdgeFunctionsClient _edgeFunctionsClient;

  Future<MapRenderConfig> loadRenderConfig({
    required List<MapProviderCode> supportedProviders,
    List<MapProviderCode> excludeProviders = const <MapProviderCode>[],
  }) async {
    final response = await _edgeFunctionsClient.mapsConfigV2(
      capability: 'render',
      supportedProviders: supportedProviders
          .map((provider) => provider.value)
          .toList(growable: false),
      excludeProviders: excludeProviders
          .map((provider) => provider.value)
          .toList(growable: false),
    );

    final ok = response['ok'] == true;
    if (!ok) {
      throw StateError('maps-config-v2 returned non-ok payload: $response');
    }

    final providerRaw = _asString(response['provider']);
    if (providerRaw == null || providerRaw.isEmpty) {
      throw StateError('maps-config-v2 payload is missing provider.');
    }

    final provider = mapProviderCodeFromValue(providerRaw);
    if (provider == null) {
      throw StateError('Unsupported map provider from backend: $providerRaw');
    }

    final configMap = _asMap(response['config']);
    final language = _asString(configMap['language']) ?? 'ar';
    final region = _asString(configMap['region']) ?? 'IQ';
    final googleMapId = _asString(configMap['mapId']);
    final apiKey = _asString(configMap['apiKey']);
    final style = _asString(configMap['style']);
    final mapboxToken = _asString(configMap['token']);
    final mapboxStyleUrl = _asString(configMap['styleUrl']);
    final requestId = _asString(response['request_id']);
    final telemetryToken = _asString(response['telemetry_token']);
    final telemetryExpiresAt = DateTime.tryParse(
      _asString(response['telemetry_expires_at']) ?? '',
    );

    final fallbackRaw = response['fallback_order'];
    final fallbackOrder = fallbackRaw is List
        ? fallbackRaw
              .map((item) => mapProviderCodeFromValue(_asString(item) ?? ''))
              .whereType<MapProviderCode>()
              .toList(growable: false)
        : const <MapProviderCode>[];

    return MapRenderConfig(
      provider: provider,
      language: language,
      region: region,
      fallbackOrder: fallbackOrder,
      googleMapId: googleMapId,
      googleApiKey: provider == MapProviderCode.google ? apiKey : null,
      mapboxPublicToken: provider == MapProviderCode.mapbox
          ? mapboxToken
          : null,
      mapboxStyleUrl: provider == MapProviderCode.mapbox
          ? mapboxStyleUrl
          : null,
      hereApiKey: provider == MapProviderCode.here ? apiKey : null,
      hereStyle: provider == MapProviderCode.here ? style : null,
      thunderforestApiKey: provider == MapProviderCode.thunderforest
          ? apiKey
          : null,
      thunderforestStyle: provider == MapProviderCode.thunderforest
          ? style
          : null,
      requestId: requestId,
      telemetryToken: telemetryToken,
      telemetryExpiresAt: telemetryExpiresAt,
    );
  }

  Future<void> trackRenderEvent({
    required MapRenderConfig config,
    required bool success,
    int? latencyMs,
    int attemptNumber = 1,
    List<MapProviderCode> triedProviders = const <MapProviderCode>[],
    String? errorDetail,
  }) async {
    await _edgeFunctionsClient.mapsUsage(
      providerCode: config.provider.value,
      capability: 'render',
      event: success ? 'render_success' : 'render_failure',
      requestId: config.requestId,
      telemetryToken: config.telemetryToken,
      attemptNumber: attemptNumber,
      triedProviders: triedProviders
          .map((provider) => provider.value)
          .toList(growable: false),
      latencyMs: latencyMs,
      errorDetail: errorDetail,
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.cast<String, dynamic>();
    }
    return <String, dynamic>{};
  }

  String? _asString(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }
}
