import 'dart:ui';
import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';
import '../viewmodels/rider_home_state.dart';

class BottomNavShell extends StatelessWidget {
  const BottomNavShell({
    required this.activeTab,
    required this.onTabSelected,
    super.key,
  });

  final HomeBottomTab activeTab;
  final ValueChanged<HomeBottomTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: HomeMobileSpec.bottomNavHeight + safeBottom,
          padding: EdgeInsets.only(
            top: HomeMobileSpec.bottomNavTopPadding,
            left: HomeMobileSpec.bottomNavPaddingHorizontal,
            right: HomeMobileSpec.bottomNavPaddingHorizontal,
            bottom: safeBottom.clamp(8.0, 22.0),
          ),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.9),
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
                  onTap: () => onTabSelected(HomeBottomTab.home),
                ),
              ),
              Expanded(
                child: _NavButton(
                  icon: Icons.history_rounded,
                  label: 'النشاط',
                  active: activeTab == HomeBottomTab.activity,
                  onTap: () => onTabSelected(HomeBottomTab.activity),
                ),
              ),
              Expanded(
                child: _NavButton(
                  icon: Icons.person_rounded,
                  label: 'حسابي',
                  active: activeTab == HomeBottomTab.account,
                  onTap: () => onTabSelected(HomeBottomTab.account),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).height < 700;

    return InkResponse(
      onTap: onTap,
      radius: 34,
      child: SizedBox(
        height: compact ? 52 : 66,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (active && !compact)
              Transform.translate(
                offset: const Offset(0, -12),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.surfaceContainerHighest,
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.surface,
                          border: Border.all(
                            color: colors.outline.withValues(alpha: 0.7),
                          ),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.14),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(icon, size: 22, color: colors.primary),
                      ),
                    ],
                  ),
                ),
              )
            else
              Icon(
                icon,
                size: compact ? 20 : 22,
                color: active ? colors.primary : colors.onSurfaceVariant,
              ),
            SizedBox(height: compact ? 1 : 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 9 : 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
