import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/providers.dart';
import '../../../../router/route_paths.dart';
import '../../../maps/presentation/widgets/ride_map_widget.dart';
import '../../../rider_rides/domain/repositories/rides_repository.dart';
import '../../../rider_rides/presentation/viewmodels/rides_list_controller.dart';
import '../spec/home_mobile_spec.dart';
import '../viewmodels/rider_home_controller.dart';
import '../viewmodels/rider_home_state.dart';
import '../widgets/route_pill_header.dart';

class TripOptionsPage extends ConsumerStatefulWidget {
  const TripOptionsPage({super.key});

  @override
  ConsumerState<TripOptionsPage> createState() => _TripOptionsPageState();
}

class _TripOptionsPageState extends ConsumerState<TripOptionsPage> {
  bool _submitting = false;
  String? _pressedOfferId;

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(riderHomeControllerProvider.notifier);
    final homeState =
        ref.watch(riderHomeControllerProvider).valueOrNull ??
        RiderHomeState.initial();
    final draft = homeState.draft;
    final selectedOffer = draft.selectedOffer;
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
            child: RoutePillHeader(
              pickup: draft.pickupLabel,
              destination: draft.destinationLabel,
              onBack: () => context.pop(),
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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'الأسعار تقريبية',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 186,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: kTripOffers.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final offer = kTripOffers[index];
                        final selected = offer.id == selectedOffer.id;
                        final pressed = offer.id == _pressedOfferId;
                        return _TripOfferCard(
                          key: ValueKey<String>('trip_offer_${offer.id}'),
                          offer: offer,
                          selected: selected,
                          pressed: pressed,
                          onTap: () => controller.setSelectedOffer(offer.id),
                          onPressChanged: (isPressed) {
                            setState(() {
                              _pressedOfferId = isPressed ? offer.id : null;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PaymentRow(
                    method: draft.paymentMethod,
                    onTap: controller.togglePaymentMethod,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: FilledButton(
                      key: const ValueKey<String>('trip_request_button'),
                      onPressed: _submitting || !draft.canRequestTrip
                          ? null
                          : () async {
                              await _requestRide(context, draft, selectedOffer);
                            },
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.bolt_rounded, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _submitting ? 'جارٍ الطلب...' : 'اطلب الآن',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              key: const ValueKey<String>('trip_cta_price_text'),
                              '${_formatIqd(selectedOffer.priceIqd)} د.ع',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    draft.destinationResolutionStatus ==
                            DestinationResolutionStatus.error
                        ? (draft.destinationResolutionError ??
                              'تعذر تأكيد إحداثيات الوجهة.')
                        : draft.destinationResolutionStatus ==
                              DestinationResolutionStatus.resolving
                        ? 'جارٍ تأكيد موقع الوجهة...'
                        : 'بالضغط، أنت توافق على شروط الخدمة للرحلات السريعة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color:
                          draft.destinationResolutionStatus ==
                              DestinationResolutionStatus.error
                          ? colors.error
                          : colors.onSurfaceVariant,
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
    return buffer.toString();
  }

  Future<void> _requestRide(
    BuildContext context,
    TripDraft draft,
    TripOfferSpec offer,
  ) async {
    if (!draft.canRequestTrip) {
      final message = draft.destinationResolutionStatus ==
              DestinationResolutionStatus.resolving
          ? 'جارٍ تأكيد الوجهة. انتظر لحظات ثم أعد المحاولة.'
          : draft.destinationResolutionError ??
                'حدد الوجهة بشكل أوضح أولًا.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final useCase = ref.read(createRideRequestUseCaseProvider);
      final request = await useCase(
        CreateRideRequestInput(
          pickupLat: draft.pickupLat,
          pickupLng: draft.pickupLng,
          dropoffLat: draft.dropoffLat,
          dropoffLng: draft.dropoffLng,
          pickupAddress: draft.pickupLabel,
          dropoffAddress: draft.destinationLabel,
          productCode: offer.productCode,
          paymentMethod: draft.paymentMethod,
        ),
      );

      try {
        await ref.read(triggerMatchRideUseCaseProvider)(request.id);
      } catch (_) {
        // Best effort: request row is already created.
      }

      await ref.read(ridesListControllerProvider.notifier).refresh();
      if (!context.mounted) {
        return;
      }
      context.go('${RoutePaths.findingDriver}?requestId=${request.id}');
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إنشاء الطلب: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _TripOfferCard extends StatelessWidget {
  const _TripOfferCard({
    required this.offer,
    required this.selected,
    required this.pressed,
    required this.onTap,
    required this.onPressChanged,
    super.key,
  });

  final TripOfferSpec offer;
  final bool selected;
  final bool pressed;
  final VoidCallback onTap;
  final ValueChanged<bool> onPressChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => onPressChanged(true),
      onTapUp: (_) => onPressChanged(false),
      onTapCancel: () => onPressChanged(false),
      child: AnimatedScale(
        duration: HomeMobileSpec.shortDuration,
        scale: pressed ? 0.985 : 1,
        child: AnimatedContainer(
          duration: HomeMobileSpec.shortDuration,
          width: 132,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colors.primary : colors.outline.withValues(alpha: 0.7),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.16),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            offer.etaText,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Image.network(
                        offer.imageUrl,
                        width: 64,
                        height: 34,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(width: 64, height: 34),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        offer.title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(Icons.person_rounded, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            '${offer.seats} ركاب',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.7),
                  border: Border(
                    top: BorderSide(color: colors.outline.withValues(alpha: 0.55)),
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      _formatIqd(offer.priceIqd),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'د.ع',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    return buffer.toString();
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.method, required this.onTap});

  final String method;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isCard = method == 'card';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCard ? Icons.credit_card_rounded : Icons.payments_rounded,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'الدفع: ${isCard ? 'بطاقة' : 'نقدًا'}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  'تغيير',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
