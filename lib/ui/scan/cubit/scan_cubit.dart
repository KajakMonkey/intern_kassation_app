import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/data/repositories/order_repository.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/models/order/order_details.dart';
import 'package:intern_kassation_app/utils/extensions/bloc_extension.dart';

part 'scan_state.dart';
part 'scan_cubit.freezed.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(ScanState.initial());

  final OrderRepository _orderRepository;

  StreamSubscription<List<String>>? _discardedSub;

  Future<void> fetchOrderDetails(String productionOrder) async {
    if (state.orderStatus == const OrderState.loading()) return;
    emit(state.copyWith(orderStatus: const OrderState.loading()));

    final result = await _orderRepository.fetchOrderDetails(productionOrder);

    result.fold(
      (failure) {
        safeEmit(
          state.copyWith(orderStatus: OrderState.failure(failure.withContext({'productionOrder': productionOrder}))),
        );
      },
      (details) {
        safeEmit(state.copyWith(orderStatus: OrderState.success(details)));
      },
    );
  }

  Future<void> fetchLatestDiscardedOrders() async {
    if (state.latestDiscardedStatus == const LatestDiscardedState.loading()) return;
    emit(state.copyWith(latestDiscardedStatus: const LatestDiscardedState.loading()));

    _discardedSub ??= _orderRepository.discardedOrdersController.stream.listen(
      (orders) => safeEmit(state.copyWith(latestDiscardedStatus: LatestDiscardedState.success(orders))),
      onError: (_) {}, // ignore errors
    );

    await _orderRepository.fetchLatestDiscardedOrders();
  }

  void clearOrderStatus() {
    safeEmit(state.copyWith(orderStatus: const OrderState.initial()));
  }

  @override
  Future<void> close() async {
    await _discardedSub?.cancel();
    _discardedSub = null;
    return super.close();
  }
}
