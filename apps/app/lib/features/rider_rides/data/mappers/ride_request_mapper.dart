import '../../../../data/supabase/schema_contract.dart';
import '../../domain/entities/driver_location.dart';
import '../../domain/entities/ride.dart';
import '../../domain/entities/ride_request.dart';

class RideRequestMapper {
  RideRequestEntity fromMap(Map<String, dynamic> json) {
    return RideRequestEntity(
      id: json[RideRequestColumns.id] as String,
      status: (json[RideRequestColumns.status] as String?) ?? 'requested',
      pickupLat: _toDouble(json[RideRequestColumns.pickupLat]),
      pickupLng: _toDouble(json[RideRequestColumns.pickupLng]),
      dropoffLat: _toDouble(json[RideRequestColumns.dropoffLat]),
      dropoffLng: _toDouble(json[RideRequestColumns.dropoffLng]),
      createdAt: DateTime.parse(json[RideRequestColumns.createdAt] as String),
      updatedAt: DateTime.parse(json[RideRequestColumns.updatedAt] as String),
      pickupAddress: json[RideRequestColumns.pickupAddress] as String?,
      dropoffAddress: json[RideRequestColumns.dropoffAddress] as String?,
      assignedDriverId: json[RideRequestColumns.assignedDriverId] as String?,
      productCode: json[RideRequestColumns.productCode] as String?,
      fareQuoteId: json[RideRequestColumns.fareQuoteId] as String?,
    );
  }

  RideEntity rideFromMap(Map<String, dynamic> json) {
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

  DriverLocationEntity driverLocationFromMap(Map<String, dynamic> json) {
    return DriverLocationEntity(
      driverId: json[DriverLocationColumns.driverId] as String,
      latitude: _toDouble(json[DriverLocationColumns.lat]),
      longitude: _toDouble(json[DriverLocationColumns.lng]),
      updatedAt: DateTime.parse(
        json[DriverLocationColumns.updatedAt] as String,
      ),
      heading: (json[DriverLocationColumns.heading] as num?)?.toDouble(),
      speedMps: (json[DriverLocationColumns.speedMps] as num?)?.toDouble(),
      accuracyM: (json[DriverLocationColumns.accuracyM] as num?)?.toDouble(),
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.parse(value.toString());
  }
}
