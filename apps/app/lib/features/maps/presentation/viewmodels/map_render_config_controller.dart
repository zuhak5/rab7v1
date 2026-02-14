import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../domain/entities/map_provider_code.dart';
import '../../domain/entities/map_render_config.dart';

final mapRenderConfigControllerProvider =
    AsyncNotifierProvider<MapRenderConfigController, MapRenderConfig>(
      MapRenderConfigController.new,
    );

class MapRenderConfigController extends AsyncNotifier<MapRenderConfig> {
  static const List<MapProviderCode> _supportedRenderProviders =
      <MapProviderCode>[
        MapProviderCode.google,
        MapProviderCode.mapbox,
        MapProviderCode.here,
        MapProviderCode.thunderforest,
        MapProviderCode.ors,
      ];

  final Set<String> _reportedSuccessRequestIds = <String>{};
  final List<MapProviderCode> _excludedProviders = <MapProviderCode>[];
  final List<MapProviderCode> _triedProviders = <MapProviderCode>[];
  var _attemptNumber = 1;
  var _fallbackInProgress = false;

  @override
  Future<MapRenderConfig> build() async {
    _resetFallback();
    return _resolveConfig();
  }

  Future<void> refreshConfig({bool resetFallback = true}) async {
    if (resetFallback) {
      _resetFallback();
    }
    state = const AsyncValue<MapRenderConfig>.loading();
    state = await AsyncValue.guard(() async {
      return _resolveConfig();
    });
  }

  Future<void> reportRenderSuccess({int? latencyMs}) async {
    final config = state.valueOrNull;
    if (config == null) {
      return;
    }

    final requestId = config.requestId;
    if (requestId != null &&
        requestId.isNotEmpty &&
        _reportedSuccessRequestIds.contains(requestId)) {
      return;
    }

    if (_canReportRenderTelemetry(config.provider)) {
      try {
        await ref
            .read(mapBackendRepositoryProvider)
            .reportRenderSuccess(
              config: config,
              latencyMs: latencyMs,
              attemptNumber: _attemptNumber,
              triedProviders: List<MapProviderCode>.from(_triedProviders),
            );
      } catch (_) {}
    }

    if (requestId != null && requestId.isNotEmpty) {
      _reportedSuccessRequestIds.add(requestId);
    }
  }

  Future<void> reportRenderFailure({
    required String errorDetail,
    int? latencyMs,
  }) async {
    final config = state.valueOrNull;
    if (config == null) {
      return;
    }

    await _reportRenderFailureInternal(
      config: config,
      errorDetail: errorDetail,
      latencyMs: latencyMs,
    );
  }

  Future<bool> fallbackAfterRenderFailure({
    required String errorDetail,
    int? latencyMs,
  }) async {
    final config = state.valueOrNull;
    if (config == null || _fallbackInProgress) {
      return false;
    }

    await _reportRenderFailureInternal(
      config: config,
      errorDetail: errorDetail,
      latencyMs: latencyMs,
    );

    _appendTriedProvider(config.provider);
    _appendExcludedProvider(config.provider);

    if (_excludedProviders.length >= _supportedRenderProviders.length) {
      return false;
    }

    _fallbackInProgress = true;
    try {
      final next = await _resolveNextConfig();
      _attemptNumber = _excludedProviders.length + 1;
      state = AsyncValue<MapRenderConfig>.data(next);
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue<MapRenderConfig>.error(error, stackTrace);
      return false;
    } finally {
      _fallbackInProgress = false;
    }
  }

  void _resetFallback() {
    _excludedProviders.clear();
    _triedProviders.clear();
    _attemptNumber = 1;
    _fallbackInProgress = false;
  }

  Future<MapRenderConfig> _resolveConfig() {
    return ref
        .read(mapBackendRepositoryProvider)
        .resolveRenderConfig(
          supportedProviders: _supportedRenderProviders,
          excludeProviders: _excludedProviders,
        );
  }

  Future<MapRenderConfig> _resolveNextConfig() async {
    final repository = ref.read(mapBackendRepositoryProvider);
    var localExcludes = List<MapProviderCode>.from(_excludedProviders);
    final maxAttempts = _supportedRenderProviders.length;

    for (var i = 0; i < maxAttempts; i++) {
      final config = await repository.resolveRenderConfig(
        supportedProviders: _supportedRenderProviders,
        excludeProviders: localExcludes,
      );

      if (!localExcludes.contains(config.provider)) {
        return config;
      }

      _appendTriedProvider(config.provider);
      _appendExcludedProvider(config.provider);
      localExcludes = List<MapProviderCode>.from(_excludedProviders);

      if (localExcludes.length >= _supportedRenderProviders.length) {
        break;
      }
    }

    throw StateError('no_render_provider_available_after_fallback');
  }

  Future<void> _reportRenderFailureInternal({
    required MapRenderConfig config,
    required String errorDetail,
    int? latencyMs,
  }) async {
    if (!_canReportRenderTelemetry(config.provider)) {
      return;
    }
    try {
      await ref
          .read(mapBackendRepositoryProvider)
          .reportRenderFailure(
            config: config,
            errorDetail: errorDetail,
            latencyMs: latencyMs,
            attemptNumber: _attemptNumber,
            triedProviders: List<MapProviderCode>.from(_triedProviders),
          );
    } catch (_) {}
  }

  void _appendExcludedProvider(MapProviderCode provider) {
    if (_excludedProviders.contains(provider)) {
      return;
    }
    _excludedProviders.add(provider);
  }

  void _appendTriedProvider(MapProviderCode provider) {
    if (_triedProviders.contains(provider)) {
      return;
    }
    _triedProviders.add(provider);
  }

  bool _canReportRenderTelemetry(MapProviderCode provider) {
    return provider != MapProviderCode.ors;
  }
}
