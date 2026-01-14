import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/config/app_config.dart';
import 'package:intern_kassation_app/data/services/image_service.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/image_error_codes.dart';

class ImageRepository {
  const ImageRepository(this._imageService);
  final ImageService _imageService;

  static const int _maxImages = AppConfig.maxImages;

  Future<Either<AppFailure, List<String>>> pickImages(List<String> currentImages) async {
    if (currentImages.length >= _maxImages) {
      return left(AppFailure(code: ImageErrorCodes.maxImagesExceeded));
    }

    final result = await _imageService.pickImages();

    return result.fold(
      left,
      (newPaths) {
        if (newPaths.isEmpty) {
          return right(currentImages);
        }

        final combinedImages = [...currentImages, ...newPaths];
        final uniqueImages = combinedImages.toSet().toList();

        if (uniqueImages.length > _maxImages) {
          return left(AppFailure(code: ImageErrorCodes.maxImagesExceeded));
        }

        return right(uniqueImages);
      },
    );
  }

  Future<Either<AppFailure, List<String>>> takePicture(List<String> currentImages) async {
    if (currentImages.length >= _maxImages) {
      return left(AppFailure(code: ImageErrorCodes.maxImagesExceeded));
    }

    final result = await _imageService.takePicture();
    return result.fold(
      left,
      (newPath) {
        if (newPath.isEmpty) {
          return right(currentImages);
        }

        final combinedImages = [...currentImages, newPath];
        final uniqueImages = combinedImages.toSet().toList();

        if (uniqueImages.length > _maxImages) {
          return left(AppFailure(code: ImageErrorCodes.maxImagesExceeded));
        }

        return right(uniqueImages);
      },
    );
  }
}
