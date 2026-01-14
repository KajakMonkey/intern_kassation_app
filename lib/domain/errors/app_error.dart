import 'package:intern_kassation_app/domain/errors/app_error_code.dart';
import 'package:intern_kassation_app/domain/errors/problem_details.dart';
import 'package:intern_kassation_app/l10n/app_localizations.dart';

abstract interface class AppError {
  AppErrorCode get code;
  String get developerMessage;
  ProblemDetails? get problemDetails;
  Map<String, dynamic>? get context;

  String getMessage(AppLocalizations l10n);
}
