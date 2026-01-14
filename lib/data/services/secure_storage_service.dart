import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/storage_error_codes.dart';

class SecureStorageService {
  const SecureStorageService();

  static const _secureStorage = FlutterSecureStorage();

  Future<Either<AppFailure, String?>> read(String key) async {
    try {
      return right(await _secureStorage.read(key: key));
    } catch (e) {
      return left(
        AppFailure(code: StorageErrorCodes.secureStorageReadError, context: {'exception': e.toString(), 'key': key}),
      );
    }
  }

  Future<Either<AppFailure, void>> write(String key, String value) async {
    try {
      return right(await _secureStorage.write(key: key, value: value));
    } catch (e) {
      return left(
        AppFailure(code: StorageErrorCodes.secureStorageWriteError, context: {'exception': e.toString(), 'key': key}),
      );
    }
  }

  Future<Either<AppFailure, void>> delete(String key) async {
    try {
      return right(await _secureStorage.delete(key: key));
    } catch (e) {
      return left(
        AppFailure(code: StorageErrorCodes.secureStorageDeleteError, context: {'exception': e.toString(), 'key': key}),
      );
    }
  }
}
