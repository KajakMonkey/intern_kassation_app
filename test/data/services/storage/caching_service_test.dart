import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/data/services/storage/caching_service.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/storage_error_codes.dart';

import '../../../../testing/fakes/services/fake_shared_preferences_service.dart';

void main() {
  late FakeSharedPreferencesService fakeSharedPreferencesService;
  late CachingService cachingService;

  setUp(() {
    fakeSharedPreferencesService = FakeSharedPreferencesService();
    cachingService = CachingService(keyValueStorage: fakeSharedPreferencesService);
  });

  group('CachingService', () {
    test('write stores value and expiry', () async {
      const key = 'token';
      const value = 'abc';
      const ttl = Duration(minutes: 10);
      final start = DateTime.now().toUtc();

      final result = await cachingService.write(key, value, ttl: ttl);

      result.match(
        (l) => fail('Expected right, got $l'),
        (_) {},
      );

      final storedValue = await fakeSharedPreferencesService.read(key);
      storedValue.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, value),
      );

      final expiryResult = await fakeSharedPreferencesService.getInt('cache_$key');
      expiryResult.match(
        (l) => fail('Expected right, got $l'),
        (r) {
          expect(r, isNotNull);
          final expiryTime = DateTime.fromMillisecondsSinceEpoch(r!).toUtc();
          final end = DateTime.now().toUtc();
          expect(
            expiryTime.isAfter(start.add(ttl).subtract(const Duration(seconds: 1))),
            isTrue,
          );
          expect(
            expiryTime.isBefore(end.add(ttl).add(const Duration(seconds: 1))),
            isTrue,
          );
        },
      );
    });

    test('write returns AppFailure when storage write fails', () async {
      fakeSharedPreferencesService.shouldFailWrites = true;

      final result = await cachingService.write('k', 'v');

      result.match(
        (l) => expect(l.code, StorageErrorCodes.sharedPrefsWriteError),
        (_) => fail('Expected left'),
      );
    });

    test('read returns cached value when not expired', () async {
      await cachingService.write('k', 'v', ttl: const Duration(hours: 1));

      final result = await cachingService.read('k');

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, 'v'),
      );
    });

    test('read returns null when expired', () async {
      await fakeSharedPreferencesService.write('k', 'v');
      final past = DateTime.now().toUtc().subtract(const Duration(minutes: 1)).millisecondsSinceEpoch;
      await fakeSharedPreferencesService.setInt('cache_k', past);

      final result = await cachingService.read('k');

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, isNull),
      );
    });

    test('read returns cached value when returnIfExpired is true', () async {
      await fakeSharedPreferencesService.write('k', 'v');
      final past = DateTime.now().toUtc().subtract(const Duration(minutes: 1)).millisecondsSinceEpoch;
      await fakeSharedPreferencesService.setInt('cache_k', past);

      final result = await cachingService.read('k', returnIfExpired: true);

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, 'v'),
      );
    });

    test('read returns null when cached value missing', () async {
      final result = await cachingService.read('missing');

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, isNull),
      );
    });

    test('read returns null when expiry missing', () async {
      await fakeSharedPreferencesService.write('k', 'v');

      final result = await cachingService.read('k');

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, isNull),
      );
    });

    test('read returns AppFailure when storage read fails', () async {
      fakeSharedPreferencesService.shouldFailReads = true;

      final result = await cachingService.read('k');

      result.match(
        (l) => expect(l.code, StorageErrorCodes.sharedPrefsReadError),
        (_) => fail('Expected left'),
      );
    });

    test('delete removes value and expiry', () async {
      await cachingService.write('k', 'v');

      final result = await cachingService.delete('k');

      result.match(
        (l) => fail('Expected right, got $l'),
        (_) {},
      );

      final storedValue = await fakeSharedPreferencesService.read('k');
      storedValue.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, isNull),
      );

      final expiryResult = await fakeSharedPreferencesService.getInt('cache_k');
      expiryResult.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, isNull),
      );
    });

    test('delete returns AppFailure when storage delete fails', () async {
      fakeSharedPreferencesService.shouldFailDeletes = true;

      final result = await cachingService.delete('k');

      result.match(
        (l) => expect(l.code, StorageErrorCodes.sharedPrefsDeleteError),
        (_) => fail('Expected left'),
      );
    });
  });
}
