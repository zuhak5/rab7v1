import '../entities/destination_resolution.dart';
import '../entities/rider_profile.dart';
import '../entities/saved_place.dart';
import '../entities/wallet_account.dart';

abstract class RiderHomeRepository {
  Future<WalletAccountEntity> getWalletAccount();

  Future<RiderProfileEntity?> getProfile();

  Future<List<SavedPlaceEntity>> getSavedPlaces();

  Future<void> savePlace(SavedPlaceEntity place);

  Future<DestinationResolutionEntity?> resolveDestination(String query);
}
