import 'dart:convert';

import '../spec/home_mobile_spec.dart';

enum PickupSheetMode { current, search, map }

enum ScheduleType { now, later }

enum HomeBottomTab { home, activity, account }

enum DestinationResolutionStatus { unresolved, resolving, resolved, error }

class TripDraft {
  const TripDraft({
    required this.pickupLabel,
    required this.pickupSecondary,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationLabel,
    required this.destinationSecondary,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.scheduleType,
    required this.scheduledAt,
    required this.selectedOfferId,
    required this.paymentMethod,
    required this.destinationResolutionStatus,
    required this.destinationResolutionError,
  });

  factory TripDraft.initial() {
    return const TripDraft(
      pickupLabel:
          '\u0645\u0648\u0642\u0639\u064a \u0627\u0644\u062d\u0627\u0644\u064a',
      pickupSecondary: 'GPS',
      pickupLat: 33.3152,
      pickupLng: 44.3661,
      destinationLabel: '',
      destinationSecondary: null,
      dropoffLat: 33.2989,
      dropoffLng: 44.3473,
      scheduleType: ScheduleType.now,
      scheduledAt: null,
      selectedOfferId: 'economy',
      paymentMethod: 'cash',
      destinationResolutionStatus: DestinationResolutionStatus.unresolved,
      destinationResolutionError: null,
    );
  }

  final String pickupLabel;
  final String pickupSecondary;
  final double pickupLat;
  final double pickupLng;
  final String destinationLabel;
  final String? destinationSecondary;
  final double dropoffLat;
  final double dropoffLng;
  final ScheduleType scheduleType;
  final DateTime? scheduledAt;
  final String selectedOfferId;
  final String paymentMethod;
  final DestinationResolutionStatus destinationResolutionStatus;
  final String? destinationResolutionError;

  bool get canRequestTrip =>
      destinationLabel.trim().isNotEmpty &&
      destinationResolutionStatus == DestinationResolutionStatus.resolved;

  TripOfferSpec get selectedOffer {
    return kTripOffers.firstWhere(
      (offer) => offer.id == selectedOfferId,
      orElse: () => kTripOffers.first,
    );
  }

  TripDraft copyWith({
    String? pickupLabel,
    String? pickupSecondary,
    double? pickupLat,
    double? pickupLng,
    String? destinationLabel,
    String? destinationSecondary,
    double? dropoffLat,
    double? dropoffLng,
    ScheduleType? scheduleType,
    DateTime? scheduledAt,
    String? selectedOfferId,
    String? paymentMethod,
    DestinationResolutionStatus? destinationResolutionStatus,
    String? destinationResolutionError,
    bool clearScheduledAt = false,
    bool clearDestinationResolutionError = false,
  }) {
    return TripDraft(
      pickupLabel: pickupLabel ?? this.pickupLabel,
      pickupSecondary: pickupSecondary ?? this.pickupSecondary,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      destinationLabel: destinationLabel ?? this.destinationLabel,
      destinationSecondary: destinationSecondary ?? this.destinationSecondary,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      scheduleType: scheduleType ?? this.scheduleType,
      scheduledAt: clearScheduledAt ? null : scheduledAt ?? this.scheduledAt,
      selectedOfferId: selectedOfferId ?? this.selectedOfferId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      destinationResolutionStatus:
          destinationResolutionStatus ?? this.destinationResolutionStatus,
      destinationResolutionError: clearDestinationResolutionError
          ? null
          : destinationResolutionError ?? this.destinationResolutionError,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'pickup_label': pickupLabel,
      'pickup_secondary': pickupSecondary,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'destination_label': destinationLabel,
      'destination_secondary': destinationSecondary,
      'dropoff_lat': dropoffLat,
      'dropoff_lng': dropoffLng,
      'schedule_type': scheduleType.name,
      'scheduled_at': scheduledAt?.toUtc().toIso8601String(),
      'selected_offer_id': selectedOfferId,
      'payment_method': paymentMethod,
      'destination_resolution_status': destinationResolutionStatus.name,
      'destination_resolution_error': destinationResolutionError,
    };
  }

  static TripDraft fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) {
      return TripDraft.initial();
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return TripDraft.initial();
    }

    final scheduleTypeRaw = decoded['schedule_type'] as String?;
    final scheduleType = scheduleTypeRaw == ScheduleType.later.name
        ? ScheduleType.later
        : ScheduleType.now;
    final destinationResolutionStatusRaw =
        decoded['destination_resolution_status'] as String?;
    final destinationResolutionStatus =
        switch (destinationResolutionStatusRaw) {
          'resolving' => DestinationResolutionStatus.resolving,
          'resolved' => DestinationResolutionStatus.resolved,
          'error' => DestinationResolutionStatus.error,
          _ => DestinationResolutionStatus.unresolved,
        };

    return TripDraft(
      pickupLabel:
          decoded['pickup_label'] as String? ??
          '\u0645\u0648\u0642\u0639\u064a \u0627\u0644\u062d\u0627\u0644\u064a',
      pickupSecondary: decoded['pickup_secondary'] as String? ?? 'GPS',
      pickupLat: _asDouble(decoded['pickup_lat'], 33.3152),
      pickupLng: _asDouble(decoded['pickup_lng'], 44.3661),
      destinationLabel: decoded['destination_label'] as String? ?? '',
      destinationSecondary: decoded['destination_secondary'] as String?,
      dropoffLat: _asDouble(decoded['dropoff_lat'], 33.2989),
      dropoffLng: _asDouble(decoded['dropoff_lng'], 44.3473),
      scheduleType: scheduleType,
      scheduledAt: DateTime.tryParse(decoded['scheduled_at'] as String? ?? ''),
      selectedOfferId: decoded['selected_offer_id'] as String? ?? 'economy',
      paymentMethod: decoded['payment_method'] as String? ?? 'cash',
      destinationResolutionStatus: destinationResolutionStatus,
      destinationResolutionError:
          decoded['destination_resolution_error'] as String?,
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static double _asDouble(dynamic value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }
}

class RiderHomeState {
  const RiderHomeState({
    required this.draft,
    required this.bottomTab,
    required this.isAccountSheetOpen,
    required this.isPickupSheetOpen,
    required this.isSchedulePanelOpen,
    required this.isScheduleCustomOpen,
    required this.scheduleValidationMessage,
    required this.isDestinationSuggestOpen,
    required this.destinationSuggestActiveIndex,
    required this.destinationSuggestions,
    required this.pickupSheetMode,
    required this.isPlaceEditOpen,
    required this.editingPlaceLabel,
  });

  factory RiderHomeState.initial() {
    return RiderHomeState(
      draft: TripDraft.initial(),
      bottomTab: HomeBottomTab.home,
      isAccountSheetOpen: false,
      isPickupSheetOpen: false,
      isSchedulePanelOpen: false,
      isScheduleCustomOpen: false,
      scheduleValidationMessage: null,
      isDestinationSuggestOpen: false,
      destinationSuggestActiveIndex: -1,
      destinationSuggestions: kDestinationSuggestionSeed,
      pickupSheetMode: PickupSheetMode.current,
      isPlaceEditOpen: false,
      editingPlaceLabel: null,
    );
  }

  final TripDraft draft;
  final HomeBottomTab bottomTab;
  final bool isAccountSheetOpen;
  final bool isPickupSheetOpen;
  final bool isSchedulePanelOpen;
  final bool isScheduleCustomOpen;
  final String? scheduleValidationMessage;
  final bool isDestinationSuggestOpen;
  final int destinationSuggestActiveIndex;
  final List<String> destinationSuggestions;
  final PickupSheetMode pickupSheetMode;
  final bool isPlaceEditOpen;
  final String? editingPlaceLabel;

  RiderHomeState copyWith({
    TripDraft? draft,
    HomeBottomTab? bottomTab,
    bool? isAccountSheetOpen,
    bool? isPickupSheetOpen,
    bool? isSchedulePanelOpen,
    bool? isScheduleCustomOpen,
    String? scheduleValidationMessage,
    bool clearScheduleValidationMessage = false,
    bool? isDestinationSuggestOpen,
    int? destinationSuggestActiveIndex,
    List<String>? destinationSuggestions,
    PickupSheetMode? pickupSheetMode,
    bool? isPlaceEditOpen,
    String? editingPlaceLabel,
    bool clearEditingLabel = false,
  }) {
    return RiderHomeState(
      draft: draft ?? this.draft,
      bottomTab: bottomTab ?? this.bottomTab,
      isAccountSheetOpen: isAccountSheetOpen ?? this.isAccountSheetOpen,
      isPickupSheetOpen: isPickupSheetOpen ?? this.isPickupSheetOpen,
      isSchedulePanelOpen: isSchedulePanelOpen ?? this.isSchedulePanelOpen,
      isScheduleCustomOpen: isScheduleCustomOpen ?? this.isScheduleCustomOpen,
      scheduleValidationMessage: clearScheduleValidationMessage
          ? null
          : scheduleValidationMessage ?? this.scheduleValidationMessage,
      isDestinationSuggestOpen:
          isDestinationSuggestOpen ?? this.isDestinationSuggestOpen,
      destinationSuggestActiveIndex:
          destinationSuggestActiveIndex ?? this.destinationSuggestActiveIndex,
      destinationSuggestions:
          destinationSuggestions ?? this.destinationSuggestions,
      pickupSheetMode: pickupSheetMode ?? this.pickupSheetMode,
      isPlaceEditOpen: isPlaceEditOpen ?? this.isPlaceEditOpen,
      editingPlaceLabel: clearEditingLabel
          ? null
          : editingPlaceLabel ?? this.editingPlaceLabel,
    );
  }
}
