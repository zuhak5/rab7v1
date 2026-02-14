import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:latlong2/latlong.dart' as lat_lng;

import '../../data/google_maps/google_map_adapter.dart';
import '../../data/repositories/map_repository_impl.dart';
import '../../domain/entities/map_marker_model.dart';
import '../../domain/entities/map_provider_code.dart';
import '../../domain/entities/map_render_config.dart';
import '../../domain/entities/route_polyline_model.dart';
import '../viewmodels/map_render_config_controller.dart';
import '../web/google_maps_web_loader.dart';

final _mapAdapterProvider = Provider<GoogleMapAdapter>((ref) {
  return GoogleMapAdapter();
});

class RideMapWidget extends ConsumerStatefulWidget {
  const RideMapWidget({
    super.key,
    this.initialLatitude = 33.3152,
    this.initialLongitude = 44.3661,
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = true,
    this.compassEnabled = true,
    this.zoomControlsEnabled = false,
  });

  final double initialLatitude;
  final double initialLongitude;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool compassEnabled;
  final bool zoomControlsEnabled;

  @override
  ConsumerState<RideMapWidget> createState() => _RideMapWidgetState();
}

class _RideMapWidgetState extends ConsumerState<RideMapWidget> {
  StreamSubscription<List<MapMarkerModel>>? _markerSubscription;
  StreamSubscription<List<RoutePolylineModel>>? _polylineSubscription;

  List<MapMarkerModel> _markerModels = const <MapMarkerModel>[];
  List<RoutePolylineModel> _polylineModels = const <RoutePolylineModel>[];
  Set<google_maps.Marker> _googleMarkers = const <google_maps.Marker>{};
  Set<google_maps.Polyline> _googlePolylines = const <google_maps.Polyline>{};

  String? _activeRenderRequestId;
  DateTime _renderAttemptStartedAt = DateTime.now();
  final Set<String> _requestedFallbackKeys = <String>{};

  Future<void>? _webSdkLoadFuture;
  String? _activeWebSdkKey;
  var _providerFallbackInProgress = false;

  @override
  void initState() {
    super.initState();

    final adapter = ref.read(_mapAdapterProvider);
    final repository = ref.read(mapRepositoryProvider);

    _markerSubscription = repository.markers().listen((markerModels) {
      final googleMarkers = adapter.toMarkers(markerModels);
      if (mounted) {
        setState(() {
          _markerModels = List<MapMarkerModel>.unmodifiable(markerModels);
          _googleMarkers = googleMarkers;
        });
      }
    });

    _polylineSubscription = repository.polylines().listen((polylineModels) {
      final googlePolylines = adapter.toPolylines(polylineModels);
      if (mounted) {
        setState(() {
          _polylineModels = List<RoutePolylineModel>.unmodifiable(
            polylineModels,
          );
          _googlePolylines = googlePolylines;
        });
      }
    });
  }

  @override
  void dispose() {
    _markerSubscription?.cancel();
    _polylineSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bindingType = WidgetsBinding.instance.runtimeType.toString();
    final isTestBinding = bindingType.contains('TestWidgetsFlutterBinding');
    if (const bool.fromEnvironment('FLUTTER_TEST') || isTestBinding) {
      return const ColoredBox(color: Color(0xFFE8EAED));
    }

    final configAsync = ref.watch(mapRenderConfigControllerProvider);
    return configAsync.when(
      data: (config) {
        _syncRenderAttempt(config);
        return _buildMapForProvider(config);
      },
      loading: () => const ColoredBox(color: Color(0xFFE8EAED)),
      error: (error, stackTrace) => _MapFailureView(
        title: 'تعذر تحميل إعدادات الخرائط',
        subtitle: 'تحقق من اتصالك ثم أعد المحاولة.',
        onRetry: () {
          unawaited(
            ref
                .read(mapRenderConfigControllerProvider.notifier)
                .refreshConfig(resetFallback: true),
          );
        },
      ),
    );
  }

  Widget _buildMapForProvider(MapRenderConfig config) {
    switch (config.provider) {
      case MapProviderCode.google:
        return _buildGoogleProvider(config);
      case MapProviderCode.mapbox:
      case MapProviderCode.here:
      case MapProviderCode.thunderforest:
        return _buildTileProvider(config);
      case MapProviderCode.ors:
        return _buildFallbackViewFor(
          config,
          errorDetail: 'ors_renderer_not_supported',
          title: 'المزوّد الحالي ليس مزوّد عرض خرائط',
          subtitle:
              'OpenRouteService مزوّد خدمات Geo وليس عرض خرائط. جارٍ التحويل لمزوّد بديل.',
        );
    }
  }

  Widget _buildGoogleProvider(MapRenderConfig config) {
    if (kIsWeb) {
      final apiKey = config.googleApiKey?.trim() ?? '';
      if (apiKey.isEmpty) {
        return _buildFallbackViewFor(
          config,
          errorDetail: 'missing_google_maps_api_key',
          title: 'تعذر تحميل خرائط Google',
          subtitle:
              'مفتاح Google Maps غير متوفر من maps-config-v2 لهذا النطاق. جارٍ تجربة مزوّد بديل.',
        );
      }

      _ensureWebGoogleMapsSdk(config, apiKey: apiKey);
      final loadFuture = _webSdkLoadFuture;
      if (loadFuture == null) {
        return _buildFallbackViewFor(
          config,
          errorDetail: 'google_maps_loader_uninitialized',
          title: 'تعذر تحميل خرائط Google',
          subtitle: 'فشل تهيئة محمل خرائط Google. جارٍ تجربة مزوّد بديل.',
        );
      }

      return FutureBuilder<void>(
        future: loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const ColoredBox(color: Color(0xFFE8EAED));
          }
          if (snapshot.hasError) {
            return _buildFallbackViewFor(
              config,
              errorDetail: 'google_maps_sdk_load_failed',
              title: 'تعذر تحميل خرائط Google',
              subtitle:
                  'فشل تحميل Google Maps SDK. جارٍ تجربة مزوّد بديل حسب ترتيب الـ fallback في الخلفية.',
            );
          }
          return _buildGoogleMap(config);
        },
      );
    }

    return _buildGoogleMap(config);
  }

  Widget _buildTileProvider(MapRenderConfig config) {
    final tileSource = _resolveTileSource(config);
    if (tileSource == null) {
      return _buildFallbackViewFor(
        config,
        errorDetail: '${config.provider.value}_missing_tile_config',
        title: 'تعذر تحميل مزوّد الخرائط',
        subtitle:
            'بيانات المزود ${config.provider.value} غير مكتملة في maps-config-v2. جارٍ تجربة مزوّد بديل.',
      );
    }

    final theme = Theme.of(context);
    final markerIconColor = theme.colorScheme.onPrimary;
    final markerBgColor = theme.colorScheme.primary;

    return flutter_map.FlutterMap(
      options: flutter_map.MapOptions(
        initialCenter: lat_lng.LatLng(
          widget.initialLatitude,
          widget.initialLongitude,
        ),
        initialZoom: 13,
        interactionOptions: const flutter_map.InteractionOptions(
          flags:
              flutter_map.InteractiveFlag.all &
              ~flutter_map.InteractiveFlag.rotate,
        ),
      ),
      children: <Widget>[
        flutter_map.TileLayer(
          urlTemplate: tileSource.urlTemplate,
          additionalOptions: tileSource.additionalOptions,
          userAgentPackageName: 'app.rideiq.frontend',
          minZoom: 3,
          maxZoom: 19,
        ),
        if (_polylineModels.isNotEmpty)
          flutter_map.PolylineLayer(
            polylines: _polylineModels
                .map(
                  (item) => flutter_map.Polyline(
                    points: item.points
                        .map(
                          (point) =>
                              lat_lng.LatLng(point.latitude, point.longitude),
                        )
                        .toList(growable: false),
                    strokeWidth: 5,
                    color: const Color(0xFF0056D2),
                  ),
                )
                .toList(growable: false),
          ),
        if (_markerModels.isNotEmpty)
          flutter_map.MarkerLayer(
            markers: _markerModels
                .map(
                  (item) => flutter_map.Marker(
                    point: lat_lng.LatLng(item.latitude, item.longitude),
                    width: 36,
                    height: 36,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: markerBgColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 20,
                        color: markerIconColor,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
      ],
    );
  }

  Widget _buildGoogleMap(MapRenderConfig config) {
    return google_maps.GoogleMap(
      initialCameraPosition: google_maps.CameraPosition(
        target: google_maps.LatLng(
          widget.initialLatitude,
          widget.initialLongitude,
        ),
        zoom: 13,
      ),
      cloudMapId: config.googleMapId,
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      markers: _googleMarkers,
      polylines: _googlePolylines,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      compassEnabled: widget.compassEnabled,
      onMapCreated: (_) {
        unawaited(_reportMapRendered());
      },
    );
  }

  Widget _buildFallbackViewFor(
    MapRenderConfig config, {
    required String errorDetail,
    required String title,
    required String subtitle,
  }) {
    _requestProviderFallback(config, errorDetail: errorDetail);

    if (_providerFallbackInProgress) {
      return const ColoredBox(color: Color(0xFFE8EAED));
    }

    return _MapFailureView(
      title: title,
      subtitle: subtitle,
      onRetry: () {
        unawaited(
          ref
              .read(mapRenderConfigControllerProvider.notifier)
              .refreshConfig(resetFallback: true),
        );
      },
    );
  }

  void _requestProviderFallback(
    MapRenderConfig config, {
    required String errorDetail,
  }) {
    final fallbackKey = _failureKey(config, 'fallback:$errorDetail');
    if (!_requestedFallbackKeys.add(fallbackKey)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _providerFallbackInProgress) {
        return;
      }
      setState(() {
        _providerFallbackInProgress = true;
      });
      unawaited(_runProviderFallback(config: config, errorDetail: errorDetail));
    });
  }

  Future<void> _runProviderFallback({
    required MapRenderConfig config,
    required String errorDetail,
  }) async {
    final latencyMs = DateTime.now()
        .difference(_renderAttemptStartedAt)
        .inMilliseconds;
    final switched = await ref
        .read(mapRenderConfigControllerProvider.notifier)
        .fallbackAfterRenderFailure(
          errorDetail: errorDetail,
          latencyMs: latencyMs,
        );

    if (!mounted) {
      return;
    }
    setState(() {
      _providerFallbackInProgress = false;
      if (switched) {
        _webSdkLoadFuture = null;
        _activeWebSdkKey = null;
      }
    });
  }

  void _ensureWebGoogleMapsSdk(
    MapRenderConfig config, {
    required String apiKey,
  }) {
    if (_activeWebSdkKey == apiKey && _webSdkLoadFuture != null) {
      return;
    }
    _activeWebSdkKey = apiKey;
    _webSdkLoadFuture = GoogleMapsWebLoader.ensureLoaded(
      apiKey: apiKey,
      language: config.language,
      region: config.region,
    );
  }

  _TileSource? _resolveTileSource(MapRenderConfig config) {
    switch (config.provider) {
      case MapProviderCode.mapbox:
        final token = config.mapboxPublicToken?.trim() ?? '';
        if (token.isEmpty) {
          return null;
        }
        final stylePath = _mapboxStylePath(config.mapboxStyleUrl);
        if (stylePath == null || stylePath.isEmpty) {
          return null;
        }
        return _TileSource(
          urlTemplate:
              'https://api.mapbox.com/styles/v1/$stylePath/tiles/256/{z}/{x}/{y}?access_token={accessToken}',
          additionalOptions: <String, String>{'accessToken': token},
        );
      case MapProviderCode.here:
        final apiKey = config.hereApiKey?.trim() ?? '';
        if (apiKey.isEmpty) {
          return null;
        }
        final hereStyle = config.hereStyle?.trim();
        final style = hereStyle == null || hereStyle.isEmpty
            ? 'normal.day'
            : hereStyle;
        return _TileSource(
          urlTemplate:
              'https://maps.hereapi.com/v3/base/mc/{z}/{x}/{y}/png8?style={style}&size=256&apiKey={apiKey}&lg={language}',
          additionalOptions: <String, String>{
            'apiKey': apiKey,
            'style': style,
            'language': config.language,
          },
        );
      case MapProviderCode.thunderforest:
        final apiKey = config.thunderforestApiKey?.trim() ?? '';
        if (apiKey.isEmpty) {
          return null;
        }
        final thunderforestStyle = config.thunderforestStyle?.trim();
        final style =
            thunderforestStyle == null || thunderforestStyle.isEmpty
            ? 'atlas'
            : thunderforestStyle;
        return _TileSource(
          urlTemplate:
              'https://tile.thunderforest.com/{style}/{z}/{x}/{y}.png?apikey={apiKey}',
          additionalOptions: <String, String>{'apiKey': apiKey, 'style': style},
        );
      case MapProviderCode.google:
      case MapProviderCode.ors:
        return null;
    }
  }

  String? _mapboxStylePath(String? styleUrl) {
    const fallback = 'mapbox/streets-v12';
    final raw = styleUrl?.trim();
    if (raw == null || raw.isEmpty) {
      return fallback;
    }

    const prefix = 'mapbox://styles/';
    if (raw.startsWith(prefix)) {
      final path = raw.substring(prefix.length);
      return path.isEmpty ? fallback : path;
    }

    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.host.contains('mapbox.com')) {
      return fallback;
    }

    final segments = uri.pathSegments;
    final stylesIndex = segments.indexOf('styles');
    if (stylesIndex >= 0 && stylesIndex + 2 < segments.length) {
      return '${segments[stylesIndex + 1]}/${segments[stylesIndex + 2]}';
    }

    return fallback;
  }

  void _syncRenderAttempt(MapRenderConfig config) {
    final requestId = config.requestId ?? '';
    if (_activeRenderRequestId == requestId) {
      return;
    }
    _activeRenderRequestId = requestId;
    _renderAttemptStartedAt = DateTime.now();
  }

  Future<void> _reportMapRendered() async {
    final latencyMs = DateTime.now()
        .difference(_renderAttemptStartedAt)
        .inMilliseconds;
    await ref
        .read(mapRenderConfigControllerProvider.notifier)
        .reportRenderSuccess(latencyMs: latencyMs);
  }

  String _failureKey(MapRenderConfig config, String errorDetail) {
    final requestId = config.requestId;
    final stableRequestId = requestId != null && requestId.isNotEmpty
        ? requestId
        : 'no_request_id';
    return '$stableRequestId:${config.provider.value}:$errorDetail';
  }
}

class _TileSource {
  const _TileSource({
    required this.urlTemplate,
    required this.additionalOptions,
  });

  final String urlTemplate;
  final Map<String, String> additionalOptions;
}

class _MapFailureView extends StatelessWidget {
  const _MapFailureView({
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: const Color(0xFFE8EAED),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: onRetry,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
