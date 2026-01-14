import 'package:flutter/services.dart';
import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/ui/core/ui/dialog/app_dialog.dart';
import 'package:intern_kassation_app/ui/discard/cubit/discard_cubit.dart';
import 'package:intern_kassation_app/ui/discard/models/step_navigation_config.dart';

class EmployeeIdStep extends StatefulWidget {
  const EmployeeIdStep({
    super.key,
    required this.onNext,
    required this.onNavConfigChanged,
  });

  final VoidCallback onNext;
  final ValueChanged<StepNavigationConfig> onNavConfigChanged;

  @override
  State<EmployeeIdStep> createState() => _EmployeeIdStepState();
}

class _EmployeeIdStepState extends State<EmployeeIdStep> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onNavConfigChanged(
        StepNavigationConfig.standard.copyWith(showAppBarBackButton: true, canProceed: false, showFab: false),
      );
      context.read<DiscardCubit>().state.employeeState.maybeWhen(
        loaded: (employeeName, employeeId) {
          _controller.text = employeeId;
          widget.onNavConfigChanged(StepNavigationConfig.standard.copyWith(canProceed: true, showFab: false));
        },
        orElse: () {},
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitForm() {
    final employeeId = _controller.text;
    if (employeeId.isEmpty) {
      setState(() {
        _errorText = context.l10n.invalid_employee_id;
      });

      return;
    }

    context.read<DiscardCubit>().state.employeeState.maybeWhen(
      loaded: (employeeName, employeeId) {
        if (employeeId == employeeId) {
          widget.onNext();
        }
      },
      orElse: () {
        context.read<DiscardCubit>().validateEmployeeId(employeeId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiscardCubit, DiscardState>(
      listenWhen: (previous, current) => previous.employeeState != current.employeeState,
      listener: (context, state) async {
        state.employeeState.maybeWhen(
          loading: () {
            widget.onNavConfigChanged(
              StepNavigationConfig.standard.copyWith(isLoading: true, canProceed: false, showFab: false),
            );
          },
          loaded: (employeeName, employeeId) async {
            widget.onNavConfigChanged(
              StepNavigationConfig.standard.copyWith(isLoading: false, canProceed: true, showFab: false),
            );
            setState(() {
              _errorText = null;
            });
            final result = await context.showConfirmationDialog(
              title: context.l10n.confirm_employee,
              content: context.l10n.confirm_employee_message(employeeName, employeeId),
            );

            if (result) {
              widget.onNext();
            }
          },
          failure: (failure) {
            setState(() {
              _errorText = failure.getMessage(context.l10n);
            });
            widget.onNavConfigChanged(
              StepNavigationConfig.standard.copyWith(isLoading: false, canProceed: false, showFab: false),
            );
          },
          orElse: () {},
        );
      },
      buildWhen: (previous, current) => previous.employeeState != current.employeeState,
      builder: (context, state) {
        final isLoading = state.employeeState == const EmployeeState.loading();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.m),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.l10n.enter_employee_id, style: Theme.of(context).textTheme.headlineSmall),
              state.employeeState.maybeWhen(
                loaded: (employeeName, employeeId) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            '${context.l10n.employee}: $employeeName - $employeeId',
                          ),
                        ],
                      ),
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),

              Gap.vm,
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: context.l10n.employee_number,
                  border: const OutlineInputBorder(),
                  errorText: _errorText,
                ),
                enabled: !isLoading,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                maxLength: 4,
                onChanged: (value) {
                  setState(() {
                    _errorText = null;
                  });
                },
                onSubmitted: (value) => _controller.text.isEmpty || isLoading ? null : _submitForm(),
              ),
              Gap.vm,
              SizedBox(
                height: 48,
                width: double.infinity,
                child: FilledButton(
                  onPressed: _controller.text.isEmpty || isLoading ? null : _submitForm,
                  child: isLoading ? const CircularProgressIndicator() : Text(context.l10n.next),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
