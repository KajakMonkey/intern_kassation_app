import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/data/services/api/api_client.dart';
import 'package:intern_kassation_app/data/services/api/models/models_index.dart';
import 'package:intern_kassation_app/data/services/api/models/orders/discarded_order_query_request.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/network_error_codes.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/product_error_codes.dart';
import 'package:intern_kassation_app/domain/models/models_index.dart';

import '../../../models/fake_discarded_order_details.dart';

class FakeApiClient implements ApiClient {
  var requestCount = 0;
  var shouldFail = false;

  static const _constantDateTime = '2026-01-01T12:00:00Z';

  @override
  AuthHeaderProvider? authHeaderProvider;

  @override
  Future<Either<AppFailure, List<DiscardReason>>> getDiscardReasons(String productType) async {
    requestCount++;

    if (shouldFail) {
      return left(
        AppFailure(
          code: NetworkErrorCodes.connectionTimeout,
          context: {'message': 'API request failed'},
        ),
      );
    }

    return right(
      [
        DiscardReason(
          errorCode: 'E001',
          description: 'Defective item',
          displayCategory: 'Quality Issues',
          shownDropdownCategory: 'Quality',
        ),
        DiscardReason(
          errorCode: 'E002',
          description: 'Wrong item shipped',
          displayCategory: 'Logistics Issues',
          shownDropdownCategory: 'Logistics',
        ),
      ],
    );
  }

  @override
  Future<Either<AppFailure, DiscardedOrderDetails>> getDiscardedOrderDetails(int id) async {
    requestCount++;

    if (shouldFail) {
      return left(
        AppFailure(
          code: NetworkErrorCodes.connectionTimeout,
          context: {'message': 'API request failed'},
        ),
      );
    }

    return right(kDiscardedOrderDetails);
  }

  @override
  Future<Either<AppFailure, DiscardedOrdersData>> getDiscardedOrders(DiscardedOrderQueryRequest request) async {
    requestCount++;

    if (shouldFail) {
      return left(
        AppFailure(
          code: NetworkErrorCodes.connectionTimeout,
          context: {'message': 'API request failed'},
        ),
      );
    }

    return right(
      DiscardedOrdersData(
        pageSize: 25,
        items: [
          DiscardedOrderPreview(
            id: 1,
            prodId: 'PROD123',
            salesId: 'SAL456',
            discardedAtUtc: DateTime.parse(_constantDateTime),
            errorCode: 'E001',
            productType: 'TypeA',
          ),
          DiscardedOrderPreview(
            id: 2,
            prodId: 'PROD789',
            salesId: 'SAL012',
            discardedAtUtc: DateTime.parse(_constantDateTime),
            errorCode: 'E002',
            productType: 'TypeB',
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<AppFailure, List<String>>> getDropdownValues(String category) async {
    requestCount++;

    if (shouldFail) {
      return left(
        AppFailure(
          code: NetworkErrorCodes.connectionTimeout,
          context: {'message': 'API request failed'},
        ),
      );
    }

    return right(
      ['CNC', 'Assembly', 'Packaging'],
    );
  }

  @override
  Future<Either<AppFailure, Employee>> getEmployeeDetails(String employeeId) async {
    requestCount++;

    if (shouldFail) {
      return left(
        AppFailure(
          code: NetworkErrorCodes.connectionTimeout,
          context: {'message': 'API request failed'},
        ),
      );
    }

    return right(
      Employee(id: employeeId, name: 'John Doe'),
    );
  }

  @override
  Future<Either<AppFailure, OrderDetailsResponse>> getOrderDetails(String productionOrder) async {
    requestCount++;

    if (shouldFail) {
      return left(
        AppFailure(
          code: NetworkErrorCodes.connectionTimeout,
          context: {'message': 'API request failed'},
        ),
      );
    }

    if (productionOrder == 'PROD_UNKNOWN') {
      return left(
        AppFailure(
          code: ProductErrorCodes.invalidProductType,
          context: {'message': 'Invalid product type for order $productionOrder'},
        ),
      );
    }

    return right(
      OrderDetailsResponse(
        productionOrder: productionOrder,
        productType: 'NA',
        worktop: 'Worktop1',
        salesId: 'SAL456',
      ),
    );
  }

  @override
  Future<Either<AppFailure, User>> getUserDetails() async {
    requestCount++;

    if (shouldFail) {
      return left(
        AppFailure(
          code: NetworkErrorCodes.connectionTimeout,
          context: {'message': 'API request failed'},
        ),
      );
    }

    return right(
      User(
        username: 'fake_user',
        sessionId: 'fake_session',
      ),
    );
  }

  @override
  Future<Either<AppFailure, void>> submitDiscardOrder(FormData formData, String productionOrder) async {
    requestCount++;

    if (shouldFail) {
      return left(
        AppFailure(
          code: NetworkErrorCodes.connectionTimeout,
          context: {'message': 'API request failed'},
        ),
      );
    }

    return right(null);
  }

  @override
  Future<void> dispose() async {}
}
