import 'package:fpdart/src/either.dart';
import 'package:intern_kassation_app/data/services/caching_service.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:clock/clock.dart';

class FakeCachingService implements CachingService {
  final Map<String, String> _cache = {};
  final Map<String, DateTime> _expiry = {};

  @override
  Future<Either<AppFailure, void>> write(
    String key,
    String value, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    _cache[key] = value;
    _expiry[key] = clock.now().toUtc().add(ttl);
    return right(null);
  }

  @override
  Future<Either<AppFailure, String?>> read(
    String key, {
    bool returnIfExpired = false,
  }) async {
    final cachedValue = _cache[key];

    if (cachedValue == null) {
      return right(null);
    }

    if (returnIfExpired) {
      return right(cachedValue);
    }

    final expiryTime = _expiry[key];
    if (expiryTime == null) {
      return right(null);
    }

    if (clock.now().toUtc().isAfter(expiryTime)) {
      return right(null);
    }

    return right(cachedValue);
  }

  @override
  Future<Either<AppFailure, void>> delete(String key) async {
    _cache.remove(key);
    _expiry.remove(key);
    return right(null);
  }

  // Helper methods for testing
  void clear() {
    _cache.clear();
    _expiry.clear();
  }

  bool hasKey(String key) => _cache.containsKey(key);

  int get cacheSize => _cache.length;
}

/* class FakeCachingService implements CachingService {
  @override
  Future<Either<AppFailure, void>> delete(String key) async {
    return right(null);
  }

  @override
  Future<Either<AppFailure, String?>> read(String key, {bool returnIfExpired = false}) async {
    // what about expired?

    return right('fake_cached_value');
  }

  @override
  Future<Either<AppFailure, void>> write(String key, String value, {Duration ttl = const Duration(hours: 1)}) async {
    return right(null);
  }
}
 */
