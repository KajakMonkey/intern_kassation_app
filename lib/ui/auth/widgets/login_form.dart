import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/network_error_codes.dart';
import 'package:intern_kassation_app/ui/auth/bloc/account_bloc.dart';
import 'package:intern_kassation_app/ui/core/ui/error_card.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _hasSubmitted = false;
  var _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed({bool refreshIfAvailable = false, bool validate = true}) {
    setState(() {
      _hasSubmitted = true;
    });
    if (!validate || _formKey.currentState!.validate()) {
      context.read<AccountBloc>().add(
        AccountEvent.loginRequested(
          username: _usernameController.text,
          password: _passwordController.text,
          refreshIfAvailable: refreshIfAvailable,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (previous, current) => previous.authStatus != current.authStatus,
      builder: (context, state) {
        final failure = state.authStatus.maybeWhen(
          failure: (failure, _) => failure,
          orElse: () => null,
        );

        return Form(
          key: _formKey,
          autovalidateMode: _hasSubmitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(context.l10n.login_form_title, style: context.textTheme.headlineSmall),
              ),
              if (failure != null && failure.code is NetworkErrorCodes) ...[
                Gap.vm,
                ErrorCard.retry(
                  errorMessage: failure.getMessage(context.l10n),
                  failure: failure,
                  onRetry: () => _onLoginPressed(refreshIfAvailable: true, validate: false),
                ),
              ],
              Gap.vm,
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: context.l10n.username_label,
                  border: const OutlineInputBorder(),
                ),
                enabled: state.authStatus != const AuthStatus.loading(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.username_cannot_be_empty;
                  }
                  return null;
                },
              ),
              Gap.vm,
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: context.l10n.password_label,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                enabled: state.authStatus != const AuthStatus.loading(),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.password_cannot_be_empty;
                  }
                  return null;
                },
                onFieldSubmitted: (value) => _onLoginPressed(),
              ),
              if (failure != null && failure.code is! NetworkErrorCodes) ...[
                Gap.vm,
                Text(
                  failure.getMessage(context.l10n),
                  style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.error),
                ),
              ],
              Gap.vm,
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.authStatus != const AuthStatus.loading() ? _onLoginPressed : null,
                  child: state.authStatus != const AuthStatus.loading()
                      ? Text(context.l10n.login)
                      : const CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
