import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/edge/edge_functions_client.dart';
import '../../../../data/supabase/schema_contract.dart';
import '../../../realtime/data/realtime_driver_location_adapter.dart';
import '../../../realtime/data/realtime_ride_status_adapter.dart';

class RidesSupabaseDataSource {
  RidesSupabaseDataSource({
    required SupabaseClient client,
    required EdgeFunctionsClient edgeFunctionsClient,
    required RealtimeRideStatusAdapter rideStatusAdapter,
    required RealtimeDriverLocationAdapter driverLocationAdapter,
  }) : _client = client,
       _edgeFunctionsClient = edgeFunctionsClient,
       _rideStatusAdapter = rideStatusAdapter,
       _driverLocationAdapter = driverLocationAdapter;

  final SupabaseClient _client;
  final EdgeFunctionsClient _edgeFunctionsClient;
  final RealtimeRideStatusAdapter _rideStatusAdapter;
  final RealtimeDriverLocationAdapter _driverLocationAdapter;

  Future<List<Map<String, dynamic>>> listRideRequests() async {
    final response = await _client
        .from(Tables.rideRequests)
        .select()
        .order(RideRequestColumns.createdAt, ascending: false)
        .limit(50);

    return response.map(Map<String, dynamic>.from).toList(growable: false);
  }

  Future<Map<String, dynamic>> createRideRequest({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    String? pickupAddress,
    String? dropoffAddress,
    String productCode = 'standard',
    String paymentMethod = 'wallet',
  }) async {
    final quote = await _edgeFunctionsClient.fareEngine(
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      productCode: productCode,
    );

    final quoteId = quote['quote_id'] as String?;
    if (quoteId == null || quoteId.isEmpty) {
      throw StateError(
        'fare-engine response did not include quote_id. Unable to create ride request.',
      );
    }

    final inserted = await _client
        .from(Tables.rideRequests)
        .insert({
          RideRequestColumns.pickupLat: pickupLat,
          RideRequestColumns.pickupLng: pickupLng,
          RideRequestColumns.dropoffLat: dropoffLat,
          RideRequestColumns.dropoffLng: dropoffLng,
          RideRequestColumns.pickupAddress: pickupAddress,
          RideRequestColumns.dropoffAddress: dropoffAddress,
          RideRequestColumns.productCode: productCode,
          RideRequestColumns.fareQuoteId: quoteId,
          RideRequestColumns.paymentMethod: paymentMethod,
        })
        .select()
        .single();

    return inserted;
  }

  Future<void> cancelRideRequest(String requestId) async {
    final response = await _client.rpc<dynamic>(
      Rpcs.cancelRideRequest,
      params: {'p_request_id': requestId},
    );

    if (response is! Map<String, dynamic> || response['ok'] != true) {
      throw StateError('Failed to cancel ride request: $response');
    }
  }

  Future<void> triggerMatchRide(String requestId) async {
    final response = await _edgeFunctionsClient.matchRide(requestId: requestId);
    if (response.isEmpty) {
      throw StateError('match-ride returned an empty response.');
    }
  }

  Stream<Map<String, dynamic>?> watchRideRequest(String requestId) {
    return _rideStatusAdapter.watchRideRequest(requestId).map((event) {
      final payload = event['new'];
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      if (payload is Map) {
        return payload.cast<String, dynamic>();
      }
      return null;
    });
  }

  Stream<Map<String, dynamic>?> watchRideByRequest(String requestId) {
    return _rideStatusAdapter.watchRideByRequest(requestId).map((event) {
      final payload = event['new'];
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      if (payload is Map) {
        return payload.cast<String, dynamic>();
      }
      return null;
    });
  }

  Stream<Map<String, dynamic>?> watchDriverLocation(String driverId) {
    return _driverLocationAdapter.watchDriverByPostgres(driverId).map((event) {
      final payload = event['new'];
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      if (payload is Map) {
        return payload.cast<String, dynamic>();
      }
      return null;
    });
  }
}
