import 'package:intern_kassation_app/data/services/storage/interface/key_value_storage.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/error_codes_index.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';

class SharedPreferencesService implements KeyValueStorage {
  const SharedPreferencesService(this._sharedPreferences);
  final SharedPreferencesAsync _sharedPreferences;

  static final _logger = Logger('SharedPreferencesService');

  @override
  Future<Either<AppFailure, void>> write(String key, String value) async {
    try {
      await _sharedPreferences.setString(key, value);
      return right(null);
    } catch (e, st) {
      _logger.severe('Error writing to SharedPreferences', e, st);
      return left(
        AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key, 'value': value}),
      );
    }
  }

  @override
  Future<Either<AppFailure, String?>> read(String key) async {
    try {
      final value = await _sharedPreferences.getString(key);
      return right(value);
    } catch (e, st) {
      _logger.severe('Error reading from SharedPreferences', e, st);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key}));
    }
  }

  @override
  Future<Either<AppFailure, void>> delete(String key) async {
    try {
      await _sharedPreferences.remove(key);
      return right(null);
    } catch (e, st) {
      _logger.severe('Error removing from SharedPreferences', e, st);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key}));
    }
  }

  @override
  Future<Either<AppFailure, void>> setInt(String key, int value) async {
    try {
      await _sharedPreferences.setInt(key, value);
      return right(null);
    } catch (e, st) {
      _logger.severe('Error writing int to SharedPreferences', e, st);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key, 'value': value}));
    }
  }

  @override
  Future<Either<AppFailure, int?>> getInt(String key) async {
    try {
      final value = await _sharedPreferences.getInt(key);
      return right(value);
    } catch (e, st) {
      _logger.severe('Error reading int from SharedPreferences', e, st);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key}));
    }
  }

  @override
  Future<Either<AppFailure, List<String>?>> getStringList(String key) async {
    try {
      final value = await _sharedPreferences.getStringList(key);
      return right(value);
    } catch (e, st) {
      _logger.severe('Error reading string list from SharedPreferences', e, st);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key}));
    }
  }

  @override
  Future<Either<AppFailure, void>> setStringList(String key, List<String> value) async {
    try {
      await _sharedPreferences.setStringList(key, value);
      return right(null);
    } catch (e, st) {
      _logger.severe('Error writing string list to SharedPreferences', e, st);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key, 'value': value}));
    }
  }

  @override
  Future<Either<AppFailure, bool?>> getBool(String key) async {
    try {
      final value = await _sharedPreferences.getBool(key);
      return right(value);
    } catch (e, st) {
      _logger.severe('Error reading bool from SharedPreferences', e, st);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key}));
    }
  }

  @override
  Future<Either<AppFailure, void>> setBool(String key, bool value) async {
    try {
      await _sharedPreferences.setBool(key, value);
      return right(null);
    } catch (e, st) {
      _logger.severe('Error writing bool to SharedPreferences', e, st);
      return left(AppFailure(code: StorageErrorCodes.sharedPrefsReadError, context: {'key': key, 'value': value}));
    }
  }
}
