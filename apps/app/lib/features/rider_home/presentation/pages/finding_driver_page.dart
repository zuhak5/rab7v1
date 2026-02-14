import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../router/route_paths.dart';
import '../../../maps/presentation/widgets/ride_map_widget.dart';
import '../../../rider_rides/presentation/viewmodels/rides_list_controller.dart';
import '../spec/home_mobile_spec.dart';
import '../viewmodels/finding_driver_controller.dart';
import '../viewmodels/ride_status_presentation.dart';
import '../viewmodels/rider_home_controller.dart';
import '../viewmodels/rider_home_state.dart';

class FindingDriverPage extends ConsumerWidget {
  const FindingDriverPage({required this.requestId, super.key});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestAsync = ref.watch(watchRideRequestProvider(requestId));
    final rideAsync = ref.watch(watchRideByRequestProvider(requestId));
    final homeState =
        ref.watch(riderHomeControllerProvider).valueOrNull ??
        RiderHomeState.initial();
    final draft = homeState.draft;
    final offer = draft.selectedOffer;

    final request = requestAsync.valueOrNull;
    final ride = rideAsync.valueOrNull;
    final status = ride?.status ?? request?.status ?? 'requested';
    final statusPresentation = mapRideStatusPresentation(status);
    final stage = statusPresentation.stage;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: IgnorePointer(
              child: RideMapWidget(
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 16,
            right: 16,
            child: _FindingHeader(
              pickup: draft.pickupLabel,
              destination: draft.destinationLabel,
              onBack: () => context.go(RoutePaths.rides),
              onMenu: () => context.go(RoutePaths.rides),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 560),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: 12 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(
                  top: BorderSide(color: colors.outline.withValues(alpha: 0.8)),
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.18),
                    blurRadius: 18,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: HomeMobileSpec.sheetHandleWidth,
                      height: HomeMobileSpec.sheetHandleHeight,
                      decoration: BoxDecoration(
                        color: colors.onSurface.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ProgressTimeline(stage: stage),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          statusPresentation.helperText,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: statusPresentation.isTerminal
                                ? colors.error
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusPresentation.isTerminal
                              ? colors.error.withValues(alpha: 0.1)
                              : colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusPresentation.displayStatus,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: statusPresentation.isTerminal
                                ? colors.error
                                : colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _TripSummaryCard(
                    pickupLabel: draft.pickupLabel,
                    pickupSub: draft.pickupSecondary,
                    destinationLabel: draft.destinationLabel,
                    destinationSub: draft.destinationSecondary ?? '—',
                    offer: offer,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: statusPresentation.isTerminal
                              ? null
                              : () => context.go(RoutePaths.rides),
                          icon: const Icon(Icons.edit_location_alt_rounded),
                          label: const Text('تعديل الالتقاط'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: statusPresentation.isTerminal
                              ? null
                              : () => context.go(RoutePaths.tripOptions),
                          icon: const Icon(Icons.directions_car_rounded),
                          label: const Text('تغيير نوع الرحلة'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'الدفع: ${draft.paymentMethod == 'card' ? 'بطاقة' : 'نقدًا'}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.tonal(
                      onPressed: statusPresentation.isTerminal
                          ? null
                          : () async {
                              await _cancel(context, ref);
                            },
                      style: FilledButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.close_rounded, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'إلغاء الطلب',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(cancelRideRequestUseCaseProvider)(requestId);
      await ref.read(ridesListControllerProvider.notifier).refresh();
      if (!context.mounted) {
        return;
      }
      context.go(RoutePaths.rides);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إلغاء الطلب: $error')),
      );
    }
  }
}

class _FindingHeader extends StatelessWidget {
  const _FindingHeader({
    required this.pickup,
    required this.destination,
    required this.onBack,
    required this.onMenu,
  });

  final String pickup;
  final String destination;
  final VoidCallback onBack;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.12),
            blurRadius: 14,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.circle, size: 10, color: HomeMobileSpec.primary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    pickup,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text('→', style: TextStyle(color: colors.onSurfaceVariant)),
                const SizedBox(width: 8),
                const Icon(Icons.circle, size: 10, color: Colors.red),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    destination.isEmpty ? 'المنزل' : destination,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMenu,
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
    );
  }
}

class _ProgressTimeline extends StatelessWidget {
  const _ProgressTimeline({required this.stage});

  final int stage;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _stepDot(Icons.check_rounded, stage >= 1, stage == 1),
            Expanded(
              child: Divider(
                color: stage >= 2 ? colors.primary : colors.outline,
                thickness: 1.4,
              ),
            ),
            _stepDot(Icons.search_rounded, stage >= 2, stage == 2),
            Expanded(
              child: Divider(
                color: stage >= 3 ? colors.primary : colors.outline,
                thickness: 1.4,
              ),
            ),
            _stepDot(Icons.person_rounded, stage >= 3, stage == 3),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'تم الإرسال',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),
            Text(
              'جارٍ البحث',
              style: TextStyle(
                fontSize: 10,
                fontWeight: stage >= 2 ? FontWeight.w800 : FontWeight.w600,
                color: stage >= 2 ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
            Text(
              'بانتظار القبول',
              style: TextStyle(
                fontSize: 10,
                fontWeight: stage >= 3 ? FontWeight.w800 : FontWeight.w600,
                color: stage >= 3 ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepDot(IconData icon, bool active, bool glowing) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? HomeMobileSpec.primary : Colors.transparent,
        border: Border.all(
          color: active ? HomeMobileSpec.primary : Colors.grey,
        ),
        boxShadow: glowing
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color.fromRGBO(0, 86, 210, 0.24),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Icon(icon, size: 14, color: active ? Colors.white : Colors.grey),
    );
  }
}

class _TripSummaryCard extends StatelessWidget {
  const _TripSummaryCard({
    required this.pickupLabel,
    required this.pickupSub,
    required this.destinationLabel,
    required this.destinationSub,
    required this.offer,
  });

  final String pickupLabel;
  final String pickupSub;
  final String destinationLabel;
  final String destinationSub;
  final TripOfferSpec offer;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: <Widget>[
          _pointRow(
            color: HomeMobileSpec.primary,
            title: pickupLabel,
            subtitle: pickupSub,
          ),
          const SizedBox(height: 10),
          _pointRow(
            color: Colors.red,
            title: destinationLabel,
            subtitle: destinationSub,
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Image.network(
                offer.imageUrl,
                width: 40,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(width: 40, height: 32),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      offer.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${offer.seats} ركاب',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pointRow({
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Builder(
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return Row(
          children: <Widget>[
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1),
              ),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
