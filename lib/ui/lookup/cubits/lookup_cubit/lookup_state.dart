part of 'lookup_cubit.dart';

@freezed
sealed class LookupState with _$LookupState {
  const factory LookupState.initial() = _LookupStateInitial;
  const factory LookupState.loading() = _LookupStateLoading;
  const factory LookupState.loaded(DiscardedOrdersData data, String query) = _LookupStateLoaded;
  const factory LookupState.failure(AppFailure failure) = _LookupStateFailure;
}
