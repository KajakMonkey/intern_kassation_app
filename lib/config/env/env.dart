import 'package:flutter/foundation.dart';
import 'package:intern_kassation_app/config/env/env_provider.dart';
import 'package:logging/logging.dart';

enum Environment { development, production }

enum EnvKey {
  baseApiUrl('BASE_API_URL'),
  useHardwareScanner('USE_HARDWARE_SCANNER'),
  showDataPicker('SHOW_DATA_PICKER')
  ;

  const EnvKey(this.key);

  final String key;
}

class EnvManager {
  EnvManager._();
  static final _log = Logger('EnvManager');

  // Injectable provider (defaults to real dotenv)
  static EnvProvider provider = DotenvEnvProvider();

  /// For tests: replace provider
  static void setProvider(EnvProvider p) => provider = p;

  /// For tests: reset to default provider
  static void resetProvider() => provider = DotenvEnvProvider();

  static Future<void> init(Environment environment) async {
    _log.finest('Loading environment: ${environment.name}');
    await provider.load('.env.${environment.name}');
    validateEnv();
  }

  static String get apiUrl => _getRequired(EnvKey.baseApiUrl.key);
  static bool get useHardwareScanner => _getBool(EnvKey.useHardwareScanner.key, defaultValue: true);
  // Should only be true in dev environment
  static bool get showDataPicker => _getBool(EnvKey.showDataPicker.key);

  static String _getRequired(String key) {
    final value = provider.env[key];
    if (value == null || value.isEmpty) {
      throw ArgumentError('$key is required but not set in .env file');
    }
    return value;
  }

  // ignore: unused_element
  static String _getOptional(String key, {String defaultValue = ''}) {
    return provider.env[key] ?? defaultValue;
  }

  static bool _getBool(String key, {bool defaultValue = false}) {
    final value = provider.env[key];
    if (value == null) {
      return defaultValue;
    }
    return value.toLowerCase() == 'true';
  }

  static void validateEnv() {
    if (kReleaseMode) {
      return;
    }
    _getRequired(EnvKey.baseApiUrl.key);
  }
}
