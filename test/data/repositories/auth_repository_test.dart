import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/config/constants/secure_storage_keys.dart';
import 'package:intern_kassation_app/data/repositories/auth_repository.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/auth_error_codes.dart';
import 'package:intern_kassation_app/domain/models/auth/auth_repo_response.dart';
import 'package:intern_kassation_app/domain/models/auth/token.dart';

import '../../../testing/fakes/services/api/fake_api_client.dart';
import '../../../testing/fakes/services/api/fake_auth_api_client.dart';
import '../../../testing/fakes/services/fake_secure_storage_service.dart';
import '../../../testing/fakes/services/fake_uuid_service.dart';

void main() {
  late FakeApiClient fakeApiClient;
  late FakeAuthApiClient fakeAuthApiClient;
  late FakeSecureStorageService fakeSecureStorageService;
  late FakeUuidService fakeUuidService;
  late AuthRepository authRepository;

  setUp(() {
    fakeApiClient = FakeApiClient();
    fakeAuthApiClient = FakeAuthApiClient();
    fakeSecureStorageService = FakeSecureStorageService();
    fakeUuidService = FakeUuidService();

    authRepository = AuthRepository(
      apiClient: fakeApiClient,
      authApiClient: fakeAuthApiClient,
      secureStorageService: fakeSecureStorageService,
      uuidService: fakeUuidService,
    );
  });

  tearDown(() {
    fakeApiClient.dispose();
    fakeAuthApiClient.dispose();
    authRepository.dispose();
  });

  group('AuthRepository', () {
    test('stream emits loading then unauthenticated when no token exists', () async {
      final events = await authRepository.stream.take(2).toList();

      expect(events[0].status, AuthResponseStatus.loading);
      expect(events[1].status, AuthResponseStatus.unauthenticated);
      expect(authRepository.currentResponse?.status, AuthResponseStatus.unauthenticated);
    });

    test('login success saves token and emits authenticated', () async {
      final result = await authRepository.login(username: 'testuser', password: 'password123');

      expect(fakeAuthApiClient.requestCount, 1);
      expect(result.isRight(), isTrue);
      result.match(
        (failure) => fail('Expected right but got left: $failure'),
        (response) {
          expect(response.status, AuthResponseStatus.authenticated);
          expect(response.hasRefreshToken, isTrue);
        },
      );

      final storedTokenResult = await fakeSecureStorageService.read(SecureStorageKeys.token.name);
      expect(storedTokenResult.isRight(), isTrue);
      final storedTokenRaw = storedTokenResult.getRight().toNullable();
      expect(storedTokenRaw, isNotNull);
      final storedToken = Token.fromJson(storedTokenRaw!);
      expect(storedToken.accessToken, equals('fake_access_token'));
      expect(storedToken.refreshToken, equals('fake_refresh_token'));

      final storedDeviceIdResult = await fakeSecureStorageService.read(SecureStorageKeys.deviceId.name);
      expect(storedDeviceIdResult.isRight(), isTrue);
      expect(storedDeviceIdResult.getRight().toNullable(), equals('123e4567-e89b-12d3-a456-426614174000'));

      expect(authRepository.currentResponse?.status, AuthResponseStatus.authenticated);
    });

    test('login with invalid credentials returns failure and emits failure', () async {
      final result = await authRepository.login(
        username: 'wrong',
        password: 'credentials',
      );

      expect(fakeAuthApiClient.requestCount, 1);
      expect(result.isLeft(), isTrue);
      result.match(
        (failure) {
          expect(failure.code, AuthErrorCode.invalidCredentials);
        },
        (response) => fail('Expected left but got right: $response'),
      );

      expect(authRepository.currentResponse?.status, AuthResponseStatus.failure);
      expect(authRepository.currentResponse?.hasRefreshToken, isFalse);
    });

    test('refresh returns authenticated when access token is still valid', () async {
      final now = DateTime.now().toUtc();
      final token = Token(
        accessToken: 'cached_access_token',
        accessTokenExpiresUtc: now.add(const Duration(minutes: 15)),
        refreshToken: 'fake_refresh_token',
        refreshTokenExpiresUtc: now.add(const Duration(days: 30)),
      );
      await authRepository.saveToken(token);

      final result = await authRepository.refresh();

      expect(fakeAuthApiClient.requestCount, 0);
      expect(result.isRight(), isTrue);
      result.match(
        (failure) => fail('Expected right but got left: $failure'),
        (response) {
          expect(response.status, AuthResponseStatus.authenticated);
          expect(response.hasRefreshToken, isTrue);
        },
      );
      expect(authRepository.currentResponse?.status, AuthResponseStatus.authenticated);
    });

    test('refresh returns failure when no valid refresh token exists', () async {
      final now = DateTime.now().toUtc();
      final token = Token(
        accessToken: 'expired_access_token',
        accessTokenExpiresUtc: now.subtract(const Duration(minutes: 10)),
        refreshToken: 'expired_refresh_token',
        refreshTokenExpiresUtc: now.subtract(const Duration(minutes: 10)),
      );
      await authRepository.saveToken(token);

      final result = await authRepository.refresh();

      expect(fakeAuthApiClient.requestCount, 0);
      expect(result.isLeft(), isTrue);
      result.match(
        (failure) {
          expect(failure.code, AuthErrorCode.invalidRefreshToken);
        },
        (response) => fail('Expected left but got right: $response'),
      );
      expect(authRepository.currentResponse?.status, AuthResponseStatus.failure);
    });

    test('getToken refreshes when access token expired and refresh token valid', () async {
      final now = DateTime.now().toUtc();
      final token = Token(
        accessToken: 'expired_access_token',
        accessTokenExpiresUtc: now.subtract(const Duration(minutes: 10)),
        refreshToken: 'fake_refresh_token',
        refreshTokenExpiresUtc: now.add(const Duration(days: 30)),
      );
      await authRepository.saveToken(token);

      final result = await authRepository.getToken();

      expect(fakeAuthApiClient.requestCount, 1);
      expect(result.isRight(), isTrue);
      result.match(
        (failure) => fail('Expected right but got left: $failure'),
        (newToken) {
          expect(newToken.accessToken, equals('new_fake_access_token'));
          expect(newToken.refreshToken, equals('new_fake_refresh_token'));
        },
      );

      final storedTokenResult = await fakeSecureStorageService.read(SecureStorageKeys.token.name);
      expect(storedTokenResult.isRight(), isTrue);
      final storedTokenRaw = storedTokenResult.getRight().toNullable();
      final storedToken = Token.fromJson(storedTokenRaw!);
      expect(storedToken.accessToken, equals('new_fake_access_token'));
      expect(storedToken.refreshToken, equals('new_fake_refresh_token'));
    });

    test('logout clears token and emits unauthenticated', () async {
      final now = DateTime.now().toUtc();
      final token = Token(
        accessToken: 'cached_access_token',
        accessTokenExpiresUtc: now.add(const Duration(minutes: 10)),
        refreshToken: 'fake_refresh_token',
        refreshTokenExpiresUtc: now.add(const Duration(days: 30)),
      );
      await authRepository.saveToken(token);

      await authRepository.logout();

      final storedTokenResult = await fakeSecureStorageService.read(SecureStorageKeys.token.name);
      expect(storedTokenResult.isRight(), isTrue);
      expect(storedTokenResult.getRight().toNullable(), isNull);
      expect(authRepository.currentResponse?.status, AuthResponseStatus.unauthenticated);
      expect(fakeAuthApiClient.requestCount, 1);
    });
  });
}
