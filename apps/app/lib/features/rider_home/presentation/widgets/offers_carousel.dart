import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';

class OffersCarousel extends StatelessWidget {
  const OffersCarousel({this.compact = false, super.key});

  /// When [compact] is true, we use tighter vertical metrics so the section
  /// fits inside the home sheet without overflow.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final cardHeight =
        compact ? HomeMobileSpec.offersCardHeight : HomeMobileSpec.offersCardHeight + 16;
    // This is the height of the horizontal list viewport (image + text).
    final listHeight =
        compact ? HomeMobileSpec.offersSectionHeight : HomeMobileSpec.offersSectionHeight + 18;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final cardWidth = (viewportWidth * HomeMobileSpec.offersCardWidthRatio)
            .clamp(HomeMobileSpec.offersCardMinWidth, HomeMobileSpec.offersCardWidth)
            .toDouble();

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
              height: listHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  if (index == 2) {
                    return _ParcelCard(
                      cardHeight: cardHeight,
                      cardWidth: cardWidth,
                    );
                  }
                  final item = kHomeOffers[index];
                  return _OfferCard(
                    item: item,
                    cardHeight: cardHeight,
                    cardWidth: cardWidth,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.item,
    required this.cardHeight,
    required this.cardWidth,
  });

  final HomeOfferMedia item;
  final double cardHeight;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: cardWidth,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: <Widget>[
                  Image.network(
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
                  PositionedDirectional(
                    top: 8,
                    end: 8,
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
  const _ParcelCard({required this.cardHeight, required this.cardWidth});

  final double cardHeight;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: cardWidth,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
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
