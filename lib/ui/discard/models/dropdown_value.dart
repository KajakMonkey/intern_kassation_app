import 'package:freezed_annotation/freezed_annotation.dart';

part 'dropdown_value.freezed.dart';

@freezed
sealed class DropdownValue with _$DropdownValue {
  const factory DropdownValue({
    required String category,
    required String dropdownItem,
  }) = _DropdownValue;
}
