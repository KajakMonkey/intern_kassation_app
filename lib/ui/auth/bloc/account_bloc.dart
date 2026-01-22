import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intern_kassation_app/data/repositories/auth_repository.dart';
import 'package:intern_kassation_app/data/repositories/user_repository.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/models/auth/auth_repo_response.dart';
import 'package:intern_kassation_app/domain/models/user.dart';
import 'package:intern_kassation_app/utils/extensions/bloc_extension.dart';

part 'account_event.dart';
part 'account_state.dart';
part 'account_bloc.freezed.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc({required AuthRepository authRepository, required UserRepository userRepository})
    : _authRepository = authRepository,
      _userRepository = userRepository,
      super(AccountState.initial()) {
    on<AccountEvent>((event, emit) async {
      await event.map(
        subscribeToAuthChanges: (e) => _onSubscriptionRequested(e, emit),
        loginRequested: (e) => _onLoginRequested(e, emit),
        refreshRequested: (e) => _onRefreshRequested(e, emit),
        logoutRequested: (e) => _onLogoutRequested(e, emit),
        userDataRequested: (e) => _onUserDataRequested(e, emit),
      );
    });
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  Future<void> _onSubscriptionRequested(_SubscribeToAuthChanges event, Emitter<AccountState> emit) async {
    return emit.onEach(
      _authRepository.stream,
      onData: (response) {
        switch (response.status) {
          case AuthResponseStatus.authenticated:
            emit.safe(state.copyWith(authStatus: const AuthStatus.authenticated()));
            state.userStatus.maybeWhen(
              loaded: (user) {
                emit.safe(state.copyWith(userStatus: UserStatus.loaded(user)));
              },
              initial: () {
                add(const AccountEvent.userDataRequested());
              },
              orElse: () {},
            );
          case AuthResponseStatus.unauthenticated:
            emit.safe(
              state.copyWith(authStatus: const AuthStatus.unauthenticated(), userStatus: const UserStatus.initial()),
            );
          case AuthResponseStatus.failure:
            emit.safe(state.copyWith(authStatus: AuthStatus.failure(response.failure!, response.hasRefreshToken)));
            state.userStatus.maybeWhen(
              loaded: (user) {
                emit.safe(state.copyWith(userStatus: UserStatus.loaded(user)));
              },
              initial: () {
                if (response.hasRefreshToken) {
                  add(const AccountEvent.userDataRequested(returnIfExpired: true));
                }
              },
              orElse: () {},
            );
          case AuthResponseStatus.loading:
            emit.safe(state.copyWith(authStatus: const AuthStatus.loading()));
          case AuthResponseStatus.initial:
        }
      },
    );
  }

  Future<void> _onLoginRequested(_LoginRequested event, Emitter<AccountState> emit) async {
    emit(state.copyWith(authStatus: const AuthStatus.loading()));
    await _authRepository.login(
      username: event.username,
      password: event.password,
    );
  }

  Future<void> _onRefreshRequested(_RefreshRequested event, Emitter<AccountState> emit) async {
    emit(state.copyWith(authStatus: const AuthStatus.loading()));
    await _authRepository.refresh();
  }

  Future<void> _onLogoutRequested(_LogoutRequested event, Emitter<AccountState> emit) async {
    emit(state.copyWith(authStatus: const AuthStatus.loading()));
    await _authRepository.logout();
    await _userRepository.clearCachedUserData();
  }

  Future<void> _onUserDataRequested(_UserDataRequested event, Emitter<AccountState> emit) async {
    emit(state.copyWith(userStatus: const UserStatus.loading()));
    final result = await _userRepository.fetchUserData(returnIfExpired: event.returnIfExpired);
    result.fold(
      (failure) => emit.safe(state.copyWith(userStatus: UserStatus.failure(failure))),
      (user) => emit.safe(state.copyWith(userStatus: UserStatus.loaded(user))),
    );
  }
}
