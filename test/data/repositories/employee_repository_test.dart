import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/data/repositories/employee_repository.dart';

import '../../../testing/fakes/services/api/fake_api_client.dart';

void main() {
  late FakeApiClient fakeApiClient;
  late EmployeeRepository employeeRepository;
  setUp(() {
    fakeApiClient = FakeApiClient();
    employeeRepository = EmployeeRepository(apiClient: fakeApiClient);
  });

  group('EmployeeRepository tests', () {
    test('Should get employee with the provided id', () async {
      // test body
      final result = await employeeRepository.fetchEmployeeDetails('emp123');
      expect(fakeApiClient.requestCount, equals(1));

      final employee = result.getRight().toNullable();
      expect(employee, isNotNull);
      expect(employee!.id, 'emp123');
      expect(employee.name, 'John Doe');
    });
  });
}
