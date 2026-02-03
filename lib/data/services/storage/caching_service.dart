import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/config/app_config.dart';
import 'package:intern_kassation_app/data/services/storage/interface/key_value_storage.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';

class CachingService {
  CachingService({required KeyValueStorage keyValueStorage}) : _keyValueStorage = keyValueStorage;
  final KeyValueStorage _keyValueStorage;

  static const _defaultTtl = AppConfig.defaultCachingTtl;

  Future<Either<AppFailure, void>> write(String key, String value, {Duration ttl = _defaultTtl}) async {
    final cacheKey = _getCacheKey(key);

    final valueResult = await _keyValueStorage.write(key, value);
    final expiryTime = DateTime.now().toUtc().add(ttl).millisecondsSinceEpoch;
    final expiryResult = await _keyValueStorage.setInt(cacheKey, expiryTime);

    if (valueResult.isLeft()) {
      return left(valueResult.getLeft().toNullable()!);
    }

    if (expiryResult.isLeft()) {
      return left(expiryResult.getLeft().toNullable()!);
    }
    return right(null);
  }

  Future<Either<AppFailure, String?>> read(String key, {bool returnIfExpired = false}) async {
    final cacheKey = _getCacheKey(key);

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
  }

  Future<Either<AppFailure, void>> delete(String key) async {
    final cacheKey = _getCacheKey(key);

    final valueResult = await _keyValueStorage.delete(key);
    final expiryResult = await _keyValueStorage.delete(cacheKey);

    if (valueResult.isLeft()) {
      return left(valueResult.getLeft().toNullable()!);
    }

    if (expiryResult.isLeft()) {
      return left(expiryResult.getLeft().toNullable()!);
    }
    return right(null);
  }

  String _getCacheKey(String key) => 'cache_$key';
}
