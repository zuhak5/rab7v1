import 'package:flutter/widgets.dart';

@immutable
class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.appEnv,
    required this.logLevel,
  });

  final String supabaseUrl;
  final String supabaseAnonKey;
  final AppEnvironment appEnv;
  final LogLevel logLevel;

  static const _supabaseUrlKey = 'SUPABASE_URL';
  static const _supabaseAnonKey = 'SUPABASE_ANON_KEY';
  static const _appEnvKey = 'APP_ENV';
  static const _logLevelKey = 'LOG_LEVEL';

  static AppConfig fromEnvironment() {
    final supabaseUrl = const String.fromEnvironment(_supabaseUrlKey).trim();
    final supabaseAnonKey = const String.fromEnvironment(
      _supabaseAnonKey,
    ).trim();
    final appEnvRaw = const String.fromEnvironment(
      _appEnvKey,
      defaultValue: 'dev',
    ).trim();
    final logLevelRaw = const String.fromEnvironment(
      _logLevelKey,
      defaultValue: 'info',
    ).trim();

    if (supabaseUrl.isEmpty) {
      throw StateError('Missing required dart-define: $_supabaseUrlKey');
    }
    if (supabaseAnonKey.isEmpty) {
      throw StateError('Missing required dart-define: $_supabaseAnonKey');
    }
    if (supabaseAnonKey.startsWith('sb_secret_') ||
        supabaseAnonKey.toLowerCase().contains('service_role')) {
      throw StateError(
        'SUPABASE_ANON_KEY must be a publishable/anon key. Service role keys are not allowed in clients.',
      );
    }

    return AppConfig(
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      appEnv: AppEnvironmentX.parse(appEnvRaw),
      logLevel: LogLevelX.parse(logLevelRaw),
    );
  }
}

enum AppEnvironment { dev, prod }

extension AppEnvironmentX on AppEnvironment {
  static AppEnvironment parse(String value) {
    switch (value.toLowerCase()) {
      case 'dev':
        return AppEnvironment.dev;
      case 'prod':
        return AppEnvironment.prod;
      default:
        throw StateError('Invalid APP_ENV value: $value');
    }
  }
}

enum LogLevel { debug, info, warning, error }

extension LogLevelX on LogLevel {
  static LogLevel parse(String value) {
    switch (value.toLowerCase()) {
      case 'debug':
        return LogLevel.debug;
      case 'info':
        return LogLevel.info;
      case 'warning':
      case 'warn':
        return LogLevel.warning;
      case 'error':
        return LogLevel.error;
      default:
        return LogLevel.info;
    }
  }
}
