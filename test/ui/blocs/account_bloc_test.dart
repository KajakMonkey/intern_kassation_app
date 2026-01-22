import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/auth_error_codes.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/network_error_codes.dart';
import 'package:intern_kassation_app/domain/models/auth/auth_repo_response.dart';
import 'package:intern_kassation_app/ui/auth/bloc/account_bloc.dart';

import '../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../testing/fakes/repositories/fake_user_repository.dart';
import '../../../testing/models/fake_user_data.dart';

void main() {
  late FakeAuthRepository fakeAuthRepository;
  late FakeUserRepository fakeUserRepository;
  late AccountBloc accountBloc;

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
    fakeUserRepository = FakeUserRepository();
    accountBloc = AccountBloc(
      authRepository: fakeAuthRepository,
      userRepository: fakeUserRepository,
    );
  });

  tearDown(() async {
    await accountBloc.close();
    await fakeAuthRepository.dispose();
  });

  group(
    'AccountBloc',
    () {
      test('initial state is AccountState.initial()', () {
        expect(accountBloc.state, equals(AccountState.initial()));
      });

      blocTest(
        'emits [AuthStatus.loading] when login is called',
        build: () => accountBloc,
        act: (bloc) => bloc.add(const AccountEvent.loginRequested(username: 'test', password: 'password')),
        expect: () => [
          const AccountState(authStatus: AuthStatus.loading(), userStatus: UserStatus.initial()),
        ],
      );

      blocTest(
        'emits [AuthStatus.loading] when refresh is called',
        build: () => accountBloc,
        act: (bloc) => bloc.add(const AccountEvent.refreshRequested()),
        expect: () => [
          const AccountState(authStatus: AuthStatus.loading(), userStatus: UserStatus.initial()),
        ],
      );

      blocTest(
        'emits [AuthStatus.loading] when logout is called',
        build: () => accountBloc,
        act: (bloc) => bloc.add(const AccountEvent.logoutRequested()),
        expect: () => [
          const AccountState(authStatus: AuthStatus.loading(), userStatus: UserStatus.initial()),
        ],
      );

      blocTest(
        'emits [UserStatus.loading, UserStatus.loaded] when user data is requested and user is fetched successfully',
        build: () => accountBloc,
        act: (bloc) => bloc.add(const AccountEvent.userDataRequested()),
        expect: () => [
          const AccountState(authStatus: AuthStatus.initial(), userStatus: UserStatus.loading()),
          AccountState(authStatus: const AuthStatus.initial(), userStatus: UserStatus.loaded(kUser)),
        ],
      );

      blocTest(
        'emits [UserStatus.loading, UserStatus.failure] when user data request fails',
        build: () => accountBloc,
        act: (bloc) {
          fakeUserRepository.shouldReturnFailure = true;
          bloc.add(const AccountEvent.userDataRequested());
        },
        expect: () => [
          const AccountState(authStatus: AuthStatus.initial(), userStatus: UserStatus.loading()),
          AccountState(
            authStatus: const AuthStatus.initial(),
            userStatus: UserStatus.failure(AppFailure(code: NetworkErrorCodes.connectionError)),
          ),
        ],
      );

      blocTest(
        'emits authenticated and loads user when auth stream emits authenticated',
        build: () {
          fakeAuthRepository = FakeAuthRepository(
            initialResponse: const AuthRepoResponse(status: AuthResponseStatus.authenticated),
          );
          fakeUserRepository = FakeUserRepository();
          return AccountBloc(
            authRepository: fakeAuthRepository,
            userRepository: fakeUserRepository,
          );
        },
        act: (bloc) => bloc.add(const AccountEvent.subscribeToAuthChanges()),
        expect: () => [
          const AccountState(authStatus: AuthStatus.authenticated(), userStatus: UserStatus.initial()),
          const AccountState(authStatus: AuthStatus.authenticated(), userStatus: UserStatus.loading()),
          AccountState(authStatus: const AuthStatus.authenticated(), userStatus: UserStatus.loaded(kUser)),
        ],
      );

      blocTest(
        'emits unauthenticated when auth stream emits unauthenticated',
        build: () {
          fakeAuthRepository = FakeAuthRepository(
            initialResponse: const AuthRepoResponse(status: AuthResponseStatus.unauthenticated),
          );
          fakeUserRepository = FakeUserRepository();
          return AccountBloc(
            authRepository: fakeAuthRepository,
            userRepository: fakeUserRepository,
          );
        },
        act: (bloc) => bloc.add(const AccountEvent.subscribeToAuthChanges()),
        expect: () => [
          const AccountState(authStatus: AuthStatus.unauthenticated(), userStatus: UserStatus.initial()),
        ],
      );

      blocTest(
        'emits failure and fetches user when failure has refresh token',
        build: () {
          final failure = AppFailure(code: AuthErrorCode.unknown);
          fakeAuthRepository = FakeAuthRepository(
            initialResponse: AuthRepoResponse(
              status: AuthResponseStatus.failure,
              failure: failure,
              hasRefreshToken: true,
            ),
          );
          fakeUserRepository = FakeUserRepository();
          return AccountBloc(
            authRepository: fakeAuthRepository,
            userRepository: fakeUserRepository,
          );
        },
        act: (bloc) => bloc.add(const AccountEvent.subscribeToAuthChanges()),
        expect: () => [
          AccountState(
            authStatus: AuthStatus.failure(AppFailure(code: AuthErrorCode.unknown), true),
            userStatus: const UserStatus.initial(),
          ),
          AccountState(
            authStatus: AuthStatus.failure(AppFailure(code: AuthErrorCode.unknown), true),
            userStatus: const UserStatus.loading(),
          ),
          AccountState(
            authStatus: AuthStatus.failure(AppFailure(code: AuthErrorCode.unknown), true),
            userStatus: UserStatus.loaded(kUser),
          ),
        ],
      );

      blocTest(
        'emits failure without fetching user when failure has no refresh token',
        build: () {
          final failure = AppFailure(code: AuthErrorCode.unknown);
          fakeAuthRepository = FakeAuthRepository(
            initialResponse: AuthRepoResponse(
              status: AuthResponseStatus.failure,
              failure: failure,
              hasRefreshToken: false,
            ),
          );
          fakeUserRepository = FakeUserRepository();
          return AccountBloc(
            authRepository: fakeAuthRepository,
            userRepository: fakeUserRepository,
          );
        },
        act: (bloc) => bloc.add(const AccountEvent.subscribeToAuthChanges()),
        expect: () => [
          AccountState(
            authStatus: AuthStatus.failure(AppFailure(code: AuthErrorCode.unknown), false),
            userStatus: const UserStatus.initial(),
          ),
        ],
      );
    },
  );
}
