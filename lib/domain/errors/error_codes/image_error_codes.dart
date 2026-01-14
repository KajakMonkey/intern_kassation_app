import 'package:intern_kassation_app/domain/errors/app_error_code.dart';
import 'package:intern_kassation_app/l10n/app_localizations.dart';

enum ImageErrorCodes implements AppErrorCode {
  unknown('IMAGE_UNKNOWN'),
  maxImagesExceeded('IMAGE_MAX_IMAGES_EXCEEDED'),
  imageRemovalFailed('IMAGE_REMOVAL_FAILED')
  ;

  const ImageErrorCodes(this.code);

  @override
  final String code;

  static AppErrorCode fromString(String code) {
    try {
      return ImageErrorCodes.values.firstWhere((e) => e.code == code);
    } catch (_) {
      return ImageErrorCodes.unknown;
    }
  }

  @override
  String getMessage(AppLocalizations l10n) => switch (this) {
    ImageErrorCodes.unknown => l10n.error_general_unknown,
    ImageErrorCodes.maxImagesExceeded => l10n.error_image_max_images_exceeded,
    ImageErrorCodes.imageRemovalFailed => l10n.error_image_removal_failed,
  };
}
