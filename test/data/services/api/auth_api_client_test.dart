import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/config/api_endpoints.dart';
import 'package:intern_kassation_app/data/services/api/auth_api_client.dart';
import 'package:intern_kassation_app/data/services/api/models/models_index.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/error_codes_index.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../testing/mocks.dart';
import '../../../../testing/models/fake_problem_details.dart';

void main() {
  late MockDio dio;
  late BaseOptions baseOptions;
  late AuthApiClient authApiClient;

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(RequestOptions(path: '/'));
  });

  setUp(() {
    dio = MockDio();
    baseOptions = BaseOptions();
    when(() => dio.options).thenReturn(baseOptions);

    authApiClient = AuthApiClient(client: dio);
  });

  tearDown(() async {
    await authApiClient.dispose();
  });

  Response<String> okResponse(String data, {int statusCode = 200}) => Response<String>(
    data: data,
    statusCode: statusCode,
    requestOptions: RequestOptions(path: '/'),
  );

  group('AuthApiClient', () {
    group('Login', () {
      test('Login with correct credentials should return a token', () async {
        when(() => dio.post<String>(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => okResponse(
            '{"accessToken":"access","refreshToken":"refresh","accessTokenExpiresUtc":"2026-12-31T23:59:59Z","refreshTokenExpiresUtc":"2026-12-31T23:59:59Z"}',
          ),
        );

        final request = LoginRequest(username: 'user', password: 'pass');

        final result = await authApiClient.login(request);

        result.match(
          (l) => fail('Expected right, got $l'),
          (r) {
            expect(r.accessToken, 'access');
            expect(r.refreshToken, 'refresh');
            expect(r.accessTokenExpiresUtc, DateTime.parse('2026-12-31T23:59:59Z'));
            expect(r.refreshTokenExpiresUtc, DateTime.parse('2026-12-31T23:59:59Z'));
          },
        );
      });

      test('Login with wrong credentials should return an error', () async {
        when(() => dio.post<String>(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => okResponse(
            getProblemDetailsJson(
              errorCode: AuthErrorCode.invalidCredentials.code,
              instance: ApiEndpoints.login,
              status: 401,
            ),
            statusCode: 401,
          ),
        );

        final request = LoginRequest(username: 'user', password: 'wrongpass');

        final result = await authApiClient.login(request);

        result.match(
          (failure) {
            expect(failure.code, AuthErrorCode.invalidCredentials);
            expect(failure.problemDetails, isNotNull);
            expect(failure.problemDetails?.status, 401);
            expect(failure.problemDetails?.instance, ApiEndpoints.login);
            expect(failure.problemDetails?.errorCode, AuthErrorCode.invalidCredentials.code);
          },
          (r) => fail('Expected left, got $r'),
        );
      });
    });

    group('Refresh', () {
      test('Refresh with correct token should return a new token', () async {
        when(() => dio.post<String>(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => okResponse(
            '{"accessToken":"newAccess","refreshToken":"newRefresh","accessTokenExpiresUtc":"2026-12-31T23:59:59Z","refreshTokenExpiresUtc":"2026-12-31T23:59:59Z"}',
          ),
        );

        final request = RefreshRequest(refreshToken: 'refresh');

        final result = await authApiClient.refresh(request);

        result.match(
          (l) => fail('Expected right, got $l'),
          (r) {
            expect(r.accessToken, 'newAccess');
            expect(r.refreshToken, 'newRefresh');
            expect(r.accessTokenExpiresUtc, DateTime.parse('2026-12-31T23:59:59Z'));
            expect(r.refreshTokenExpiresUtc, DateTime.parse('2026-12-31T23:59:59Z'));
          },
        );
      });

      test('Refresh with wrong token should return an error', () async {
        when(() => dio.post<String>(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => okResponse(
            getProblemDetailsJson(
              errorCode: AuthErrorCode.invalidRefreshToken.code,
              instance: ApiEndpoints.refresh,
              status: 401,
            ),
            statusCode: 401,
          ),
        );

        final request = RefreshRequest(refreshToken: 'wrongRefresh');

        final result = await authApiClient.refresh(request);

        result.match(
          (failure) {
            expect(failure.code, AuthErrorCode.invalidRefreshToken);
            expect(failure.problemDetails, isNotNull);
            expect(failure.problemDetails?.status, 401);
            expect(failure.problemDetails?.instance, ApiEndpoints.refresh);
            expect(failure.problemDetails?.errorCode, AuthErrorCode.invalidRefreshToken.code);
          },
          (r) => fail('Expected left, got $r'),
        );
      });
    });

    group('Logout', () {
      test('Logout with correct token should return void', () async {
        when(() => dio.post<String>(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => okResponse(''),
        );

        final request = LogoutRequest(refreshToken: 'refresh');

        final result = await authApiClient.logout(request);

        result.match((l) => fail('Expected right, got $l'), (_) {
          // Success, nothing to check;
        });
      });

      test('Logout with wrong token should return an error', () async {
        when(() => dio.post<String>(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => okResponse(
            getProblemDetailsJson(
              errorCode: AuthErrorCode.invalidRefreshToken.code,
              instance: ApiEndpoints.logout,
              status: 401,
            ),
            statusCode: 401,
          ),
        );

        final request = LogoutRequest(refreshToken: 'wrongRefresh');

        final result = await authApiClient.logout(request);

        result.match(
          (failure) {
            expect(failure.code, AuthErrorCode.invalidRefreshToken);
            expect(failure.problemDetails, isNotNull);
            expect(failure.problemDetails?.status, 401);
            expect(failure.problemDetails?.instance, ApiEndpoints.logout);
            expect(failure.problemDetails?.errorCode, AuthErrorCode.invalidRefreshToken.code);
          },
          (_) => fail('Expected left, got right'),
        );
      });
    });

    group('Dio Error', () {
      test('DioException during request should return appropriate AppFailure', () async {
        when(() => dio.post<String>(any(), data: any(named: 'data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timed out',
          ),
        );

        final request = LoginRequest(username: 'user', password: 'pass');

        final result = await authApiClient.login(request);

        result.match(
          (failure) {
            expect(failure.code, NetworkErrorCodes.connectionTimeout);
          },
          (r) => fail('Expected left, got $r'),
        );
      });
    });

    group('Parsing Error', () {
      test('Malformed JSON response should return parsing AppFailure', () async {
        when(() => dio.post<String>(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => okResponse('{"accessToken":"incomplete"'),
        );

        final request = LoginRequest(username: 'user', password: 'pass');

        final result = await authApiClient.login(request);

        result.match(
          (failure) {
            expect(failure.code, ValidationErrorCodes.parsingError);
          },
          (r) => fail('Expected left, got $r'),
        );
      });

      test('Malformed JSON problem details should return parsing AppFailure', () async {
        when(() => dio.post<String>(any(), data: any(named: 'data'))).thenAnswer(
          (_) async => okResponse(
            '{"errorCode":123,"instance":"/auth/login","status":"not_a_number"',
            statusCode: 401,
          ),
        );

        final request = LoginRequest(username: 'user', password: 'wrongpass');

        final result = await authApiClient.login(request);

        result.match(
          (failure) {
            expect(failure.code, ValidationErrorCodes.parsingError);
          },
          (r) => fail('Expected left, got $r'),
        );
      });
    });
  });
}
