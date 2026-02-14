import 'package:equatable/equatable.dart';

import 'map_provider_code.dart';

class MapRenderConfig extends Equatable {
  const MapRenderConfig({
    required this.provider,
    required this.language,
    required this.region,
    required this.fallbackOrder,
    this.googleMapId,
    this.googleApiKey,
    this.mapboxPublicToken,
    this.mapboxStyleUrl,
    this.hereApiKey,
    this.hereStyle,
    this.thunderforestApiKey,
    this.thunderforestStyle,
    this.requestId,
    this.telemetryToken,
    this.telemetryExpiresAt,
  });

  final MapProviderCode provider;
  final String language;
  final String region;
  final List<MapProviderCode> fallbackOrder;
  final String? googleMapId;
  final String? googleApiKey;
  final String? mapboxPublicToken;
  final String? mapboxStyleUrl;
  final String? hereApiKey;
  final String? hereStyle;
  final String? thunderforestApiKey;
  final String? thunderforestStyle;
  final String? requestId;
  final String? telemetryToken;
  final DateTime? telemetryExpiresAt;

  bool get hasTelemetryToken {
    final requestIdValue = requestId;
    final telemetryTokenValue = telemetryToken;
    return requestIdValue != null &&
        requestIdValue.isNotEmpty &&
        telemetryTokenValue != null &&
        telemetryTokenValue.isNotEmpty;
  }

  @override
  List<Object?> get props => <Object?>[
    provider,
    language,
    region,
    fallbackOrder,
    googleMapId,
    googleApiKey,
    mapboxPublicToken,
    mapboxStyleUrl,
    hereApiKey,
    hereStyle,
    thunderforestApiKey,
    thunderforestStyle,
    requestId,
    telemetryToken,
    telemetryExpiresAt,
  ];
}
