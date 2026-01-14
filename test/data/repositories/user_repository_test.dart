import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/config/constants/shared_preferences_keys.dart';
import 'package:intern_kassation_app/data/repositories/user_repository.dart';

import '../../../testing/fakes/services/api/fake_api_client.dart';
import '../../../testing/fakes/services/fake_caching_service.dart';

void main() {
  late FakeApiClient fakeApiClient;
  late FakeCachingService fakeCachingService;
  late UserRepository userRepository;

  setUp(
    () {
      fakeApiClient = FakeApiClient();
      fakeCachingService = FakeCachingService();
      userRepository = UserRepository(apiClient: fakeApiClient, cachingService: fakeCachingService);
    },
  );

  group(
    'UserRepository tests',
    () {
      test('should fetch user data from API and cache it', () async {
        final result = await userRepository.fetchUserData();

        expect(result.isRight(), isTrue);
        final user = result.getRight().toNullable()!;
        expect(user.username, equals('fake_user'));
        expect(user.sessionId, equals('fake_session'));

        expect(fakeCachingService.hasKey(SharedPreferencesKeys.userData.name), isTrue);
      });

      test('should return cached user data without calling API', () async {
        // First call - fetches from API and caches
        await userRepository.fetchUserData();
        expect(fakeApiClient.requestCount, equals(1));

        // Second call - should use cache
        final cacheResult = await fakeCachingService.read(
          SharedPreferencesKeys.userData.name,
        );
        expect(cacheResult.isRight(), isTrue);
        expect(cacheResult.getRight().toNullable(), isNotNull);

        final result = await userRepository.fetchUserData();
        expect(fakeApiClient.requestCount, equals(1));

        expect(result.isRight(), isTrue);
        final user = result.getRight().toNullable()!;
        expect(user.username, equals('fake_user'));
      });

      test('should fetch from API when cache is expired', () {
        FakeAsync().run((async) async {
          // First call - caches with 30 min TTL
          await userRepository.fetchUserData();
          expect(fakeApiClient.requestCount, equals(1));

          // Fast-forward past expiry
          async.elapse(const Duration(minutes: 31));

          // Second call - cache expired, should fetch from API
          await userRepository.fetchUserData();
          expect(fakeApiClient.requestCount, equals(2));
        });
      });

      test('should use cache when not expired', () {
        FakeAsync().run((async) async {
          // First call
          await userRepository.fetchUserData();
          expect(fakeApiClient.requestCount, equals(1));

          // Fast-forward but not past expiry
          async.elapse(const Duration(minutes: 15));

          // Second call - cache still valid
          await userRepository.fetchUserData();
          expect(fakeApiClient.requestCount, equals(1)); // Still using cache
        });
      });

      test('should return expired cache on API failure when returnIfExpired is true', () {
        FakeAsync().run((async) async {
          // First call - caches data
          await userRepository.fetchUserData();

          // Make API fail
          fakeApiClient.shouldFail = true;

          // Fast-forward past expiry
          async.elapse(const Duration(minutes: 31));

          // Should return expired cache as fallback
          final result = await userRepository.fetchUserData();
          expect(result.isRight(), isTrue);
          final user = result.getRight().toNullable()!;
          expect(user.username, equals('fake_user'));
        });
      });

      test('should return API failure when cache is empty and API fails', () async {
        fakeApiClient.shouldFail = true;

        final result = await userRepository.fetchUserData();
        expect(result.isLeft(), isTrue);
      });

      test('should clear cached user data', () async {
        // Cache some data
        await userRepository.fetchUserData();
        expect(fakeCachingService.hasKey(SharedPreferencesKeys.userData.name), isTrue);

        // Clear cache
        await userRepository.clearCachedUserData();
        expect(fakeCachingService.hasKey(SharedPreferencesKeys.userData.name), isFalse);
      });

      test('should fetch from API after cache is cleared', () async {
        // First call - caches
        await userRepository.fetchUserData();
        expect(fakeApiClient.requestCount, equals(1));

        // Clear cache
        await userRepository.clearCachedUserData();

        // Next call should fetch from API
        await userRepository.fetchUserData();
        expect(fakeApiClient.requestCount, equals(2));
      });

      test('should handle corrupted cache data gracefully', () async {
        // Manually insert bad data into cache
        await fakeCachingService.write(
          SharedPreferencesKeys.userData.name,
          'invalid_json_data',
        );

        // Should fetch from API instead of crashing
        final result = await userRepository.fetchUserData();
        expect(result.isRight(), isTrue);
        expect(fakeApiClient.requestCount, equals(1));

        // Bad cache should be deleted
        final cachedUser = await userRepository.getCachedUserData();
        expect(cachedUser, isNotNull); // Now has valid data from API
      });

      test('getCachedUserData should return null when no cache exists', () async {
        final cachedUser = await userRepository.getCachedUserData();
        expect(cachedUser, isNull);
      });

      test('getCachedUserData should return null when cache is expired', () {
        FakeAsync().run((async) async {
          // Cache data
          await userRepository.fetchUserData();

          // Fast-forward past expiry
          async.elapse(const Duration(minutes: 31));

          final cachedUser = await userRepository.getCachedUserData();
          expect(cachedUser, isNull);
        });
      });

      test('getCachedUserData with returnIfExpired should return expired data', () {
        FakeAsync().run((async) async {
          // Cache data
          await userRepository.fetchUserData();

          // Fast-forward past expiry
          async.elapse(const Duration(minutes: 31));

          final cachedUser = await userRepository.getCachedUserData(
            returnIfExpired: true,
          );
          expect(cachedUser, isNotNull);
          expect(cachedUser!.username, equals('fake_user'));
        });
      });
    },
  );
}

/*
@override
  Future<Either<AppFailure, User>> getUserDetails() async {
    requestCount++;
    return right(
      User(
        username: 'fake_user',
        sessionId: 'fake_session',
      ),
    );
  }
*/
