import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/config/api_endpoints.dart';
import 'package:intern_kassation_app/config/app_config.dart';
import 'package:intern_kassation_app/config/env.dart';
import 'package:intern_kassation_app/data/services/api/models/orders/discarded_order_query_request.dart';
import 'package:intern_kassation_app/data/services/api/models/orders/order_details_response.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/error_codes_index.dart';
import 'package:intern_kassation_app/domain/errors/problem_details.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_reason.dart';
import 'package:intern_kassation_app/domain/models/employee.dart';
import 'package:intern_kassation_app/domain/models/order/discarded_order_details.dart';
import 'package:intern_kassation_app/domain/models/order/discarded_orders_data.dart';
import 'package:intern_kassation_app/domain/models/user.dart';
import 'package:intern_kassation_app/utils/extensions/dio_type_extension.dart';
import 'package:intern_kassation_app/utils/extensions/int_extension.dart';
import 'package:logging/logging.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

typedef AuthHeaderProvider = Future<String?> Function();

class ApiClient {
  ApiClient({
    Dio? client,
    AuthHeaderProvider? authHeaderProvider,
  }) : _client = client ?? _createDefaultClient(),
       _authHeaderProvider = authHeaderProvider;

  static Dio _createDefaultClient() {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvManager.apiUrl,
        connectTimeout: AppConfig.httpTimeout,
        receiveTimeout: AppConfig.httpReceiveTimeout,
        sendTimeout: AppConfig.httpSendTimeout,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ),
    );

    dio.interceptors.add(RetryInterceptor(dio: dio, logPrint: _logger.info));
    /* dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: kDebugMode,
        responseBody: kDebugMode,
        request: true,
        logPrint: (obj) => _logger.fine(_redactAuth(obj)),
      ),
    ); */

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
        logPrint: (obj) => _logger.fine(obj),
      ),
    );

    return dio;
  }

  /* static String _redactAuth(Object? obj) {
    final s = obj?.toString() ?? '';
    return s
        .replaceAll(
          RegExp(r'(Bearer)\s+[A-Za-z0-9\-\._=]+', caseSensitive: false),
          r'\1 [REDACTED]',
        )
        .replaceAll(
          RegExp(r'("password"\s*:\s*")([^"]+)(")', caseSensitive: false),
          r'\1[REDACTED]\3',
        )
        .replaceAll(
          RegExp(r'("accessToken"\s*:\s*")([^"]+)(")', caseSensitive: false),
          r'\1[REDACTED]\3',
        )
        .replaceAll(
          RegExp(r'("refreshToken"\s*:\s*")([^"]+)(")', caseSensitive: false),
          r'\1[REDACTED]\3',
        );
  } */

  /*
  .replaceAll(
          RegExp(r'^\s*(authorization:\s*)Bearer\s+\S+', caseSensitive: false, multiLine: true),
          r' authorization: Bearer [REDACTED]',
        )
  */

  final Dio _client;

  static final _logger = Logger('ApiClient');

  AuthHeaderProvider? _authHeaderProvider;

  set authHeaderProvider(AuthHeaderProvider provider) => _authHeaderProvider = provider;

  // * Employee requests ---------------------------------------------

  Future<Either<AppFailure, Employee>> getEmployeeDetails(String employeeId) => _request(
    'getEmployeeDetails',
    () => _client.get<String>(ApiEndpoints.getEmployeeDetails(employeeId)),
    (data) => Employee.fromJson(data),
  );

  // * Account requests ----------------------------------------------

  Future<Either<AppFailure, User>> getUserDetails() => _request<User>(
    'getUserDetails',
    () => _client.get<String>(ApiEndpoints.getUserDetails),
    (data) => User.fromJson(data),
  );

  // * Order requests -----------------------------------------------

  Future<Either<AppFailure, OrderDetailsResponse>> getOrderDetails(String productionOrder) =>
      _request<OrderDetailsResponse>(
        'getOrderDetails',
        () => _client.get<String>(ApiEndpoints.getOrderDetails(productionOrder)),
        (data) => OrderDetailsResponse.fromJson(data),
      );

  Future<Either<AppFailure, void>> submitDiscardOrder(FormData formData, String productionOrder) => _request(
    'submitDiscardOrder',
    () => _client.post<String>(
      ApiEndpoints.discardOrder(productionOrder),
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        sendTimeout: AppConfig.imageUploadTimeout,
        receiveTimeout: AppConfig.imageUploadTimeout,
      ),
    ),
    (_) {},
  );

  Future<Either<AppFailure, DiscardedOrdersData>> getDiscardedOrders(DiscardedOrderQueryRequest request) => _request(
    'getDiscardedOrders',
    () => _client.post<String>(
      ApiEndpoints.getDiscardedOrders,
      data: request.toJson(),
    ),
    (data) => DiscardedOrdersData.fromJson(data),
  );

  Future<Either<AppFailure, DiscardedOrderDetails>> getDiscardedOrderDetails(int id) => _request(
    'getDiscardedOrderDetails',
    () => _client.get<String>(ApiEndpoints.getDiscardedOrderDetails(id)),
    (data) => DiscardedOrderDetails.fromJson(data),
  );

  // * Product requests ---------------------------------------------

  Future<Either<AppFailure, List<String>>> getDropdownValues(String category) => _request(
    'getDropdownValues',
    () => _client.get<String>(ApiEndpoints.getDropdown(category)),
    (data) {
      final items = (jsonDecode(data) as List<dynamic>).map((e) => e as String).toList();
      return items;
    },
  );

  Future<Either<AppFailure, List<DiscardReason>>> getDiscardReasons(String productType) => _request(
    'getDiscardReasons',
    () => _client.get<String>(ApiEndpoints.getDiscardReasons(productType)),
    (data) {
      final reasons = DiscardReasonExtension.fromJsonList(data);
      return reasons;
    },
  );

  Future<Either<AppFailure, T>> _request<T>(
    String name,
    Future<Response<String>> Function() request,
    T Function(String) parser,
  ) async {
    try {
      await _applyAuthHeader();
      final response = await request();
      return _handleResponse(response, parser);
    } on DioException catch (e, st) {
      return _handleDioError(e, name, stackTrace: st);
    } catch (e, st) {
      return _handleError(e, name, stackTrace: st);
    }
  }

  Future<void> _applyAuthHeader() async {
    if (_authHeaderProvider != null) {
      final header = await _authHeaderProvider!();
      if (header != null) {
        _client.options.headers[HttpHeaders.authorizationHeader] = header;
      }
    }
  }

  Future<Either<AppFailure, T>> _handleDioError<T>(DioException error, String name, {StackTrace? stackTrace}) async {
    if (error.response != null) {
      final responseData = error.response?.data;
      if (responseData != null) {
        try {
          final dataString = responseData is String ? responseData : json.encode(responseData);
          if (dataString.isNotEmpty) {
            final problem = ProblemDetails.fromJson(dataString);
            return left(AppFailure.fromProblemDetails(problem));
          }
        } catch (_) {
          // Failed to parse as ProblemDetails, fall through to default handling
        }
      }
    }

    _logger.warning('DioException in $name: ${error.type}', error, stackTrace);
    return left(
      error.type.toAppFailure({
        'error': error.message,
        if (error.response?.statusCode != null) 'statusCode': error.response!.statusCode.toString(),
        if (error.response?.data != null) 'responseData': error.response!.data,
      }),
    );
  }

  Future<Either<AppFailure, T>> _handleResponse<T>(
    Response<String> response,
    T Function(String) parser,
  ) async {
    final statusCode = response.statusCode;
    final responseData = response.data is String ? response.data : json.encode(response.data);

    if (statusCode != null && statusCode.isSuccessful && responseData != null) {
      try {
        final parsedData = parser(responseData);
        return right(parsedData);
      } catch (e) {
        //log('Error parsing response', error: e);
        _logger.warning('Error parsing response', e);
        return left(AppFailure(code: ValidationErrorCodes.parsingError, context: {'responseData': responseData}));
      }
    }

    if (statusCode != null && statusCode.isSuccessful) {
      return right(parser(''));
    }

    if (responseData != null && responseData.isNotEmpty) {
      try {
        final problem = ProblemDetails.fromJson(responseData);
        return left(AppFailure.fromProblemDetails(problem));
      } catch (e) {
        _logger.warning('Error parsing ProblemDetails', e);
        return left(AppFailure(code: ValidationErrorCodes.parsingError, context: {'responseData': responseData}));
      }
    }

    return left(AppFailure(code: NetworkErrorCodes.unknown, context: {'statusCode': statusCode.toString()}));
  }

  Future<Either<AppFailure, T>> _handleError<T>(Object error, String name, {StackTrace? stackTrace}) async {
    if (error is AppFailure) {
      return left(error);
    }

    _logger.severe('Unexpected error in $name', error, stackTrace);
    return left(AppFailure(code: NetworkErrorCodes.unknown, context: {'error': error.toString()}));
  }

  Future<void> dispose() async {
    _client.close();
  }
}
