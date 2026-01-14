import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/data/repositories/order_repository.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/models/order/discarded_orders_data.dart';
import 'package:intern_kassation_app/utils/extensions/bloc_extension.dart';

part 'lookup_state.dart';
part 'lookup_cubit.freezed.dart';

class LookupCubit extends Cubit<LookupState> {
  LookupCubit({required OrderRepository orderRepository})
    : _orderRepository = orderRepository,
      super(const LookupState.initial());

  final OrderRepository _orderRepository;

  Future<void> lookupDiscardedOrders(String query, {String? cursor, int? pageSize}) async {
    emit(const LookupState.loading());

    final result = await _orderRepository.getDiscardedOrders(
      query: query,
      cursor: cursor,
      pageSize: pageSize,
    );

    result.fold(
      (failure) => safeEmit(LookupState.failure(failure)),
      (data) => safeEmit(LookupState.loaded(data, query)),
    );
  }

  Future<void> lookupNextPage(String query) async {
    state.maybeWhen(
      loaded: (data, previousQuery) {
        assert(data.nextCursor != null, 'No next cursor available for pagination');
        if (data.nextCursor != null) {
          lookupDiscardedOrders(
            query,
            cursor: data.nextCursor,
            pageSize: data.pageSize,
          );
        }
      },
      orElse: () {},
    );
  }

  Future<void> lookupPreviousPage(String query) async {
    state.maybeWhen(
      loaded: (data, previousQuery) {
        assert(data.previousCursor != null, 'No previous cursor available for pagination');
        if (data.previousCursor != null) {
          lookupDiscardedOrders(
            query,
            cursor: data.previousCursor,
            pageSize: data.pageSize,
          );
        }
      },
      orElse: () {},
    );
  }
}
