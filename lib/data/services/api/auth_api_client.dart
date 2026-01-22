import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/config/api_endpoints.dart';
import 'package:intern_kassation_app/config/app_config.dart';
import 'package:intern_kassation_app/config/env.dart';
import 'package:intern_kassation_app/data/services/api/models/auth/auth_index.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/error_codes_index.dart';
import 'package:intern_kassation_app/domain/errors/problem_details.dart';
import 'package:intern_kassation_app/domain/models/auth/token.dart';
import 'package:intern_kassation_app/utils/extensions/dio_type_extension.dart';
import 'package:logging/logging.dart';

class AuthApiClient {
  AuthApiClient({
    Dio? client,
  }) : _client = client ?? _defaultDioFactory();

  static Dio _defaultDioFactory() {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvManager.apiUrl,
        connectTimeout: AppConfig.httpTimeout,
        receiveTimeout: AppConfig.httpReceiveTimeout,
        sendTimeout: AppConfig.httpSendTimeout,
        validateStatus: (status) => true,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );

    dio.interceptors.add(RetryInterceptor(dio: dio, logPrint: _logger.info));
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: kDebugMode,
        responseBody: kDebugMode,
        request: true,
        logPrint: (obj) => _logger.fine(_redactAuth(obj)),
      ),
    );
    return dio;
  }

  static String _redactAuth(Object? obj) {
    final s = obj?.toString() ?? '';
    return s
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
  }

  final Dio _client;
  static final _logger = Logger('AuthApiClient');

  Future<Either<AppFailure, Token>> login(LoginRequest r) => _executeRequest<Token>(
    request: () => _client.post<String>(ApiEndpoints.login, data: r.toJson()),
    parseSuccess: (s) => Token.fromJson(s),
    action: 'login',
  );

  Future<Either<AppFailure, Token>> refresh(RefreshRequest r) => _executeRequest<Token>(
    request: () => _client.post<String>(ApiEndpoints.refresh, data: r.toJson()),
    parseSuccess: (s) => Token.fromJson(s),
    action: 'refresh',
  );

  Future<Either<AppFailure, void>> logout(LogoutRequest r) => _executeRequest<void>(
    request: () => _client.post<String>(ApiEndpoints.logout, data: r.toJson()),
    parseSuccess: (_) {},
    action: 'logout',
  );

  Future<Either<AppFailure, T>> _executeRequest<T>({
    required Future<Response<String>> Function() request,
    required T Function(String) parseSuccess,
    required String action,
  }) async {
    try {
      final response = await request();
      return _handleResponse<T>(response, parseSuccess, action);
    } on DioException catch (e) {
      _logger.severe('DioException during $action: ${e.message}', e);
      return left(e.type.toAppFailure());
    }
  }

  Either<AppFailure, T> _handleResponse<T>(
    Response<String> response,
    T Function(String) parseSuccess,
    String action,
  ) {
    if (response.statusCode == 200) {
      try {
        return right(parseSuccess(response.data!));
      } catch (_) {
        _logger.warning('Failed to parse success response for $action: ${response.data}');
        return left(AppFailure(code: ValidationErrorCodes.parsingError, context: {'responseData': response.data}));
      }
    } else {
      try {
        final problem = ProblemDetails.fromJson(response.data!);
        return left(AppFailure.fromProblemDetails(problem));
      } catch (_) {
        _logger.warning('Failed to parse ProblemDetails from response: ${response.data}');
        return left(AppFailure(code: ValidationErrorCodes.parsingError, context: {'responseData': response.data}));
      }
    }
  }

  Future<void> dispose() async {
    _client.close();
  }
}
