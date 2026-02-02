import 'package:intern_kassation_app/domain/errors/error_codes/error_codes_index.dart';
import 'package:intern_kassation_app/l10n/app_localizations.dart';

abstract interface class AppErrorCode {
  String get code;
  String getMessage(AppLocalizations l10n);
}

typedef Parser = AppErrorCode Function(String code);

class AppErrorCodeTranslator {
  static final Map<Pattern, Parser> _routes = {
    RegExp(r'^(AUTH|AUTHENTICATION)_'): (c) => AuthErrorCode.fromString(c),
    RegExp(r'^(NET|NETWORK)_'): (c) => NetworkErrorCodes.fromString(c),
    RegExp(r'^(PROD|PRODUCT)_'): (c) => ProductErrorCodes.fromString(c),
    RegExp(r'^(STOR|STORAGE)_'): (c) => StorageErrorCodes.fromString(c),
    RegExp(r'^(VAL|VALIDATION)_'): (c) => ValidationErrorCodes.fromString(c),
    RegExp(r'^(EMP|EMPLOYEE)_'): (c) => EmployeeErrorCodes.fromString(c),
    RegExp(r'^(ORD|ORDER)_'): (c) => OrderErrorCodes.fromString(c),
    RegExp(r'^(IMA|IMAGE)_'): (c) => ImageErrorCodes.fromString(c),
  };

  static AppErrorCode toAppErrorCode(String code) {
    final normalized = code.trim().toUpperCase().replaceAll('-', '_');
    for (final entry in _routes.entries) {
      if (entry.key.allMatches(normalized).isNotEmpty) {
        final parsed = entry.value(normalized);
        if (parsed != GeneralErrorCodes.unknown) return parsed;
      }
    }
    return GeneralErrorCodes.fromString(normalized);
  }
}
