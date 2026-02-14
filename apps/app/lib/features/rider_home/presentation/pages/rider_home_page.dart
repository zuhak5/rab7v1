import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/route_paths.dart';
import '../../../auth/presentation/viewmodels/auth_controller.dart';
import '../../../maps/data/repositories/map_repository_impl.dart';
import '../../../maps/presentation/widgets/ride_map_widget.dart';
import '../../../rider_rides/presentation/viewmodels/rides_list_controller.dart';
import '../../domain/entities/saved_place.dart';
import '../spec/home_mobile_spec.dart';
import '../viewmodels/rider_home_controller.dart';
import '../viewmodels/rider_home_data_controller.dart';
import '../viewmodels/rider_home_state.dart';
import '../viewmodels/theme_mode_controller.dart';
import '../widgets/account_sheet.dart';
import '../widgets/bottom_nav_shell.dart';
import '../widgets/header_pill.dart';
import '../widgets/home_main_sheet.dart';
import '../widgets/pickup_overlay_sheet.dart';
import '../widgets/place_edit_overlay.dart';
import '../widgets/rider_marker.dart';
import '../widgets/rider_shell_layout.dart';

class RiderHomePage extends ConsumerStatefulWidget {
  const RiderHomePage({super.key});

  @override
  ConsumerState<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends ConsumerState<RiderHomePage> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _pickupSearchController = TextEditingController();
  final FocusNode _pageFocusNode = FocusNode();

  static const List<String> _pickupSuggestions = <String>[
    'ساحة الوثاق',
    'شارع الأميرات',
    'مول المنصور',
    'فندق بابل',
    'شارع المتنبي',
  ];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await ref.read(mapRepositoryProvider).ensureInitialized();
    });
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _pickupSearchController.dispose();
    _pageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(riderHomeControllerProvider.notifier);
    final homeState =
        ref.watch(riderHomeControllerProvider).valueOrNull ??
        RiderHomeState.initial();
    final draft = homeState.draft;

    final walletAsync = ref.watch(walletAccountProvider);
    final profileAsync = ref.watch(riderProfileProvider);
    final savedPlacesAsync = ref.watch(savedPlacesControllerProvider);
    final ridesAsync = ref.watch(ridesListControllerProvider);

    final savedPlaces =
        savedPlacesAsync.valueOrNull ?? const <String, SavedPlaceEntity>{};
    final walletValue = walletAsync.valueOrNull;
    final profileValue = profileAsync.valueOrNull;

    final activeRequest = ridesAsync.valueOrNull
        ?.where((request) => request.isActive)
        .firstOrNull;

    _syncDestinationField(draft.destinationLabel);

    final mediaSize = MediaQuery.sizeOf(context);
    final mediaPadding = MediaQuery.paddingOf(context);
    final metrics = HomeLayoutMetrics.fromViewport(
      size: mediaSize,
      safeArea: mediaPadding,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Focus(
        autofocus: true,
        focusNode: _pageFocusNode,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent ||
              event.logicalKey != LogicalKeyboardKey.escape) {
            return KeyEventResult.ignored;
          }
          if (_dismissTopLayer(homeState, controller)) {
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
            if (homeState.isDestinationSuggestOpen) {
              controller.setDestinationSuggestOpen(false);
            }
            if (homeState.isSchedulePanelOpen) {
              controller.setSchedulePanelOpen(false);
            }
          },
          child: Align(
            alignment: Alignment.topCenter,
            child: Transform.scale(
              scale: metrics.uiScale,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: HomeMobileSpec.designWidth,
                height: metrics.viewportHeight,
                child: RiderShellLayout(
                  metrics: metrics,
                  map: const IgnorePointer(
                    child: RideMapWidget(
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                    ),
                  ),
                  header: HeaderPill(
                    locationStatus: 'الالتقاط: ${draft.pickupLabel}',
                    avatarUrl: profileValue?.avatarUrl,
                    onRecenterTap: () async {
                      await ref.read(mapRepositoryProvider).ensureInitialized();
                    },
                    onPickupTap: controller.openPickupSheet,
                    onProfileTap: controller.openAccountSheet,
                  ),
                  marker: RiderMarker(avatarUrl: profileValue?.avatarUrl),
                  mainSheet: HomeMainSheet(
                    metrics: metrics,
                    homeState: homeState,
                    destinationController: _destinationController,
                    savedPlaces: savedPlaces,
                    activeRequest: activeRequest,
                    walletLoading: walletAsync.isLoading,
                    profileLoading: profileAsync.isLoading,
                    walletHasError: walletAsync.hasError,
                    profileHasError: profileAsync.hasError,
                    onRetryAccountData: () {
                      ref.invalidate(walletAccountProvider);
                      ref.invalidate(riderProfileProvider);
                    },
                    onDestinationChanged: controller.setDestinationLabel,
                    onDestinationClear: controller.clearDestination,
                    onDestinationSuggestTap: (value) {
                      controller.setDestinationLabel(value);
                      controller.setDestinationSuggestOpen(false);
                    },
                    onDestinationMove:
                        controller.moveDestinationSuggestionSelection,
                    onDestinationOpen: () {
                      if (_destinationController.text.trim().isNotEmpty) {
                        controller.setDestinationSuggestOpen(true);
                      }
                    },
                    onDestinationClose: () {
                      controller.setDestinationSuggestOpen(false);
                    },
                    onScheduleToggle: () {
                      controller.setSchedulePanelOpen(
                        !homeState.isSchedulePanelOpen,
                      );
                    },
                    onScheduleSetNow: controller.setScheduleNow,
                    onScheduleSetDelay: (minutes) {
                      controller.setScheduleAfterMinutes(minutes);
                      controller.setSchedulePanelOpen(false);
                    },
                    onScheduleSetCustom: (scheduledAt) {
                      controller.setScheduleCustom(scheduledAt);
                      controller.setSchedulePanelOpen(false);
                    },
                    onScheduleCustomToggle: controller.setScheduleCustomOpen,
                    onScheduleValidation:
                        controller.setScheduleValidationMessage,
                    onTripTap: () {
                      context.push(RoutePaths.tripOptions);
                    },
                    onDestinationRetry: () {
                      controller.setDestinationLabel(draft.destinationLabel);
                    },
                    onHomeTap: () {
                      final place = savedPlaces['home'];
                      if (place != null) {
                        controller.setDestinationFromSavedPlace(place);
                      } else {
                        controller.openPlaceEdit('home');
                      }
                    },
                    onHomeLongPress: () {
                      controller.openPlaceEdit('home');
                    },
                    onWorkTap: () {
                      final place = savedPlaces['work'];
                      if (place != null) {
                        controller.setDestinationFromSavedPlace(place);
                      } else {
                        controller.openPlaceEdit('work');
                      }
                    },
                    onWorkLongPress: () {
                      controller.openPlaceEdit('work');
                    },
                    onRecentPlaceTap: (value) {
                      if (value == 'المزيد') {
                        return;
                      }
                      controller.setDestinationLabel(value);
                    },
                    onOpenActiveRequest: () {
                      if (activeRequest == null) {
                        return;
                      }
                      context.go(
                        '${RoutePaths.findingDriver}?requestId=${activeRequest.id}',
                      );
                    },
                  ),
                  bottomNav: BottomNavShell(
                    activeTab: HomeBottomTab.home,
                    onTabSelected: (tab) {
                      controller.setBottomTab(tab);
                      switch (tab) {
                        case HomeBottomTab.home:
                          context.go(RoutePaths.rides);
                        case HomeBottomTab.activity:
                          context.go(RoutePaths.activity);
                        case HomeBottomTab.account:
                          context.go(RoutePaths.account);
                      }
                    },
                  ),
                  overlays: <Widget>[
                    PickupOverlaySheet(
                      isOpen: homeState.isPickupSheetOpen,
                      mode: homeState.pickupSheetMode,
                      searchController: _pickupSearchController,
                      suggestions: _pickupSuggestions,
                      onDismiss: controller.closePickupSheet,
                      onModeChanged: controller.setPickupMode,
                      onUseCurrent: controller.setPickupFromCurrentLocation,
                      onSuggestionTap: controller.setPickupFromSearch,
                      onConfirmMap: controller.closePickupSheet,
                    ),
                    PlaceEditOverlay(
                      isOpen: homeState.isPlaceEditOpen,
                      placeLabel: homeState.editingPlaceLabel ?? 'home',
                      initialValue:
                          savedPlaces[homeState.editingPlaceLabel ?? 'home']
                              ?.addressLine1 ??
                          '',
                      topInset: metrics.mainSheetTop,
                      onSave: (value) async {
                        final label = homeState.editingPlaceLabel ?? 'home';
                        await ref
                            .read(savedPlacesControllerProvider.notifier)
                            .savePlace(
                              SavedPlaceEntity(
                                label: label,
                                city: 'Baghdad',
                                addressLine1: value,
                                area: 'Baghdad',
                              ),
                            );
                        if (!mounted) {
                          return;
                        }
                        controller.closePlaceEdit();
                      },
                      onCancel: controller.closePlaceEdit,
                    ),
                    AccountSheet(
                      isOpen: homeState.isAccountSheetOpen,
                      topOffset:
                          metrics.headerTop + HomeMobileSpec.headerHeight + 12,
                      walletText: walletAsync.hasError
                          ? 'خطأ'
                          : walletValue == null
                          ? '—'
                          : _formatIqd(walletValue.balanceIqd),
                      isWalletLoading: walletAsync.isLoading,
                      isDarkMode:
                          (ref
                                  .watch(appThemeModeControllerProvider)
                                  .valueOrNull ??
                              ThemeMode.system) ==
                          ThemeMode.dark,
                      onDismiss: controller.closeAccountSheet,
                      onThemeToggle: () {
                        ref
                            .read(appThemeModeControllerProvider.notifier)
                            .toggleDark();
                      },
                      onWalletTap: () {
                        if (walletAsync.hasError) {
                          ref.invalidate(walletAccountProvider);
                        }
                        controller.closeAccountSheet();
                      },
                      onLogoutTap: () async {
                        controller.closeAccountSheet();
                        await ref
                            .read(authControllerProvider.notifier)
                            .signOut();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _dismissTopLayer(RiderHomeState state, RiderHomeController controller) {
    if (state.isPlaceEditOpen) {
      controller.closePlaceEdit();
      return true;
    }
    if (state.isPickupSheetOpen) {
      controller.closePickupSheet();
      return true;
    }
    if (state.isAccountSheetOpen) {
      controller.closeAccountSheet();
      return true;
    }
    if (state.isSchedulePanelOpen) {
      controller.setSchedulePanelOpen(false);
      return true;
    }
    if (state.isDestinationSuggestOpen) {
      controller.setDestinationSuggestOpen(false);
      return true;
    }
    return false;
  }

  String _formatIqd(int amount) {
    final text = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;
      buffer.write(text[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return '$buffer د.ع';
  }

  void _syncDestinationField(String destinationLabel) {
    if (_destinationController.text == destinationLabel) {
      return;
    }
    _destinationController.value = TextEditingValue(
      text: destinationLabel,
      selection: TextSelection.collapsed(offset: destinationLabel.length),
    );
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }
    return first;
  }
}
