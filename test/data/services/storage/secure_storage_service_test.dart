import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/data/services/storage/secure_storage_service.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/storage_error_codes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  late SecureStorageService service;
  late Map<String, String> storage;
  var shouldThrowRead = false;
  var shouldThrowWrite = false;
  var shouldThrowDelete = false;

  Future<dynamic> handler(MethodCall call) async {
    final args = Map<String, dynamic>.from(call.arguments as Map);
    final key = args['key'] as String;

    switch (call.method) {
      case 'read':
        if (shouldThrowRead) throw Exception('read error');
        return storage[key];
      case 'write':
        if (shouldThrowWrite) throw Exception('write error');
        final value = args['value'] as String?;
        if (value != null) {
          storage[key] = value;
        }
        return null;
      case 'delete':
        if (shouldThrowDelete) throw Exception('delete error');
        storage.remove(key);
        return null;
      default:
        return null;
    }
  }

  setUp(() {
    service = const SecureStorageService();
    storage = <String, String>{};
    shouldThrowRead = false;
    shouldThrowWrite = false;
    shouldThrowDelete = false;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, handler);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('SecureStorageService', () {
    test('write then read returns stored value', () async {
      const key = 'token';
      const value = 'abc';

      final writeResult = await service.write(key, value);
      writeResult.match(
        (l) => fail('Expected right, got $l'),
        (_) {},
      );

      final readResult = await service.read(key);
      readResult.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, value),
      );
    });

    test('delete removes stored value', () async {
      storage['k'] = 'v';

      final deleteResult = await service.delete('k');
      deleteResult.match(
        (l) => fail('Expected right, got $l'),
        (_) {},
      );

      final readResult = await service.read('k');
      readResult.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, isNull),
      );
    });

    test('getInt returns parsed int after setInt', () async {
      const key = 'int_key';

      final setResult = await service.setInt(key, 42);
      setResult.match(
        (l) => fail('Expected right, got $l'),
        (_) {},
      );

      final getResult = await service.getInt(key);
      getResult.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, 42),
      );
    });

    test('getInt returns failure when read throws', () async {
      shouldThrowRead = true;

      final result = await service.getInt('k');
      result.match(
        (l) => expect(l.code, StorageErrorCodes.secureStorageReadError),
        (_) => fail('Expected left'),
      );
    });

    test('setInt returns failure when write throws', () async {
      shouldThrowWrite = true;

      final result = await service.setInt('k', 10);
      result.match(
        (l) => expect(l.code, StorageErrorCodes.secureStorageWriteError),
        (_) => fail('Expected left'),
      );
    });

    test('getStringList returns list and null when missing', () async {
      final missingResult = await service.getStringList('missing');
      missingResult.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, isNull),
      );

      storage['list'] = 'a|b|c';

      final listResult = await service.getStringList('list');
      listResult.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, ['a', 'b', 'c']),
      );
    });

    test('getStringList returns failure when read throws', () async {
      shouldThrowRead = true;

      final result = await service.getStringList('k');
      result.match(
        (l) => expect(l.code, StorageErrorCodes.secureStorageReadError),
        (_) => fail('Expected left'),
      );
    });

    test('setStringList stores pipe-delimited value', () async {
      const key = 'list_key';

      final result = await service.setStringList(key, ['x', 'y']);
      result.match(
        (l) => fail('Expected right, got $l'),
        (_) {},
      );

      expect(storage[key], 'x|y');
    });

    test('setStringList returns failure when write throws', () async {
      shouldThrowWrite = true;

      final result = await service.setStringList('k', ['a']);
      result.match(
        (l) => expect(l.code, StorageErrorCodes.secureStorageWriteError),
        (_) => fail('Expected left'),
      );
    });

    test('getBool returns bool and null when missing', () async {
      final missingResult = await service.getBool('missing');
      missingResult.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, isNull),
      );

      storage['flag'] = '1';

      final boolResult = await service.getBool('flag');
      boolResult.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, isTrue),
      );
    });

    test('getBool returns failure when read throws', () async {
      shouldThrowRead = true;

      final result = await service.getBool('k');
      result.match(
        (l) => expect(l.code, StorageErrorCodes.secureStorageReadError),
        (_) => fail('Expected left'),
      );
    });

    test('setBool returns failure when write throws', () async {
      shouldThrowWrite = true;

      final result = await service.setBool('k', true);
      result.match(
        (l) => expect(l.code, StorageErrorCodes.secureStorageWriteError),
        (_) => fail('Expected left'),
      );
    });

    test('setBool stores 1/0 and getBool returns correct value', () async {
      const key = 'bool_key';

      final setResult = await service.setBool(key, false);
      setResult.match(
        (l) => fail('Expected right, got $l'),
        (_) {},
      );

      expect(storage[key], '0');

      final getResult = await service.getBool(key);
      getResult.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, isFalse),
      );
    });

    test('read returns failure when secure storage throws', () async {
      shouldThrowRead = true;

      final result = await service.read('k');
      result.match(
        (l) => expect(l.code, StorageErrorCodes.secureStorageReadError),
        (_) => fail('Expected left'),
      );
    });

    test('write returns failure when secure storage throws', () async {
      shouldThrowWrite = true;

      final result = await service.write('k', 'v');
      result.match(
        (l) => expect(l.code, StorageErrorCodes.secureStorageWriteError),
        (_) => fail('Expected left'),
      );
    });

    test('delete returns failure when secure storage throws', () async {
      shouldThrowDelete = true;

      final result = await service.delete('k');
      result.match(
        (l) => expect(l.code, StorageErrorCodes.secureStorageDeleteError),
        (_) => fail('Expected left'),
      );
    });
  });
}
