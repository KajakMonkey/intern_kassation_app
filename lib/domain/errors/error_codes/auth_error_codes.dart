import 'package:intern_kassation_app/domain/errors/app_error_code.dart';
import 'package:intern_kassation_app/l10n/app_localizations.dart';

enum AuthErrorCode implements AppErrorCode {
  // from the backend
  userFetchFailedUnknown('AUTH_USER_FETCH_FAILED_UNKNOWN'),
  userNotFound('AUTH_USER_NOT_FOUND'),
  searchFailed('AUTH_SEARCH_FAILED'),
  serverUnavailable('AUTH_SERVER_UNAVAILABLE'),
  unauthorized('AUTH_UNAUTHORIZED'),
  invalidCredentials('AUTH_INVALID_CREDENTIALS'),
  disabled('AUTH_ACCOUNT_DISABLED'),
  refreshTokenExpired('AUTH_REFRESH_TOKEN_EXPIRED'),
  refreshTokenRevoked('AUTH_REFRESH_TOKEN_REVOKED'),
  refreshTokenMissing('AUTH_REFRESH_TOKEN_MISSING'),
  refreshTokenInvalid('AUTH_REFRESH_TOKEN_INVALID'),
  userIdNotFound('AUTH_USER_ID_NOT_FOUND'),
  invalidDueToPasswordChange('AUTH_INVALID_DUE_TO_PASSWORD_CHANGE'),
  invalidForDevice('AUTH_INVALID_FOR_DEVICE'),
  invalidFormat('AUTH_INVALID_FORMAT'),
  invalidAccessToken("AUTH_INVALID_ACCESS_TOKEN"),
  // frontend specific errors can be added here
  unknown('AUTH_UNKNOWN'),
  invalidToken('AUTH_INVALID_TOKEN'),
  invalidRefreshToken('AUTH_INVALID_REFRESH_TOKEN'),
  tokenNotFound('AUTH_TOKEN_NOT_FOUND')
  ;

  const AuthErrorCode(this.code);

  @override
  final String code;

  static AppErrorCode fromString(String code) {
    try {
      return AuthErrorCode.values.firstWhere((e) => e.code == code);
    } catch (_) {
      return AuthErrorCode.unknown;
    }
  }

  @override
  String getMessage(AppLocalizations l10n) => switch (this) {
    AuthErrorCode.userFetchFailedUnknown => l10n.error_failed_fetch_user_unknown,
    AuthErrorCode.userNotFound => l10n.error_auth_invalid_credentials,
    AuthErrorCode.searchFailed => l10n.error_auth_search_failed,
    AuthErrorCode.serverUnavailable => l10n.error_auth_server_unavailable,
    AuthErrorCode.unauthorized => l10n.error_auth_unauthorized,
    AuthErrorCode.invalidCredentials => l10n.error_auth_invalid_credentials,
    AuthErrorCode.disabled => l10n.error_auth_account_disabled,
    AuthErrorCode.refreshTokenExpired => l10n.error_auth_refresh_token_expired,
    AuthErrorCode.refreshTokenRevoked => l10n.error_auth_refresh_token_revoked,
    AuthErrorCode.refreshTokenMissing => l10n.error_auth_refresh_token_missing,
    AuthErrorCode.refreshTokenInvalid => l10n.error_auth_refresh_token_invalid,
    AuthErrorCode.userIdNotFound => l10n.error_auth_user_id_not_found,
    AuthErrorCode.invalidDueToPasswordChange => l10n.error_auth_invalid_due_to_password_change,
    AuthErrorCode.invalidForDevice => l10n.error_auth_invalid_for_device,
    AuthErrorCode.invalidFormat => l10n.error_auth_invalid_format,
    AuthErrorCode.invalidAccessToken => l10n.error_auth_invalid_access_token,
    // frontend specific errors can be added here
    AuthErrorCode.unknown => l10n.error_auth_unknown,
    AuthErrorCode.invalidToken => l10n.error_auth_invalid_token,
    AuthErrorCode.invalidRefreshToken => l10n.error_auth_invalid_refresh_token,
    AuthErrorCode.tokenNotFound => l10n.error_auth_token_not_found,
  };
}
