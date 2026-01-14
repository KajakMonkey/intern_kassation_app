import 'package:dio/dio.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/network_error_codes.dart';

extension DioTypeExtensionX on DioExceptionType {
  AppFailure toAppFailure([Map<String, dynamic>? context]) {
    switch (this) {
      case DioExceptionType.connectionTimeout:
        return AppFailure(code: NetworkErrorCodes.connectionTimeout, context: context);
      case DioExceptionType.sendTimeout:
        return AppFailure(code: NetworkErrorCodes.sendTimeout, context: context);
      case DioExceptionType.receiveTimeout:
        return AppFailure(code: NetworkErrorCodes.receiveTimeout, context: context);
      case DioExceptionType.badResponse:
        return AppFailure(code: NetworkErrorCodes.badResponse, context: context);
      case DioExceptionType.cancel:
        return AppFailure(code: NetworkErrorCodes.requestCancelled, context: context);
      case DioExceptionType.connectionError:
        return AppFailure(code: NetworkErrorCodes.connectionError, context: context);
      case DioExceptionType.badCertificate:
        return AppFailure(code: NetworkErrorCodes.badCertificate, context: context);
      case DioExceptionType.unknown:
        return AppFailure(code: NetworkErrorCodes.unknown, context: context);
    }
  }
}
