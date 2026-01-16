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
}
