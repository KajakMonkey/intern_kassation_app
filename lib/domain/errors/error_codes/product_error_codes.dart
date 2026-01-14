import 'package:intern_kassation_app/domain/errors/app_error_code.dart';
import 'package:intern_kassation_app/l10n/app_localizations.dart';

enum ProductErrorCodes implements AppErrorCode {
  unknown('PRODUCT_UNKNOWN'),
  // from the backend
  invalidProductType('PRODUCT_INVALID_PRODUCT_TYPE'),
  invalidProductGroup('PRODUCT_INVALID_PRODUCT_GROUP'),
  invalidDropdownName('PRODUCT_INVALID_DROPDOWN_NAME'),
  productDefectsNotFound('PRODUCT_DEFECTS_NOT_FOUND')
  ;

  const ProductErrorCodes(this.code);

  @override
  final String code;

  static AppErrorCode fromString(String code) {
    try {
      return ProductErrorCodes.values.firstWhere((e) => e.code == code);
    } catch (_) {
      return ProductErrorCodes.unknown;
    }
  }

  @override
  String getMessage(AppLocalizations l10n) => switch (this) {
    ProductErrorCodes.unknown => l10n.error_general_unknown,
    ProductErrorCodes.invalidProductType => l10n.error_product_invalid_product_type,
    ProductErrorCodes.invalidProductGroup => l10n.error_product_invalid_product_group,
    ProductErrorCodes.invalidDropdownName => l10n.error_product_invalid_dropdown_name,
    ProductErrorCodes.productDefectsNotFound => l10n.error_product_defects_not_found,
  };
}
