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
/// Why String.fromEnvironment?
/// - Dart's core libraries expose `String.fromEnvironment`,
///   `int.fromEnvironment`, and `bool.fromEnvironment`.
/// - There is **no** `double.fromEnvironment`, so numeric tuning values are
///   read as strings and parsed to `double`.
/// - The `name` argument must be a compile-time constant, so each knob is its
///   own getter (no dynamic lookup helper).
abstract class HomeOverlayTuning {
  // ----------------
  // Header pill
  // ----------------

  static double get headerAvatarPaddingLeft {
    const raw = String.fromEnvironment('HOME_HEADER_AVATAR_LEFT', defaultValue: '18');
    return double.tryParse(raw) ?? 18;
  }

  static double get headerTrailingIconPaddingRight {
    const raw = String.fromEnvironment('HOME_HEADER_ICON_RIGHT', defaultValue: '20');
    return double.tryParse(raw) ?? 20;
  }

  /// Excludes avatar + trailing icon hit targets from the center tap area.
  static double get headerCenterHitInset {
    const raw = String.fromEnvironment('HOME_HEADER_CENTER_INSET', defaultValue: '84');
    return double.tryParse(raw) ?? 84;
  }

  static double get headerTrailingIconSize {
    const raw = String.fromEnvironment('HOME_HEADER_ICON_SIZE', defaultValue: '22');
    return double.tryParse(raw) ?? 22;
  }

  static double get headerTextSize {
    const raw = String.fromEnvironment('HOME_HEADER_TEXT_SIZE', defaultValue: '18');
    return double.tryParse(raw) ?? 18;
  }

  // ----------------
  // Bottom navigation
  // ----------------

  static double get navBorderAlpha {
    const raw = String.fromEnvironment('HOME_NAV_BORDER_ALPHA', defaultValue: '0.75');
    final v = double.tryParse(raw);
    // Clamp defensively to [0,1] so accidental values don't break rendering.
    if (v == null) return 0.75;
    if (v < 0) return 0;
    if (v > 1) return 1;
    return v;
  }

  static double get navActiveDiscSize {
    const raw = String.fromEnvironment('HOME_NAV_ACTIVE_DISC', defaultValue: '64');
    return double.tryParse(raw) ?? 64;
  }

  static double get navActiveIconSize {
    const raw = String.fromEnvironment('HOME_NAV_ACTIVE_ICON', defaultValue: '26');
    return double.tryParse(raw) ?? 26;
  }

  static double get navActiveLift {
    const raw = String.fromEnvironment('HOME_NAV_ACTIVE_LIFT', defaultValue: '20');
    return double.tryParse(raw) ?? 20;
  }

  static double get navInactiveIconSize {
    const raw = String.fromEnvironment('HOME_NAV_ICON_SIZE', defaultValue: '26');
    return double.tryParse(raw) ?? 26;
  }

  static double get navLabelGap {
    const raw = String.fromEnvironment('HOME_NAV_LABEL_GAP', defaultValue: '2');
    return double.tryParse(raw) ?? 2;
  }

  static double get navLabelSize {
    const raw = String.fromEnvironment('HOME_NAV_LABEL_SIZE', defaultValue: '13');
    return double.tryParse(raw) ?? 13;
  }
}
