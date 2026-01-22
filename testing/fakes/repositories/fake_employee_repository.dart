import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/data/repositories/employee_repository.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/network_error_codes.dart';
import 'package:intern_kassation_app/domain/models/employee.dart';

import '../../models/fake_employee.dart';

class FakeEmployeeRepository implements EmployeeRepository {
  var shouldFail = false;
  @override
  Future<Either<AppFailure, Employee>> fetchEmployeeDetails(String employeeId) async {
    if (shouldFail) {
      return left(AppFailure(code: NetworkErrorCodes.connectionTimeout));
    }
    return right(kEmployee);
  }
}
