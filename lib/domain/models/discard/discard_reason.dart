// ignore_for_file: invalid_annotation_target

import 'dart:convert';

import 'package:dart_mappable/dart_mappable.dart';

part 'discard_reason.mapper.dart';

@MappableClass()
class DiscardReason with DiscardReasonMappable {
  final String errorCode;
  final String description;
  final String? displayCategory;
  @MappableField(key: 'dropdown')
  final String? shownDropdownCategory;

  DiscardReason({
    required this.errorCode,
    required this.description,
    this.displayCategory,
    this.shownDropdownCategory,
  });

  static const fromMap = DiscardReasonMapper.fromMap;
  static const fromJson = DiscardReasonMapper.fromJson;
}

extension DiscardReasonExtension on DiscardReason {
  static List<DiscardReason> fromJsonList(String jsonList) {
    if (jsonList.isEmpty) return [];
    final decoded = jsonDecode(jsonList) as List<dynamic>;
    return decoded.map((e) => DiscardReason.fromMap(e as Map<String, dynamic>)).toList();
  }

  static String toJsonList(List<DiscardReason> reasons) {
    final jsonList = reasons.map((e) => e.toMap()).toList();
    return jsonEncode(jsonList);
  }
}
