import '../../domain/entities/destination_resolution.dart';
import '../../domain/entities/rider_profile.dart';
import '../../domain/entities/saved_place.dart';
import '../../domain/entities/wallet_account.dart';
import '../../domain/repositories/rider_home_repository.dart';
import '../datasources/rider_home_supabase_datasource.dart';

class RiderHomeRepositoryImpl implements RiderHomeRepository {
  RiderHomeRepositoryImpl(this._dataSource);

  final RiderHomeSupabaseDataSource _dataSource;

  @override
  Future<RiderProfileEntity?> getProfile() async {
    final payload = await _dataSource.getProfile();
    if (payload == null) {
      return null;
    }

    final avatarObjectKey = payload['avatar_object_key'] as String?;
    String? avatarUrl;
    if (avatarObjectKey != null && avatarObjectKey.isNotEmpty) {
      avatarUrl = await _dataSource.getSignedAvatarUrl(avatarObjectKey);
    }

    final id = payload['id'] as String?;
    if (id == null || id.isEmpty) {
      return null;
    }

    return RiderProfileEntity(
      id: id,
      displayName: payload['display_name'] as String?,
      phoneE164: payload['phone_e164'] as String?,
      avatarObjectKey: avatarObjectKey,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<List<SavedPlaceEntity>> getSavedPlaces() async {
    final rows = await _dataSource.listSavedPlaces();
    return rows
        .map(
          (row) {
            final point = _extractLatLngFromPoint(row['loc']);
            return SavedPlaceEntity(
              id: row['id'] as String?,
              label: (row['label'] as String? ?? '').toLowerCase(),
              city: row['city'] as String? ?? 'Baghdad',
              area: row['area'] as String?,
              addressLine1: row['address_line1'] as String? ?? '',
              addressLine2: row['address_line2'] as String?,
              latitude: point?.$1,
              longitude: point?.$2,
              isDefault: row['is_default'] as bool? ?? false,
              updatedAt: _asDateTime(row['updated_at']),
            );
          },
        )
        .where((place) => place.addressLine1.trim().isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<void> savePlace(SavedPlaceEntity place) {
    return _dataSource.savePlace(
      label: place.label.toLowerCase(),
      city: place.city,
      addressLine1: place.addressLine1,
      area: place.area,
      addressLine2: place.addressLine2,
      isDefault: place.isDefault,
    );
  }

  @override
  Future<WalletAccountEntity> getWalletAccount() async {
    final payload = await _dataSource.getWalletAccount();
    final balance = _asInt(payload['balance_iqd']);
    final held = _asInt(payload['held_iqd']);

    return WalletAccountEntity(
      balanceIqd: balance,
      heldIqd: held,
      currency: payload['currency'] as String? ?? 'IQD',
      updatedAt:
          _asDateTime(payload['updated_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  Future<DestinationResolutionEntity?> resolveDestination(String query) async {
    final rows = await _dataSource.geocodeDestination(query.trim());
    for (final row in rows) {
      final location = row['location'];
      if (location is! Map) {
        continue;
      }
      final lat = _asDouble(location['lat']);
      final lng = _asDouble(location['lng']);
      if (lat == null || lng == null) {
        continue;
      }

      final label = (row['label'] as String?)?.trim();
      return DestinationResolutionEntity(
        label: label == null || label.isEmpty ? query : label,
        latitude: lat,
        longitude: lng,
      );
    }
    return null;
  }

  DateTime? _asDateTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  double? _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  (double, double)? _extractLatLngFromPoint(dynamic value) {
    if (value is Map) {
      final map = value.cast<String, dynamic>();
      final coordinates = map['coordinates'];
      if (coordinates is List && coordinates.length >= 2) {
        final lng = _asDouble(coordinates[0]);
        final lat = _asDouble(coordinates[1]);
        if (lat != null && lng != null) {
          return (lat, lng);
        }
      }
    }

    if (value is String) {
      final match = RegExp(
        r'POINT\s*\(\s*([\-0-9.]+)\s+([\-0-9.]+)\s*\)',
        caseSensitive: false,
      ).firstMatch(value);
      if (match != null) {
        final lng = _asDouble(match.group(1));
        final lat = _asDouble(match.group(2));
        if (lat != null && lng != null) {
          return (lat, lng);
        }
      }
    }

    return null;
  }
}
