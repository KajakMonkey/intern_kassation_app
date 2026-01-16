import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/config/constants/product_type.dart';
import 'package:intern_kassation_app/data/services/api/api_client.dart';
import 'package:intern_kassation_app/data/services/storage/caching_service.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_reason.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_reason_response.dart';
import 'package:logging/logging.dart';

class DiscardReasonsRepository {
  DiscardReasonsRepository({
    required ApiClient apiClient,
    required CachingService cachingService,
  }) : _apiClient = apiClient,
       _cachingService = cachingService;

  final ApiClient _apiClient;
  final CachingService _cachingService;

  static const rejectionCacheKeyPrefix = 'errorCodes';
  static const dropdownCacheKeyPrefix = 'dropdownItems';

  final _logger = Logger('DiscardReasonsRepository');

  Future<Either<AppFailure, DiscardReasonResponse>> fetchDiscardReasons(
    ProductType productType, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = '$rejectionCacheKeyPrefix${productType.code}';
    if (!forceRefresh) {
      final cachedReasons = await _loadDiscardFromCache(cacheKey);
      if (cachedReasons != null) {
        return right(DiscardReasonResponse(reasons: cachedReasons));
      }
    }

    final result = await _apiClient.getDiscardReasons(productType.code);

    return await result.fold(
      (failure) async {
        final staleReasons = await _loadDiscardFromCache(cacheKey, returnIfExpired: true);
        if (staleReasons != null) {
          _logger.warning('Using stale discard reasons from cache due to failure: $failure');
          return right(DiscardReasonResponse(reasons: staleReasons, failure: failure));
        }
        return left(failure);
      },
      (response) async {
        await _saveToCache(cacheKey, DiscardReasonExtension.toJsonList(response));
        return right(DiscardReasonResponse(reasons: response));
      },
    );
  }

  Future<Either<AppFailure, List<String>>> fetchDropdownItems(String category, {bool forceRefresh = false}) async {
    final cacheKey = '$dropdownCacheKeyPrefix$category';
    if (!forceRefresh) {
      final cachedItems = await _cachingService.read(cacheKey);
      final items = cachedItems.fold(
        (_) => null,
        (data) {
          _logger.info('Loaded dropdown items from cache for category: $category');
          return data != null ? List<String>.from(data.split(',')) : null;
        },
      );
      if (items != null) {
        return right(items);
      }
    }

    final response = await _apiClient.getDropdownValues(category);

    return await response.fold(
      (failure) async {
        final staleItems = await _loadDropdownFromCache(cacheKey, returnIfExpired: true);
        if (staleItems != null) {
          _logger.warning('Using stale dropdown items from cache due to failure: $failure');
          return right(staleItems);
        }
        return left(failure);
      },
      (items) async {
        await _cachingService.write(cacheKey, items.join(','));
        return right(items);
      },
    );
  }

  Future<List<DiscardReason>?> _loadDiscardFromCache(String key, {bool returnIfExpired = false}) async {
    try {
      final result = await _cachingService.read(key, returnIfExpired: returnIfExpired);
      return await result.fold(
        (_) => null,
        (cachedData) async {
          if (cachedData == null) {
            return null;
          }

          return DiscardReasonExtension.fromJsonList(cachedData);
        },
      );
    } catch (_) {
      _logger.severe('Error loading discard reasons from cache for key: $key');
      await _cachingService.delete(key);
      return null;
    }
  }

  Future<List<String>?> _loadDropdownFromCache(String key, {bool returnIfExpired = false}) async {
    try {
      final result = await _cachingService.read(key, returnIfExpired: returnIfExpired);
      return await result.fold(
        (_) => null,
        (cachedData) {
          if (cachedData == null) {
            return null;
          }

          return List<String>.from(cachedData.split(','));
        },
      );
    } catch (_) {
      _logger.severe('Error loading dropdown items from cache for key: $key');
      await _cachingService.delete(key);
      return null;
    }
  }

  Future<void> _saveToCache(String key, String data) async {
    await _cachingService.write(key, data);
  }
}
