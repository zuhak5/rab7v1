import 'package:flutter/material.dart';

import '../spec/home_mobile_spec.dart';

class HeaderPill extends StatelessWidget {
  const HeaderPill({
    required this.locationStatus,
    required this.avatarUrl,
    required this.onRecenterTap,
    required this.onPickupTap,
    required this.onProfileTap,
    super.key,
  });

  final String locationStatus;
  final String? avatarUrl;
  final VoidCallback onRecenterTap;
  final VoidCallback onPickupTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final trimmedAvatarUrl = avatarUrl?.trim();
    final resolvedAvatarUrl =
        trimmedAvatarUrl == null || trimmedAvatarUrl.isEmpty
        ? null
        : trimmedAvatarUrl;

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(
        horizontal: HomeMobileSpec.headerInnerHorizontalMargin,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.outline.withValues(alpha: 0.6)),
        boxShadow: HomeMobileSpec.elevation2,
      ),
      child: Row(
        children: <Widget>[
          _CircleButton(
            icon: Icons.my_location_rounded,
            onPressed: onRecenterTap,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onPickupTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Text(
                      locationStatus,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.outline, width: 2),
                    color: colors.surfaceContainerHighest,
                    image: resolvedAvatarUrl == null
                        ? null
                        : DecorationImage(
                            image: NetworkImage(resolvedAvatarUrl),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: resolvedAvatarUrl == null
                      ? const Icon(Icons.person_rounded, size: 20)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onPressed});

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
          child: Icon(icon, size: 24, color: colors.onSurfaceVariant),
        ),
      ),
    );
  }
}
