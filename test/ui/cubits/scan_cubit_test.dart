import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/order_error_codes.dart';
import 'package:intern_kassation_app/ui/scan/cubit/scan_cubit.dart';

import '../../../testing/fakes/repositories/fake_order_repository.dart';
import '../../../testing/models/fake_order_data.dart';

void main() {
  late FakeOrderRepository fakeOrderRepository;
  late ScanCubit scanCubit;

  setUp(() {
    fakeOrderRepository = FakeOrderRepository();
    scanCubit = ScanCubit(
      orderRepository: fakeOrderRepository,
    );
  });

  tearDown(() async {
    await scanCubit.close();
  });

  group('ScanCubit', () {
    test('initial state is ScanState.initial()', () {
      expect(scanCubit.state, equals(ScanState.initial()));
    });

    blocTest(
      'emits loading and success when fetchOrderDetails succeeds',
      build: () {
        fakeOrderRepository = FakeOrderRepository(
          initialOrderDetails: [kOrderDetails],
        );
        scanCubit = ScanCubit(orderRepository: fakeOrderRepository);
        return scanCubit;
      },
      act: (cubit) => cubit.fetchOrderDetails('PO-1'),
      expect: () => [
        const ScanState(
          orderStatus: OrderState.loading(),
          latestDiscardedStatus: LatestDiscardedState.initial(),
        ),
        ScanState(
          orderStatus: OrderState.success(kOrderDetails),
          latestDiscardedStatus: const LatestDiscardedState.initial(),
        ),
      ],
    );

    blocTest<ScanCubit, ScanState>(
      'emits loading and failure when fetchOrderDetails fails',
      build: () {
        fakeOrderRepository = FakeOrderRepository(
          returnNotFoundOnMissingOrder: true,
        );
        scanCubit = ScanCubit(orderRepository: fakeOrderRepository);
        return scanCubit;
      },
      act: (cubit) => cubit.fetchOrderDetails('MISSING-ORDER'),
      expect: () => [
        const ScanState(
          orderStatus: OrderState.loading(),
          latestDiscardedStatus: LatestDiscardedState.initial(),
        ),
        ScanState(
          orderStatus: OrderState.failure(
            AppFailure(
              code: OrderErrorCodes.orderNotFound,
              context: {'productionOrder': 'MISSING-ORDER'},
            ),
          ),
          latestDiscardedStatus: const LatestDiscardedState.initial(),
        ),
      ],
    );

    blocTest<ScanCubit, ScanState>(
      'emits loading and success when fetchLatestDiscardedOrders succeeds',
      build: () {
        fakeOrderRepository = FakeOrderRepository(
          initialDiscardedOrders: ['PO-1', 'PO-2'],
        );
        scanCubit = ScanCubit(orderRepository: fakeOrderRepository);
        return scanCubit;
      },
      act: (cubit) => cubit.fetchLatestDiscardedOrders(),
      expect: () => [
        const ScanState(
          orderStatus: OrderState.initial(),
          latestDiscardedStatus: LatestDiscardedState.loading(),
        ),
        const ScanState(
          orderStatus: OrderState.initial(),
          latestDiscardedStatus: LatestDiscardedState.success(['PO-1', 'PO-2']),
        ),
      ],
    );

    blocTest<ScanCubit, ScanState>(
      'emits initial after clearOrderStatus',
      build: () {
        fakeOrderRepository = FakeOrderRepository(
          initialOrderDetails: [kOrderDetails],
        );
        scanCubit = ScanCubit(orderRepository: fakeOrderRepository);
        return scanCubit;
      },
      act: (cubit) async {
        await cubit.fetchOrderDetails('PO-1');
        cubit.clearOrderStatus();
      },
      expect: () => [
        const ScanState(
          orderStatus: OrderState.loading(),
          latestDiscardedStatus: LatestDiscardedState.initial(),
        ),
        ScanState(
          orderStatus: OrderState.success(kOrderDetails),
          latestDiscardedStatus: const LatestDiscardedState.initial(),
        ),
        const ScanState(
          orderStatus: OrderState.initial(),
          latestDiscardedStatus: LatestDiscardedState.initial(),
        ),
      ],
    );
  });
}
