import 'package:intern_kassation_app/domain/errors/app_error_code.dart';
import 'package:intern_kassation_app/l10n/app_localizations.dart';

enum OrderErrorCodes implements AppErrorCode {
  unknown('ORDER_UNKNOWN'),
  // from the backend
  orderNotFound('ORDER_NOT_FOUND'),
  unableToExtractWorktop('ORDER_UNABLE_TO_EXTRACT_WORKTOP'),
  // images
  noImagesProvided('ORDER_NO_IMAGES_PROVIDED'),
  contentTypeNotSupported('ORDER_CONTENT_TYPE_NOT_SUPPORTED'),
  fileTooLarge('ORDER_FILE_TOO_LARGE'),
  fileStreamNotAvailable('ORDER_FILE_STREAM_NOT_AVAILABLE'),
  // discarded orders
  discardedOrderNotFound('DISCARDED_ORDER_NOT_FOUND'),
  invalidDiscardedOrderQuery('DISCARDED_INVALID_DISCARDED_ORDER_QUERY'),
  invalidDiscardedOrderQueryLength('DISCARDED_INVALID_DISCARDED_ORDER_QUERY_LENGTH')
  ;

  const OrderErrorCodes(this.code);

  @override
  final String code;

  static AppErrorCode fromString(String code) {
    try {
      return OrderErrorCodes.values.firstWhere((e) => e.code == code);
    } catch (_) {
      return OrderErrorCodes.unknown;
    }
  }

  @override
  String getMessage(AppLocalizations l10n) => switch (this) {
    OrderErrorCodes.unknown => l10n.error_general_unknown,
    OrderErrorCodes.orderNotFound => l10n.error_order_not_found,
    OrderErrorCodes.unableToExtractWorktop => l10n.error_order_unable_to_extract_worktop,
    // images
    OrderErrorCodes.noImagesProvided => l10n.error_order_no_images_provided,
    OrderErrorCodes.contentTypeNotSupported => l10n.error_order_content_type_not_supported,
    OrderErrorCodes.fileTooLarge => l10n.error_order_file_too_large,
    OrderErrorCodes.fileStreamNotAvailable => l10n.error_order_file_stream_not_available,
    // discarded orders
    OrderErrorCodes.discardedOrderNotFound => l10n.error_discarded_order_not_found,
    OrderErrorCodes.invalidDiscardedOrderQuery => l10n.error_discarded_invalid_discarded_order_query,
    OrderErrorCodes.invalidDiscardedOrderQueryLength => l10n.error_discarded_invalid_discarded_order_query_length,
  };
}
