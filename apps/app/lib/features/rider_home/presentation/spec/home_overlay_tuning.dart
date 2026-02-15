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
  /// Header pill
  /// Values are sourced from compile-time `--dart-define` entries.
  ///
  /// Notes
  /// - Dart's `*.fromEnvironment()` constructors require a compile-time constant
  ///   key, so we expose each knob as its own getter.
  /// - Values must be parseable as a Dart number literal.
  static double get headerAvatarPaddingLeft =>
      const double.fromEnvironment('HOME_HEADER_AVATAR_LEFT', defaultValue: 18);

  static double get headerTrailingIconPaddingRight =>
      const double.fromEnvironment('HOME_HEADER_ICON_RIGHT', defaultValue: 20);

  /// Excludes avatar + trailing icon hit targets from the center tap area.
  static double get headerCenterHitInset =>
      const double.fromEnvironment('HOME_HEADER_CENTER_INSET', defaultValue: 84);

  static double get headerTrailingIconSize =>
      const double.fromEnvironment('HOME_HEADER_ICON_SIZE', defaultValue: 22);

  static double get headerTextSize =>
      const double.fromEnvironment('HOME_HEADER_TEXT_SIZE', defaultValue: 18);

  /// Bottom navigation
  static double get navBorderAlpha =>
      const double.fromEnvironment('HOME_NAV_BORDER_ALPHA', defaultValue: 0.75);

  static double get navActiveDiscSize =>
      const double.fromEnvironment('HOME_NAV_ACTIVE_DISC', defaultValue: 64);

  static double get navActiveIconSize =>
      const double.fromEnvironment('HOME_NAV_ACTIVE_ICON', defaultValue: 26);

  static double get navActiveLift =>
      const double.fromEnvironment('HOME_NAV_ACTIVE_LIFT', defaultValue: 20);

  static double get navInactiveIconSize =>
      const double.fromEnvironment('HOME_NAV_ICON_SIZE', defaultValue: 26);

  static double get navLabelGap =>
      const double.fromEnvironment('HOME_NAV_LABEL_GAP', defaultValue: 2);

  static double get navLabelSize =>
      const double.fromEnvironment('HOME_NAV_LABEL_SIZE', defaultValue: 13);
}
