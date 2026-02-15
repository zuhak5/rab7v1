import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_goldens/flutter_test_goldens.dart';

/// Global Flutter test configuration.
///
/// We load *real* app fonts and Material icons for all golden tests.
/// Otherwise, Flutter substitutes the Ahem test font and does not load icon
/// fonts, which makes goldens unusable for pixel-accuracy work.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Loads fonts declared in pubspec.yaml.
  await loadAppFonts();
  // Loads the Material icon font.
  await loadMaterialIconsFont();

  await testMain();
}
