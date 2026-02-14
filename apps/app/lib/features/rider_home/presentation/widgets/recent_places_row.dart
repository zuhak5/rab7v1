import 'package:flutter/material.dart';

class RecentPlacesRow extends StatelessWidget {
  const RecentPlacesRow({required this.onPlaceTap, super.key});

  final ValueChanged<String> onPlaceTap;

  static const List<String> _items = <String>[
    'مول المنصور',
    'فندق بابل',
    'شارع المتنبي',
    'المزيد',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = _items[index];
          final isMore = index == _items.length - 1;
          return InkWell(
            onTap: () => onPlaceTap(value),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMore
                    ? colors.surfaceContainerHighest.withValues(alpha: 0.6)
                    : colors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.9),
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    isMore ? Icons.more_horiz_rounded : Icons.history_rounded,
                    size: isMore ? 18 : 14,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
