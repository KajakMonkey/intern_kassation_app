import 'dart:async';

import 'package:fpdart/src/either.dart';
import 'package:intern_kassation_app/data/repositories/auth_repository.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/auth_error_codes.dart';
import 'package:intern_kassation_app/domain/models/auth/auth_repo_response.dart';
import 'package:intern_kassation_app/domain/models/auth/token.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    Token? initialToken,
    AuthRepoResponse? initialResponse,
  }) : _token = initialToken {
    _currentResponse =
        initialResponse ??
        (initialToken == null
            ? const AuthRepoResponse(status: AuthResponseStatus.unauthenticated)
            : AuthRepoResponse(
                status: AuthResponseStatus.authenticated,
                hasRefreshToken: initialToken.hasValidRefreshToken,
              ));
  }

  final _controller = StreamController<AuthRepoResponse>.broadcast();
  Token? _token;
  AuthRepoResponse? _currentResponse;

  /// Set these in tests to force the next call to fail.
  AppFailure? nextLoginFailure;
  AppFailure? nextRefreshFailure;
  AppFailure? nextGetTokenFailure;

  /// Optional token to use on the next successful login.
  Token? nextLoginToken;

  @override
  AuthRepoResponse? get currentResponse => _currentResponse;

  late final Stream<AuthRepoResponse> _statusStream = (() async* {
    if (_currentResponse != null) {
      yield _currentResponse!;
    }
    yield* _controller.stream;
  })().asBroadcastStream();

  @override
  Stream<AuthRepoResponse> get stream => _statusStream;

  @override
  Future<Either<AppFailure, AuthRepoResponse>> login({
    required String username,
    required String password,
    bool refreshIfAvailable = false,
  }) async {
    final failure = nextLoginFailure;
    nextLoginFailure = null;
    if (failure != null) {
      final response = AuthRepoResponse(
        status: AuthResponseStatus.failure,
        failure: failure,
        hasRefreshToken: false,
      );
      _emit(response);
      return left(failure);
    }

    _token = nextLoginToken ?? _buildValidToken();
    nextLoginToken = null;

    final response = AuthRepoResponse(
      status: AuthResponseStatus.authenticated,
      hasRefreshToken: _token!.hasValidRefreshToken,
    );
    _emit(response);
    return right(response);
  }

  @override
  Future<Either<AppFailure, AuthRepoResponse>> refresh({bool forceRefresh = false}) async {
    final failure = nextRefreshFailure;
    nextRefreshFailure = null;
    if (failure != null) {
      final response = AuthRepoResponse(
        status: AuthResponseStatus.failure,
        failure: failure,
        hasRefreshToken: _token?.hasValidRefreshToken ?? false,
      );
      _emit(response);
      return left(failure);
    }

    if (_token == null || !_token!.hasValidRefreshToken) {
      final failure = AppFailure(
        code: AuthErrorCode.invalidRefreshToken,
        context: {'message': 'No valid refresh token available.'},
      );
      final response = AuthRepoResponse(
        status: AuthResponseStatus.failure,
        failure: failure,
        hasRefreshToken: false,
      );
      _emit(response);
      return left(failure);
    }

    _token = _buildValidToken(refreshToken: _token!.refreshToken);
    final response = AuthRepoResponse(
      status: AuthResponseStatus.authenticated,
      hasRefreshToken: _token!.hasValidRefreshToken,
    );
    _emit(response);
    return right(response);
  }

  @override
  Future<Either<AppFailure, Token>> getToken({bool refreshIfNeeded = true}) async {
    final failure = nextGetTokenFailure;
    nextGetTokenFailure = null;
    if (failure != null) {
      return left(failure);
    }

    if (_token == null) {
      return left(
        AppFailure(
          code: AuthErrorCode.tokenNotFound,
          context: {'message': 'No token available.'},
        ),
      );
    }

    if (_token!.hasValidAccessToken) {
      return right(_token!);
    }

    if (refreshIfNeeded && _token!.hasValidRefreshToken) {
      final refreshResult = await refresh();
      return refreshResult.fold(
        (failure) => left(failure),
        (_) => _token != null ? right(_token!) : left(AppFailure(code: AuthErrorCode.unknown)),
      );
    }

    return left(
      AppFailure(
        code: AuthErrorCode.invalidToken,
        context: {'message': 'Access token invalid and refresh not available.'},
      ),
    );
  }

  @override
  Future<void> logout() async {
    _token = null;
    _emit(const AuthRepoResponse(status: AuthResponseStatus.unauthenticated));
  }

  @override
  Future<Either<AppFailure, void>> saveToken(Token token) async {
    _token = token;
    return right(null);
  }

  Token _buildValidToken({String? refreshToken}) {
    final now = DateTime.now().toUtc();
    return Token(
      accessToken: 'fake_access_token',
      accessTokenExpiresUtc: now.add(const Duration(hours: 1)),
      refreshToken: refreshToken ?? 'fake_refresh_token',
      refreshTokenExpiresUtc: now.add(const Duration(days: 30)),
    );
  }

  void _emit(AuthRepoResponse response) {
    _currentResponse = response;
    _controller.add(response);
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}
