import 'package:dart_mappable/dart_mappable.dart';

part 'employee.mapper.dart';

@MappableClass()
class Employee with EmployeeMappable {
  @MappableField(key: 'employeeId')
  final String id;
  final String name;

  Employee({
    required this.id,
    required this.name,
  });

  static const fromMap = EmployeeMapper.fromMap;
  static const fromJson = EmployeeMapper.fromJson;
}
