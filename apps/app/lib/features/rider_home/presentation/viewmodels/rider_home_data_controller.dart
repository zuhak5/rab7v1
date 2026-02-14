import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../domain/entities/rider_profile.dart';
import '../../domain/entities/saved_place.dart';
import '../../domain/entities/wallet_account.dart';

final walletAccountProvider = FutureProvider.autoDispose<WalletAccountEntity>((
  ref,
) {
  final repository = ref.watch(riderHomeRepositoryProvider);
  return repository.getWalletAccount();
});

final riderProfileProvider = FutureProvider.autoDispose<RiderProfileEntity?>((
  ref,
) {
  final repository = ref.watch(riderHomeRepositoryProvider);
  return repository.getProfile();
});

class SavedPlacesController
    extends AutoDisposeAsyncNotifier<Map<String, SavedPlaceEntity>> {
  @override
  Future<Map<String, SavedPlaceEntity>> build() async {
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncValue<Map<String, SavedPlaceEntity>>.loading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> savePlace(SavedPlaceEntity place) async {
    await ref.read(riderHomeRepositoryProvider).savePlace(place);
    await refresh();
  }

  Future<Map<String, SavedPlaceEntity>> _load() async {
    final rows = await ref.read(riderHomeRepositoryProvider).getSavedPlaces();
    final mapped = <String, SavedPlaceEntity>{};
    for (final place in rows) {
      final label = place.label.toLowerCase();
      mapped[label] = place;
    }
    return mapped;
  }
}

final savedPlacesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      SavedPlacesController,
      Map<String, SavedPlaceEntity>
    >(SavedPlacesController.new);
