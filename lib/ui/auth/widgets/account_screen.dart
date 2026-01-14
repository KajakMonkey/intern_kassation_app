import 'dart:developer';

import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/ui/auth/bloc/account_bloc.dart';
import 'package:intern_kassation_app/ui/auth/widgets/account_details.dart';
import 'package:intern_kassation_app/ui/auth/widgets/account_loading.dart';
import 'package:intern_kassation_app/ui/auth/widgets/login_form.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, this.redirectToUrl});
  final String? redirectToUrl;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(context.l10n.account_page_title),
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(Routes.scan.name);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: BlocConsumer<AccountBloc, AccountState>(
        listenWhen: (previous, current) => previous.authStatus != current.authStatus,
        listener: (context, state) {
          state.authStatus.maybeWhen(
            authenticated: () {
              if (redirectToUrl != null) {
                context.goNamed(Routes.scan.name);
              }
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          log('authStatus: ${state.authStatus}\n userStatus: ${state.userStatus}', name: 'AccountScreen');
          final failureState = state.authStatus.maybeMap(
            failure: (f) => f,
            orElse: () => null,
          );

          final AppFailure? failure = failureState?.failure;
          final bool hasRefreshToken = failureState?.hasRefreshToken ?? false;

          final shouldShowAccountDetails =
              state.authStatus == const AuthStatus.authenticated() || (failure != null && hasRefreshToken);

          final shouldShowLogin = state.authStatus != const AuthStatus.authenticated() && !hasRefreshToken;

          final shouldShowLoading = state.userStatus == const UserStatus.loading();

          if (shouldShowLoading) {
            return const AccountLoading();
          }

          return Column(
            children: [
              if (shouldShowAccountDetails) const AccountDetails(),
              if (shouldShowLogin) const LoginForm(),
            ],
          );
        },
      ),
    );
  }
}
