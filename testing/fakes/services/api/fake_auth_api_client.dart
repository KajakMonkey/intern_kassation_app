import 'package:fpdart/src/either.dart';
import 'package:intern_kassation_app/data/services/api/auth_api_client.dart';
import 'package:intern_kassation_app/data/services/api/models/auth/login_request.dart';
import 'package:intern_kassation_app/data/services/api/models/auth/logout_request.dart';
import 'package:intern_kassation_app/data/services/api/models/auth/refresh_request.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/auth_error_codes.dart';
import 'package:intern_kassation_app/domain/models/auth/token.dart';

class FakeAuthApiClient implements AuthApiClient {
  @override
  Future<Either<AppFailure, Token>> login(LoginRequest request) async {
    if (request.username == 'testuser' && request.password == 'password123') {
      return right(
        Token(
          accessToken: 'fake_access_token',
          accessTokenExpiresUtc: DateTime.now().add(const Duration(hours: 1)),
          refreshToken: 'fake_refresh_token',
          refreshTokenExpiresUtc: DateTime.now().add(const Duration(days: 30)),
        ),
      );
    }

    return left(AppFailure(code: AuthErrorCode.invalidCredentials));
  }

  @override
  Future<Either<AppFailure, void>> logout(LogoutRequest request) async {
    if (request.refreshToken == 'fake_refresh_token') {
      return right(null);
    }

    return left(AppFailure(code: AuthErrorCode.invalidToken));
  }

  @override
  Future<Either<AppFailure, Token>> refresh(RefreshRequest request) async {
    if (request.refreshToken == 'fake_refresh_token') {
      return right(
        Token(
          accessToken: 'new_fake_access_token',
          accessTokenExpiresUtc: DateTime.now().add(const Duration(hours: 1)),
          refreshToken: 'new_fake_refresh_token',
          refreshTokenExpiresUtc: DateTime.now().add(const Duration(days: 30)),
        ),
      );
    }

    return left(AppFailure(code: AuthErrorCode.invalidRefreshToken));
  }
}
