import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/data/repositories/order_repository.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/models/order/discarded_order_details.dart';
import 'package:intern_kassation_app/utils/extensions/bloc_extension.dart';

part 'lookup_details_state.dart';
part 'lookup_details_cubit.freezed.dart';

class LookupDetailsCubit extends Cubit<LookupDetailsState> {
  LookupDetailsCubit({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const LookupDetailsState.initial());

  final OrderRepository _orderRepository;

  Future<void> fetchDiscardedOrderDetails(int id) async {
    emit(const LookupDetailsState.loading());

    final result = await _orderRepository.getDiscardedOrderDetails(id);

    result.fold(
      (failure) => safeEmit(LookupDetailsState.failure(failure)),
      (data) => safeEmit(LookupDetailsState.loaded(data)),
    );
  }
}
