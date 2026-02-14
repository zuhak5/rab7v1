import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';

class RoutePillHeader extends StatelessWidget {
  const RoutePillHeader({
    required this.pickup,
    required this.destination,
    required this.onBack,
    required this.onMenu,
    super.key,
  });

  final String pickup;
  final String destination;
  final VoidCallback onBack;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: HomeMobileSpec.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outline.withValues(alpha: 0.68)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.11),
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
                    maxLines: 1,
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
                    maxLines: 1,
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
