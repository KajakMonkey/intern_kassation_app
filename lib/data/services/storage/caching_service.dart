import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/data/services/storage/interface/key_value_storage.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/storage_error_codes.dart';
import 'package:logging/logging.dart';

class CachingService {
  CachingService({required KeyValueStorage keyValueStorage}) : _keyValueStorage = keyValueStorage;
  final KeyValueStorage _keyValueStorage;

  static const _defaultTtl = Duration(minutes: 15);

  static final _logger = Logger('CachingService');

  Future<Either<AppFailure, void>> write(String key, String value, {Duration ttl = _defaultTtl}) async {
    final cacheKey = _getCacheKey(key);
    try {
      await _keyValueStorage.write(key, value);
      final expiryTime = DateTime.now().toUtc().add(ttl).millisecondsSinceEpoch;
      await _keyValueStorage.setInt(cacheKey, expiryTime);
      return right(null);
    } catch (e, st) {
      _logger.severe('Error writing to cache', e, st);
      return left(
        AppFailure(
          code: StorageErrorCodes.sharedPrefsWriteError,
          context: {'message': e.toString(), 'method': 'CachingService.write'},
        ),
      );
    }
  }

  Future<Either<AppFailure, String?>> read(String key, {bool returnIfExpired = false}) async {
    final cacheKey = _getCacheKey(key);
    try {
      final result = await _keyValueStorage.read(key);
      if (result.isLeft()) {
        return left(result.getLeft().toNullable()!);
      }
      final String? cachedValue = result.getRight().toNullable();

      if (returnIfExpired) {
        return right(cachedValue);
      }

      if (cachedValue == null) {
        return right(null);
      }

      final expiryResult = await _keyValueStorage.getInt(cacheKey);
      if (expiryResult.isLeft()) {
        return left(expiryResult.getLeft().toNullable()!);
      }
      final int? expiryTimeInt = expiryResult.getRight().toNullable();
      if (expiryTimeInt == null) {
        //await _sharedPreferencesService.remove(key);
        //await _sharedPreferencesService.remove(cacheKey);
        return right(null);
      }

      final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimeInt).toUtc();

      if (DateTime.now().toUtc().isAfter(expiryTime)) {
        return right(null);
      }

      return right(cachedValue);
    } catch (e, st) {
      _logger.severe('Error reading from cache', e, st);
      return left(
        AppFailure(
          code: StorageErrorCodes.sharedPrefsReadError,
          context: {'message': e.toString(), 'method': 'CachingService.read'},
        ),
      );
    }
  }

  Future<Either<AppFailure, void>> delete(String key) async {
    final cacheKey = _getCacheKey(key);
    try {
      await _keyValueStorage.delete(key);
      await _keyValueStorage.delete(cacheKey);
      return right(null);
    } catch (e, st) {
      _logger.severe('Error deleting from cache', e, st);
      return left(
        AppFailure(
          code: StorageErrorCodes.sharedPrefsDeleteError,
          context: {'message': e.toString(), 'method': 'CachingService.delete'},
        ),
      );
    }
  }

  String _getCacheKey(String key) => 'cache_$key';
}
