part of 'account_bloc.dart';

@freezed
sealed class AccountState with _$AccountState {
  const factory AccountState({
    required AuthStatus authStatus,
    required UserStatus userStatus,
  }) = _AccountState;

  factory AccountState.initial() => const AccountState(
    authStatus: AuthStatus.initial(),
    userStatus: UserStatus.initial(),
  );
}

@freezed
sealed class AuthStatus with _$AuthStatus {
  const factory AuthStatus.initial() = _AuthStatusInitial;
  const factory AuthStatus.authenticated() = _AuthStatusAuthenticated;
  const factory AuthStatus.unauthenticated() = _AuthStatusUnauthenticated;
  const factory AuthStatus.loading() = _AuthStatusLoading;
  const factory AuthStatus.failure(AppFailure failure, bool hasRefreshToken) = _AuthStatusFailure;
}

@freezed
sealed class UserStatus with _$UserStatus {
  const factory UserStatus.initial() = _UserStatusInitial;
  const factory UserStatus.loading() = _UserStatusLoading;
  const factory UserStatus.loaded(User user) = _UserStatusLoaded;
  const factory UserStatus.failure(AppFailure failure) = _UserStatusFailure;
}
