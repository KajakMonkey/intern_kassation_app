import 'package:intern_kassation_app/domain/errors/app_error_code.dart';
import 'package:intern_kassation_app/l10n/app_localizations.dart';

enum GeneralErrorCodes implements AppErrorCode {
  unknown('GENERAL_UNKNOWN')
  ;

  const GeneralErrorCodes(this.code);

  @override
  final String code;

  static AppErrorCode fromString(String code) {
    try {
      return GeneralErrorCodes.values.firstWhere((e) => e.code == code);
    } catch (_) {
      return GeneralErrorCodes.unknown;
    }
  }

  @override
  String getMessage(AppLocalizations l10n) => switch (this) {
    GeneralErrorCodes.unknown => l10n.error_general_unknown,
  };
}
