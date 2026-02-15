import 'package:flutter/foundation.dart';

/// Centralized, pixel-level tuning knobs for the Rider Home overlay (non-map).
///
/// Purpose
/// - Provide a single place to tune header + bottom-nav geometry.
/// - Enable dp-by-dp iteration via `--dart-define` without code edits.
///
/// Example
/// flutter test \
///   --dart-define=RUN_1JPG_REFERENCE_GOLDEN=true \
///   --dart-define=HOME_NAV_ACTIVE_DISC=66 \
///   --dart-define=HOME_NAV_ACTIVE_LIFT=19 \
///   test/features/rider_home/presentation/rider_home_reference_1jpg_golden_test.dart
///
/// All values have sensible defaults taken from the current screenshot parity.
abstract class HomeOverlayTuning {
  @visibleForTesting
  static double doubleFromEnv(String key, double fallback) {
    final raw = const String.fromEnvironment(key, defaultValue: '').trim();
    final parsed = double.tryParse(raw);
    return parsed ?? fallback;
  }

  /// Header pill
  static double get headerAvatarPaddingLeft =>
      doubleFromEnv('HOME_HEADER_AVATAR_LEFT', 18);

  static double get headerTrailingIconPaddingRight =>
      doubleFromEnv('HOME_HEADER_ICON_RIGHT', 20);

  /// Excludes avatar + trailing icon hit targets from the center tap area.
  static double get headerCenterHitInset =>
      doubleFromEnv('HOME_HEADER_CENTER_INSET', 84);

  static double get headerTrailingIconSize =>
      doubleFromEnv('HOME_HEADER_ICON_SIZE', 22);

  static double get headerTextSize =>
      doubleFromEnv('HOME_HEADER_TEXT_SIZE', 18);

  /// Bottom navigation
  static double get navBorderAlpha =>
      doubleFromEnv('HOME_NAV_BORDER_ALPHA', 0.75);

  static double get navActiveDiscSize =>
      doubleFromEnv('HOME_NAV_ACTIVE_DISC', 64);

  static double get navActiveIconSize =>
      doubleFromEnv('HOME_NAV_ACTIVE_ICON', 26);

  static double get navActiveLift =>
      doubleFromEnv('HOME_NAV_ACTIVE_LIFT', 20);

  static double get navInactiveIconSize =>
      doubleFromEnv('HOME_NAV_ICON_SIZE', 26);

  static double get navLabelGap =>
      doubleFromEnv('HOME_NAV_LABEL_GAP', 2);

  static double get navLabelSize =>
      doubleFromEnv('HOME_NAV_LABEL_SIZE', 13);
}
