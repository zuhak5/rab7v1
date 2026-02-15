import 'package:flutter/material.dart';

import '../../domain/entities/saved_place.dart';
import '../spec/home_mobile_spec.dart';
import '../viewmodels/rider_home_state.dart';
import 'destination_input.dart';
import 'offers_carousel.dart';
import 'recent_places_row.dart';
import 'schedule_panel.dart';

class HomeMainSheet extends StatelessWidget {
  const HomeMainSheet({
    required this.metrics,
    required this.homeState,
    required this.destinationController,
    required this.savedPlaces,
    required this.walletLoading,
    required this.profileLoading,
    required this.walletHasError,
    required this.profileHasError,
    required this.onRetryAccountData,
    required this.onDestinationChanged,
    required this.onDestinationClear,
    required this.onDestinationSuggestTap,
    required this.onDestinationMove,
    required this.onDestinationOpen,
    required this.onDestinationClose,
    required this.onScheduleToggle,
    required this.onScheduleSetNow,
    required this.onScheduleSetDelay,
    required this.onScheduleSetCustom,
    required this.onScheduleCustomToggle,
    required this.onScheduleValidation,
    required this.onTripTap,
    required this.onDestinationRetry,
    required this.onHomeTap,
    required this.onHomeLongPress,
    required this.onWorkTap,
    required this.onWorkLongPress,
    required this.onRecentPlaceTap,
    super.key,
  });

  final HomeLayoutMetrics metrics;
  final RiderHomeState homeState;
  final TextEditingController destinationController;
  final Map<String, SavedPlaceEntity> savedPlaces;
  final bool walletLoading;
  final bool profileLoading;
  final bool walletHasError;
  final bool profileHasError;
  final VoidCallback onRetryAccountData;
  final ValueChanged<String> onDestinationChanged;
  final VoidCallback onDestinationClear;
  final ValueChanged<String> onDestinationSuggestTap;
  final ValueChanged<int> onDestinationMove;
  final VoidCallback onDestinationOpen;
  final VoidCallback onDestinationClose;
  final VoidCallback onScheduleToggle;
  final VoidCallback onScheduleSetNow;
  final ValueChanged<int> onScheduleSetDelay;
  final ValueChanged<DateTime> onScheduleSetCustom;
  final ValueChanged<bool> onScheduleCustomToggle;
  final ValueChanged<String?> onScheduleValidation;
  final VoidCallback onTripTap;
  final VoidCallback onDestinationRetry;
  final VoidCallback onHomeTap;
  final VoidCallback onHomeLongPress;
  final VoidCallback onWorkTap;
  final VoidCallback onWorkLongPress;
  final ValueChanged<String> onRecentPlaceTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final draft = homeState.draft;

    return Container(
      height: metrics.mainSheetHeight,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(HomeMobileSpec.sheetTopRadius),
        ),
        border: Border(
          top: BorderSide(color: colors.outline.withValues(alpha: 0.65)),
        ),
        boxShadow: HomeMobileSpec.elevationPrimary,
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          Container(
            width: HomeMobileSpec.sheetHandleWidth,
            height: HomeMobileSpec.sheetHandleHeight,
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                HomeMobileSpec.mainSheetHorizontalPadding,
                metrics.mainSheetTopPadding,
                HomeMobileSpec.mainSheetHorizontalPadding,
                HomeMobileSpec.mainSheetBottomPadding,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tightLayout = constraints.maxHeight < 420;
                  final showRecentAndOffers = constraints.maxHeight > 380;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Image 1 baseline: no "approx prices" info row on home.
                      if (walletLoading || profileLoading)
                        const _InfoBanner(
                          icon: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          message: 'جارٍ تحميل بيانات الحساب...',
                          actionLabel: null,
                          onAction: null,
                        ),
                      if (walletHasError || profileHasError)
                        _InfoBanner(
                          icon: const Icon(Icons.error_outline_rounded),
                          message: 'تعذر تحميل بعض بيانات الحساب.',
                          actionLabel: 'إعادة',
                          onAction: onRetryAccountData,
                          isError: true,
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: DestinationInput(
                              controller: destinationController,
                              suggestions: homeState.destinationSuggestions,
                              isSuggestOpen: homeState.isDestinationSuggestOpen,
                              activeSuggestionIndex:
                                  homeState.destinationSuggestActiveIndex,
                              onChanged: onDestinationChanged,
                              onClear: onDestinationClear,
                              onSuggestionTap: onDestinationSuggestTap,
                              onMoveSelection: onDestinationMove,
                              onOpenSuggestions: onDestinationOpen,
                              onCloseSuggestions: onDestinationClose,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SchedulePanel(
                            isOpen: homeState.isSchedulePanelOpen,
                            scheduleType: draft.scheduleType,
                            scheduledAt: draft.scheduledAt,
                            isCustomOpen: homeState.isScheduleCustomOpen,
                            validationMessage:
                                homeState.scheduleValidationMessage,
                            onToggle: onScheduleToggle,
                            onSetNow: onScheduleSetNow,
                            onSetDelay: onScheduleSetDelay,
                            onSetCustom: onScheduleSetCustom,
                            onCustomToggle: onScheduleCustomToggle,
                            onSetValidationMessage: onScheduleValidation,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: HomeMobileSpec.primaryButtonHeight,
                        child: FilledButton(
                          key: const ValueKey<String>(
                            'home_trip_options_button',
                          ),
                          // Image 1 shows this CTA as enabled (blue) even
                          // before a destination is resolved.
                          onPressed: onTripTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: const Text('عرض خيارات الرحلة'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _helperText(draft),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              draft.destinationResolutionStatus ==
                                  DestinationResolutionStatus.error
                              ? colors.error
                              : colors.onSurfaceVariant.withValues(alpha: 0.9),
                        ),
                      ),
                      if (draft.destinationResolutionStatus ==
                          DestinationResolutionStatus.error)
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed: onDestinationRetry,
                            child: const Text('إعادة تحديد الوجهة'),
                          ),
                        ),
                      SizedBox(height: metrics.mainSheetGap / 2),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _SavedPlaceCard(
                              icon: Icons.home_rounded,
                              title: 'المنزل',
                              subtitle:
                                  savedPlaces['home']?.addressLine1 ??
                                  'شارع الأميرات',
                              onTap: onHomeTap,
                              onLongPress: onHomeLongPress,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SavedPlaceCard(
                              icon: Icons.work_rounded,
                              title: 'العمل',
                              subtitle:
                                  savedPlaces['work']?.addressLine1 ??
                                  'ساحة الوثاق',
                              onTap: onWorkTap,
                              onLongPress: onWorkLongPress,
                            ),
                          ),
                        ],
                      ),
                      if (showRecentAndOffers) ...<Widget>[
                        SizedBox(height: metrics.mainSheetGap / 2),
                        RecentPlacesRow(onPlaceTap: onRecentPlaceTap),
                        SizedBox(height: metrics.mainSheetGap / 2),
                        SizedBox(
                          height: tightLayout ? 204 : 214,
                          child: const OffersCarousel(compact: true),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _helperText(TripDraft draft) {
    if (draft.destinationResolutionStatus ==
        DestinationResolutionStatus.resolving) {
      return 'جارٍ تحديد الوجهة على الخريطة...';
    }
    if (draft.destinationResolutionStatus ==
        DestinationResolutionStatus.error) {
      return draft.destinationResolutionError ?? 'تعذر تحديد موقع الوجهة.';
    }
    if (draft.canRequestTrip) {
      return 'يمكنك تعديل الالتقاط أو الوقت قبل المتابعة.';
    }
    return 'حدّد الوجهة لعرض خيارات الرحلة.';
  }
}

class _SavedPlaceCard extends StatelessWidget {
  const _SavedPlaceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onLongPress,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: HomeMobileSpec.cardMinHeight,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.55),
                ),
              ),
              child: Icon(icon, size: 20, color: colors.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.isError = false,
  });

  final Widget icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isError ? colors.errorContainer : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

