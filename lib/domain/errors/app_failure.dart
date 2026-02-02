import 'package:dart_mappable/dart_mappable.dart';
import 'package:intern_kassation_app/domain/errors/app_error.dart';
import 'package:intern_kassation_app/domain/errors/app_error_code.dart';
import 'package:intern_kassation_app/domain/errors/problem_details.dart';
import 'package:intern_kassation_app/l10n/app_localizations.dart';

part 'app_failure.mapper.dart';

@MappableClass()
final class AppFailure with AppFailureMappable implements AppError {
  AppFailure({
    required this.code,
    this.problemDetails,
    Map<String, dynamic>? context,
  }) : context = Map.unmodifiable(context ?? <String, dynamic>{});

  @override
  final AppErrorCode code;

  @override
  final ProblemDetails? problemDetails;

  /// Additional context for debugging (e.g., file path, field name)
  @override
  final Map<String, dynamic> context;

  @override
  String get developerMessage {
    final base = problemDetails?.detail ?? 'Error with code: $code';
    if (context.isNotEmpty) {
      return '$base | Context: $context';
    }
    return base;
  }

  @override
  String getMessage(AppLocalizations l10n) => code.getMessage(l10n);

  factory AppFailure.fromProblemDetails(ProblemDetails details) {
    return AppFailure(
      code: AppErrorCodeTranslator.toAppErrorCode(details.errorCode ?? 'UNKNOWN'),
      problemDetails: details,
    );
  }

  AppFailure withContext(Map<String, dynamic> extra) {
    return AppFailure(
      code: code,
      problemDetails: problemDetails,
      context: {
        ...context,
        ...extra,
      },
    );
  }

  @override
  String toString() {
    return 'AppFailure(code: $code, problemDetails: $problemDetails, context: $context)';
  }

  static const fromMap = AppFailureMapper.fromMap;
  static const fromJson = AppFailureMapper.fromJson;
}
