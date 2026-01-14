part of 'scan_cubit.dart';

@freezed
sealed class ScanState with _$ScanState {
  const factory ScanState({
    required OrderState orderStatus,
    required LatestDiscardedState latestDiscardedStatus,
  }) = _ScanState;

  factory ScanState.initial() => const ScanState(
    orderStatus: OrderState.initial(),
    latestDiscardedStatus: LatestDiscardedState.initial(),
  );
}

@freezed
class OrderState with _$OrderState {
  const factory OrderState.initial() = _Initial;
  const factory OrderState.loading() = _Loading;
  const factory OrderState.success(OrderDetails details) = _Success;
  const factory OrderState.failure(AppFailure failure) = _Failure;
}

@freezed
class LatestDiscardedState with _$LatestDiscardedState {
  const factory LatestDiscardedState.initial() = _DiscardInitial;
  const factory LatestDiscardedState.loading() = _DiscardLoading;
  const factory LatestDiscardedState.success(List<String> discardedOrders) = _DiscardSuccess;
  const factory LatestDiscardedState.failure(AppFailure failure) = _DiscardFailure;
}
