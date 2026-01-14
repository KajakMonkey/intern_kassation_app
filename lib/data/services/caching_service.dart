import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/data/services/shared_preferences_service.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/storage_error_codes.dart';

class CachingService {
  CachingService({required SharedPreferencesService sharedPreferencesService})
    : _sharedPreferencesService = sharedPreferencesService;
  final SharedPreferencesService _sharedPreferencesService;

  static const _defaultTtl = Duration(minutes: 15);

  Future<Either<AppFailure, void>> write(String key, String value, {Duration ttl = _defaultTtl}) async {
    final cacheKey = _getCacheKey(key);
    try {
      await _sharedPreferencesService.setString(key, value);
      final expiryTime = DateTime.now().toUtc().add(ttl).millisecondsSinceEpoch;
      await _sharedPreferencesService.setInt(cacheKey, expiryTime);
      return right(null);
    } catch (e) {
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
      final result = await _sharedPreferencesService.getString(key);
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

      final expiryResult = await _sharedPreferencesService.getInt(cacheKey);
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
    } catch (e) {
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
      await _sharedPreferencesService.remove(key);
      await _sharedPreferencesService.remove(cacheKey);
      return right(null);
    } catch (e) {
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
