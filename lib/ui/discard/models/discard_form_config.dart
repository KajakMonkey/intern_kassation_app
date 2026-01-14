import 'package:intern_kassation_app/config/constants/product_type.dart';
import 'package:intern_kassation_app/ui/discard/models/discard_form_step.dart';

class DiscardFormConfig {
  const DiscardFormConfig._();

  static List<DiscardFormStep> getStepsForProduct(ProductType productType) {
    return switch (productType) {
      // Default for stone products: all steps
      _ when productType.isStoneProduct => [
        DiscardFormStep.employeeId,
        DiscardFormStep.discardReason,
        DiscardFormStep.images,
        DiscardFormStep.note,
        DiscardFormStep.overview,
      ],

      // Unknown or fallback
      _ => [DiscardFormStep.unknown],
    };
  }

  static bool requiresStep(ProductType productType, DiscardFormStep step) {
    return getStepsForProduct(productType).contains(step);
  }

  static bool requiresEmployeeCubit(ProductType productType) => requiresStep(productType, DiscardFormStep.employeeId);

  static bool requiresProductsCubit(ProductType productType) =>
      requiresStep(productType, DiscardFormStep.discardReason);

  static bool requiresImageCubit(ProductType productType) => requiresStep(productType, DiscardFormStep.images);
}
