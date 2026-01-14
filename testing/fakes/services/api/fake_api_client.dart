import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/data/services/api/api_client.dart';
import 'package:intern_kassation_app/data/services/api/models/models_index.dart';
import 'package:intern_kassation_app/data/services/api/models/orders/discarded_order_query_request.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/network_error_codes.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/product_error_codes.dart';
import 'package:intern_kassation_app/domain/models/models_index.dart';

class FakeApiClient implements ApiClient {
  var requestCount = 0;
  var shouldFail = false;

  @override
  AuthHeaderProvider? authHeaderProvider;

  @override
  Future<Either<AppFailure, List<DiscardReason>>> getDiscardReasons(String productType) async {
    requestCount++;
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
    return right(
      DiscardedOrderDetails(
        id: id,
        prodId: 'PROD123',
        salesId: 'SAL456',
        discardedAtUtc: DateTime.now(),
        employeeId: 'EMP789',
        errorCode: 'E001',
        note: 'Sample discarded order',
        productType: 'TypeA',
        worktop: 'Worktop1',
        errorDescription: 'Defective item',
        machineName: 'MachineX',
      ),
    );
  }

  @override
  Future<Either<AppFailure, DiscardedOrdersData>> getDiscardedOrders(DiscardedOrderQueryRequest request) async {
    requestCount++;
    return right(
      DiscardedOrdersData(
        pageSize: 25,
        items: [
          DiscardedOrderPreview(
            id: 1,
            prodId: 'PROD123',
            salesId: 'SAL456',
            discardedAtUtc: DateTime.now(),
            errorCode: 'E001',
            productType: 'TypeA',
          ),
        ],
      ),
    );
  }

  @override
  Future<Either<AppFailure, List<String>>> getDropdownValues(String category) async {
    requestCount++;
    return right(
      ['CNC', 'Assembly', 'Packaging'],
    );
  }

  @override
  Future<Either<AppFailure, Employee>> getEmployeeDetails(String employeeId) async {
    requestCount++;
    return right(
      Employee(id: employeeId, name: 'John Doe'),
    );
  }

  @override
  Future<Either<AppFailure, OrderDetailsResponse>> getOrderDetails(String productionOrder) async {
    requestCount++;

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
    return right(null);
  }
}
