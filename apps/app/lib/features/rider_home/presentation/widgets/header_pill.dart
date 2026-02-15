import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';

/// Top header pill.
///
/// Pixel contract (per 1.jpg):
/// - Left: avatar
/// - Center: pickup status text (tappable)
/// - Right: settings/utility icon
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

    final trimmedAvatarUrl = avatarUrl?.trim();
    final resolvedAvatarUrl =
        trimmedAvatarUrl == null || trimmedAvatarUrl.isEmpty
            ? null
            : trimmedAvatarUrl;

    return Container(
      height: HomeMobileSpec.headerHeight,
      margin: const EdgeInsets.symmetric(
        horizontal: HomeMobileSpec.headerInnerHorizontalMargin,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outline.withValues(alpha: 0.6)),
        boxShadow: HomeMobileSpec.elevation2,
      ),
      child: Row(
        children: <Widget>[
          _AvatarButton(avatarUrl: resolvedAvatarUrl, onTap: onAvatarTap),
          const SizedBox(width: 10),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPickupTap,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      locationStatus,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _IconCircleButton(
            icon: Icons.gps_fixed_rounded,
            onPressed: onSettingsTap,
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceContainerHighest,
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
                      size: 22,
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

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({required this.icon, required this.onPressed});

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
            child: Icon(icon, size: 28, color: colors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
