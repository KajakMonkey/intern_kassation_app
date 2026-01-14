import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:fpdart/fpdart.dart';
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
    String? host,
    Dio? client,
  }) : _host = host ?? EnvManager.apiUrl,
       _client = client ?? _defaultDioFactory(EnvManager.apiUrl);

  static Dio _defaultDioFactory(String host) {
    final dio = Dio(
      BaseOptions(
        baseUrl: host,
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
        requestBody: true,
        responseBody: true,
        request: true,
        logPrint: (obj) => _logger.fine(_redactAuth(obj)),
      ),
    );
    return dio;
  }

  static String _redactAuth(Object? obj) {
    final s = obj?.toString() ?? '';
    //replace password and refresh token in the log with [REDACTED]
    return s;
    // TODO: redact sensitive info when testing is complete
    /* return s
        .replaceAll(
          RegExp(r'("password"\s*:\s*")([^"]+)(")', caseSensitive: false),
          r'\1[REDACTED]\3',
        )
        .replaceAll(
          RegExp(r'("refreshToken"\s*:\s*")([^"]+)(")', caseSensitive: false),
          r'\1[REDACTED]\3',
        ); */
  }

  final String _host;
  final Dio _client;
  static final _logger = Logger('AuthApiClient');

  Future<Either<AppFailure, Token>> login(LoginRequest request) async {
    try {
      final response = await _client.post<String>(
        '$_host/auth/login',
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        final token = Token.fromJson(response.data!);
        return right(token);
      } else {
        try {
          final problem = ProblemDetails.fromJson(response.data!);
          return left(AppFailure.fromProblemDetails(problem));
        } catch (_) {
          _logger.warning('Failed to parse ProblemDetails from response: ${response.data}');
          return left(AppFailure(code: ValidationErrorCodes.parsingError, context: {'responseData': response.data}));
        }
      }
    } on DioException catch (e) {
      _logger.severe('DioException during login: ${e.message}', e);
      return left(e.type.toAppFailure());
    } catch (e) {
      _logger.severe('Unknown exception during login: ${e.toString()}', e);
      return left(AppFailure(code: AuthErrorCode.unknown, context: {'message': e.toString()}));
    }
  }

  Future<Either<AppFailure, Token>> refresh(RefreshRequest request) async {
    try {
      final response = await _client.post<String>(
        '$_host/auth/refresh',
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        final token = Token.fromJson(response.data!);
        return right(token);
      } else {
        try {
          final problem = ProblemDetails.fromJson(response.data!);
          return left(AppFailure.fromProblemDetails(problem));
        } catch (_) {
          _logger.warning('Failed to parse ProblemDetails from response: ${response.data}');
          return left(AppFailure(code: ValidationErrorCodes.parsingError, context: {'responseData': response.data}));
        }
      }
    } on DioException catch (e) {
      _logger.severe('DioException during refresh: ${e.message}', e);
      return left(e.type.toAppFailure());
    } catch (e) {
      _logger.severe('Unknown exception during refresh: ${e.toString()}', e);
      return left(AppFailure(code: AuthErrorCode.unknown, context: {'message': e.toString()}));
    }
  }

  Future<Either<AppFailure, void>> logout(LogoutRequest request) async {
    try {
      final response = await _client.post<String>(
        '$_host/auth/logout',
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        return right(null);
      } else {
        try {
          final problem = ProblemDetails.fromJson(response.data!);
          return left(AppFailure.fromProblemDetails(problem));
        } catch (_) {
          _logger.warning('Failed to parse ProblemDetails from response: ${response.data}');
          return left(AppFailure(code: ValidationErrorCodes.parsingError, context: {'responseData': response.data}));
        }
      }
    } on DioException catch (e) {
      _logger.severe('DioException during logout: ${e.message}', e);
      return left(e.type.toAppFailure());
    } catch (e) {
      _logger.severe('Unknown exception during logout: ${e.toString()}', e);
      return left(AppFailure(code: AuthErrorCode.unknown, context: {'message': e.toString()}));
    }
  }
}
