import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rideiq_app/app/theme/app_theme.dart';

/// Wrapper for golden/widget tests.
///
/// Goals:
/// - Deterministic text metrics (fixed text scale).
/// - Deterministic safe-area insets (fixed viewPadding).
/// - RTL directionality for Arabic UI.
Widget wrapForGolden(
  Widget home, {
  ThemeMode themeMode = ThemeMode.light,
  List<Override> overrides = const <Override>[],
  EdgeInsets viewPadding = const EdgeInsets.only(top: 47, bottom: 34),
}) {
  final light = AppTheme.light.copyWith(
    textTheme: AppTheme.light.textTheme.apply(fontFamily: 'NotoSansArabic'),
  );
  final dark = AppTheme.dark.copyWith(
    textTheme: AppTheme.dark.textTheme.apply(fontFamily: 'NotoSansArabic'),
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      themeMode: themeMode,
      builder: (context, child) {
        final base = MediaQuery.of(context);
        final data = base.copyWith(
          // Keep safe area stable; do not tie it to viewInsets.
          viewPadding: viewPadding,
          padding: viewPadding,
          viewInsets: EdgeInsets.zero,
          textScaler: const TextScaler.linear(1.0),
        );

        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: data,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: home,
    ),
  );
}
