import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/ui/core/extensions/navigation_extension.dart';
import 'package:intern_kassation_app/ui/discard/cubit/discard_cubit.dart';
import 'package:intern_kassation_app/ui/discard/models/step_navigation_config.dart';

class UnknownStep extends StatefulWidget {
  const UnknownStep({
    super.key,
    required this.onNavConfigChanged,
    required this.isLastStep,
    required this.productGroup,
  });

  final ValueChanged<StepNavigationConfig> onNavConfigChanged;
  final bool isLastStep;
  final String productGroup;

  @override
  State<UnknownStep> createState() => _UnknownStepState();
}

class _UnknownStepState extends State<UnknownStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Switch to bottom buttons for submit
      widget.onNavConfigChanged(
        const StepNavigationConfig(showAppBarBackButton: true, showBottomButtons: false, canProceed: false),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Gap.m),
      child: Center(
        child: Column(
          children: [
            BlocBuilder<DiscardCubit, DiscardState>(
              builder: (context, state) {
                return Text('${context.l10n.unknown_step_error}: ${widget.productGroup}');
              },
            ),
            Gap.vm,
            Text(context.l10n.unknown_step_description),
            Gap.vl,
            FilledButton.icon(
              onPressed: () {
                context.maybePopElse(Routes.scan.name);
              },
              label: Text(context.l10n.go_to_main_menu),
              icon: const Icon(Icons.home),
            ),
          ],
        ),
      ),
    );
  }
}
