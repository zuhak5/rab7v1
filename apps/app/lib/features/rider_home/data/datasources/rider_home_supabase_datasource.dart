import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/edge/edge_functions_client.dart';
import '../../../../data/supabase/schema_contract.dart';

class RiderHomeSupabaseDataSource {
  RiderHomeSupabaseDataSource({
    required SupabaseClient client,
    required EdgeFunctionsClient edgeFunctionsClient,
  }) : _client = client,
       _edgeFunctionsClient = edgeFunctionsClient;

  final SupabaseClient _client;
  final EdgeFunctionsClient _edgeFunctionsClient;

  Future<Map<String, dynamic>> getWalletAccount() async {
    final response = await _client.rpc<dynamic>(Rpcs.walletGetMyAccount);
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is Map) {
      return response.cast<String, dynamic>();
    }
    throw StateError('Unexpected wallet_get_my_account payload: $response');
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    final response = await _client
        .from(Tables.profiles)
        .select(
          '${ProfileColumns.id},'
          '${ProfileColumns.displayName},'
          '${ProfileColumns.phoneE164},'
          '${ProfileColumns.avatarObjectKey}',
        )
        .eq(ProfileColumns.id, userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }
    return Map<String, dynamic>.from(response);
  }

  Future<String?> getSignedAvatarUrl(String objectKey) {
    return _edgeFunctionsClient.profileAvatarDownload(objectKey: objectKey);
  }

  Future<List<Map<String, dynamic>>> listSavedPlaces() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return const <Map<String, dynamic>>[];
    }

    final response = await _client
        .from(Tables.customerAddresses)
        .select(
          '${CustomerAddressColumns.id},'
          '${CustomerAddressColumns.userId},'
          '${CustomerAddressColumns.label},'
          '${CustomerAddressColumns.city},'
          '${CustomerAddressColumns.area},'
          '${CustomerAddressColumns.addressLine1},'
          '${CustomerAddressColumns.addressLine2},'
          '${CustomerAddressColumns.loc},'
          '${CustomerAddressColumns.isDefault},'
          '${CustomerAddressColumns.updatedAt}',
        )
        .eq(CustomerAddressColumns.userId, userId)
        .order(CustomerAddressColumns.updatedAt, ascending: false)
        .limit(40);

    return response.map(Map<String, dynamic>.from).toList(growable: false);
  }

  Future<void> savePlace({
    required String label,
    required String city,
    required String addressLine1,
    String? area,
    String? addressLine2,
    bool isDefault = false,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('User session is required to save places.');
    }

    final payload = <String, dynamic>{
      CustomerAddressColumns.userId: userId,
      CustomerAddressColumns.label: label,
      CustomerAddressColumns.city: city,
      CustomerAddressColumns.area: area,
      CustomerAddressColumns.addressLine1: addressLine1,
      CustomerAddressColumns.addressLine2: addressLine2,
      CustomerAddressColumns.isDefault: isDefault,
    };

    final existing = await _client
        .from(Tables.customerAddresses)
        .select(CustomerAddressColumns.id)
        .eq(CustomerAddressColumns.userId, userId)
        .eq(CustomerAddressColumns.label, label)
        .maybeSingle();

    if (existing != null) {
      final existingId = existing[CustomerAddressColumns.id] as String?;
      if (existingId == null || existingId.isEmpty) {
        throw StateError(
          'customer_addresses row is missing id for label=$label',
        );
      }
      await _client
          .from(Tables.customerAddresses)
          .update(payload)
          .eq(CustomerAddressColumns.id, existingId);
      return;
    }

    await _client.from(Tables.customerAddresses).insert(payload);
  }

  Future<List<Map<String, dynamic>>> geocodeDestination(String query) async {
    final response = await _edgeFunctionsClient.geo(
      action: 'geocode',
      payload: <String, dynamic>{
        'query': query,
        'limit': 5,
        'language': 'ar',
        'region': 'IQ',
      },
    );

    final raw = response['data'];
    if (raw is! List) {
      return const <Map<String, dynamic>>[];
    }

    return raw
        .where((item) => item is Map || item is Map<String, dynamic>)
        .map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          }
          return (item as Map<dynamic, dynamic>).cast<String, dynamic>();
        })
        .toList(growable: false);
  }
}
