import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/config/app_config.dart';
import 'package:intern_kassation_app/config/constants/product_type.dart';
import 'package:intern_kassation_app/config/constants/shared_preferences_keys.dart';
import 'package:intern_kassation_app/data/repositories/order_repository.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/product_error_codes.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/storage_error_codes.dart';
import 'package:intern_kassation_app/domain/models/order/discarded_order_preview.dart';

import '../../../testing/fakes/services/api/fake_api_client.dart';
import '../../../testing/fakes/services/fake_shared_preferences_service.dart';
import '../../../testing/models/fake_data_time.dart';
import '../../../testing/models/fake_discard_order.dart';

void main() {
  late FakeApiClient fakeApiClient;
  late FakeSharedPreferencesService fakeSharedPreferencesService;
  late OrderRepository orderRepository;

  setUp(() {
    fakeApiClient = FakeApiClient();
    fakeSharedPreferencesService = FakeSharedPreferencesService();
    orderRepository = OrderRepository(
      apiClient: fakeApiClient,
      sharedPreferencesService: fakeSharedPreferencesService,
    );
  });

  group('OrderRepository tests', () {
    group('fetchOrderDetails', () {
      test(
        'Should return order details',
        () async {
          // Arrange
          const productionOrder = 'PROD123';

          // Act
          final result = await orderRepository.fetchOrderDetails(productionOrder);

          // Assert
          expect(fakeApiClient.requestCount, 1);
          expect(result.isRight(), true);
          result.match(
            (failure) => fail('Expected right but got left: $failure'),
            (orderDetails) {
              expect(orderDetails.productionOrder, productionOrder);
              expect(orderDetails.productType, ProductType.granit);
              expect(orderDetails.worktop, 'Worktop1');
              expect(orderDetails.salesId, 'SAL456');
            },
          );
        },
      );

      test(
        'If product type is unknown return ProductErrorCodes.invalidProductType',
        () async {
          // Arrange
          const productionOrder = 'PROD_UNKNOWN';

          // Act
          final result = await orderRepository.fetchOrderDetails(productionOrder);

          // Assert
          expect(fakeApiClient.requestCount, 1);
          expect(result.isLeft(), true);
          result.match(
            (failure) {
              expect(failure.code, ProductErrorCodes.invalidProductType);
            },
            (orderDetails) => fail('Expected left but got right: $orderDetails'),
          );
        },
      );
    });
    group('discardOrder', () {
      test('Should return void if successful', () async {
        // Act
        final result = await orderRepository.discardOrder(kDiscardOrder);

        // Assert
        expect(fakeApiClient.requestCount, 1);
        expect(result.isRight(), true);
        result.match(
          (failure) => fail('Expected right but got left: $failure'),
          (value) {
            // Success case - void return value, nothing to assert
          },
        );
      });

      test(
        'after discard should add to latest discarded and to stream',
        () async {
          // Arrange
          log('Starting test for discard order stream emission');
          final emittedValues = <List<String>>[];
          final subscription = orderRepository.discardedOrdersController.stream.listen(
            (list) {
              log('Emitted discarded orders: $list');
              emittedValues.add(list);
            },
          );

          // Act
          final result = await orderRepository.discardOrder(kDiscardOrder);

          await Future<void>.delayed(const Duration(milliseconds: 250)); // Wait for stream emission

          // Assert
          expect(emittedValues.length, 2);
          log('Total emitted values count: ${emittedValues.length}: $emittedValues');
          expect(emittedValues.last, contains(kDiscardOrder.productionOrder));

          expect(fakeApiClient.requestCount, 1);
          expect(result.isRight(), true);
          result.match(
            (failure) => fail('Expected right but got left: $failure'),
            (value) {
              // Success case - void return value, nothing to assert
            },
          );

          await subscription.cancel();
        },
      );
    });
    group('fetchLatestDiscardedOrders', () {
      test('Should return list of latest discarded orders', () async {
        fakeSharedPreferencesService.overrideStringListValue = ['PROD123', 'PROD456'];
        // Act
        final result = await orderRepository.fetchLatestDiscardedOrders();

        // Assert
        expect(result.isRight(), true);
        result.match(
          (failure) => fail('Expected right but got left: $failure'),
          (orders) {
            expect(orders, isA<List<String>>());
            expect(orders?.length, 2);
            expect(orders, containsAll(['PROD123', 'PROD456']));
          },
        );
      });

      test('Should return a empty list if there are no discarded orders stored', () async {
        // Act
        final result = await orderRepository.fetchLatestDiscardedOrders();

        // Assert
        expect(result.isRight(), true);
        result.match(
          (failure) => fail('Expected right but got left: $failure'),
          (orders) {
            expect(orders, isA<List<String>?>());
            expect(orders?.length, isNull);
            expect(orders, isNull);
          },
        );
      });

      test('Should emit loaded discarded orders to stream', () async {
        // Arrange
        fakeSharedPreferencesService.overrideStringListValue = ['PROD123', 'PROD456'];
        final emittedValues = <List<String>?>[];
        final subscription = orderRepository.discardedOrdersController.stream.listen(
          (list) {
            emittedValues.add(list);
          },
        );

        // Act
        final result = await orderRepository.fetchLatestDiscardedOrders();

        await Future<void>.delayed(const Duration(milliseconds: 250)); // Wait for stream emission

        // Assert
        expect(result.isRight(), true);
        result.match(
          (failure) => fail('Expected right but got left: $failure'),
          (orders) {
            expect(orders, isA<List<String>>());
            expect(orders?.length, 2);
            expect(orders, containsAll(['PROD123', 'PROD456']));
          },
        );
        expect(emittedValues.length, 1);
        expect(emittedValues.last, ['PROD123', 'PROD456']);
        await subscription.cancel();
      });
    });
    group('addDiscardedOrder', () {
      test('Should add discarded order to shared preferences', () async {
        // Act
        await orderRepository.addDiscardedOrder('PROD456');

        // Assert
        final result = await fakeSharedPreferencesService.getStringList(SharedPreferencesKeys.discardedOrders.name);
        result.match(
          (failure) => fail('Expected right but got left: $failure'),
          (value) {
            expect(value, isA<List<String>>());
            expect(value?.length, 1);
            expect(value, contains('PROD456'));
          },
        );
      });

      test('Should remove the oldest discarded orders when limit is exceeded', () async {
        // Arrange
        fakeSharedPreferencesService.overrideStringListValue = List<String>.generate(
          AppConfig.latestReportsLimit,
          (index) => 'PROD${index + 1}',
        );

        // Act
        await orderRepository.addDiscardedOrder('PROD456');
        await orderRepository.addDiscardedOrder('PROD457');

        // Assert
        final result = await fakeSharedPreferencesService.getStringList(SharedPreferencesKeys.discardedOrders.name);
        result.match(
          (failure) => fail('Expected right but got left: $failure'),
          (value) {
            expect(value, isA<List<String>>());
            expect(value?.length, AppConfig.latestReportsLimit);
            expect(value, contains('PROD456'));
            expect(value, contains('PROD457'));
            expect(value, isNot(contains('PROD24')));
            expect(value, isNot(contains('PROD25')));
          },
        );
      });

      test('Should return StorageErrorCodes.sharedPrefsWriteError if save fails', () async {
        // Arrange
        fakeSharedPreferencesService.shouldFailWrites = true;

        // Act
        final result = await orderRepository.addDiscardedOrder('PROD456');

        // Assert
        expect(result.isLeft(), true);
        result.match(
          (failure) {
            expect(failure.code, StorageErrorCodes.sharedPrefsWriteError);
          },
          (_) => fail('Expected left but got right'),
        );
      });

      test('Should return StorageErrorCodes.sharedPrefsReadError if read fails', () async {
        // Arrange
        fakeSharedPreferencesService.shouldFailReads = true;

        // Act
        final result = await orderRepository.addDiscardedOrder('PROD456');

        // Assert
        expect(result.isLeft(), true);
        result.match(
          (failure) {
            expect(failure.code, StorageErrorCodes.sharedPrefsReadError);
          },
          (_) => fail('Expected left but got right'),
        );
      });

      test('Should not add anything to stream if save fails', () async {
        // Arrange
        fakeSharedPreferencesService
          ..overrideStringListValue = ['PROD123']
          ..shouldFailWrites = true;

        final emitted = <List<String>>[];
        final sub = orderRepository.discardedOrdersController.stream.listen(emitted.add);

        // Act
        final result = await orderRepository.addDiscardedOrder('PROD456');
        await Future<void>.delayed(const Duration(milliseconds: 250));

        // Assert
        expect(result.isLeft(), true);
        result.match(
          (failure) => expect(failure.code, StorageErrorCodes.sharedPrefsWriteError),
          (_) => fail('Expected left but got right'),
        );

        expect(emitted.length, 1);
        expect(emitted.single, ['PROD123']);
        expect(emitted.single, isNot(contains('PROD456')));

        await sub.cancel();
      });
    });
    group('getDiscardedOrders', () {
      test('Should return discarded orders data', () async {
        // Arrange
        const query = 'test_query';

        // Act
        final result = await orderRepository.getDiscardedOrders(query: query);

        // Assert
        expect(fakeApiClient.requestCount, 1);
        expect(result.isRight(), true);
        result.match(
          (failure) => fail('Expected right but got left: $failure'),
          (data) {
            expect(data.items, isA<List<DiscardedOrderPreview>>());
            expect(data.items.length, 2);
            expect(data.nextCursor, isNull);
          },
        );
      });
    });
    group('getDiscardedOrderDetails', () {
      test('Should return discarded order details', () async {
        // Arrange
        const orderId = 1;

        // Act
        final result = await orderRepository.getDiscardedOrderDetails(orderId);

        // Assert
        expect(fakeApiClient.requestCount, 1);
        expect(result.isRight(), true);
        result.match(
          (failure) => fail('Expected right but got left: $failure'),
          (details) {
            expect(details.id, 1);
            expect(details.prodId, 'PROD123');
            expect(details.salesId, 'SAL456');
            expect(details.discardedAtUtc, kDateTime);
            expect(details.employeeId, 'EMP789');
            expect(details.errorCode, 'E001');
            expect(details.note, 'Sample discarded order');
            expect(details.productType, 'TypeA');
            expect(details.worktop, 'Worktop1');
            expect(details.errorDescription, 'Defective item');
            expect(details.machineName, 'MachineX');
          },
        );
      });
    });
  });
}
