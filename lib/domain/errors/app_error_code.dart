import 'package:intern_kassation_app/domain/errors/error_codes/error_codes_index.dart';
import 'package:intern_kassation_app/l10n/app_localizations.dart';

abstract interface class AppErrorCode {
  String get code;
  String getMessage(AppLocalizations l10n);
}

/* class AppErrorCodeTranslator {
  static AppErrorCode toAppErrorCode(String code) {
    final authErrorCode = AuthErrorCode.fromString(code);
    if (authErrorCode != AuthErrorCode.unknown) {
      return authErrorCode;
    }
    final networkErrorCode = NetworkErrorCodes.fromString(code);
    if (networkErrorCode != NetworkErrorCodes.unknown) {
      return networkErrorCode;
    }
    final productErrorCode = ProductErrorCodes.fromString(code);
    if (productErrorCode != ProductErrorCodes.unknown) {
      return productErrorCode;
    }
    final stroageErrorCode = StorageErrorCodes.fromString(code);
    if (stroageErrorCode != StorageErrorCodes.unknown) {
      return stroageErrorCode;
    }
    final validationErrorCode = ValidationErrorCodes.fromString(code);
    if (validationErrorCode != ValidationErrorCodes.unknown) {
      return validationErrorCode;
    }
    final employeeErrorCode = EmployeeErrorCodes.fromString(code);
    if (employeeErrorCode != EmployeeErrorCodes.unknown) {
      return employeeErrorCode;
    }
    final orderErrorCode = OrderErrorCodes.fromString(code);
    if (orderErrorCode != OrderErrorCodes.unknown) {
      return orderErrorCode;
    }
    final storageErrorCode = StorageErrorCodes.fromString(code);
    if (storageErrorCode != StorageErrorCodes.unknown) {
      return storageErrorCode;
    }
    final valadationErrorCode = ValidationErrorCodes.fromString(code);
    if (valadationErrorCode != ValidationErrorCodes.unknown) {
      return valadationErrorCode;
    }

    return GeneralErrorCodes.fromString(code);
  }
} */

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
