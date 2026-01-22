import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/config/constants/product_type.dart';
import 'package:intern_kassation_app/data/repositories/discard_reasons_repository.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_reason.dart';

import '../../../testing/fakes/services/api/fake_api_client.dart';
import '../../../testing/fakes/services/fake_caching_service.dart';

void main() {
  late FakeApiClient apiClient;
  late FakeCachingService cachingService;
  late DiscardReasonsRepository repository;

  setUp(() {
    apiClient = FakeApiClient();
    cachingService = FakeCachingService();
    repository = DiscardReasonsRepository(
      apiClient: apiClient,
      cachingService: cachingService,
    );
  });

  group(
    'DiscardReasonsRepository',
    () {
      group(
        'fetchDiscardReasons',
        () {
          test('returns cached reasons without calling API', () async {
            const productType = ProductType.granit;
            final cacheKey = '${DiscardReasonsRepository.rejectionCacheKeyPrefix}${productType.code}';
            final cached = [
              DiscardReason(
                errorCode: 'C001',
                description: 'Cached reason 1',
                displayCategory: 'Cached',
                shownDropdownCategory: 'Cached',
              ),
              DiscardReason(
                errorCode: 'C002',
                description: 'Cached reason 2',
                displayCategory: 'Cached',
                shownDropdownCategory: 'Cached',
              ),
              DiscardReason(
                errorCode: 'C003',
                description: 'Cached reason 3',
                displayCategory: 'Cached',
                shownDropdownCategory: 'Cached',
              ),
            ];

            await cachingService.write(cacheKey, DiscardReasonExtension.toJsonList(cached));

            final result = await repository.fetchDiscardReasons(productType);

            expect(apiClient.requestCount, equals(0));
            expect(result.isRight(), isTrue);
            final response = result.getRight().toNullable()!;
            expect(response.reasons.map((e) => e.errorCode), equals(['C001', 'C002', 'C003']));
          });

          test('fetches from API and caches when no cache exists', () async {
            const productType = ProductType.granit;
            final cacheKey = '${DiscardReasonsRepository.rejectionCacheKeyPrefix}${productType.code}';

            final result = await repository.fetchDiscardReasons(productType);

            expect(apiClient.requestCount, equals(1));
            expect(result.isRight(), isTrue);
            final response = result.getRight().toNullable()!;
            expect(response.reasons.length, equals(2));
            expect(cachingService.hasKey(cacheKey), isTrue);
          });

          test('forceRefresh bypasses cache and calls API', () async {
            const productType = ProductType.granit;
            final cacheKey = '${DiscardReasonsRepository.rejectionCacheKeyPrefix}${productType.code}';

            await cachingService.write(
              cacheKey,
              DiscardReasonExtension.toJsonList(
                [
                  DiscardReason(
                    errorCode: 'C001',
                    description: 'Cached reason',
                    displayCategory: 'Cached',
                    shownDropdownCategory: 'Cached',
                  ),
                ],
              ),
            );

            final result = await repository.fetchDiscardReasons(productType, forceRefresh: true);

            expect(apiClient.requestCount, equals(1));
            expect(result.isRight(), isTrue);
            final response = result.getRight().toNullable()!;
            expect(response.reasons.map((e) => e.errorCode), equals(['E001', 'E002']));
          });

          test('returns stale cache on API failure', () {
            FakeAsync().run((async) async {
              const productType = ProductType.granit;
              final cacheKey = '${DiscardReasonsRepository.rejectionCacheKeyPrefix}${productType.code}';
              final cached = [
                DiscardReason(
                  errorCode: 'C001',
                  description: 'Cached reason',
                  displayCategory: 'Cached',
                  shownDropdownCategory: 'Cached',
                ),
              ];

              await cachingService.write(cacheKey, DiscardReasonExtension.toJsonList(cached));

              async.elapse(const Duration(hours: 2));

              apiClient.shouldFail = true;

              final result = await repository.fetchDiscardReasons(productType);

              expect(apiClient.requestCount, equals(1));
              expect(result.isRight(), isTrue);
              final response = result.getRight().toNullable()!;
              expect(response.reasons.map((e) => e.errorCode), equals(['C001']));
              expect(response.failure, isNotNull);
            });
          });

          test('returns failure when API fails and no cache exists', () async {
            apiClient.shouldFail = true;

            final result = await repository.fetchDiscardReasons(ProductType.ceramics);

            expect(result.isLeft(), isTrue);
          });
        },
      );

      group(
        'fetchDropdownItems',
        () {
          test('returns cached items without calling API', () async {
            const category = 'worktop';
            const cacheKey = '${DiscardReasonsRepository.dropdownCacheKeyPrefix}$category';

            await cachingService.write(cacheKey, 'Cutting,Polishing');

            final result = await repository.fetchDropdownItems(category);

            expect(apiClient.requestCount, equals(0));
            expect(result.isRight(), isTrue);
            final items = result.getRight().toNullable()!;
            expect(items, equals(['Cutting', 'Polishing']));
          });

          test('fetches from API and caches when no cache exists', () async {
            const category = 'worktop';
            const cacheKey = '${DiscardReasonsRepository.dropdownCacheKeyPrefix}$category';

            final result = await repository.fetchDropdownItems(category);

            expect(apiClient.requestCount, equals(1));
            expect(result.isRight(), isTrue);
            final items = result.getRight().toNullable()!;
            expect(items, equals(['CNC', 'Assembly', 'Packaging']));
            expect(cachingService.hasKey(cacheKey), isTrue);
          });

          test('forceRefresh bypasses cache and calls API', () async {
            const category = 'worktop';
            const cacheKey = '${DiscardReasonsRepository.dropdownCacheKeyPrefix}$category';

            await cachingService.write(cacheKey, 'Cached1,Cached2');

            final result = await repository.fetchDropdownItems(category, forceRefresh: true);

            expect(apiClient.requestCount, equals(1));
            expect(result.isRight(), isTrue);
            final items = result.getRight().toNullable()!;
            expect(items, equals(['CNC', 'Assembly', 'Packaging']));
          });

          test('returns stale cache on API failure', () {
            FakeAsync().run((async) async {
              const category = 'worktop';
              const cacheKey = '${DiscardReasonsRepository.dropdownCacheKeyPrefix}$category';

              await cachingService.write(cacheKey, 'Cached1,Cached2');

              async.elapse(const Duration(hours: 2));

              apiClient.shouldFail = true;

              final result = await repository.fetchDropdownItems(category);

              expect(apiClient.requestCount, equals(1));
              expect(result.isRight(), isTrue);
              final items = result.getRight().toNullable()!;
              expect(items, equals(['Cached1', 'Cached2']));
            });
          });

          test('returns failure when API fails and no cache exists', () async {
            apiClient.shouldFail = true;

            final result = await repository.fetchDropdownItems('worktop');

            expect(result.isLeft(), isTrue);
          });
        },
      );
    },
  );
}
