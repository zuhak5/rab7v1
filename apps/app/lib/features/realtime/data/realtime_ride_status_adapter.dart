import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase/realtime_subscription_manager.dart';
import '../../../data/supabase/schema_contract.dart';

class RealtimeRideStatusAdapter {
  RealtimeRideStatusAdapter(this._subscriptions);

  final RealtimeSubscriptionManager _subscriptions;

  Stream<Map<String, dynamic>> watchRideRequest(String requestId) {
    return _subscriptions.watchPostgres(
      key: 'ride_request:$requestId',
      schema: 'public',
      table: Tables.rideRequests,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: RideRequestColumns.id,
        value: requestId,
      ),
    );
  }

  Stream<Map<String, dynamic>> watchRideByRequest(String requestId) {
    return _subscriptions.watchPostgres(
      key: 'ride_by_request:$requestId',
      schema: 'public',
      table: Tables.rides,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: RideColumns.requestId,
        value: requestId,
      ),
    );
  }
}
