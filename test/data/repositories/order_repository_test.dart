import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/config/constants/product_type.dart';
import 'package:intern_kassation_app/data/repositories/order_repository.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/product_error_codes.dart';

import '../../../testing/fakes/services/api/fake_api_client.dart';
import '../../../testing/fakes/services/fake_shared_preferences_service.dart';
import '../../../testing/models/discard_order.dart';

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
        final result = await fakeSharedPreferencesService.getStringList('latest_discarded_orders');
        result.match(
          (failure) => fail('Expected right but got left: $failure'),
          (value) {
            expect(value, isA<List<String>>());
            expect(value?.length, 1);
            expect(value, contains('PROD456'));
          },
        );
      });
    });
    group('getDiscardedOrders', () {});
    group('getDiscardedOrderDetails', () {});
  });
}
