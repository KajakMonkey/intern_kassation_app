import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/ui/auth/bloc/account_bloc.dart';
import 'package:intern_kassation_app/ui/core/ui/dialog/app_dialog.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final result = await context.showConfirmationDialog(
            title: context.l10n.logout_confirmation_title,
            content: context.l10n.logout_confirmation_message,
            confirmText: context.l10n.logout,
            cancelText: context.l10n.cancel,
            highlightCancelButton: true,
          );

          if (context.mounted && result) {
            context.read<AccountBloc>().add(const AccountEvent.logoutRequested());
          }
        },
        label: Text(context.l10n.logout),
        icon: const Icon(Icons.logout),
      ),
    );
  }
}
