class SchemaContract {
  const SchemaContract._();
}

class Tables {
  const Tables._();

  static const rideRequests = 'ride_requests';
  static const rides = 'rides';
  static const driverLocations = 'driver_locations';
  static const profiles = 'profiles';
  static const rideProducts = 'ride_products';
  static const fareQuotes = 'fare_quotes';
  static const customerAddresses = 'customer_addresses';
}

class RideRequestColumns {
  const RideRequestColumns._();

  static const id = 'id';
  static const riderId = 'rider_id';
  static const pickupLat = 'pickup_lat';
  static const pickupLng = 'pickup_lng';
  static const dropoffLat = 'dropoff_lat';
  static const dropoffLng = 'dropoff_lng';
  static const pickupAddress = 'pickup_address';
  static const dropoffAddress = 'dropoff_address';
  static const status = 'status';
  static const assignedDriverId = 'assigned_driver_id';
  static const quoteAmountIqd = 'quote_amount_iqd';
  static const currency = 'currency';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
  static const matchedAt = 'matched_at';
  static const productCode = 'product_code';
  static const fareQuoteId = 'fare_quote_id';
  static const paymentMethod = 'payment_method';
}

class RideColumns {
  const RideColumns._();

  static const id = 'id';
  static const requestId = 'request_id';
  static const riderId = 'rider_id';
  static const driverId = 'driver_id';
  static const status = 'status';
  static const version = 'version';
  static const fareAmountIqd = 'fare_amount_iqd';
  static const currency = 'currency';
  static const productCode = 'product_code';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}

class DriverLocationColumns {
  const DriverLocationColumns._();

  static const driverId = 'driver_id';
  static const lat = 'lat';
  static const lng = 'lng';
  static const heading = 'heading';
  static const speedMps = 'speed_mps';
  static const accuracyM = 'accuracy_m';
  static const updatedAt = 'updated_at';
}

class CustomerAddressColumns {
  const CustomerAddressColumns._();

  static const id = 'id';
  static const userId = 'user_id';
  static const label = 'label';
  static const city = 'city';
  static const area = 'area';
  static const addressLine1 = 'address_line1';
  static const addressLine2 = 'address_line2';
  static const loc = 'loc';
  static const isDefault = 'is_default';
  static const updatedAt = 'updated_at';
}

class ProfileColumns {
  const ProfileColumns._();

  static const id = 'id';
  static const displayName = 'display_name';
  static const phoneE164 = 'phone_e164';
  static const avatarObjectKey = 'avatar_object_key';
  static const activeRole = 'active_role';
  static const roleOnboardingCompleted = 'role_onboarding_completed';
  static const locale = 'locale';
}

class Rpcs {
  const Rpcs._();

  static const getMyAppContext = 'get_my_app_context';
  static const setMyActiveRole = 'set_my_active_role';
  static const cancelRideRequest = 'cancel_ride_request';
  static const driversNearbyUserV1 = 'drivers_nearby_user_v1';
  static const dispatchMatchRideUser = 'dispatch_match_ride_user';
  static const transitionRideUserV1 = 'transition_ride_user_v1';
  static const walletGetMyAccount = 'wallet_get_my_account';
}

class EdgeFns {
  const EdgeFns._();

  static const fareEngine = 'fare-engine';
  static const matchRide = 'match-ride';
  static const rideTransition = 'ride-transition';
  static const mapsConfigV2 = 'maps-config-v2';
  static const mapsUsage = 'maps-usage';
  static const geo = 'geo';
  static const ablyToken = 'ably-token';
  static const deviceTokenUpsert = 'device-token-upsert';
  static const profileAvatarUrl = 'profile-avatar-url';
}

class RealtimeTopics {
  const RealtimeTopics._();

  static String nearbyGeohash6(String geohash6) => 'nearby:gh6:$geohash6';
  static String ownDriverLocation(String userId) => 'loc:driver:$userId';
}
