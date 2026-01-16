import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/general_error_codes.dart';
import 'package:logging/logging.dart';

class ImageService {
  ImageService({required ImagePicker imagePicker}) : _imagePicker = imagePicker;
  final ImagePicker _imagePicker;

  static final _logger = Logger('ImageService');

  Future<Either<AppFailure, List<String>>> pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(imageQuality: 80);
      if (pickedFiles.isEmpty || pickedFiles.first.path.isEmpty) {
        return right([]);
      }
      final imagePaths = pickedFiles.map((file) => file.path).toList();
      return right(imagePaths);
    } catch (e, st) {
      _logger.severe('Error picking images', e, st);
      return left(AppFailure(code: GeneralErrorCodes.unknown, context: {'exception': e.toString()}));
    }
  }

  Future<Either<AppFailure, String>> takePicture() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (photo == null || photo.path.isEmpty) {
        return right('');
      }
      return right(photo.path);
    } catch (e, st) {
      _logger.severe('Error taking picture', e, st);
      return left(AppFailure(code: GeneralErrorCodes.unknown, context: {'exception': e.toString()}));
    }
  }
}
