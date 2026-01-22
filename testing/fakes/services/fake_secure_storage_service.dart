import 'package:fpdart/src/either.dart';
import 'package:intern_kassation_app/data/services/storage/secure_storage_service.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/storage_error_codes.dart';

class FakeSecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = {};

  String? overrideStringValue;
  int? overrideIntValue;
  List<String>? overrideStringListValue;

  var shouldFailAll = false;
  var shouldFailReads = false;
  var shouldFailWrites = false;
  var shouldFailDeletes = false;

  Either<AppFailure, T> _failRead<T>(String key) => left(
    AppFailure(code: StorageErrorCodes.secureStorageReadError, context: {'key': key}),
  );

  Either<AppFailure, T> _failWrite<T>(String key, Object? value) => left(
    AppFailure(code: StorageErrorCodes.secureStorageWriteError, context: {'key': key, 'value': value}),
  );

  Either<AppFailure, T> _failDelete<T>(String key) => left(
    AppFailure(code: StorageErrorCodes.secureStorageDeleteError, context: {'key': key}),
  );

  @override
  Future<Either<AppFailure, void>> delete(String key) async {
    if (shouldFailAll || shouldFailDeletes) return _failDelete(key);
    _storage.remove(key);
    return right(null);
  }

  @override
  Future<Either<AppFailure, void>> write(String key, String value) async {
    if (shouldFailAll || shouldFailWrites) return _failWrite(key, value);
    _storage[key] = value;
    return right(null);
  }

  @override
  Future<Either<AppFailure, String?>> read(String key) async {
    if (shouldFailAll || shouldFailReads) return _failRead(key);
    final value = _storage[key];
    return right(value);
  }

  @override
  Future<Either<AppFailure, void>> setBool(String key, bool value) async {
    if (shouldFailAll || shouldFailWrites) return _failWrite(key, value);
    _storage[key] = value ? '1' : '0';
    return right(null);
  }

  @override
  Future<Either<AppFailure, bool?>> getBool(String key) async {
    if (shouldFailAll || shouldFailReads) return _failRead(key);
    final value = _storage[key];
    if (value == null) {
      return right(null);
    }
    return right(value == '1');
  }

  @override
  Future<Either<AppFailure, int?>> getInt(String key) async {
    if (shouldFailAll || shouldFailReads) return _failRead(key);
    if (overrideIntValue != null) {
      return right(overrideIntValue);
    }
    final value = _storage[key];
    if (value == null) {
      return right(null);
    }
    return right(int.tryParse(value));
  }

  @override
  Future<Either<AppFailure, void>> setInt(String key, int value) async {
    if (shouldFailAll || shouldFailWrites) return _failWrite(key, value);
    _storage[key] = value.toString();
    return right(null);
  }

  @override
  Future<Either<AppFailure, void>> setStringList(String key, List<String> value) async {
    if (shouldFailAll || shouldFailWrites) return _failWrite(key, value);
    _storage[key] = value.join('|');
    overrideStringListValue = List<String>.from(value);
    return right(null);
  }

  @override
  Future<Either<AppFailure, List<String>?>> getStringList(String key) async {
    if (shouldFailAll || shouldFailReads) return _failRead(key);
    if (overrideStringListValue != null) {
      return right(overrideStringListValue);
    }
    final value = _storage[key];
    if (value == null) {
      return right(null);
    }
    return right(value.split('|'));
  }
}
