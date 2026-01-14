import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/config/constants/secure_storage_keys.dart';
import 'package:intern_kassation_app/data/services/api/api_client.dart';
import 'package:intern_kassation_app/data/services/api/auth_api_client.dart';
import 'package:intern_kassation_app/data/services/api/models/auth/login_request.dart';
import 'package:intern_kassation_app/data/services/api/models/auth/logout_request.dart';
import 'package:intern_kassation_app/data/services/api/models/auth/refresh_request.dart';
import 'package:intern_kassation_app/data/services/secure_storage_service.dart';
import 'package:intern_kassation_app/data/services/uuid_service.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/auth_error_codes.dart';
import 'package:intern_kassation_app/domain/models/auth/auth_repo_response.dart';
import 'package:intern_kassation_app/domain/models/auth/token.dart';
import 'package:logging/logging.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required AuthApiClient authApiClient,
    required SecureStorageService secureStorageService,
    required UuidService uuidService,
  }) : _apiClient = apiClient,
       _authApiClient = authApiClient,
       _secureStorageService = secureStorageService,
       _uuidService = uuidService {
    _apiClient.authHeaderProvider = _authHeaderProvider;
  }

  final ApiClient _apiClient;
  final AuthApiClient _authApiClient;
  final SecureStorageService _secureStorageService;
  final UuidService _uuidService;

  final _controller = StreamController<AuthRepoResponse>.broadcast();
  Token? _cachedToken;
  AuthRepoResponse? _currentResponse = const AuthRepoResponse(status: AuthResponseStatus.initial);
  AuthRepoResponse? get currentResponse => _currentResponse;

  final _logger = Logger('AuthRepository');

  late final Stream<AuthRepoResponse> _statusStream = (() async* {
    _logger.info('Starting authentication status stream');
    const loading = AuthRepoResponse(status: AuthResponseStatus.loading);
    _currentResponse = loading;
    yield loading;

    final result = await _trySilentAuthentication();
    if (result != null) {
      _currentResponse = result;
      yield result;
    } else {
      const unauth = AuthRepoResponse(status: AuthResponseStatus.unauthenticated);
      _currentResponse = unauth;
      yield unauth;
    }

    yield* _controller.stream;
  })().asBroadcastStream();

  // Update getter
  Stream<AuthRepoResponse> get stream => _statusStream;

  /* Stream<AuthRepoResponse> get stream async* {
    _logger.info('Starting authentication status stream');
    const loading = AuthRepoResponse(status: AuthResponseStatus.loading);
    _currentResponse = loading;
    yield loading;

    final result = await _trySilentAuthentication();
    if (result != null) {
      _currentResponse = result;
      yield result;
    } else {
      const unauth = AuthRepoResponse(status: AuthResponseStatus.unauthenticated);
      _currentResponse = unauth;
      yield unauth;
    }
    yield* _controller.stream;
  } */

  Future<AuthRepoResponse?> _trySilentAuthentication() async {
    final token = await _loadToken();
    if (token == null) {
      return null;
    }

    if (token.hasValidAccessToken) {
      _cachedToken = token;
      return AuthRepoResponse(
        status: AuthResponseStatus.authenticated,
        hasRefreshToken: token.hasValidRefreshToken,
      );
    }

    if (token.hasValidRefreshToken) {
      final result = await refresh();
      return result.fold(
        (failure) => AuthRepoResponse(status: AuthResponseStatus.failure, failure: failure, hasRefreshToken: true),
        (entity) async {
          return entity;
        },
      );
    }

    return null;
  }

  Future<Either<AppFailure, AuthRepoResponse>> login({
    required String username,
    required String password,
    bool refreshIfAvailable = false,
  }) async {
    if (refreshIfAvailable) {
      final silentAuthResult = await _trySilentAuthentication();
      if (silentAuthResult != null) {
        _emit(silentAuthResult);
        return right(silentAuthResult);
      }
    }

    final deviceId = await _getDeviceId();

    final result = await _authApiClient.login(
      LoginRequest(
        username: username,
        password: password,
        deviceId: deviceId,
      ),
    );

    return await result.fold(
      (failure) {
        _emit(AuthRepoResponse(status: AuthResponseStatus.failure, failure: failure, hasRefreshToken: false));
        return left(failure);
      },
      (token) async {
        if (!token.hasValidAccessToken && !token.hasValidRefreshToken) {
          final failure = AppFailure(
            code: AuthErrorCode.invalidToken,
            context: {
              'message': 'Received invalid token from server.',
              'accessTokenExpiryUtc': token.accessTokenExpiresUtc,
              'refreshTokenExpiryUtc': token.refreshTokenExpiresUtc,
            },
          );
          _emit(
            AuthRepoResponse(status: AuthResponseStatus.failure, failure: failure, hasRefreshToken: false),
          );
          return left(failure);
        }

        _cachedToken = token;

        final saveResult = await saveToken(token);
        return saveResult.fold(
          (failure) {
            _emit(
              AuthRepoResponse(status: AuthResponseStatus.failure, failure: failure, hasRefreshToken: false),
            );
            return left(failure);
          },
          (_) {
            final repoResponse = AuthRepoResponse(
              status: AuthResponseStatus.authenticated,
              hasRefreshToken: token.hasValidRefreshToken,
            );
            _emit(repoResponse);
            return right(repoResponse);
          },
        );
      },
    );
  }

  Future<Either<AppFailure, AuthRepoResponse>> refresh({bool forceRefresh = false}) async {
    final currentToken = _cachedToken ?? await _loadToken();
    if (currentToken != null && currentToken.hasValidAccessToken && !forceRefresh) {
      final repoResponse = AuthRepoResponse(
        status: AuthResponseStatus.authenticated,
        hasRefreshToken: currentToken.hasValidRefreshToken,
      );
      _emit(repoResponse);
      return right(repoResponse);
    }

    if (currentToken == null || !currentToken.hasValidRefreshToken) {
      final failure = AppFailure(
        code: AuthErrorCode.invalidRefreshToken,
        context: {
          'message': 'No valid refresh token available for refreshing access token.',
          'refreshTokenExpiryUtc': currentToken?.refreshTokenExpiresUtc,
        },
      );
      _emit(AuthRepoResponse(status: AuthResponseStatus.failure, failure: failure, hasRefreshToken: false));
      return left(failure);
    }

    final deviceId = await _getDeviceId();
    final result = await _authApiClient.refresh(
      RefreshRequest(
        refreshToken: currentToken.refreshToken,
        deviceId: deviceId,
      ),
    );

    return await result.fold(
      (failure) {
        _emit(AuthRepoResponse(status: AuthResponseStatus.failure, failure: failure, hasRefreshToken: true));
        return left(failure);
      },
      (token) async {
        if (!token.hasValidAccessToken || !token.hasValidRefreshToken) {
          final failure = AppFailure(
            code: AuthErrorCode.invalidToken,
            context: {
              'message': 'Received invalid token from server during refresh.',
              'accessTokenExpiryUtc': token.accessTokenExpiresUtc,
              'refreshTokenExpiryUtc': token.refreshTokenExpiresUtc,
            },
          );
          _logger.severe('Received invalid token from server during refresh: $failure');
          _emit(
            AuthRepoResponse(status: AuthResponseStatus.failure, failure: failure, hasRefreshToken: true),
          );
          return left(failure);
        }
        _cachedToken = token;
        final saveResult = await saveToken(token);

        return saveResult.fold(
          (failure) {
            _emit(
              AuthRepoResponse(status: AuthResponseStatus.failure, failure: failure, hasRefreshToken: true),
            );
            return left(failure);
          },
          (_) {
            final repoResponse = AuthRepoResponse(
              status: AuthResponseStatus.authenticated,
              hasRefreshToken: token.hasValidRefreshToken,
            );
            _emit(repoResponse);
            return right(repoResponse);
          },
        );
      },
    );
  }

  Future<void> logout() async {
    final currentToken = _cachedToken ?? await _loadToken();
    if (currentToken == null) {
      return;
    }
    await _authApiClient.logout(LogoutRequest(refreshToken: currentToken.refreshToken));
    await _secureStorageService.delete(SecureStorageKeys.token.name);
    _cachedToken = null;
    _emit(const AuthRepoResponse(status: AuthResponseStatus.unauthenticated));
  }

  Future<Either<AppFailure, Token>> getToken({bool refreshIfNeeded = true}) async {
    final token = _cachedToken ?? await _loadToken();

    if (token == null) {
      final failure = AppFailure(
        code: AuthErrorCode.tokenNotFound,
        context: {'message': 'No token available.'},
      );
      return left(failure);
    }

    _logger.info(
      'getToken: Retrieved token with access token expiry: ${token.refreshToken}, refresh token expiry: ${token.refreshTokenExpiresUtc}',
    );

    if (token.hasValidAccessToken) {
      return right(token);
    }

    if (!refreshIfNeeded || !token.hasValidRefreshToken) {
      final failure = AppFailure(
        code: AuthErrorCode.invalidToken,
        context: {
          'message': 'No valid access token available and refresh not attempted or refresh token invalid.',
          'accessTokenExpiryUtc': token.accessTokenExpiresUtc,
          'refreshTokenExpiryUtc': token.refreshTokenExpiresUtc,
        },
      );
      return left(failure);
    }

    final refreshResult = await refresh();
    return await refreshResult.fold(
      (failure) => left(failure),
      (response) async {
        final newToken = _cachedToken ?? await _loadToken();
        if (newToken != null && newToken.hasValidAccessToken) {
          return right(newToken);
        } else {
          final failure = AppFailure(
            code: AuthErrorCode.invalidToken,
            context: {
              'message': 'Failed to load token after refresh.',
              'hasValidAccessToken': newToken?.hasValidAccessToken,
              'hasValidRefreshToken': newToken?.hasValidRefreshToken,
            },
          );
          return left(failure);
        }
      },
    );
  }

  Future<String?> _getDeviceId() async {
    final result = await _secureStorageService.read(SecureStorageKeys.deviceId.name);
    return await result.fold(
      (failure) => null,
      (id) async {
        if (id != null && id.isNotEmpty) {
          return id;
        }

        final newDeviceId = _uuidService.generateUuid();

        final saveResult = await _secureStorageService.write(
          SecureStorageKeys.deviceId.name,
          newDeviceId,
        );

        if (saveResult.isLeft()) {
          return null;
        }

        return newDeviceId;
      },
    );
  }

  Future<Either<AppFailure, void>> saveToken(Token token) async {
    final result = await _secureStorageService.write(
      SecureStorageKeys.token.name,
      token.toJson(),
    );
    return result;
  }

  Future<Token?> _loadToken() async {
    final result = await _secureStorageService.read(SecureStorageKeys.token.name);
    if (result.isLeft()) return null;

    final raw = result.getRight().toNullable();
    if (raw == null) return null;

    try {
      final token = Token.fromJson(raw);
      return token;
    } catch (e) {
      _secureStorageService.delete(SecureStorageKeys.token.name);
      return null;
    }
  }

  Future<String?> _authHeaderProvider() async {
    final token = await getToken();

    return token.isRight() ? 'Bearer ${token.getRight().toNullable()?.accessToken}' : null;
  }

  void _emit(AuthRepoResponse response) {
    _currentResponse = response;
    _controller.add(response);
  }
}
