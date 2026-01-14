import 'package:intern_kassation_app/ui/discard/models/step_navigation_config.dart';

enum DiscardFormStep {
  employeeId(),
  discardReason(),
  images(),
  note(),
  overview(),
  // Fallback for unhandled cases
  unknown(),
  ;

  const DiscardFormStep();

  StepNavigationConfig get defaultConfig {
    return switch (this) {
      DiscardFormStep.employeeId ||
      DiscardFormStep.discardReason ||
      DiscardFormStep.images ||
      DiscardFormStep.note => StepNavigationConfig.standard,
      DiscardFormStep.overview => StepNavigationConfig.submit,
      DiscardFormStep.unknown => StepNavigationConfig.standardNoFab,
    };
  }
}
