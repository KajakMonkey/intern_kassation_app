part of 'lookup_details_cubit.dart';

@freezed
class LookupDetailsState with _$LookupDetailsState {
  const factory LookupDetailsState.initial() = _LookupDetailsInitial;
  const factory LookupDetailsState.loading() = _LookupDetailsLoading;
  const factory LookupDetailsState.loaded(DiscardedOrderDetails details) = _LookupDetailsLoaded;
  const factory LookupDetailsState.failure(AppFailure failure) = _LookupDetailsFailure;
}
