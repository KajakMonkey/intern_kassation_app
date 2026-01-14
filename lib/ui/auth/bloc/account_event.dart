part of 'account_bloc.dart';

@freezed
class AccountEvent with _$AccountEvent {
  const factory AccountEvent.subscribeToAuthChanges() = _SubscribeToAuthChanges;
  const factory AccountEvent.loginRequested({
    required String username,
    required String password,
    @Default(false) bool refreshIfAvailable,
  }) = _LoginRequested;
  const factory AccountEvent.logoutRequested() = _LogoutRequested;
  const factory AccountEvent.refreshRequested({
    @Default(false) bool forceRefresh,
  }) = _RefreshRequested;
  const factory AccountEvent.userDataRequested({
    @Default(false) bool returnIfExpired,
  }) = _UserDataRequested;
}
