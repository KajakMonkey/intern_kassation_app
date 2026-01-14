import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/error_codes_index.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';

class SharedPreferencesService {
  const SharedPreferencesService(this._sharedPreferences);
  final SharedPreferencesAsync _sharedPreferences;

  static final _logger = Logger('SharedPreferencesService');

  Future<Either<AppFailure, void>> setString(String key, String value) async {
    try {
      await _sharedPreferences.setString(key, value);
      return right(null);
    } catch (e) {
      _logger.severe('Error writing to SharedPreferences', e);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key}));
    }
  }

  Future<Either<AppFailure, String?>> getString(String key) async {
    try {
      final value = await _sharedPreferences.getString(key);
      return right(value);
    } catch (e) {
      _logger.severe('Error reading from SharedPreferences', e);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key}));
    }
  }

  Future<Either<AppFailure, void>> remove(String key) async {
    try {
      await _sharedPreferences.remove(key);
      return right(null);
    } catch (e) {
      _logger.severe('Error removing from SharedPreferences', e);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key}));
    }
  }

  Future<Either<AppFailure, void>> setInt(String key, int value) async {
    try {
      await _sharedPreferences.setInt(key, value);
      return right(null);
    } catch (e) {
      _logger.severe('Error writing int to SharedPreferences', e);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key}));
    }
  }

  Future<Either<AppFailure, int?>> getInt(String key) async {
    try {
      final value = await _sharedPreferences.getInt(key);
      return right(value);
    } catch (e) {
      _logger.severe('Error reading int from SharedPreferences', e);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key}));
    }
  }

  Future<Either<AppFailure, List<String>?>> getStringList(String key) async {
    try {
      final value = await _sharedPreferences.getStringList(key);
      return right(value);
    } catch (e) {
      _logger.severe('Error reading string list from SharedPreferences', e);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key}));
    }
  }

  Future<Either<AppFailure, void>> setStringList(String key, List<String> value) async {
    try {
      await _sharedPreferences.setStringList(key, value);
      return right(null);
    } catch (e) {
      _logger.severe('Error writing string list to SharedPreferences', e);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key}));
    }
  }
}
