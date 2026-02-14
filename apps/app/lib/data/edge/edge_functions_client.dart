import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'edge_function_names.dart';

class EdgeFunctionsClient {
  EdgeFunctionsClient(this._client);

  final SupabaseClient _client;

  Future<Map<String, dynamic>> fareEngine({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    String productCode = 'standard',
  }) async {
    final response = await _client.functions.invoke(
      EdgeFunctionNames.fareEngine,
      body: {
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'dropoff_lat': dropoffLat,
        'dropoff_lng': dropoffLng,
        'product_code': productCode,
      },
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> matchRide({
    required String requestId,
    double radiusMeters = 5000,
  }) async {
    final response = await _client.functions.invoke(
      EdgeFunctionNames.matchRide,
      body: {'request_id': requestId, 'radius_m': radiusMeters},
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> rideTransition({
    required String rideId,
    required String toStatus,
    int? expectedVersion,
  }) async {
    final response = await _client.functions.invoke(
      EdgeFunctionNames.rideTransition,
      body: {
        'ride_id': rideId,
        'to_status': toStatus,
        ...?expectedVersion == null
            ? null
            : <String, dynamic>{'expected_version': expectedVersion},
      },
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> mapsConfigV2({
    String capability = 'render',
    List<String> supportedProviders = const <String>[],
    List<String> excludeProviders = const <String>[],
    String? requestId,
  }) async {
    final body = <String, dynamic>{
      'capability': capability,
      if (supportedProviders.isNotEmpty) 'supported': supportedProviders,
      if (excludeProviders.isNotEmpty) 'exclude': excludeProviders,
      if (requestId != null && requestId.isNotEmpty) 'request_id': requestId,
    };

    final response = await _client.functions.invoke(
      EdgeFunctionNames.mapsConfigV2,
      body: body,
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> mapsUsage({
    required String providerCode,
    String capability = 'render',
    String event = 'render_success',
    String? requestId,
    String? telemetryToken,
    int? attemptNumber,
    List<String> triedProviders = const <String>[],
    int? latencyMs,
    String? errorDetail,
  }) async {
    final body = <String, dynamic>{
      'provider_code': providerCode,
      'capability': capability,
      'event': event,
      if (requestId != null && requestId.isNotEmpty) 'request_id': requestId,
      if (telemetryToken != null && telemetryToken.isNotEmpty)
        'telemetry_token': telemetryToken,
      if (attemptNumber != null && attemptNumber > 0)
        'attempt_number': attemptNumber,
      if (triedProviders.isNotEmpty) 'tried_providers': triedProviders,
      if (latencyMs != null && latencyMs >= 0) 'latency_ms': latencyMs,
      if (errorDetail != null && errorDetail.isNotEmpty)
        'error_detail': errorDetail,
    };

    final response = await _client.functions.invoke(
      EdgeFunctionNames.mapsUsage,
      body: body,
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> geo({
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.functions.invoke(
      EdgeFunctionNames.geo,
      body: <String, dynamic>{'action': action, ...payload},
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> ablyToken({
    required List<String> channels,
  }) async {
    final response = await _client.functions.invoke(
      EdgeFunctionNames.ablyToken,
      body: {'channels': channels},
    );

    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> deviceTokenUpsert({
    required String token,
    required String platform,
    String? deviceId,
    String? appVersion,
  }) async {
    final response = await _client.functions.invoke(
      EdgeFunctionNames.deviceTokenUpsert,
      body: {
        'token': token,
        'platform': platform,
        ...?deviceId == null || deviceId.isEmpty
            ? null
            : <String, dynamic>{'device_id': deviceId},
        ...?appVersion == null || appVersion.isEmpty
            ? null
            : <String, dynamic>{'app_version': appVersion},
      },
    );

    return _asMap(response.data);
  }

  Future<String?> profileAvatarDownload({
    required String objectKey,
    int expiresInSeconds = 120,
  }) async {
    final response = await _client.functions.invoke(
      EdgeFunctionNames.profileAvatarUrl,
      body: {
        'action': 'download',
        'object_key': objectKey,
        'expires_in': expiresInSeconds,
      },
    );

    final data = _asMap(response.data);
    final signedUrl = data['signedUrl'] as String?;
    if (signedUrl == null || signedUrl.isEmpty) {
      return null;
    }
    return signedUrl;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.cast<String, dynamic>();
    }

    throw StateError(
      'Unexpected edge function payload type: ${describeIdentity(data)}',
    );
  }
}
