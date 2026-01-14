part of 'discard_cubit.dart';

@freezed
sealed class DiscardState with _$DiscardState {
  const factory DiscardState({
    required DiscardFormData formData,
    required EmployeeState employeeState,
    required ImageState imageState,
    required DiscardReasonState discardReasonState,
    required DropdownValuesState dropdownValuesState,
    required SubmitState submitState,
  }) = _DiscardState;

  factory DiscardState.initial() => const DiscardState(
    formData: DiscardFormData(),
    employeeState: EmployeeState.initial(),
    imageState: ImageState(),
    discardReasonState: DiscardReasonState(),
    dropdownValuesState: DropdownValuesState(),
    submitState: SubmitState.initial(),
  );
}

@freezed
sealed class DiscardFormData with _$DiscardFormData {
  const factory DiscardFormData({
    @Default('') String salesId,
    @Default('') String worktop,
    @Default(ProductType.unknown) ProductType productType,
    @Default('') String productionOrder,
    DateTime? dateTime,
    @Default('') String date,
    @Default('') String note,
  }) = _DiscardFormData;
}

@freezed
class EmployeeState with _$EmployeeState {
  const factory EmployeeState.initial() = _EmployeeInitial;
  const factory EmployeeState.loading() = _EmployeeLoading;
  const factory EmployeeState.loaded({
    required String employeeName,
    required String employeeId,
  }) = _EmployeeLoaded;
  const factory EmployeeState.failure({
    required AppFailure failure,
  }) = _EmployeeFailure;
}

enum ImageStatus {
  initial,
  loading,
  loaded,
  failure,
}

@freezed
sealed class ImageState with _$ImageState {
  const factory ImageState({
    @Default(ImageStatus.initial) ImageStatus status,
    @Default(<String>[]) List<String> imagePaths,
    AppFailure? failure,
  }) = _ImageState;
}

enum DiscardReasonStatus {
  initial,
  loading,
  loaded,
  failure,
}

@freezed
sealed class DiscardReasonState with _$DiscardReasonState {
  const factory DiscardReasonState({
    @Default(DiscardReasonStatus.initial) DiscardReasonStatus status,
    @Default(<DiscardReason>[]) List<DiscardReason> reasons,
    DiscardReason? selectedReason,
    AppFailure? failure,
  }) = _DiscardReasonState;
}

enum DropdownValuesStatus {
  initial,
  loading,
  loaded,
  failure,
}

@freezed
sealed class DropdownValuesState with _$DropdownValuesState {
  const factory DropdownValuesState({
    @Default(DropdownValuesStatus.initial) DropdownValuesStatus status,
    @Default(<String>[]) List<String> items,
    @Default('') String dropdownName,
    DropdownValue? selectedDropdownValue,
    AppFailure? failure,
  }) = _DropdownValuesState;
}

@freezed
class SubmitState with _$SubmitState {
  const factory SubmitState.initial() = _SubmitInitial;
  const factory SubmitState.submitting() = _SubmitSubmitting;
  const factory SubmitState.success() = _SubmitSuccess;
  const factory SubmitState.failure({
    required AppFailure failure,
  }) = _SubmitFailure;
}
