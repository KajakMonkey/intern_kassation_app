import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intern_kassation_app/data/services/image_service.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/general_error_codes.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late MockImagePicker imagePicker;
  late ImageService imageService;

  setUpAll(() {
    registerFallbackValue(ImageSource.gallery);
  });

  setUp(() {
    imagePicker = MockImagePicker();
    imageService = ImageService(imagePicker: imagePicker);
  });

  group('ImageService', () {
    test('pickImages returns empty list when picker returns empty', () async {
      when(
        () => imagePicker.pickMultiImage(imageQuality: any(named: 'imageQuality')),
      ).thenAnswer((_) async => <XFile>[]);

      final result = await imageService.pickImages();

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, isEmpty),
      );
    });

    test('pickImages returns empty list when first path is empty', () async {
      when(
        () => imagePicker.pickMultiImage(imageQuality: any(named: 'imageQuality')),
      ).thenAnswer((_) async => <XFile>[XFile('')]);

      final result = await imageService.pickImages();

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, isEmpty),
      );
    });

    test('pickImages maps paths correctly', () async {
      when(
        () => imagePicker.pickMultiImage(imageQuality: any(named: 'imageQuality')),
      ).thenAnswer((_) async => <XFile>[XFile('a.png'), XFile('b.jpg')]);

      final result = await imageService.pickImages();

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, ['a.png', 'b.jpg']),
      );
    });

    test('pickImages returns AppFailure on exception', () async {
      when(() => imagePicker.pickMultiImage(imageQuality: any(named: 'imageQuality'))).thenThrow(Exception('boom'));

      final result = await imageService.pickImages();

      result.match(
        (l) => expect(l.code, GeneralErrorCodes.unknown),
        (_) => fail('Expected left'),
      );
    });

    test('takePicture returns empty string when null', () async {
      when(
        () => imagePicker.pickImage(
          source: any(named: 'source'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => null);

      final result = await imageService.takePicture();

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, isEmpty),
      );
    });

    test('takePicture returns empty string when path empty', () async {
      when(
        () => imagePicker.pickImage(
          source: any(named: 'source'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => XFile(''));

      final result = await imageService.takePicture();

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, isEmpty),
      );
    });

    test('takePicture returns path when photo exists', () async {
      when(
        () => imagePicker.pickImage(
          source: any(named: 'source'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => XFile('camera.jpg'));

      final result = await imageService.takePicture();

      result.match(
        (l) => fail('Expected right, got $l'),
        (r) => expect(r, 'camera.jpg'),
      );
    });

    test('takePicture returns AppFailure on exception', () async {
      when(
        () => imagePicker.pickImage(
          source: any(named: 'source'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenThrow(Exception('boom'));

      final result = await imageService.takePicture();

      result.match(
        (l) => expect(l.code, GeneralErrorCodes.unknown),
        (_) => fail('Expected left'),
      );
    });
  });
}
