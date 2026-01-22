import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/config/constants/product_type.dart';
import 'package:intern_kassation_app/data/repositories/order_repository.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/order_error_codes.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_order.dart';
import 'package:intern_kassation_app/domain/models/order/discarded_order_details.dart';
import 'package:intern_kassation_app/domain/models/order/discarded_order_preview.dart';
import 'package:intern_kassation_app/domain/models/order/discarded_orders_data.dart';
import 'package:intern_kassation_app/domain/models/order/order_details.dart';

class FakeOrderRepository implements OrderRepository {
  FakeOrderRepository({
    List<OrderDetails>? initialOrderDetails,
    List<DiscardedOrderDetails>? initialDiscardedDetails,
    List<String>? initialDiscardedOrders,
    this.returnNotFoundOnMissingOrder = false,
  }) : _orderDetailsByProductionOrder = {
         for (final item in initialOrderDetails ?? <OrderDetails>[]) item.productionOrder: item,
       },
       _discardedOrderDetails = List<DiscardedOrderDetails>.from(initialDiscardedDetails ?? []),
       _discardedOrders = List<String>.from(initialDiscardedOrders ?? []) {
    _discardedOrdersController.add(List<String>.from(_discardedOrders));
    if (_discardedOrderDetails.isNotEmpty) {
      final maxId = _discardedOrderDetails.map((e) => e.id).reduce((a, b) => a > b ? a : b);
      _nextDiscardedId = maxId + 1;
    }
  }

  final bool returnNotFoundOnMissingOrder;

  final _discardedOrdersController = StreamController<List<String>>.broadcast();

  final Map<String, OrderDetails> _orderDetailsByProductionOrder;
  final List<DiscardedOrderDetails> _discardedOrderDetails;
  final List<String> _discardedOrders;

  var _nextDiscardedId = 1;

  /// Set these in tests to force the next call to fail.
  AppFailure? nextFetchOrderDetailsFailure;
  AppFailure? nextDiscardOrderFailure;
  AppFailure? nextGetDiscardedOrdersFailure;
  AppFailure? nextGetDiscardedOrderDetailsFailure;
  AppFailure? nextFetchLatestDiscardedOrdersFailure;
  AppFailure? nextAddDiscardedOrderFailure;

  /// Optional one-time override for the next order details result.
  OrderDetails? nextOrderDetails;

  @override
  StreamController<List<String>> get discardedOrdersController => _discardedOrdersController;

  @override
  Future<Either<AppFailure, OrderDetails>> fetchOrderDetails(String productionOrder) async {
    final failure = nextFetchOrderDetailsFailure;
    nextFetchOrderDetailsFailure = null;
    if (failure != null) return left(failure);

    final trimmed = productionOrder.trim();

    final forced = nextOrderDetails;
    nextOrderDetails = null;
    if (forced != null) return right(forced);

    final details = _orderDetailsByProductionOrder[trimmed];
    if (details != null) return right(details);

    if (returnNotFoundOnMissingOrder) {
      return left(
        AppFailure(
          code: OrderErrorCodes.orderNotFound,
          context: {'productionOrder': trimmed},
        ),
      );
    }

    return right(
      OrderDetails(
        salesId: 'S-0001',
        worktop: 'WT-DEFAULT',
        productType: ProductType.granit,
        productGroup: 'PG-DEFAULT',
        productionOrder: trimmed,
      ),
    );
  }

  @override
  Future<Either<AppFailure, void>> discardOrder(DiscardOrder order) async {
    final failure = nextDiscardOrderFailure;
    nextDiscardOrderFailure = null;
    if (failure != null) return left(failure);

    final details = DiscardedOrderDetails(
      id: _nextDiscardedId++,
      errorCode: order.errorCode,
      worktop: order.worktop,
      productType: order.productType.code,
      discardedAtUtc: order.reportDate.toUtc(),
      prodId: order.productionOrder,
      salesId: order.salesId,
      note: order.note,
      employeeId: order.employeeId,
      machineName: order.machine.isEmpty ? null : order.machine,
      errorDescription: null,
    );

    _discardedOrderDetails.insert(0, details);
    await addDiscardedOrder(order.productionOrder);
    return right(null);
  }

  @override
  Future<Either<AppFailure, List<String>?>> fetchLatestDiscardedOrders() async {
    final failure = nextFetchLatestDiscardedOrdersFailure;
    nextFetchLatestDiscardedOrdersFailure = null;
    if (failure != null) return left(failure);

    final list = List<String>.from(_discardedOrders);
    _discardedOrdersController.add(list);
    return right(list);
  }

  @override
  Future<Either<AppFailure, void>> addDiscardedOrder(String productionOrder) async {
    final failure = nextAddDiscardedOrderFailure;
    nextAddDiscardedOrderFailure = null;
    if (failure != null) return left(failure);

    _discardedOrders
      ..remove(productionOrder)
      ..insert(0, productionOrder);
    _discardedOrdersController.add(List<String>.from(_discardedOrders));
    return right(null);
  }

  @override
  Future<Either<AppFailure, DiscardedOrdersData>> getDiscardedOrders({
    required String query,
    String? cursor,
    int? pageSize,
  }) async {
    final failure = nextGetDiscardedOrdersFailure;
    nextGetDiscardedOrdersFailure = null;
    if (failure != null) return left(failure);

    final normalizedQuery = query.trim().toLowerCase();

    final filtered = normalizedQuery.isEmpty
        ? List<DiscardedOrderDetails>.from(_discardedOrderDetails)
        : _discardedOrderDetails.where((item) {
            return item.prodId.toLowerCase().contains(normalizedQuery) ||
                item.salesId.toLowerCase().contains(normalizedQuery) ||
                item.errorCode.toLowerCase().contains(normalizedQuery);
          }).toList();

    final size = pageSize ?? filtered.length;
    final start = cursor == null ? 0 : int.tryParse(cursor) ?? 0;
    final end = (start + size).clamp(0, filtered.length);

    final items = filtered.sublist(start, end).map(_toPreview).toList();
    final nextCursor = end < filtered.length ? end.toString() : null;
    final previousCursor = start > 0 ? (start - size).clamp(0, filtered.length).toString() : null;

    return right(
      DiscardedOrdersData(
        items: items,
        pageSize: size,
        previousCursor: previousCursor,
        nextCursor: nextCursor,
      ),
    );
  }

  @override
  Future<Either<AppFailure, DiscardedOrderDetails>> getDiscardedOrderDetails(int id) async {
    final failure = nextGetDiscardedOrderDetailsFailure;
    nextGetDiscardedOrderDetailsFailure = null;
    if (failure != null) return left(failure);

    final found = _discardedOrderDetails.where((e) => e.id == id).toList();
    if (found.isEmpty) {
      return left(
        AppFailure(
          code: OrderErrorCodes.discardedOrderNotFound,
          context: {'id': id},
        ),
      );
    }
    return right(found.first);
  }

  DiscardedOrderPreview _toPreview(DiscardedOrderDetails details) {
    return DiscardedOrderPreview(
      id: details.id,
      errorCode: details.errorCode,
      productType: details.productType,
      discardedAtUtc: details.discardedAtUtc,
      prodId: details.prodId,
      salesId: details.salesId,
    );
  }
}
