import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

enum Environment { development, production }

class EnvManager {
  EnvManager._();
  static final _log = Logger('EnvManager');

  static Future<void> init(Environment environment) async {
    _log.finest('Loading environment: ${environment.name}');
    await dotenv.load(fileName: '.env.${environment.name}');
    validateEnv();
  }

  static String get apiUrl => _getRequired('BASE_API_URL');
  static bool get useHardwareScanner => _getBool('USE_HARDWARE_SCANNER', defaultValue: true);
  // Should only be true in dev environment
  static bool get showDataPicker => _getBool('SHOW_DATA_PICKER');

  static String _getRequired(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw ArgumentError('$key is required but not set in .env file');
    }
    return value;
  }

  // ignore: unused_element
  static String _getOptional(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }

  static bool _getBool(String key, {bool defaultValue = false}) {
    final value = dotenv.env[key];
    if (value == null) {
      return defaultValue;
    }
    return value.toLowerCase() == 'true';
  }

  static void validateEnv() {
    if (kReleaseMode) {
      return;
    }
    _getRequired('BASE_API_URL');
  }
}
