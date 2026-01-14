import 'package:fpdart/src/either.dart';
import 'package:intern_kassation_app/data/services/image_service.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/general_error_codes.dart';

class FakeImageService implements ImageService {
  var shouldFail = false;
  List<String>? overridePickImagesResult;
  String? overrideTakePictureResult;

  @override
  Future<Either<AppFailure, List<String>>> pickImages() async {
    if (shouldFail) {
      return left(AppFailure(code: GeneralErrorCodes.unknown));
    }
    return right(
      overridePickImagesResult ??
          [
            'path/to/fake_image1.jpg',
            'path/to/fake_image2.jpg',
            'path/to/fake_image3.jpg',
          ],
    );
  }

  @override
  Future<Either<AppFailure, String>> takePicture() async {
    if (shouldFail) {
      return left(AppFailure(code: GeneralErrorCodes.unknown));
    }
    return right(overrideTakePictureResult ?? 'path/to/fake_picture.jpg');
  }
}
