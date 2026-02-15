import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';
import '../viewmodels/rider_home_state.dart';

class BottomNavShell extends StatelessWidget {
  const BottomNavShell({
    this.metrics,
    required this.activeTab,
    required this.onTabSelected,
    super.key,
  });

  final HomeLayoutMetrics? metrics;
  final HomeBottomTab activeTab;
  final ValueChanged<HomeBottomTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final safeBottom = metrics?.safeBottomPadding ?? MediaQuery.paddingOf(context).bottom;
    final compact = metrics?.isCompact ?? (MediaQuery.sizeOf(context).height < 700);

    return Container(
      height: HomeMobileSpec.bottomNavHeight + safeBottom,
      padding: EdgeInsets.only(
        top: HomeMobileSpec.bottomNavTopPadding,
        left: HomeMobileSpec.bottomNavPaddingHorizontal,
        right: HomeMobileSpec.bottomNavPaddingHorizontal,
        bottom: safeBottom.clamp(8.0, 22.0),
      ),
      decoration: BoxDecoration(
        // Image 1: solid surface (no blur).
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outline.withValues(alpha: 0.9)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: _NavButton(
              icon: Icons.home_rounded,
              label: 'الرئيسية',
              active: activeTab == HomeBottomTab.home,
              compact: compact,
              onTap: () => onTabSelected(HomeBottomTab.home),
            ),
          ),
          Expanded(
            child: _NavButton(
              icon: Icons.history_rounded,
              label: 'النشاط',
              active: activeTab == HomeBottomTab.activity,
              compact: compact,
              onTap: () => onTabSelected(HomeBottomTab.activity),
            ),
          ),
          Expanded(
            child: _NavButton(
              icon: Icons.person_rounded,
              label: 'حسابي',
              active: activeTab == HomeBottomTab.account,
              compact: compact,
              onTap: () => onTabSelected(HomeBottomTab.account),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.compact,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkResponse(
      onTap: onTap,
      radius: 36,
      child: SizedBox(
        height: compact ? 52 : 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (active && !compact)
              Transform.translate(
                // Image 1: selected icon sits above baseline.
                offset: const Offset(0, -14),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Faint outer disc.
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.surfaceContainerHighest,
                        ),
                      ),
                      // Inner elevated disc with border + shadow.
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.surface,
                          border: Border.all(
                            color: colors.outline.withValues(alpha: 0.85),
                          ),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.14),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(icon, size: 28, color: colors.primary),
                      ),
                    ],
                  ),
                ),
              )
            else
              Icon(
                icon,
                size: compact ? 20 : 24,
                color: active ? colors.primary : colors.onSurfaceVariant,
              ),
            SizedBox(height: compact ? 2 : 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 9 : 12,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? colors.primary : colors.onSurfaceVariant,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
