import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/ui/discard/models/step_navigation_config.dart';

class UnknownStep extends StatefulWidget {
  const UnknownStep({
    super.key,
    required this.onNavConfigChanged,
    required this.isLastStep,
  });

  final ValueChanged<StepNavigationConfig> onNavConfigChanged;
  final bool isLastStep;

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
        const StepNavigationConfig(showAppBarBackButton: true),
      );
    });
  }

  // TODO: Implement the actual unknown step UI
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Placeholder(
          fallbackHeight: 200,
          child: Center(child: Text('Unknown Step - TODO')),
        ),
      ),
    );
  }
}
