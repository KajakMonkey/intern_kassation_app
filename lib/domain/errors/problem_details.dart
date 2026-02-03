import 'package:dart_mappable/dart_mappable.dart';

part 'problem_details.mapper.dart';

@MappableClass(hook: ProblemDetailsHook())
class ProblemDetails with ProblemDetailsMappable {
  final String? type;
  final String? title;
  final int? status;
  final String? instance;
  final String? detail;
  final Map<String, List<String>>? errors;
  final String? errorCode;

  const ProblemDetails({
    this.type,
    this.title,
    this.status,
    this.instance,
    this.detail,
    this.errors,
    this.errorCode,
  });

  static const fromMap = ProblemDetailsMapper.fromMap;
  static const fromJson = ProblemDetailsMapper.fromJson;
}

// Handles parsing for `errors` and `status`.
class ProblemDetailsHook extends MappingHook {
  const ProblemDetailsHook();

  @override
  Object? beforeDecode(Object? value) {
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final rawErrors = map['errors'];
      if (rawErrors is Map) {
        map['errors'] = rawErrors.map<String, List<String>>((key, val) {
          final list = (val is List) ? val.map((e) => e.toString()).toList() : <String>[];
          return MapEntry(key.toString(), list);
        });
      }
      final status = map['status'];
      if (status is! int && status != null) {
        map['status'] = int.tryParse(status.toString());
      }
      return map;
    }
    return value;
  }
}
