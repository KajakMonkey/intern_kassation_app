// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ProblemDetails {
  final String? type;
  final String? title;
  final int? status;
  final String? instance;
  final String? detail;
  final Map<String, List<String>>? errors;
  final String? errorCode;

  ProblemDetails({
    this.type,
    this.title,
    this.status,
    this.instance,
    this.detail,
    this.errors,
    this.errorCode,
  });

  factory ProblemDetails.fromMap(Map<String, dynamic> map) {
    Map<String, List<String>>? parsedErrors;

    final rawErrors = map['errors'];
    if (rawErrors is Map) {
      parsedErrors = rawErrors.map<String, List<String>>((key, value) {
        final list = (value is List) ? value.map((e) => e.toString()).toList() : <String>[];
        return MapEntry(key.toString(), list);
      });
    }

    return ProblemDetails(
      type: map['type']?.toString(),
      title: map['title']?.toString(),
      status: map['status'] is int ? map['status'] as int : int.tryParse(map['status']?.toString() ?? ''),
      instance: map['instance']?.toString(),
      detail: map['detail']?.toString(),
      errors: parsedErrors,
      errorCode: map['errorCode']?.toString(),
    );
  }

  factory ProblemDetails.fromJson(String source) => ProblemDetails.fromMap(json.decode(source) as Map<String, dynamic>);

  //to map
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'status': status,
      'instance': instance,
      'detail': detail,
      'errors': errors,
      'errorCode': errorCode,
    };
  }

  @override
  String toString() {
    return 'ProblemDetails(type: $type, title: $title, status: $status, instance: $instance, detail: $detail, errors: $errors, errorCode: $errorCode)';
  }
}
