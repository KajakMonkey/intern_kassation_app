import 'package:flutter/services.dart';
import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/ui/auth/bloc/account_bloc.dart';
import 'package:intern_kassation_app/ui/auth/widgets/account_loading.dart';
import 'package:intern_kassation_app/ui/auth/widgets/logout_button.dart';
import 'package:intern_kassation_app/ui/core/ui/error_card.dart';

class AccountDetails extends StatelessWidget {
  const AccountDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountBloc, AccountState>(
      listener: (context, state) {
        final failureState = state.authStatus.maybeMap(
          failure: (f) => f, // returns the generated _AuthStatusFailure instance
          orElse: () => null,
        );

        final AppFailure? failure = failureState?.failure;

        final bool hasRefreshToken = failureState?.hasRefreshToken ?? false;
        if (failure != null && hasRefreshToken) {
          context.read<AccountBloc>().add(const AccountEvent.userDataRequested(returnIfExpired: true));
        }
      },
      builder: (context, state) {
        if (state.userStatus == const UserStatus.loading()) {
          return const AccountLoading();
        }
        final authFailureState = state.authStatus.maybeMap(
          failure: (f) => f,
          orElse: () => null,
        );

        final AppFailure? authFailure = authFailureState?.failure;

        final user = state.userStatus.maybeMap(
          loaded: (value) => value.user,
          orElse: () => null,
        );

        final userFailure = state.userStatus.maybeMap(
          failure: (f) => f.failure,
          orElse: () => null,
        );

        final shouldShowSingleFailure = authFailure != null && userFailure != null;

        return Column(
          children: [
            if (authFailure != null && !shouldShowSingleFailure) ...[
              Gap.vm,
              ErrorCard.retry(
                errorMessage: authFailure.getMessage(context.l10n),
                failure: authFailure,
                onRetry: () => context.read<AccountBloc>().add(const AccountEvent.refreshRequested(forceRefresh: true)),
              ),
            ],
            if (shouldShowSingleFailure)
              _SingleFailureWidget(
                firstFailure: authFailure,
                secondFailure: userFailure,
              ),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(context.l10n.username_label),
                    subtitle: Text(user?.username ?? context.l10n.account_page_anonymous),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        if (user?.username != null && user?.sessionId != null) {
                          Clipboard.setData(
                            ClipboardData(text: 'Username: ${user?.username}\nSession ID: ${user?.sessionId}'),
                          );
                        }
                      },
                    ),
                  ),
                  const Divider(height: 0, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.vpn_key),
                    title: Text(context.l10n.account_page_session_id_label),
                    subtitle: Text(user?.sessionId ?? context.l10n.account_page_no_session),
                  ),
                ],
              ),
            ),
            if (userFailure != null && !shouldShowSingleFailure) ...[
              Gap.vm,
              Text(
                userFailure.getMessage(context.l10n),
                style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.error),
              ),
              Gap.vs,
              FilledButton(
                onPressed: () {
                  context.read<AccountBloc>().add(const AccountEvent.userDataRequested(returnIfExpired: true));
                },
                child: Text(context.l10n.try_again),
              ),
            ],
            Gap.vl,
            const LogoutButton(),
          ],
        );
      },
    );
  }
}

class _SingleFailureWidget extends StatelessWidget {
  const _SingleFailureWidget({required this.firstFailure, required this.secondFailure});
  final AppFailure firstFailure;
  final AppFailure secondFailure;

  @override
  Widget build(BuildContext context) {
    // if they are not the same show both
    final firstMessage = firstFailure.getMessage(context.l10n);
    final secondMessage = secondFailure.getMessage(context.l10n);
    String message;
    if (firstMessage != secondMessage) {
      message = '${firstFailure.getMessage(context.l10n)}\n${secondFailure.getMessage(context.l10n)}';
    } else {
      message = firstMessage;
    }

    return Column(
      children: [
        Gap.vm,
        ErrorCard.retry(
          errorMessage: message,
          failure: firstFailure,
          onRetry: () => context.read<AccountBloc>().add(const AccountEvent.refreshRequested(forceRefresh: true)),
        ),
      ],
    );
  }
}
