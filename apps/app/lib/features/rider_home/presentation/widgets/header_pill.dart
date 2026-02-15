import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';
import '../spec/home_overlay_tuning.dart';

/// Top header pill.
///
/// Pixel contract (per 1.jpg):
/// - Left: avatar
/// - Center: pickup status text (tappable)
/// - Right: crosshair/target icon
/// - No recenter button inside the pill
class HeaderPill extends StatelessWidget {
  const HeaderPill({
    required this.locationStatus,
    required this.avatarUrl,
    required this.onPickupTap,
    required this.onAvatarTap,
    required this.onSettingsTap,
    super.key,
  });

  final String locationStatus;
  final String? avatarUrl;
  final VoidCallback onPickupTap;
  final VoidCallback onAvatarTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final centerInset = HomeOverlayTuning.headerCenterHitInset;

    final trimmedAvatarUrl = avatarUrl?.trim();
    final resolvedAvatarUrl =
        trimmedAvatarUrl == null || trimmedAvatarUrl.isEmpty
            ? null
            : trimmedAvatarUrl;

    // Match the Material 3 search-bar-like capsule geometry:
    // - height 56dp
    // - strong rounding (capsule)
    // - subtle shadow
    // Ref: M3 search specs list height 56dp and 16dp paddings.
    // We'll keep the component height aligned with HomeMobileSpec.headerHeight
    // and fine-tune internal paddings for screenshot parity.
    return Container(
      height: HomeMobileSpec.headerHeight,
      margin: const EdgeInsets.symmetric(
        horizontal: HomeMobileSpec.headerInnerHorizontalMargin,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
        // Image 1: almost no visible stroke; rely primarily on shadow.
        border: Border.all(color: colors.outline.withValues(alpha: 0.14)),
        // Softer than HomeMobileSpec.elevation1 for closer screenshot parity.
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 2),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      // Pixel parity: keep center text visually centered regardless of
      // left/right content widths by using a Stack.
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              // In 1.jpg the avatar sits slightly more inset than the default
              // 12dp. These values were derived from measuring the crop.
              padding: EdgeInsets.only(left: HomeOverlayTuning.headerAvatarPaddingLeft),
              child: _AvatarButton(avatarUrl: resolvedAvatarUrl, onTap: onAvatarTap),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              // In 1.jpg the trailing icon sits a bit further from the edge.
              padding: EdgeInsets.only(right: HomeOverlayTuning.headerTrailingIconPaddingRight),
              child: _HeaderIconButton(
                icon: Icons.gps_fixed,
                onPressed: onSettingsTap,
              ),
            ),
          ),
          // Center tap target (kept away from avatar/icon hit targets).
          Positioned.fill(
            left: centerInset,
            right: centerInset,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPickupTap,
                borderRadius: BorderRadius.circular(999),
                child: Center(
                  child: Text(
                    locationStatus,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: HomeOverlayTuning.headerTextSize,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.avatarUrl, required this.onTap});

  final String? avatarUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.35),
                ),
                image: avatarUrl == null
                    ? null
                    : DecorationImage(
                        image: NetworkImage(avatarUrl!),
                        fit: BoxFit.cover,
                      ),
              ),
              child: avatarUrl == null
                  ? Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onPressed,
        radius: 24,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Icon(icon, size: HomeOverlayTuning.headerTrailingIconSize, color: colors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
