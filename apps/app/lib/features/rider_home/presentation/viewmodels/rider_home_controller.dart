import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/di/providers.dart';
import '../../domain/entities/saved_place.dart';
import '../spec/home_mobile_spec.dart';
import 'rider_home_state.dart';

final riderHomeControllerProvider =
    AsyncNotifierProvider<RiderHomeController, RiderHomeState>(
      RiderHomeController.new,
    );

class RiderHomeController extends AsyncNotifier<RiderHomeState> {
  static const _draftStorageKey = 'sr.tripDraft';
  static const _destinationResolveDebounce = Duration(milliseconds: 500);

  Timer? _destinationResolveTimer;
  var _destinationResolveToken = 0;

  @override
  Future<RiderHomeState> build() async {
    ref.onDispose(() {
      _destinationResolveTimer?.cancel();
    });

    final prefs = await SharedPreferences.getInstance();
    final draftRaw = prefs.getString(_draftStorageKey);
    return RiderHomeState.initial().copyWith(
      draft: TripDraft.fromJsonString(draftRaw),
    );
  }

  void setBottomTab(HomeBottomTab tab) {
    _mutate((current) => current.copyWith(bottomTab: tab));
  }

  void openAccountSheet() {
    _mutate((current) => current.copyWith(isAccountSheetOpen: true));
  }

  void closeAccountSheet() {
    _mutate((current) => current.copyWith(isAccountSheetOpen: false));
  }

  void openPickupSheet() {
    _mutate((current) => current.copyWith(isPickupSheetOpen: true));
  }

  void closePickupSheet() {
    _mutate(
      (current) => current.copyWith(
        isPickupSheetOpen: false,
        pickupSheetMode: PickupSheetMode.current,
      ),
    );
  }

  void setPickupMode(PickupSheetMode mode) {
    _mutate((current) => current.copyWith(pickupSheetMode: mode));
  }

  void setSchedulePanelOpen(bool isOpen) {
    _mutate((current) {
      return current.copyWith(
        isSchedulePanelOpen: isOpen,
        isScheduleCustomOpen: isOpen ? current.isScheduleCustomOpen : false,
        clearScheduleValidationMessage: true,
      );
    });
  }

  void setScheduleCustomOpen(bool isOpen) {
    _mutate((current) {
      return current.copyWith(
        isScheduleCustomOpen: isOpen,
        clearScheduleValidationMessage: true,
      );
    });
  }

  void setScheduleValidationMessage(String? message) {
    _mutate((current) {
      return current.copyWith(
        scheduleValidationMessage: message,
        clearScheduleValidationMessage: message == null,
      );
    });
  }

  void setDestinationSuggestOpen(bool isOpen) {
    _mutate((current) {
      return current.copyWith(
        isDestinationSuggestOpen: isOpen,
        destinationSuggestActiveIndex: isOpen ? 0 : -1,
      );
    });
  }

  void moveDestinationSuggestionSelection(int delta) {
    _mutate((current) {
      if (!current.isDestinationSuggestOpen ||
          current.destinationSuggestions.isEmpty) {
        return current;
      }
      final maxIndex = current.destinationSuggestions.length - 1;
      final next = (current.destinationSuggestActiveIndex + delta).clamp(
        0,
        maxIndex,
      );
      return current.copyWith(destinationSuggestActiveIndex: next);
    });
  }

  void commitDestinationSuggestion([int? index]) {
    final current = state.valueOrNull ?? RiderHomeState.initial();
    if (current.destinationSuggestions.isEmpty) {
      return;
    }
    final suggestionIndex = (index ?? current.destinationSuggestActiveIndex)
        .clamp(0, current.destinationSuggestions.length - 1);
    final value = current.destinationSuggestions[suggestionIndex];
    setDestinationLabel(value);
    _mutate((after) {
      return after.copyWith(
        isDestinationSuggestOpen: false,
        destinationSuggestActiveIndex: -1,
      );
    });
  }

  void setDestinationLabel(String value) {
    _destinationResolveTimer?.cancel();

    final normalized = value.trim();
    _mutate((current) {
      final suggestions = _filterDestinationSuggestions(normalized);
      return current.copyWith(
        draft: current.draft.copyWith(
          destinationLabel: value,
          destinationSecondary: null,
          destinationResolutionStatus: normalized.isEmpty
              ? DestinationResolutionStatus.unresolved
              : DestinationResolutionStatus.resolving,
          clearDestinationResolutionError: true,
        ),
        destinationSuggestions: suggestions,
        destinationSuggestActiveIndex: suggestions.isEmpty ? -1 : 0,
        isDestinationSuggestOpen: normalized.isNotEmpty,
      );
    }, persistDraft: true);

    if (normalized.isEmpty) {
      return;
    }
    _queueDestinationResolution(normalized);
  }

  void clearDestination() {
    _destinationResolveTimer?.cancel();
    _mutate((current) {
      return current.copyWith(
        draft: current.draft.copyWith(
          destinationLabel: '',
          destinationSecondary: null,
          destinationResolutionStatus: DestinationResolutionStatus.unresolved,
          clearDestinationResolutionError: true,
        ),
        destinationSuggestions: kDestinationSuggestionSeed,
        isDestinationSuggestOpen: false,
        destinationSuggestActiveIndex: -1,
      );
    }, persistDraft: true);
  }

  void setPickupFromCurrentLocation() {
    _mutate((current) {
      return current.copyWith(
        draft: current.draft.copyWith(
          pickupLabel: 'موقعي الحالي',
          pickupSecondary: 'GPS',
          pickupLat: 33.3152,
          pickupLng: 44.3661,
        ),
        isPickupSheetOpen: false,
        pickupSheetMode: PickupSheetMode.current,
      );
    }, persistDraft: true);
  }

  void setPickupFromSearch(String label) {
    _mutate((current) {
      return current.copyWith(
        draft: current.draft.copyWith(
          pickupLabel: label,
          pickupSecondary: 'محدد',
        ),
        isPickupSheetOpen: false,
        pickupSheetMode: PickupSheetMode.current,
      );
    }, persistDraft: true);
  }

  void setDestinationFromSavedPlace(SavedPlaceEntity place) {
    _destinationResolveTimer?.cancel();

    final placeLat = place.latitude;
    final placeLng = place.longitude;
    if (placeLat != null && placeLng != null) {
      _mutate((current) {
        return current.copyWith(
          draft: current.draft.copyWith(
            destinationLabel: place.addressLine1,
            destinationSecondary: place.area ?? place.city,
            dropoffLat: placeLat,
            dropoffLng: placeLng,
            destinationResolutionStatus: DestinationResolutionStatus.resolved,
            clearDestinationResolutionError: true,
          ),
          isDestinationSuggestOpen: false,
          destinationSuggestActiveIndex: -1,
        );
      }, persistDraft: true);
      return;
    }

    _mutate((current) {
      return current.copyWith(
        draft: current.draft.copyWith(
          destinationLabel: place.addressLine1,
          destinationSecondary: place.area ?? place.city,
          destinationResolutionStatus: DestinationResolutionStatus.resolving,
          clearDestinationResolutionError: true,
        ),
        isDestinationSuggestOpen: false,
        destinationSuggestActiveIndex: -1,
      );
    }, persistDraft: true);

    _queueDestinationResolution(place.addressLine1, immediate: true);
  }

  void setScheduleNow() {
    _mutate((current) {
      return current.copyWith(
        draft: current.draft.copyWith(
          scheduleType: ScheduleType.now,
          clearScheduledAt: true,
        ),
        isScheduleCustomOpen: false,
        clearScheduleValidationMessage: true,
      );
    }, persistDraft: true);
  }

  void setScheduleAfterMinutes(int minutes) {
    final scheduledAt = DateTime.now().add(Duration(minutes: minutes));
    _mutate((current) {
      return current.copyWith(
        draft: current.draft.copyWith(
          scheduleType: ScheduleType.later,
          scheduledAt: scheduledAt,
        ),
        clearScheduleValidationMessage: true,
      );
    }, persistDraft: true);
  }

  void setScheduleCustom(DateTime scheduledAt) {
    _mutate((current) {
      return current.copyWith(
        draft: current.draft.copyWith(
          scheduleType: ScheduleType.later,
          scheduledAt: scheduledAt,
        ),
        clearScheduleValidationMessage: true,
      );
    }, persistDraft: true);
  }

  void setSelectedOffer(String offerId) {
    _mutate((current) {
      return current.copyWith(
        draft: current.draft.copyWith(selectedOfferId: offerId),
      );
    }, persistDraft: true);
  }

  void setPaymentMethod(String method) {
    _mutate((current) {
      return current.copyWith(
        draft: current.draft.copyWith(paymentMethod: method),
      );
    }, persistDraft: true);
  }

  void togglePaymentMethod() {
    final draft = state.valueOrNull?.draft;
    if (draft == null) {
      return;
    }
    setPaymentMethod(draft.paymentMethod == 'cash' ? 'card' : 'cash');
  }

  void openPlaceEdit(String placeLabel) {
    _mutate(
      (current) => current.copyWith(
        isPlaceEditOpen: true,
        editingPlaceLabel: placeLabel,
      ),
    );
  }

  void closePlaceEdit() {
    _mutate(
      (current) =>
          current.copyWith(isPlaceEditOpen: false, clearEditingLabel: true),
    );
  }

  void _mutate(
    RiderHomeState Function(RiderHomeState current) transformer, {
    bool persistDraft = false,
  }) {
    final current = state.valueOrNull ?? RiderHomeState.initial();
    final next = transformer(current);
    state = AsyncValue<RiderHomeState>.data(next);

    if (persistDraft) {
      _persistDraft(next.draft);
    }
  }

  Future<void> _persistDraft(TripDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftStorageKey, draft.toJsonString());
  }

  List<String> _filterDestinationSuggestions(String query) {
    if (query.isEmpty) {
      return kDestinationSuggestionSeed;
    }
    final normalized = query.toLowerCase();
    final filtered = kDestinationSuggestionSeed
        .where((item) => item.toLowerCase().contains(normalized))
        .toList(growable: false);
    if (filtered.isNotEmpty) {
      return filtered;
    }
    return <String>[query];
  }

  void _queueDestinationResolution(String query, {bool immediate = false}) {
    final token = ++_destinationResolveToken;
    if (immediate) {
      unawaited(_resolveDestination(query: query, token: token));
      return;
    }
    _destinationResolveTimer = Timer(_destinationResolveDebounce, () {
      unawaited(_resolveDestination(query: query, token: token));
    });
  }

  Future<void> _resolveDestination({
    required String query,
    required int token,
  }) async {
    try {
      final resolved = await ref
          .read(riderHomeRepositoryProvider)
          .resolveDestination(query);

      if (token != _destinationResolveToken) {
        return;
      }

      if (resolved == null) {
        _mutate((current) {
          return current.copyWith(
            draft: current.draft.copyWith(
              destinationResolutionStatus: DestinationResolutionStatus.error,
              destinationResolutionError:
                  'تعذر تحديد الإحداثيات. اختر وجهة أوضح ثم أعد المحاولة.',
            ),
          );
        }, persistDraft: true);
        return;
      }

      _mutate((current) {
        return current.copyWith(
          draft: current.draft.copyWith(
            destinationLabel: current.draft.destinationLabel,
            destinationSecondary: resolved.secondary ?? resolved.label,
            dropoffLat: resolved.latitude,
            dropoffLng: resolved.longitude,
            destinationResolutionStatus: DestinationResolutionStatus.resolved,
            clearDestinationResolutionError: true,
          ),
        );
      }, persistDraft: true);
    } catch (_) {
      if (token != _destinationResolveToken) {
        return;
      }
      _mutate((current) {
        return current.copyWith(
          draft: current.draft.copyWith(
            destinationResolutionStatus: DestinationResolutionStatus.error,
            destinationResolutionError:
                'فشل الاتصال بخدمة الخرائط. تحقق من الاتصال ثم أعد المحاولة.',
          ),
        );
      }, persistDraft: true);
    }
  }
}
