import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase/realtime_subscription_manager.dart';
import '../../../data/supabase/schema_contract.dart';

class RealtimeDriverLocationAdapter {
  RealtimeDriverLocationAdapter(this._subscriptions);

  final RealtimeSubscriptionManager _subscriptions;

  Stream<Map<String, dynamic>> watchDriverByPostgres(String driverId) {
    return _subscriptions.watchPostgres(
      key: 'driver_location:$driverId',
      schema: 'public',
      table: Tables.driverLocations,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: DriverLocationColumns.driverId,
        value: driverId,
      ),
    );
  }

  Stream<Map<String, dynamic>> watchOwnDriverLocationBroadcast(String userId) {
    return _subscriptions.watchBroadcast(
      key: 'driver_location_broadcast:$userId',
      topic: RealtimeTopics.ownDriverLocation(userId),
      event: '*',
    );
  }
}
