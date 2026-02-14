import 'package:flutter/foundation.dart';

import '../../app/config/app_config.dart';

class AppLogger {
  const AppLogger(this.level);

  final LogLevel level;

  void debug(String message, {Map<String, Object?> context = const {}}) {
    if (level.index <= LogLevel.debug.index) {
      _print('DEBUG', message, context);
    }
  }

  void info(String message, {Map<String, Object?> context = const {}}) {
    if (level.index <= LogLevel.info.index) {
      _print('INFO', message, context);
    }
  }

  void warning(String message, {Map<String, Object?> context = const {}}) {
    if (level.index <= LogLevel.warning.index) {
      _print('WARN', message, context);
    }
  }

  void error(String message, {Map<String, Object?> context = const {}}) {
    if (level.index <= LogLevel.error.index) {
      _print('ERROR', message, context);
    }
  }

  void _print(String prefix, String message, Map<String, Object?> context) {
    if (kReleaseMode && level == LogLevel.error && context.isEmpty) {
      debugPrint('[$prefix] $message');
      return;
    }

    debugPrint('[$prefix] $message ${context.isEmpty ? '' : context}');
  }
}
