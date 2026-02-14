import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';

class OffersCarousel extends StatefulWidget {
  const OffersCarousel({this.compact = false, super.key});

  final bool compact;

  @override
  State<OffersCarousel> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<OffersCarousel> {
  String? _pressedId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final cardHeight = widget.compact ? 90.0 : HomeMobileSpec.offersCardHeight;
    final sectionHeight = widget.compact ? 172.0 : HomeMobileSpec.offersSectionHeight;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (viewportWidth * HomeMobileSpec.offersCardWidthRatio).clamp(
      HomeMobileSpec.offersCardMinWidth,
      HomeMobileSpec.offersCardWidth,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'عروض وخدمات',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.onSurface.withValues(alpha: 0.9),
              ),
            ),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('عرض الكل')),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: sectionHeight,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == 2) {
                return _ParcelCard(
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                  pressed: _pressedId == 'parcel',
                  onPressedState: (pressed) {
                    setState(() {
                      _pressedId = pressed ? 'parcel' : null;
                    });
                  },
                );
              }
              final item = kHomeOffers[index];
              return _OfferCard(
                item: item,
                cardHeight: cardHeight,
                cardWidth: cardWidth,
                pressed: _pressedId == item.title,
                onPressedState: (pressed) {
                  setState(() {
                    _pressedId = pressed ? item.title : null;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.item,
    required this.cardHeight,
    required this.cardWidth,
    required this.pressed,
    required this.onPressedState,
  });

  final HomeOfferMedia item;
  final double cardHeight;
  final double cardWidth;
  final bool pressed;
  final ValueChanged<bool> onPressedState;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        onTapDown: (_) => onPressedState(true),
        onTapUp: (_) => onPressedState(false),
        onTapCancel: () => onPressedState(false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: <Widget>[
                  AnimatedScale(
                    duration: HomeMobileSpec.panelDuration,
                    curve: HomeMobileSpec.standardEase,
                    scale: pressed ? 1.02 : 1,
                    child: Image.network(
                      item.imageUrl,
                      width: cardWidth,
                      height: cardHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: cardWidth,
                        height: cardHeight,
                        color: colors.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  if (pressed)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: <Color>[
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.26),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.badge,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParcelCard extends StatelessWidget {
  const _ParcelCard({
    required this.cardHeight,
    required this.cardWidth,
    required this.pressed,
    required this.onPressedState,
  });

  final double cardHeight;
  final double cardWidth;
  final bool pressed;
  final ValueChanged<bool> onPressedState;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        onTapDown: (_) => onPressedState(true),
        onTapUp: (_) => onPressedState(false),
        onTapCancel: () => onPressedState(false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedScale(
              duration: HomeMobileSpec.panelDuration,
              curve: HomeMobileSpec.standardEase,
              scale: pressed ? 1.02 : 1,
                child: Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      colors.primary.withValues(alpha: 0.15),
                      colors.surfaceContainerHighest,
                      colors.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.6),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.inventory_2_rounded,
                    size: 38,
                    color: colors.primary.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'توصيل طرود',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'استلام وتسليم داخل بغداد',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
