import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intern_kassation_app/config/constants/product_type.dart';
import 'package:intern_kassation_app/data/repositories/discard_reasons_repository.dart';
import 'package:intern_kassation_app/data/repositories/employee_repository.dart';
import 'package:intern_kassation_app/data/repositories/image_repository.dart';
import 'package:intern_kassation_app/data/repositories/order_repository.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/image_error_codes.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/validation_error_codes.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_order.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_reason.dart';
import 'package:intern_kassation_app/ui/discard/models/dropdown_value.dart';
import 'package:intern_kassation_app/utils/extensions/bloc_extension.dart';

part 'discard_state.dart';
part 'discard_cubit.freezed.dart';

class DiscardCubit extends Cubit<DiscardState> {
  DiscardCubit({
    required EmployeeRepository employeeRepository,
    required DiscardReasonsRepository discardReasonsRepository,
    required ImageRepository imageRepository,
    required OrderRepository orderRepository,
  }) : _employeeRepository = employeeRepository,
       _discardReasonsRepository = discardReasonsRepository,
       _imageRepository = imageRepository,
       _orderRepository = orderRepository,
       super(DiscardState.initial());

  final EmployeeRepository _employeeRepository;
  final DiscardReasonsRepository _discardReasonsRepository;
  final ImageRepository _imageRepository;
  final OrderRepository _orderRepository;

  // * Form data methods

  void onInitinalData({
    required String salesId,
    required String productionOrder,
    required String worktop,
    required ProductType productType,
    required DateTime dateTime,
    required String date,
  }) {
    emit(
      state.copyWith(
        formData: DiscardFormData(
          salesId: salesId,
          productionOrder: productionOrder,
          worktop: worktop,
          productType: productType,
          dateTime: dateTime,
          date: date,
        ),
      ),
    );
  }

  void onNoteChanged(String note) => emit(state.copyWith(formData: state.formData.copyWith(note: note)));

  void onDateChanged(DateTime dateTime, String date) {
    emit(
      state.copyWith(
        formData: state.formData.copyWith(dateTime: dateTime, date: date),
      ),
    );
  }

  // * Employee methods

  Future<void> validateEmployeeId(String employeeId) async {
    emit(state.copyWith(employeeState: const EmployeeState.loading()));

    final result = await _employeeRepository.fetchEmployeeDetails(employeeId);

    result.fold(
      (failure) {
        safeEmit(state.copyWith(employeeState: EmployeeState.failure(failure: failure)));
      },
      (employee) {
        safeEmit(
          state.copyWith(
            employeeState: EmployeeState.loaded(
              employeeName: employee.name,
              employeeId: employee.id,
            ),
          ),
        );
      },
    );
  }

  Future<void> loadDiscardReasons(ProductType productType, {bool forceRefresh = false}) async {
    emit(
      state.copyWith(
        discardReasonState: state.discardReasonState.copyWith(status: DiscardReasonStatus.loading, failure: null),
      ),
    );

    final result = await _discardReasonsRepository.fetchDiscardReasons(productType, forceRefresh: forceRefresh);

    result.fold(
      (failure) {
        safeEmit(
          state.copyWith(
            discardReasonState: state.discardReasonState.copyWith(
              status: DiscardReasonStatus.failure,
              failure: failure,
            ),
          ),
        );
      },
      (response) {
        safeEmit(
          state.copyWith(
            discardReasonState: state.discardReasonState.copyWith(
              status: DiscardReasonStatus.loaded,
              reasons: response.reasons,
              failure: response.failure,
            ),
          ),
        );
      },
    );
  }

  void onDiscardReasonSelected(DiscardReason? reason) {
    emit(
      state.copyWith(
        discardReasonState: state.discardReasonState.copyWith(selectedReason: reason),
        dropdownValuesState: state.dropdownValuesState.copyWith(selectedDropdownValue: null),
      ),
    );
  }

  void onDropdownValueSelected(DropdownValue? dropdownValue) {
    emit(
      state.copyWith(
        dropdownValuesState: state.dropdownValuesState.copyWith(selectedDropdownValue: dropdownValue),
      ),
    );
  }

  Future<void> loadDropdownItems(String category, {bool forceRefresh = false}) async {
    emit(
      state.copyWith(
        dropdownValuesState: state.dropdownValuesState.copyWith(
          status: DropdownValuesStatus.loading,
          failure: null,
        ),
      ),
    );

    final result = await _discardReasonsRepository.fetchDropdownItems(category, forceRefresh: forceRefresh);

    result.fold(
      (failure) {
        safeEmit(
          state.copyWith(
            dropdownValuesState: state.dropdownValuesState.copyWith(
              status: DropdownValuesStatus.failure,
              failure: failure,
              dropdownName: category,
            ),
          ),
        );
      },
      (items) {
        safeEmit(
          state.copyWith(
            dropdownValuesState: state.dropdownValuesState.copyWith(
              status: DropdownValuesStatus.loaded,
              items: items,
              dropdownName: category,
            ),
          ),
        );
      },
    );
  }

  // * Image handling methods

  Future<void> pickImages() async {
    emit(state.copyWith(imageState: const ImageState(status: ImageStatus.loading, failure: null)));

    final result = await _imageRepository.pickImages(state.imageState.imagePaths);

    result.fold(
      (failure) => safeEmit(
        state.copyWith(
          imageState: state.imageState.copyWith(status: ImageStatus.failure, failure: failure),
        ),
      ),
      (paths) => safeEmit(
        state.copyWith(
          imageState: state.imageState.copyWith(status: ImageStatus.loaded, imagePaths: paths),
        ),
      ),
    );
  }

  Future<void> takePicture() async {
    emit(state.copyWith(imageState: const ImageState(status: ImageStatus.loading, failure: null)));

    final result = await _imageRepository.takePicture(state.imageState.imagePaths);

    result.fold(
      (failure) => safeEmit(
        state.copyWith(
          imageState: state.imageState.copyWith(status: ImageStatus.failure, failure: failure),
        ),
      ),
      (paths) => safeEmit(
        state.copyWith(
          imageState: state.imageState.copyWith(status: ImageStatus.loaded, imagePaths: paths),
        ),
      ),
    );
  }

  Future<void> removeImageAt(int index) async {
    try {
      final updatedImages = List<String>.from(state.imageState.imagePaths)..removeAt(index);
      emit(
        state.copyWith(
          imageState: state.imageState.copyWith(imagePaths: updatedImages, status: ImageStatus.loaded),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          imageState: state.imageState.copyWith(
            status: ImageStatus.failure,
            failure: AppFailure(
              code: ImageErrorCodes.imageRemovalFailed,
              context: {
                'exception': e.toString(),
                'index': index,
              },
            ),
          ),
        ),
      );
    }
  }

  // * Form submission methods

  Future<void> submitForm() async {
    emit(state.copyWith(submitState: const SubmitState.submitting()));

    final isValid = _validateForm();

    if (!isValid) {
      emit(
        state.copyWith(
          submitState: SubmitState.failure(
            failure: AppFailure(
              code: ValidationErrorCodes.missingDiscardReason,
              context: {'message': 'Discard reason is required.'},
            ),
          ),
        ),
      );
      return;
    }

    final (employeeId, employeeName) = state.employeeState.maybeWhen(
      loaded: (name, id) => (id, name),
      orElse: () => ('', ''),
    );

    if (employeeId.isEmpty || employeeName.isEmpty) {
      emit(
        state.copyWith(
          submitState: SubmitState.failure(
            failure: AppFailure(
              code: ValidationErrorCodes.invalidEmployeeId,
              context: {'message': 'Valid employee information is required.'},
            ),
          ),
        ),
      );
      return;
    }

    final result = await _orderRepository.discardOrder(
      DiscardOrder(
        productionOrder: state.formData.productionOrder,
        errorCode: state.discardReasonState.selectedReason!.errorCode,
        note: state.formData.note,
        employeeId: employeeId,
        reportDate: state.formData.dateTime?.toUtc() ?? DateTime.now().toUtc(),
        salesId: state.formData.salesId,
        worktop: state.formData.worktop,
        productType: state.formData.productType,
        machine: state.dropdownValuesState.selectedDropdownValue?.dropdownItem ?? '',
        imagePaths: state.imageState.imagePaths,
      ),
    );

    result.fold(
      (failure) => safeEmit(state.copyWith(submitState: SubmitState.failure(failure: failure))),
      (_) => safeEmit(state.copyWith(submitState: const SubmitState.success())),
    );
  }

  // * Helpers
  bool _validateForm() {
    log('Validating form data value: ${state.discardReasonState.selectedReason}');
    if (state.discardReasonState.selectedReason == null) {
      return false;
    }
    return true;
  }
}
