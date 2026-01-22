import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/data/services/storage/interface/key_value_storage.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/storage_error_codes.dart';
import 'package:logging/logging.dart';

class SecureStorageService implements KeyValueStorage {
  const SecureStorageService();

  static const _secureStorage = FlutterSecureStorage();

  static final _logger = Logger('SecureStorageService');

  @override
  Future<Either<AppFailure, String?>> read(String key) async {
    try {
      return right(await _secureStorage.read(key: key));
    } catch (e, st) {
      _logger.severe('Error reading from secure storage', e, st);
      return left(
        AppFailure(code: StorageErrorCodes.secureStorageReadError, context: {'exception': e.toString(), 'key': key}),
      );
    }
  }

  @override
  Future<Either<AppFailure, void>> write(String key, String value) async {
    try {
      return right(await _secureStorage.write(key: key, value: value));
    } catch (e, st) {
      _logger.severe('Error writing to secure storage', e, st);
      return left(
        AppFailure(code: StorageErrorCodes.secureStorageWriteError, context: {'exception': e.toString(), 'key': key}),
      );
    }
  }

  @override
  Future<Either<AppFailure, void>> delete(String key) async {
    try {
      return right(await _secureStorage.delete(key: key));
    } catch (e, st) {
      _logger.severe('Error deleting from secure storage', e, st);
      return left(
        AppFailure(code: StorageErrorCodes.secureStorageDeleteError, context: {'exception': e.toString(), 'key': key}),
      );
    }
  }

  @override
  Future<Either<AppFailure, int?>> getInt(String key) async {
    try {
      return right(int.tryParse(await _secureStorage.read(key: key) as String));
    } catch (e, st) {
      _logger.severe('Error reading int from secure storage', e, st);
      return left(
        AppFailure(code: StorageErrorCodes.secureStorageReadError, context: {'exception': e.toString(), 'key': key}),
      );
    }
  }

  @override
  Future<Either<AppFailure, void>> setInt(String key, int value) async {
    try {
      return right(await _secureStorage.write(key: key, value: value.toString()));
    } catch (e, st) {
      _logger.severe('Error writing int to secure storage', e, st);
      return left(
        AppFailure(code: StorageErrorCodes.secureStorageWriteError, context: {'exception': e.toString(), 'key': key}),
      );
    }
  }

  @override
  Future<Either<AppFailure, List<String>?>> getStringList(String key) async {
    try {
      final storedValue = await _secureStorage.read(key: key);
      if (storedValue == null) {
        return right(null);
      }
      final List<String> valueList = storedValue.split('|');
      return right(valueList);
    } catch (e, st) {
      _logger.severe('Error reading string list from secure storage', e, st);
      return left(
        AppFailure(code: StorageErrorCodes.secureStorageReadError, context: {'exception': e.toString(), 'key': key}),
      );
    }
  }

  @override
  Future<Either<AppFailure, void>> setStringList(String key, List<String> value) async {
    try {
      final storedValue = value.join('|');
      await _secureStorage.write(key: key, value: storedValue);
      return right(null);
    } catch (e, st) {
      _logger.severe('Error writing string list to secure storage', e, st);
      return left(
        AppFailure(code: StorageErrorCodes.secureStorageWriteError, context: {'exception': e.toString(), 'key': key}),
      );
    }
  }

  @override
  Future<Either<AppFailure, bool?>> getBool(String key) async {
    try {
      final storedValue = await _secureStorage.read(key: key);
      if (storedValue == null) {
        return right(null);
      }
      final boolValue = storedValue == '1' ? true : false;
      return right(boolValue);
    } catch (e, st) {
      _logger.severe('Error reading bool from secure storage', e, st);
      return left(
        AppFailure(code: StorageErrorCodes.secureStorageReadError, context: {'exception': e.toString(), 'key': key}),
      );
    }
  }

  @override
  Future<Either<AppFailure, void>> setBool(String key, bool value) async {
    try {
      final storedValue = value ? '1' : '0';
      await _secureStorage.write(key: key, value: storedValue);
      return right(null);
    } catch (e, st) {
      _logger.severe('Error writing bool to secure storage', e, st);
      return left(
        AppFailure(code: StorageErrorCodes.secureStorageWriteError, context: {'exception': e.toString(), 'key': key}),
      );
    }
  }
}
