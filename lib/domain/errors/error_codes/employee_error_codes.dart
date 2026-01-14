import 'package:intern_kassation_app/domain/errors/app_error_code.dart';
import 'package:intern_kassation_app/l10n/app_localizations.dart';

enum EmployeeErrorCodes implements AppErrorCode {
  unknown('EMPLOYEE_UNKNOWN'),
  // from the backend
  missingEmployeeId('EMPLOYEE_MISSING_ID'),
  employeeNotFound('EMPLOYEE_NOT_FOUND')
  ;

  const EmployeeErrorCodes(this.code);

  @override
  final String code;

  static AppErrorCode fromString(String code) {
    try {
      return EmployeeErrorCodes.values.firstWhere((e) => e.code == code);
    } catch (_) {
      return EmployeeErrorCodes.unknown;
    }
  }

  @override
  String getMessage(AppLocalizations l10n) => switch (this) {
    EmployeeErrorCodes.unknown => l10n.error_general_unknown,
    EmployeeErrorCodes.missingEmployeeId => l10n.error_employee_missing_id,
    EmployeeErrorCodes.employeeNotFound => l10n.error_employee_not_found,
  };
}
