import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/data/services/api/api_client.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/models/employee.dart';

class EmployeeRepository {
  EmployeeRepository({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<Either<AppFailure, Employee>> fetchEmployeeDetails(String employeeId) async {
    final trimmedId = employeeId.trim();
    final result = await _apiClient.getEmployeeDetails(trimmedId);
    return result;
  }
}
