import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';
import '../spec/home_overlay_tuning.dart';
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
    // Match the HTML spec: padding-bottom = max(24dp, safe-area-inset-bottom).
    final safeBottom = metrics?.safeBottomPadding ??
        // Use viewPadding so the bar doesn't "jump" when the keyboard animates.
        // (padding can shrink when viewInsets grows.)
        math.max(HomeMobileSpec.safeBottomMin, MediaQuery.viewPaddingOf(context).bottom);
    final compact = metrics?.isCompact ?? (MediaQuery.sizeOf(context).height < 700);

    return Container(
      height: HomeMobileSpec.bottomNavHeight + safeBottom,
      padding: EdgeInsets.only(
        top: HomeMobileSpec.bottomNavTopPadding,
        left: HomeMobileSpec.bottomNavPaddingHorizontal,
        right: HomeMobileSpec.bottomNavPaddingHorizontal,
        bottom: safeBottom,
      ),
      decoration: BoxDecoration(
        // Image 1: solid surface (no blur).
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outline.withValues(alpha: HomeOverlayTuning.navBorderAlpha)),
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
    // Values tuned against 1.jpg (nav1_up.png crop):
    // - Selected tab has a single elevated white disc (no tinted halo fill)
    // - Disc visually ~55dp with a soft shadow, lifted above the baseline.
    // nav1_up.png shows a prominent ~60dp disc, lifted above the label line.
    // Micro-tuned for closer parity with nav1_up.png:
    // - Slightly larger disc
    // - Slightly less lift (disc appears closer to the bar baseline)
    final kActiveDiscSize = HomeOverlayTuning.navActiveDiscSize;
    final kActiveIconSize = HomeOverlayTuning.navActiveIconSize;
    final kActiveLift = HomeOverlayTuning.navActiveLift;
    final kInactiveIconSize = HomeOverlayTuning.navInactiveIconSize;
    final kLabelGap = HomeOverlayTuning.navLabelGap;
    final kLabelSize = HomeOverlayTuning.navLabelSize;

    return InkResponse(
      onTap: onTap,
      radius: 40,
      child: SizedBox(
        height: compact ? 52 : 78,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (active && !compact)
              Transform.translate(
                // Image 1: selected icon sits above baseline.
                offset: Offset(0, -kActiveLift),
                child: SizedBox(
                  width: kActiveDiscSize,
                  height: kActiveDiscSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface,
                      border: Border.all(
                        // In the screenshot the disc edge is barely visible.
                        color: colors.outline.withValues(alpha: 0.12),
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.10),
                          blurRadius: 18,
                          offset: Offset(0, 7),
                        ),
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.06),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: kActiveIconSize, color: colors.primary),
                  ),
                ),
              )
            else
              Icon(
                icon,
                size: compact ? 20 : kInactiveIconSize,
                color: active ? colors.primary : colors.onSurfaceVariant,
              ),
            // Slightly tighter gap like nav1_up.png.
            SizedBox(height: compact ? 2 : kLabelGap),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 9 : kLabelSize,
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
