import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/config/app_config.dart';
import 'package:intern_kassation_app/config/constants/product_type.dart';
import 'package:intern_kassation_app/config/constants/shared_preferences_keys.dart';
import 'package:intern_kassation_app/data/services/api/api_client.dart';
import 'package:intern_kassation_app/data/services/api/models/orders/discarded_order_query_request.dart';
import 'package:intern_kassation_app/data/services/api/models/orders/order_details_response.dart';
import 'package:intern_kassation_app/data/services/storage/shared_preferences_service.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/product_error_codes.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_order.dart';
import 'package:intern_kassation_app/domain/models/order/discarded_order_details.dart';
import 'package:intern_kassation_app/domain/models/order/discarded_orders_data.dart';
import 'package:intern_kassation_app/domain/models/order/order_details.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class OrderRepository {
  OrderRepository({required ApiClient apiClient, required SharedPreferencesService sharedPreferencesService})
    : _apiClient = apiClient,
      _sharedPreferencesService = sharedPreferencesService;
  final ApiClient _apiClient;
  final SharedPreferencesService _sharedPreferencesService;

  final discardedOrdersController = StreamController<List<String>>.broadcast();

  Future<Either<AppFailure, OrderDetails>> fetchOrderDetails(String productionOrder) async {
    final trimmedOrder = productionOrder.trim();
    final result = await _apiClient.getOrderDetails(trimmedOrder);
    return result.fold(
      left,
      (response) {
        final orderDetails = response.toDomain();
        if (orderDetails.productType == ProductType.unknown) {
          return left(
            AppFailure(
              code: ProductErrorCodes.invalidProductType,
              context: {'produktionsOrder': orderDetails.productionOrder, 'productTypeResponse': response.productType},
            ),
          );
        }
        return right(orderDetails);
      },
    );
  }

  Future<Either<AppFailure, void>> discardOrder(DiscardOrder order) async {
    final formData = FormData();
    formData.fields.addAll([
      MapEntry('orderNr', order.salesId),
      MapEntry('productionOrder', order.productionOrder),
      MapEntry('reportDate', order.reportDate.toUtc().toIso8601String()),
      MapEntry('errorCode', order.errorCode),
      MapEntry('productType', order.productType.code),
      MapEntry('worktop', order.worktop),
      MapEntry('employeeId', order.employeeId),
    ]);
    if (order.note.isNotEmpty) {
      formData.fields.add(MapEntry('notes', order.note));
    }
    if (order.machine.isNotEmpty) {
      formData.fields.add(MapEntry('machine', order.machine));
    }

    final formattedDate = DateFormat('yyyyMMddHHmmss').format(order.reportDate.toUtc());
    final localImagePaths = order.imagePaths;

    for (var i = 0; i < localImagePaths.length; i++) {
      final sourcePath = localImagePaths[i];
      final ext = path.extension(sourcePath);
      final fileName = '${order.productionOrder}-$i-$formattedDate$ext';
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(
            sourcePath,
            filename: fileName,
            contentType: DioMediaType.parse(_getMimeType(fileName)),
          ),
        ),
      );
    }

    final result = await _apiClient.submitDiscardOrder(formData, order.productionOrder);

    return result.fold(
      left,
      (_) async {
        await addDiscardedOrder(order.productionOrder);
        return right(null);
      },
    );
  }

  Future<Either<AppFailure, List<String>?>> fetchLatestDiscardedOrders() async {
    final result = await _sharedPreferencesService.getStringList(SharedPreferencesKeys.discardedOrders.name);
    final list = result.getOrElse((_) => []) ?? [];
    discardedOrdersController.add(list);
    return result;
  }

  Future<Either<AppFailure, void>> addDiscardedOrder(String productionOrder) async {
    final currentResult = await fetchLatestDiscardedOrders();
    return currentResult.fold(
      left,
      (currentList) async {
        final updatedDiscardedOrders = List<String>.from(currentList ?? [])
          ..remove(productionOrder)
          ..insert(0, productionOrder);

        if (updatedDiscardedOrders.length > AppConfig.latestReportsLimit) {
          updatedDiscardedOrders.removeRange(AppConfig.latestReportsLimit, updatedDiscardedOrders.length);
        }

        final saveResult = await _sharedPreferencesService.setStringList(
          SharedPreferencesKeys.discardedOrders.name,
          updatedDiscardedOrders,
        );
        saveResult.fold(
          (failure) => null,
          (_) => discardedOrdersController.add(updatedDiscardedOrders),
        );
        return saveResult;
      },
    );
  }

  // * Discarded Orders

  Future<Either<AppFailure, DiscardedOrdersData>> getDiscardedOrders({
    required String query,
    String? cursor,
    int? pageSize,
  }) async {
    final request = DiscardedOrderQueryRequest(
      query: query,
      cursor: cursor,
      pageSize: pageSize ?? AppConfig.discardedOrdersPageSize,
    );
    final result = await _apiClient.getDiscardedOrders(request);
    return result;
  }

  Future<Either<AppFailure, DiscardedOrderDetails>> getDiscardedOrderDetails(int id) async {
    final result = await _apiClient.getDiscardedOrderDetails(id);
    return result;
  }

  // * Helper methods

  String _getMimeType(String fileName) {
    final mime = lookupMimeType(fileName);
    return mime ?? (fileName.endsWith('.png') ? 'image/png' : 'image/jpeg');
  }
}
