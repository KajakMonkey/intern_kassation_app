import 'package:intern_kassation_app/domain/errors/app_error_code.dart';
import 'package:intern_kassation_app/l10n/app_localizations.dart';

enum NetworkErrorCodes implements AppErrorCode {
  unknown('NETWORK_UNKNOWN'),
  connectionTimeout('NETWORK_CONNECTION_TIMEOUT'),
  sendTimeout('NETWORK_SEND_TIMEOUT'),
  receiveTimeout('NETWORK_RECEIVE_TIMEOUT'),
  badResponse('NETWORK_BAD_RESPONSE'),
  requestCancelled('NETWORK_REQUEST_CANCELLED'),
  connectionError('NETWORK_CONNECTION_ERROR'),
  badCertificate('NETWORK_BAD_CERTIFICATE')
  ;

  const NetworkErrorCodes(this.code);

  @override
  final String code;

  static AppErrorCode fromString(String code) {
    try {
      return NetworkErrorCodes.values.firstWhere((e) => e.code == code);
    } catch (_) {
      return NetworkErrorCodes.unknown;
    }
  }

  @override
  String getMessage(AppLocalizations l10n) => switch (this) {
    NetworkErrorCodes.unknown => l10n.error_network_unknown,
    NetworkErrorCodes.connectionTimeout => l10n.error_network_connection_timeout,
    NetworkErrorCodes.sendTimeout => l10n.error_network_send_timeout,
    NetworkErrorCodes.receiveTimeout => l10n.error_network_receive_timeout,
    NetworkErrorCodes.badResponse => l10n.error_network_bad_response,
    NetworkErrorCodes.requestCancelled => l10n.error_network_request_cancelled,
    NetworkErrorCodes.connectionError => l10n.error_network_connection_error,
    NetworkErrorCodes.badCertificate => l10n.error_network_bad_certificate,
  };
}
