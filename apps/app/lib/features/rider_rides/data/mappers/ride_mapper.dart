import '../../../../data/supabase/schema_contract.dart';
import '../../domain/entities/ride.dart';

class RideMapper {
  RideEntity fromMap(Map<String, dynamic> json) {
    return RideEntity(
      id: json[RideColumns.id] as String,
      requestId: json[RideColumns.requestId] as String,
      status: (json[RideColumns.status] as String?) ?? 'assigned',
      version: (json[RideColumns.version] as int?) ?? 0,
      updatedAt: DateTime.parse(json[RideColumns.updatedAt] as String),
      driverId: json[RideColumns.driverId] as String?,
      fareAmountIqd: (json[RideColumns.fareAmountIqd] as num?)?.toInt(),
      currency: json[RideColumns.currency] as String?,
    );
  }
}
