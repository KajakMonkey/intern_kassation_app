import 'package:intern_kassation_app/domain/errors/app_error_code.dart';
import 'package:intern_kassation_app/l10n/app_localizations.dart';

enum ValidationErrorCodes implements AppErrorCode {
  invalidJsonFormat('VALIDATION_INVALID_JSON_FORMAT'),
  parsingError('VALIDATION_PARSING_ERROR'),
  unknown('VALIDATION_UNKNOWN'),
  apiError('VALIDATION_API_ERROR'),
  missingDiscardReason('VALIDATION_MISSING_DISCARD_REASON')
  ;

  const ValidationErrorCodes(this.code);

  @override
  final String code;

  static AppErrorCode fromString(String code) {
    try {
      return ValidationErrorCodes.values.firstWhere((e) => e.code == code);
    } catch (_) {
      return ValidationErrorCodes.unknown;
    }
  }

  @override
  String getMessage(AppLocalizations l10n) => switch (this) {
    ValidationErrorCodes.unknown => l10n.error_validation_unknown,
    ValidationErrorCodes.invalidJsonFormat => l10n.error_validation_invalid_json_format,
    ValidationErrorCodes.parsingError => l10n.error_validation_parsing_error,
    ValidationErrorCodes.apiError => l10n.error_validation_api_error,
    ValidationErrorCodes.missingDiscardReason => l10n.error_validation_missing_discard_reason,
  };
}
